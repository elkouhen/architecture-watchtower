#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "fileutils"
require "json"
require "open3"
require "optparse"
require "pathname"
require "rbconfig"
require "yaml"
require_relative "index_reports"
require_relative "prepare_radar_context"
require_relative "radar_collection"
require_relative "radar_digest"
require_relative "radar_manifest"
require_relative "radar_render"
require_relative "radar_selection"
require_relative "radar_signal_registry"

# Orchestrateur du radar hebdomadaire, en phases, sans appel de modèle : le modèle de la
# session lit les briefs produits ici et complète le manifest ; les scripts font le reste.
#
#   prepare  → échéances de signaux, collecte, digest, contexte, squelette de manifest, brief de qualification
#   select   → sélection déterministe depuis le manifest qualifié, brief de rédaction
#   publish  → rendu du rapport et du catalogue, curseurs de sources, signaux, index, validation, commit
#   replace  → nouveau rendu du rapport existant depuis son manifest (aucune collecte ni sélection)
ROOT = Pathname.new(__dir__).join("..").expand_path
PHASES = %w[prepare select publish replace].freeze

def changed_paths(root)
  porcelain, status = Open3.capture2("git", "status", "--porcelain=v1", "--untracked-files=all", "-z", chdir: root.to_s)
  abort "Impossible de contrôler les changements" unless status.success?
  porcelain.split("\0").map { |entry| entry.length >= 4 ? entry[3..-1] : nil }.compact
end

def log(message)
  puts "[radar] #{message}"
end

def budget
  path = ROOT.join("state/budget.yaml")
  return {} unless path.file?

  (YAML.safe_load(path.read, permitted_classes: [Date]) || {})["radar"] || {}
end

def warn_budget(label, bytes)
  limit = budget["max_brief_bytes"]
  log("#{label} : #{bytes} octets")
  return unless limit && bytes > limit

  warn "AVERTISSEMENT: #{label} dépasse max_brief_bytes=#{limit} (state/budget.yaml) ; lire par sections."
end

def git_clean!(options)
  status, ok = Open3.capture2("git", "status", "--porcelain", chdir: ROOT.to_s)
  abort "Impossible de lire l’état Git" unless ok.success?
  abort "Le dépôt doit être propre avant cette phase" unless status.empty? || options[:allow_dirty]
end

def paths_for(date)
  {
    report: ROOT.join("dist", date.iso8601, "radar-architecture.md"),
    manifest: ROOT.join("state", "radar-runs", "#{date.iso8601}.yaml"),
    cache: WatchtowerRadarContext.cache_dir(date),
    signals: ROOT.join("state/signals.yaml"),
    sources: ROOT.join("state/sources.yaml")
  }
end

def relative(path)
  Pathname.new(path).relative_path_from(ROOT).to_s
end

def prepare(date, options)
  paths = paths_for(date)
  abort "Radar déjà présent: #{relative(paths[:report])} (utiliser replace pour un nouveau rendu)" if paths[:report].exist?
  abort "Manifest déjà présent: #{relative(paths[:manifest])} ; le supprimer pour recommencer la qualification" if paths[:manifest].exist? && !options[:force]
  git_clean!(options)

  log("Échéances de signaux")
  signals_data = WatchtowerRadarSignalRegistry.load(paths[:signals])
  reviewed = WatchtowerRadarSignalRegistry.review_due!(signals_data, date: date)
  WatchtowerRadarSignalRegistry.save(paths[:signals], signals_data) unless reviewed.empty?
  log("#{reviewed.length} signal(aux) clos ou différé(s)")

  sources_data = WatchtowerRadarContext.load_yaml(paths[:sources])
  selected = WatchtowerRadarContext.selected_sources(sources_data)
  cache_dir = paths[:cache]
  FileUtils.rm_rf(ROOT.join(cache_dir))
  log("Collecte de #{selected.length} source(s) vers #{cache_dir}")
  collection = WatchtowerRadarCollection.collect(selected, date: date, root: ROOT, cache_dir: cache_dir, feeds: WatchtowerRadarContext.feeds(sources_data))
  collection.each do |result|
    detail = case [result["status"], result["kind"]]
    when %w[ok feed] then "flux, #{result['items_total']} élément(s)#{result['truncated_period'] ? ', plafonné' : ''}"
    when %w[ok page] then "page, #{result['chars']} caractères"
    else "échec : #{result['attempts'].map { |attempt| attempt['error'] }.join(' ; ')}"
    end
    log("  #{result['source_id']} — #{detail}#{result['gap'] ? " ; lacune #{result['gap']['from']}/#{result['gap']['through']}" : ''}")
  end
  ROOT.join(cache_dir, "collection.json").write(JSON.pretty_generate(collection))

  log("Digest des deltas")
  digest = WatchtowerRadarDigest.build(root: ROOT, cache_dir: cache_dir, collection: collection, date: date,
                                       sources_data: sources_data, discovery_ids: WatchtowerRadarContext::DISCOVERY_SOURCE_IDS)
  log("  #{digest['retained']} élément(s) retenu(s) par mots-clés, #{digest['titles_only']} titre(s) seuls, " \
      "#{digest['page_blocks']} bloc(s) de page, #{digest['discovery_entries']} dépôt(s) de découverte")

  manifest = WatchtowerRadarManifest.skeleton(date: date, sources_data: sources_data, collection: collection)
  WatchtowerRadarManifest.save(paths[:manifest], manifest)
  context = WatchtowerRadarContext.build(root: ROOT, date: date, collection: collection, reviewed_signals: reviewed,
                                         digest: digest.select { |key, _value| %w[path bytes retained titles_only page_blocks discovery_entries].include?(key) })
  brief = WatchtowerRadarManifest.qualification_brief(
    date: date, prompt_text: ROOT.join("radar-architecture.md").read, contract_text: ROOT.join("docs/contrats-veille.md").read,
    context: context, manifest_path: relative(paths[:manifest]), digest_path: digest["path"], cache_dir: cache_dir
  )
  brief_path = ROOT.join(cache_dir, "brief-qualification.md")
  brief_path.write(brief)
  warn_budget("Brief de qualification", brief.bytesize)
  warn_budget("Digest", digest["bytes"])
  puts "Prêt pour la qualification : lire #{relative(brief_path)} puis #{digest['path']}, compléter #{relative(paths[:manifest])}, " \
       "puis exécuter `ruby scripts/run_radar.rb select --date #{date.iso8601}`."
end

def select_phase(date, _options)
  paths = paths_for(date)
  abort "Manifest absent: #{relative(paths[:manifest])}" unless paths[:manifest].file?
  manifest = WatchtowerRadarManifest.load(paths[:manifest])
  errors = WatchtowerRadarSelection.validate(manifest, date: date)
  abort "Manifest de qualification invalide:\n- #{errors.join("\n- ")}" unless errors.empty?
  signals_data = YAML.safe_load(paths[:signals].read, permitted_classes: [Date, Time], aliases: true) || {}
  identities = WatchtowerRadarSelection.recent_identities(signals_data, date)
  WatchtowerRadarSelection.select!(manifest, identities: identities)
  errors = WatchtowerRadarSelection.validate(manifest, date: date, selected: true)
  abort "Sélection invalide:\n- #{errors.join("\n- ")}" unless errors.empty?
  WatchtowerRadarManifest.save(paths[:manifest], manifest)
  selection = manifest["selection"]
  log("Sélection : #{selection['selected_count']} sujet(s) sur #{selection['eligible_count']} éligible(s), " \
      "#{selection['oss_selected']}/#{selection['oss_required']} nouveau(x) projet(s) OSS")
  log("  exception quota OSS : #{selection['oss_exception']}") if selection["oss_exception"]
  log("  exception minimum : #{selection['minimum_exception']}") if selection["minimum_exception"]
  brief = WatchtowerRadarManifest.writing_brief(date: date, prompt_text: ROOT.join("radar-architecture.md").read,
                                                manifest: manifest, manifest_path: relative(paths[:manifest]))
  brief_path = ROOT.join(paths[:cache], "brief-redaction.md")
  brief_path.dirname.mkpath
  brief_path.write(brief)
  warn_budget("Brief de rédaction", brief.bytesize)
  puts "Prêt pour la rédaction : lire #{relative(brief_path)}, ajouter la prose des candidats sélectionnés dans " \
       "#{relative(paths[:manifest])}, puis exécuter `ruby scripts/run_radar.rb publish --date #{date.iso8601}`."
end

def render!(paths, manifest, date)
  report = WatchtowerRadarRender.report(manifest, date: date)
  paths[:report].dirname.mkpath
  paths[:report].write(report)
  log("Rapport rendu : #{relative(paths[:report])} (#{report.bytesize} octets)")
end

def validate!(paths)
  log("Validation")
  ok = system(RbConfig.ruby, ROOT.join("scripts/validate_watchtower.rb").to_s, "--report", relative(paths[:report]), chdir: ROOT.to_s)
  abort "Validation du radar échouée ; fichiers conservés pour correction, aucun commit" unless ok
end

def commit!(allowed, message, options, allow_empty: false)
  changed = changed_paths(ROOT)
  unexpected = changed - allowed
  abort "Changements hors périmètre: #{unexpected.join(', ')}" unless unexpected.empty?
  return log("Aucun changement : le rendu est identique au rapport existant") if changed.empty? && allow_empty
  abort "Aucun changement à publier" if changed.empty?
  return log("Commit non demandé (--no-commit) ; changements : #{changed.join(', ')}") unless options[:commit]

  system("git", "add", "--", *changed, chdir: ROOT.to_s) || abort("git add a échoué")
  system("git", "commit", "-q", "-m", message, chdir: ROOT.to_s) || abort("git commit a échoué")
  log("Commit local créé : #{message}")
end

def publish(date, options)
  paths = paths_for(date)
  abort "Manifest absent: #{relative(paths[:manifest])}" unless paths[:manifest].file?
  abort "Radar déjà présent: #{relative(paths[:report])} (utiliser replace)" if paths[:report].exist?
  manifest = WatchtowerRadarManifest.load(paths[:manifest])
  errors = WatchtowerRadarSelection.validate(manifest, date: date, selected: true, prose: true)
  abort "Manifest rédigé invalide:\n- #{errors.join("\n- ")}" unless errors.empty?
  collection_path = ROOT.join(paths[:cache], "collection.json")
  abort "Collecte absente: #{relative(collection_path)} ; relancer prepare" unless collection_path.file?
  collection = JSON.parse(collection_path.read)

  render!(paths, manifest, date)
  WatchtowerRadarRender.catalogue_rows!(ROOT.join("docs/catalogue.md"), manifest, date: date)
  log("Curseurs de sources")
  WatchtowerRadarManifest.update_sources_registry(paths[:sources], collection, manifest, date: date)
  log("Signaux")
  signals_data = WatchtowerRadarSignalRegistry.load(paths[:signals])
  begin
    changes = WatchtowerRadarSignalRegistry.sync_from_manifest!(signals_data, manifest, report_path: relative(paths[:report]), date: date,
                                                                publication: options[:commit] ? "local_commit" : "pending_orchestrator_commit")
  rescue WatchtowerRadarSignalRegistry::Error => e
    abort "Synchronisation des signaux échouée: #{e.message}"
  end
  WatchtowerRadarSignalRegistry.save(paths[:signals], signals_data)
  log("  #{changes.count { |change| change['action'] == 'created' }} créé(s), #{changes.count { |change| change['action'] == 'updated' }} mis à jour")
  WatchtowerReportIndex.add_radar(root: ROOT, date: date)
  validate!(paths)
  allowed = [relative(paths[:report]), "README.md", "docs/catalogue.md", "docs/rapports.md", "state/feedback.yaml",
             relative(paths[:manifest]), "state/signals.yaml", "state/sources.yaml"]
  commit!(allowed, "radar: publish #{date.iso8601} architecture watch", options)
  puts "Radar publié : #{relative(paths[:report])}"
end

def replace(date, options)
  paths = paths_for(date)
  abort "replace exige un radar existant: #{relative(paths[:report])}" unless paths[:report].file?
  abort "replace exige un manifest existant: #{relative(paths[:manifest])}" unless paths[:manifest].file?
  git_clean!(options)
  manifest = WatchtowerRadarManifest.load(paths[:manifest])
  errors = WatchtowerRadarSelection.validate(manifest, date: date, selected: true, prose: true)
  abort "Manifest invalide:\n- #{errors.join("\n- ")}" unless errors.empty?
  render!(paths, manifest, date)
  validate!(paths)
  commit!([relative(paths[:report])], "radar: re-render #{date.iso8601} architecture watch", options, allow_empty: true)
  puts "Radar rendu à nouveau : #{relative(paths[:report])}"
end

options = { date: Date.today, commit: true, allow_dirty: false, force: false }
parser = OptionParser.new do |option_parser|
  option_parser.banner = "Usage: ruby scripts/run_radar.rb (#{PHASES.join('|')}) [--date YYYY-MM-DD] [--no-commit] [--allow-dirty]"
  option_parser.on("--date YYYY-MM-DD", "Date du radar") do |value|
    options[:date] = Date.iso8601(value)
  rescue ArgumentError
    raise OptionParser::InvalidArgument, "date ISO invalide: #{value}"
  end
  option_parser.on("--no-commit", "Ne pas committer après validation") { options[:commit] = false }
  option_parser.on("--allow-dirty", "Autoriser un dépôt non propre (tests, reprise)") { options[:allow_dirty] = true }
  option_parser.on("--force", "prepare : écraser un manifest existant sans rapport") { options[:force] = true }
  option_parser.on("-h", "--help", "Afficher cette aide") { puts option_parser; exit }
end
begin
  parser.parse!
rescue OptionParser::ParseError => e
  warn "ERREUR: #{e.message}"
  warn parser
  exit 2
end
phase = ARGV.shift
unless PHASES.include?(phase)
  warn "ERREUR: phase attendue parmi #{PHASES.join(', ')}"
  warn parser
  exit 2
end
abort "La date du radar ne peut pas être future: #{options[:date]}" if options[:date] > Date.today

begin
  case phase
  when "prepare" then prepare(options[:date], options)
  when "select" then select_phase(options[:date], options)
  when "publish" then publish(options[:date], options)
  when "replace" then replace(options[:date], options)
  end
rescue WatchtowerRadarContext::Error, WatchtowerRadarCollection::Error, WatchtowerRadarManifest::Error,
       WatchtowerRadarRender::Error, WatchtowerRadarSelection::Error, WatchtowerRadarSourceRegistry::Error,
       WatchtowerContractSections::Error => e
  warn "ERREUR: #{e.message}"
  exit 1
end
