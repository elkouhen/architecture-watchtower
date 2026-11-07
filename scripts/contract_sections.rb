# frozen_string_literal: true

# Extraction de sections d’un document Markdown par titre, pour n’injecter dans
# une phase orchestrée que les règles qui la concernent.
module WatchtowerContractSections
  class Error < StandardError; end

  HEADING = /\A(\#{2,3}) (.+?)\s*\z/

  module_function

  def parse(text)
    sections = []
    current = nil
    text.each_line do |line|
      if (match = line.match(HEADING))
        current = { "level" => match[1].length, "title" => match[2], "body" => +"" }
        sections << current
      elsif current
        current["body"] << line
      end
    end
    sections
  end

  def extract(text, titles)
    sections = parse(text)
    titles.map do |title|
      section = sections.find { |candidate| candidate["title"] == title || candidate["title"].start_with?(title) }
      raise Error, "section introuvable : #{title}" unless section

      "#{'#' * section['level']} #{section['title']}\n#{section['body'].rstrip}\n"
    end.join("\n")
  end
end
