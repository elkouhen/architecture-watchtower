#!/usr/bin/env ruby
# frozen_string_literal: true

require "fileutils"
require "pathname"

ROOT = Pathname.new(__dir__).join("..").expand_path
STAGING = ROOT.join(".mkdocs")

ROOT_DOCUMENTS = %w[
  AGENTS.md
  PRD.md
  amelioration-continue.md
  carte-service.md
  classement-mensuel.md
  radar-architecture.md
].freeze

def report_title(path)
  heading = path.each_line.find { |line| line.start_with?("# ") }
  (heading || path.basename(".md").to_s).sub(/^#\s+/, "").strip
    .gsub(/\[([^\]]+)\]\([^)]+\)/, "\\1")
end

def report_kind(path)
  basename = path.basename.to_s
  return "Radar" if basename.start_with?("radar-")
  return "Carte de service" if basename.start_with?("carte-")

  "Classement mensuel"
end

def build_homepage(root)
  all_reports = root.glob("dist/*/*.md").sort.reverse
  reports = [
    all_reports.find { |path| path.basename.to_s.start_with?("radar-") },
    all_reports.find { |path| path.basename.to_s.start_with?("carte-") },
    all_reports.find { |path| path.basename.to_s.start_with?("classement-mensuel-") }
  ].compact.sort.reverse
  latest_radar = reports.find { |path| path.basename.to_s == "radar-architecture.md" }
  report_cards = reports.map do |path|
    relative = path.relative_path_from(root)
    <<~HTML.strip
      <a class="watchtower-report-card" href="#{relative}">
        <span class="watchtower-report-card__kind">#{report_kind(path)}</span>
        <strong>#{report_title(path)}</strong>
        <span class="watchtower-report-card__date">#{path.parent.basename}</span>
      </a>
    HTML
  end

  latest_path = if latest_radar
    latest_radar.relative_path_from(root).to_s
  else
    "docs/rapports.md"
  end

  <<~MARKDOWN
    ---
    hide:
      - toc
    ---

    <div class="watchtower-hero">
      <p class="watchtower-kicker">SIGNAL / SYSTÈMES / DÉCISIONS</p>
      <h1>Architecture<br><span>Watchtower</span></h1>
      <p class="watchtower-hero__lede">Le radar qui transforme le bruit Cloud, DevOps et IA en décisions d’architecture exploitables.</p>
      <div class="watchtower-hero__actions">
        <a class="md-button md-button--primary" href="#{latest_path}">Lire le dernier radar</a>
        <a class="md-button" href="docs/catalogue.md">Explorer le catalogue</a>
      </div>
      <div class="watchtower-signal-row">
        <span><i></i> Sources primaires</span>
        <span><i></i> Analyse locale</span>
        <span><i></i> Décisions traçables</span>
      </div>
    </div>

    ## Derniers signaux

    <div class="watchtower-report-grid">
    #{report_cards.join("\n")}
    </div>

    ## Explorer le poste de contrôle

    <div class="watchtower-explore-grid">
      <a href="docs/catalogue.md"><span>01</span><strong>Catalogue</strong><small>Technologies et patterns analysés.</small></a>
      <a href="docs/rapports.md"><span>02</span><strong>Rapports</strong><small>Radars, cartes et classements datés.</small></a>
      <a href="docs/algorithme-radar.html"><span>03</span><strong>Algorithme</strong><small>De la collecte à la publication.</small></a>
    </div>
  MARKDOWN
end

def prepare_site_sources(root: ROOT, destination: STAGING)
  FileUtils.rm_rf(destination)
  FileUtils.mkdir_p(destination)

  destination.join("index.md").write(build_homepage(root))
  ROOT_DOCUMENTS.each do |name|
    FileUtils.cp(root.join(name), destination.join(name))
  end
  %w[dist docs].each do |directory|
    FileUtils.cp_r(root.join(directory), destination.join(directory))
  end

  destination
end

if $PROGRAM_NAME == __FILE__
  prepare_site_sources
  local_python = ROOT.join(".venv-docs", "bin", "python")
  default_python = local_python.executable? ? local_python.to_s : "python3"
  python = ENV.fetch("WATCHTOWER_PYTHON", default_python)
  success = system(python, "-m", "mkdocs", "build", "--strict", chdir: ROOT.to_s)
  abort "Construction MkDocs échouée ; vérifiez mkdocs.yml et requirements-docs.txt." unless success
end
