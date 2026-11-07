# frozen_string_literal: true

require "date"
require "json"
require "yaml"

module WatchtowerRadarSourceRegistry
  class Error < StandardError; end

  module_function

  def update(path, source_id, attributes)
    data = YAML.safe_load(File.read(path), permitted_classes: [Date, Time], aliases: true) || {}
    raise Error, "le registre doit utiliser tabular-v1" unless data["format"] == "tabular-v1"
    fields = data.fetch("source_fields")
    rows = data.fetch("sources")
    id_index = fields.index("id")
    raise Error, "champ id absent" unless id_index
    row_index = rows.index { |row| row[id_index] == source_id }
    raise Error, "source inconnue #{source_id}" unless row_index

    record = fields.zip(rows[row_index]).to_h
    attributes.each do |key, value|
      raise Error, "champ source inconnu #{key}" unless fields.include?(key)
      record[key] = value
    end
    replacement = fields.map { |field| json_value(record[field]) }
    replace_tabular_row(path, row_index, replacement)
  end

  # Remplace la ligne cible de la section `sources:` en une seule ligne compacte,
  # qu’elle soit déjà compacte (`- [..]`) ou en style bloc (`- - id` sur plusieurs lignes).
  def replace_tabular_row(path, target_index, row)
    lines = File.readlines(path)
    section = lines.index { |line| line.start_with?("sources:") }
    raise Error, "section sources absente" unless section

    finish = ((section + 1)...lines.length).find { |i| lines[i] =~ /\A[^\s#-]/ } || lines.length
    first_item = ((section + 1)...finish).find { |i| lines[i] =~ /\A\s*- / }
    raise Error, "ligne tabulaire #{target_index + 1} introuvable" unless first_item

    indent = lines[first_item][/\A */]
    starts = ((section + 1)...finish).select { |i| lines[i].start_with?("#{indent}- ") || lines[i].rstrip == "#{indent}-" }
    start = starts[target_index]
    raise Error, "ligne tabulaire #{target_index + 1} introuvable" unless start

    stop = starts[target_index + 1] || finish
    stop -= 1 while stop > start + 1 && lines[stop - 1].strip.empty?
    lines[start...stop] = ["#{indent}- #{JSON.generate(row)}\n"]
    File.write(path, lines.join)
  end

  def json_value(value)
    case value
    when Date, Time then value.iso8601
    when Array then value.map { |item| json_value(item) }
    when Hash then value.to_h { |key, item| [key, json_value(item)] }
    else value
    end
  end
end
