# frozen_string_literal: true

CARD_SECTIONS = ["Type, lien et pitch rapide", "Résumé décisionnel", "Position dans le système", "Modèle mental", "Architecture de déploiement", "Données et cycle de vie", "Exploitation", "Sécurité et responsabilités", "Choix et alternatives", "Quand l’utiliser / l’éviter", "Évolutions depuis la dernière carte", "Incertitudes et sources"].freeze
MONTHLY_SECTIONS = ["Période et méthode", "Classement complet", "Tendances du mois", "Lecture architecturale", "Par thème", "Mouvements du mois", "Sujets non classés", "Sources et limites"].freeze
WEIGHTS = { "nouveaute_interet" => 30, "impact_architectural" => 25, "pertinence_stack" => 20, "confiance" => 15, "maturite_exploitation" => 10 }.freeze
CLASSES = ["priorité nouveauté", "à qualifier", "veille", "signal faible", "à écarter"].freeze

def sections_of(text)
  text.split(/^## /).drop(1).to_h do |part|
    title, body = part.split("\n", 2)
    [title.sub(/^\d+\.\s*/, "").strip.downcase, body.to_s.strip]
  end
end

def require_sections(text, names, label)
  sections = sections_of(text)
  names.each do |name|
    error("#{label}: section absente ou vide #{name}") if sections[name.downcase].to_s.empty?
  end
  sections
end

def http_url?(value)
  value.is_a?(String) && value.match?(%r{\Ahttps?://[^\s/]+(?:/[^\s]*)?\z})
end

def contract_yaml(text, name, label)
  blocks = text.scan(/^```#{Regexp.escape(name)}\s*\n(.*?)^```\s*$/m).flatten
  return error("#{label}: un bloc #{name} requis") unless blocks.length == 1
  data = YAML.safe_load(blocks.first, permitted_classes: [Date, Time], aliases: false)
  return error("#{label}: #{name} doit être un objet YAML") unless data.is_a?(Hash)
  data
rescue Psych::Exception => e
  error("#{label}: YAML #{name} invalide : #{e.message}")
  nil
end

def table_rows(body)
  body.to_s.lines.select { |line| line.strip.start_with?("|") }.map do |line|
    line.strip.split("|", -1)[1...-1].map(&:strip)
  end.reject { |row| row.all? { |cell| cell.match?(/\A:?-+:?\z/) } }
end

def validate_card(text, label, modern: true)
  sections = require_sections(text, CARD_SECTIONS, label)
  sources = sections["incertitudes et sources"].to_s
  urls = if modern
    sources.scan(/Source primaire\s*:\s*\[[^\]]+\]\((https?:\/\/[^)]+)\)/i).flatten
  else
    sources.scan(%r{https?://[^\s)]+})
  end
  error("#{label}: au moins trois URL primaires distinctes requises") if urls.uniq.length < 3
end

def validate_monthly_sections(text, label)
  require_sections(text, MONTHLY_SECTIONS, label)
end

def validate_monthly_editions(root)
  paths = Dir.glob(root.join("dist/*/classement-mensuel-*.md").to_s)
  paths.group_by { |path| File.basename(path) }.each do |month, editions|
    error("#{month}: plusieurs éditions mensuelles : #{editions.join(', ')}") if editions.length > 1
  end
end

def validate_contract(text, path, root)
  label = path.to_s
  error("#{label}: répertoire de date ISO requis") unless path.parent.basename.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
  error("#{label}: marqueur requis immédiatement après le titre") unless text.match?(/\A# [^\n]+\n\s*<!-- watchtower:2 -->/)
  date = date_value(path.parent.basename.to_s, label)
  error("#{label}: date de production future") if date && date > TODAY
  text.scan(/\[[^\]]+\]\(([^)]+)\)/).flatten.each do |target|
    next if target.start_with?("https://", "http://", "#")
    clean = target.split("#", 2).first
    error("#{label}: lien local absent #{target}") unless path.dirname.join(clean).file?
  end
  case path.basename.to_s
  when "radar-architecture.md"
    validate_radar_contract(text, label, date)
  when /\Acarte-.+\.md\z/
    validate_card(text, label)
  when /\Aclassement-mensuel-(\d{4}-\d{2})\.md\z/
    month = Regexp.last_match(1)
    validate_monthly_contract(text, label, month, date, path)
  else
    error("#{label}: type de rapport inconnu")
  end
end

def validate_radar_contract(text, label, date)
  sections = require_sections(text, ["Vue d’ensemble", "Sujets écartés", "Sources consultées", "Sources en échec"], label)
  rows = table_rows(sections["vue d’ensemble"])
  error("#{label}: colonnes du radar invalides") unless rows.shift == ["Outil", "Type", "Pitch rapide", "Lien vers la section"]
  topics = text.scan(/^## (\[[^\n]+)(.*?)(?=^## |\z)/m)
  error("#{label}: nombre de lignes différent des fiches") unless rows.length == topics.length
  topics.each do |title, body|
    error("#{label}: titre sans URL canonique") unless title.match?(%r{\]\(https?://[^)]+\)})
    ["Pitch rapide", "Utilité", "Outils similaires"].each do |field|
      error("#{label}: #{title}, champ #{field} absent") unless body.match?(/\*\*#{field}\s*:\*\*\s*\S/)
    end
  end
  rows.each do |row|
    error("#{label}: ligne radar invalide") unless row.length == 4 && row[0].match?(%r{\]\(https?://[^)]+\)}) && row[1].match?(/\A(outil|service|pattern|standard|plateforme|modèle|bibliothèque) · (Nouveau projet OSS|Nouveau hors OSS|Mise à jour)\z/) && row[3].match?(/\]\(#[^)]+\)/)
  end
  table_urls = rows.map { |row| row[0].to_s[/\]\((https?:\/\/[^)]+)\)/, 1] }
  topic_urls = topics.map { |title, _body| title[/\]\((https?:\/\/[^)]+)\)/, 1] }
  error("#{label}: fiches différentes de la vue d’ensemble") unless table_urls == topic_urls
  error("#{label}: plus de trois pitchs détaillés") if text.scan(/^### Pitch détaillé/).length > 3
  oss = rows.count { |row| row[1].to_s.include?("Nouveau projet OSS") }
  error("#{label}: quota OSS sans exception motivée") if oss < (rows.length * 0.33).ceil && !sections["sujets écartés"].to_s.match?(/Exception quota OSS\s*:\s*\S.+/)
  error("#{label}: dépassement sans motif critique") if rows.length > 10 && !sections["sujets écartés"].to_s.match?(/Dépassement critique\s*:\s*\S.+/)
  data = contract_yaml(sections["sources consultées"].to_s, "watchtower-couverture", label)
  return unless data.is_a?(Hash)
  coverage = data["coverage"]
  return error("#{label}: coverage doit être une liste") unless coverage.is_a?(Array) && coverage.all? { |entry| entry.is_a?(Hash) }
  expected = %w[AWS GCP IA].product(%w[releases_features security lifecycle_deprecations availability_quotas_costs])
  pairs = coverage.map { |entry| [entry["domain"], entry["lane"]] }
  error("#{label}: douze voies uniques requises") unless pairs.length == 12 && pairs.uniq.length == 12 && (expected - pairs).empty?
  coverage.each do |entry|
    start = date_value(entry["from"], label)
    finish = date_value(entry["through"], label)
    checked = date_value(entry["checked_at"], label)
    error("#{label}: dates de collecte incohérentes") if start && finish && checked && (start > finish || finish > checked || (date && checked != date))
    error("#{label}: source ou résultat de collecte invalide") unless http_url?(entry["source"]) && ["signal retenu", "aucun changement retenu", "échec"].include?(entry["result"])
    error("#{label}: complete doit être booléen") unless [true, false].include?(entry["complete"])
    if entry["complete"] == false || entry["result"] == "échec"
      error("#{label}: couverture incomplète non déclarée") unless text.include?("Couverture incomplète") && !entry["note"].to_s.strip.empty? && entry["complete"] == false
    end
  end
end

def validate_monthly_contract(text, label, month, date, path)
  sections = validate_monthly_sections(text, label)
  first = date_value("#{month}-01", label)
  return unless first
  last = first.next_month - 1
  error("#{label}: mois non clos à la production") if date && last >= date
  data = contract_yaml(sections["période et méthode"].to_s, "watchtower-classement", label)
  return unless data.is_a?(Hash)
  error("#{label}: période différente du nom de fichier") unless data["period"] == month
  items, events, trends = data.values_at("items", "events", "trends")
  return error("#{label}: items/events/trends doivent être des listes d’objets") unless [items, events, trends].all? { |list| list.is_a?(Array) && list.all? { |entry| entry.is_a?(Hash) } }
  [items, events, trends].each do |list|
    error("#{label}: identifiants absents ou dupliqués") if list.any? { |entry| !entry["id"].is_a?(String) || entry["id"].empty? } || list.map { |entry| entry["id"] }.uniq.length != list.length
  end
  event_ids = events.map { |event| event["id"] }
  events.each do |event|
    observed = date_value(event["date"], label)
    error("#{label}: événement hors période") if observed && !(first..last).cover?(observed)
    error("#{label}: événement sans origine, technologie ou URL") unless http_url?(event["url"]) && %w[origin technology].all? { |key| !event[key].to_s.strip.empty? }
  end
  signatures = events.map { |event| [event["url"], event["date"].to_s, event["technology"]] }
  error("#{label}: même événement compté plusieurs fois") unless signatures.uniq.length == signatures.length
  items.each do |item|
    %w[urgence].concat(WEIGHTS.keys).each do |key|
      value = item[key]
      error("#{label}: note #{key} invalide pour #{item['id']}") unless value == "inconnu" || (value.is_a?(Integer) && value.between?(1, 5))
    end
    numeric = WEIGHTS.keys.all? { |key| item[key].is_a?(Integer) }
    score = numeric ? WEIGHTS.sum { |key, weight| item[key] * weight } / 100.0 : "inconnu"
    error("#{label}: score incohérent pour #{item['id']}") unless item["score"] == score
    error("#{label}: classe, URL ou justification invalide") unless CLASSES.include?(item["classification"]) && http_url?(item["canonical_url"]) && !item["reason"].to_s.strip.empty?
    evidence = item["evidence"]
    error("#{label}: preuves manquantes ou inconnues") unless evidence.is_a?(Array) && !evidence.empty? && (evidence - event_ids).empty?
  end
  items.group_by { |item| item["canonical_url"] }.each_value do |group|
    error("#{label}: URL partagée sans justification d’identité") if group.length > 1 && group.any? { |item| item["identity_note"].to_s.strip.empty? }
  end
  complete = items.all? { |item| WEIGHTS.keys.all? { |key| item[key].is_a?(Integer) } }
  expected_mode = complete ? "pondéré" : "qualitatif"
  error("#{label}: mode attendu #{expected_mode}") unless data["mode"] == expected_mode
  sorted = items.sort_by do |item|
    impact = item["impact_architectural"].is_a?(Integer) ? item["impact_architectural"] : 0
    primary = complete ? -WEIGHTS.sum { |key, weight| item[key] * weight } : (CLASSES.index(item["classification"]) || 99)
    [primary, -impact, item["id"].to_s]
  end
  error("#{label}: ordre ou rangs incohérents") unless items == sorted && items.map { |item| item["rank"] } == (1..items.length).to_a
  rows = table_rows(sections["classement complet"])
  header = ["Rang", "Technologie", "Pitch rapide — pourquoi c’est intéressant", "Tendance", "Classe", "Lien vers la preuve"]
  error("#{label}: colonnes mensuelles invalides") unless rows.shift == header
  error("#{label}: tableau et registre différents") unless rows.length == items.length
  rows.zip(items).each do |row, item|
    next unless item
    error("#{label}: ligne mensuelle différente du registre") unless row.length == 6 && row[0] == item["rank"].to_s && row[1].include?("(#{item['canonical_url']})") && row[3] == item["trend"] && row[4] == item["classification"] && row[5].match?(/\]\([^)]+\)/)
  end
  error("#{label}: plus de sept tendances") if trends.length > 7
  item_trends = items.map { |item| { "level" => item["trend"], "evidence" => item["trend_evidence"], "reason" => item["reason"], "previous_report" => item["previous_report"] } }
  (trends + item_trends).each do |trend|
    evidence = Array(trend["evidence"])
    selected = events.select { |event| evidence.include?(event["id"]) }
    error("#{label}: preuves de tendance inconnues ou répétées") unless (evidence - event_ids).empty? && evidence.uniq == evidence
    valid = case trend["level"]
    when "forte" then selected.length >= 3 && selected.map { |event| event["technology"] }.uniq.length >= 2
    when "émergente" then selected.length >= 2
    when "stable"
      previous = trend["previous_report"].to_s.split("#").first.to_s
      !previous.empty? && File.basename(previous) == "classement-mensuel-#{first.prev_month.strftime('%Y-%m')}.md" && path.dirname.join(previous).file?
    when "faible" then true
    else false
    end
    error("#{label}: tendance insuffisamment justifiée") unless valid && !trend["reason"].to_s.strip.empty?
  end
end
