# frozen_string_literal: true

require "date"
require "pathname"
require "yaml"
require_relative "index_reports"

# Rendu déterministe du radar à partir du manifest sélectionné et rédigé (schéma 2).
# Le modèle n’écrit plus le rapport : il fournit la prose dans le manifest, le script
# produit le Markdown, la vue d’ensemble, les sujets écartés, les sources et la couverture.
module WatchtowerRadarRender
  class Error < StandardError; end

  DECISION_LABELS = {
    "monitor" => "surveillance", "qualify" => "qualification", "test" => "test", "adopt" => "adoption", "avoid" => "mise à l’écart"
  }.freeze
  CATALOGUE_LEVELS = {
    "monitor" => "surveillance", "qualify" => "à qualifier", "test" => "test prévu", "adopt" => "adoption", "avoid" => "à écarter"
  }.freeze
  ROLE_LABELS = { "control" => "contrôle", "discovery" => "découverte", "qualification" => "qualification" }.freeze

  module_function

  def visible_label(candidate)
    case candidate["novelty"]
    when "Nouveau hors OSS" then candidate["origin"].to_s.strip
    else candidate["novelty"].to_s
    end
  end

  # Ancre compatible avec le rendu Markdown du site : minuscules, ponctuation retirée, espaces en tirets.
  def anchor(title)
    title.to_s.downcase.gsub(/[^\p{L}\p{N}\s_-]/, "").gsub(/\s/, "-")
  end

  def short_date(value)
    date = to_date(value)
    date ? date.strftime("%d/%m/%Y") : value.to_s
  end

  def to_date(value)
    return value if value.is_a?(Date)
    return value.to_date if value.is_a?(Time)
    return nil if value.to_s.strip.empty?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def selected(manifest)
    Array(manifest["candidates"]).select { |candidate| candidate["selection_status"] == "selected" }.sort_by { |candidate| candidate["rank"].to_i }
  end

  def report(manifest, date:)
    raise Error, "le rendu par script exige un manifest de schéma 2" unless manifest["schema_version"] == 2

    chosen = selected(manifest)
    out = +"# Radar architecture — #{WatchtowerReportIndex.french_date(date)}\n<!-- watchtower:2 -->\n"
    out << "> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.\n\n"
    out << intro(manifest) << "\n"
    out << overview(chosen)
    chosen.each { |candidate| out << fiche(candidate) }
    out << rejected(manifest)
    out << consulted(manifest, date)
    out << failures(manifest)
    out
  end

  def intro(manifest)
    text = +"Exposition locale commune : à qualifier."
    incomplete = Array(manifest["coverage"]).select { |entry| entry["complete"] == false || entry["result"] == "échec" }
    unless incomplete.empty?
      grouped = incomplete.group_by { |entry| entry["note"].to_s }
      details = grouped.map { |note, entries| "#{entries.map { |entry| "#{entry['domain']}/#{entry['lane']}" }.join(', ')} — #{note}" }
      text << " Couverture incomplète : #{details.join(' ; ')}. Aucune absence de changement n’en est déduite."
    end
    text << "\n"
  end

  def overview(chosen)
    out = +"## Vue d’ensemble\n\n| Outil | Type | Pitch rapide | Lien vers la section |\n|---|---|---|---|\n"
    chosen.each do |candidate|
      out << "| [#{candidate['name']}](#{candidate['canonical_url']}) | #{candidate['nature']} · #{visible_label(candidate)} | " \
             "#{cell(candidate['pitch_court'])} | [Fiche](##{anchor(candidate['name'])}) |\n"
    end
    out << "\n"
  end

  def cell(value)
    value.to_s.gsub("|", "/").gsub(/\s+/, " ").strip
  end

  def fiche(candidate)
    out = +"## [#{candidate['name']}](#{candidate['canonical_url']})\n\n"
    out << "- **Pitch rapide :** **Fait :** #{candidate['fact'].to_s.strip} **Analyse :** #{candidate['analyse'].to_s.strip}\n"
    decision = DECISION_LABELS.fetch(candidate["decision"].to_s, candidate["decision"].to_s)
    out << "- **Utilité :** #{candidate['utilite'].to_s.strip} Niveau : #{candidate['signal_level']} ; exposition locale : #{candidate['environment']}. " \
           "**Décision :** #{decision} par `#{candidate['owner']}`, réexamen le #{short_date(candidate['due_date'])} ; " \
           "succès = #{candidate['success_criterion'].to_s.strip}\n"
    out << "- **Repères de comparaison :** #{candidate['reperes'].to_s.strip}\n" unless candidate["reperes"].to_s.strip.empty?
    out << "\n### Pitch détaillé\n\n#{candidate['pitch_detaille'].to_s.strip}\n" unless candidate["pitch_detaille"].to_s.strip.empty?
    out << "\n"
  end

  def rejected(manifest)
    out = +"## Sujets écartés\n\n"
    candidates = Array(manifest["candidates"]).reject { |candidate| candidate["selection_status"] == "selected" }
    capacity, filtered = candidates.partition { |candidate| candidate["selection_reason"].to_s.start_with?("hors capacité") }
    unless capacity.empty?
      links = capacity.map { |candidate| "[#{candidate['name']}](#{candidate['canonical_url']})" }.join(" ; ")
      out << "- Hors capacité après classement déterministe (#{manifest.dig('selection', 'selected_count')} sujets publiés) : #{links}.\n"
    end
    filtered.each do |candidate|
      note = candidate["rejection_note"].to_s.strip
      note = candidate["scoring_note"].to_s.strip if note.empty?
      out << "- [#{candidate['name']}](#{candidate['canonical_url']}) — #{candidate['selection_reason']}#{note.empty? ? '' : " : #{note}"}\n"
    end
    selection = manifest["selection"] || {}
    out << "- Exception quota OSS : #{selection['oss_exception']}\n" if selection["oss_exception"]
    out << "- Exception minimum de sujets : #{selection['minimum_exception']}\n" if selection["minimum_exception"]
    out << "- Rendement : #{manifest['candidate_yield_note']}\n" unless manifest["candidate_yield_note"].to_s.strip.empty?
    out << "- Aucun sujet écarté.\n" if candidates.empty? && selection["oss_exception"].nil? && selection["minimum_exception"].nil?
    out << "\n"
  end

  def roles_for(manifest, source_id)
    roles = ROLE_LABELS.select { |role, _label| Array(manifest.dig("sources", role)).include?(source_id) }.values
    roles.empty? ? ["qualification"] : roles
  end

  def consulted(manifest, date)
    out = +"## Sources consultées\n\n"
    chosen = selected(manifest)
    cited = []
    chosen.each do |candidate|
      Array(candidate["evidence"]).each do |proof|
        next unless proof.is_a?(Hash)

        cited << proof["source_id"]
        out << "- `#{proof['source_id']}` — #{roles_for(manifest, proof['source_id']).join(' et ')} — " \
               "[#{candidate['name']}](#{proof['url']}) — #{candidate['product_version']} ; " \
               "publié le #{proof['published_at'] || 'inconnue'} ; effet #{proof['effective_at'] || 'inconnue'} ; " \
               "consulté le #{proof['observed_at']} ; #{proof['fact']}\n"
      end
    end
    controls = Array(manifest.dig("sources", "control")) - cited.uniq
    unless controls.empty?
      out << "- #{controls.map { |id| "`#{id}`" }.join(', ')} — contrôle — deltas lus dans le cache local le #{date.iso8601} via le digest ; " \
             "candidats retenus ou écartés listés ci-dessus.\n"
    end
    discoveries = Array(manifest.dig("sources", "discovery"))
    out << "- #{discoveries.map { |id| "`#{id}`" }.join(' et ')} — découverte — consultés le #{date.iso8601}.\n" unless discoveries.empty?
    block = {
      "algorithm" => manifest["algorithm"],
      "control_sources" => manifest.dig("sources", "control"),
      "discovery_sources" => manifest.dig("sources", "discovery"),
      "qualification_sources" => manifest.dig("sources", "qualification"),
      "coverage" => manifest["coverage"]
    }
    out << "\n```watchtower-couverture\n#{YAML.dump(block, line_width: -1).sub(/\A---\n/, '')}```\n\n"
  end

  def failures(manifest)
    out = +"## Sources en échec\n\n"
    list = Array(manifest["source_failures"])
    if list.empty?
      out << "Aucune.\n"
    else
      list.each { |failure| out << "- `#{failure['source_id']}` — `#{failure['period']}` — #{failure['consequence']}\n" }
    end
    out
  end

  # Une ligne de catalogue par sujet retenu : insérée après l’en-tête ou mise à jour
  # sur la ligne existante de même URL, sans toucher au reste du fichier.
  def catalogue_rows!(path, manifest, date:)
    path = Pathname.new(path)
    lines = path.read.lines
    separator = lines.index { |line| line.match?(/\A\|\s*-{3,}/) }
    raise Error, "#{path}: en-tête de tableau introuvable" unless separator

    review = "[#{date.strftime('%d/%m')}](../dist/#{date.iso8601}/radar-architecture.md)"
    selected(manifest).reverse_each do |candidate|
      url = candidate["canonical_url"]
      link = "#{review.sub(')', "##{anchor(candidate['name'])})")}"
      level = CATALOGUE_LEVELS.fetch(candidate["decision"].to_s, candidate["decision"].to_s)
      trend = "#{candidate['signal_level']} · #{date.strftime('%d/%m')}"
      existing = lines.index { |line| line[/\A\| \[[^\]]+\]\((https?:\/\/[^)]+)\)/, 1] == url }
      if existing
        cells = lines[existing].strip.split("|", -1)[1...-1].map(&:strip)
        nature = cells[1].to_s.empty? ? "#{candidate['nature']} · #{visible_label(candidate)}" : cells[1]
        lines[existing] = "| [#{candidate['name']}](#{url}) | #{nature} | #{level} | #{link} | #{trend} |\n"
      else
        lines.insert(separator + 1, "| [#{candidate['name']}](#{url}) | #{candidate['nature']} · #{visible_label(candidate)} | #{level} | #{link} | #{trend} |\n")
      end
    end
    path.write(lines.join)
  end
end
