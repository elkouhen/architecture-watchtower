#!/usr/bin/env ruby
# frozen_string_literal: true

require "date"
require "json"
require "pathname"
require "yaml"

path = Pathname.new(ARGV[0] || Pathname.new(__dir__).join("../state/signals.yaml")).expand_path
abort "Registre absent: #{path}" unless path.file?

data = YAML.safe_load(path.read, permitted_classes: [Date, Time], aliases: true) || {}
abort "Le registre doit utiliser tabular-v1" unless data["format"] == "tabular-v1"
fields = data.fetch("signal_fields")
if fields.include?("identity_key")
  puts "Migration déjà appliquée: #{path}"
  exit
end

id_index = fields.index("id")
abort "Champ id absent" unless id_index
rows = data.fetch("signals")
identities = rows.map do |row|
  id = row[id_index].to_s
  abort "Identifiant de signal absent" if id.empty?
  "legacy:#{id}"
end

lines = path.readlines
field_line = lines.index { |line| line.chomp == "- id" }
abort "Déclaration du champ id introuvable" unless field_line
lines.insert(field_line + 1, "- identity_key\n")

row_number = 0
lines.map! do |line|
  next line unless line.start_with?("  - [")

  identity = identities.fetch(row_number)
  row_number += 1
  line.sub(/\A(  - \[[^,]+,)/, "\\1 #{JSON.generate(identity)},")
end
abort "Nombre de lignes migrées incohérent" unless row_number == identities.length

path.write(lines.join)
puts "Identités ajoutées à #{row_number} signaux: #{path}"
