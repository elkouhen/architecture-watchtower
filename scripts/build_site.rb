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
  report_lines = reports.map do |path|
    relative = path.relative_path_from(root)
    "- `#{path.parent.basename}` · **#{report_kind(path)}** — [#{report_title(path)}](#{relative})"
  end

  latest_link = if latest_radar
    "[Lire le dernier radar](#{latest_radar.relative_path_from(root)})"
  else
    "[Parcourir les rapports](docs/rapports.md)"
  end

  <<~MARKDOWN
    ---
    hide:
      - toc
    ---

    # Architecture Watchtower

    Veille locale et vérifiée sur le Cloud, le DevOps, l’architecture applicative et l’IA.

    #{latest_link}

    ## Dernières publications

    #{report_lines.join("\n")}

    ## Explorer

    - [Catalogue](docs/catalogue.md) — technologies et patterns déjà analysés.
    - [Tous les rapports](docs/rapports.md) — historique chronologique des radars, cartes et classements.
    - [Algorithme du radar](docs/algorithme-radar.html) — fonctionnement de la collecte à la publication.
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
