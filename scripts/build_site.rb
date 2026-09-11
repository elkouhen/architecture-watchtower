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

def prepare_site_sources(root: ROOT, destination: STAGING)
  FileUtils.rm_rf(destination)
  FileUtils.mkdir_p(destination)

  homepage = root.join("README.md").read.gsub(/\]\((state\/[^)]+)\)/) do
    "](https://github.com/elkouhen/architecture-watchtower/blob/master/#{Regexp.last_match(1)})"
  end
  destination.join("index.md").write(homepage)
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
