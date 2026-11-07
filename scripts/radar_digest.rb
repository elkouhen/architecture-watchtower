# frozen_string_literal: true

require "date"
require "pathname"
require_relative "html_text"

# Pré-filtre déterministe des deltas collectés : un seul fichier `digest.md` par
# exécution, qui classe chaque élément par voie (mots-clés) et par intérêt pour
# la stack déclarée. Le modèle lit ce digest en une fois, puis n’ouvre dans le
# cache que les éléments qu’il qualifie. Aucun appel réseau, aucun token.
module WatchtowerRadarDigest
  MONTHS = %w[january february march april may june july august september october november december].freeze
  SHORT_MONTHS = %w[jan feb mar apr may jun jul aug sep oct nov dec].freeze
  EXCERPT_CHARS = 300
  SECTION_EXCERPT_CHARS = 400
  PAGE_BLOCK_CHARS = 800
  PAGE_MAX_BLOCKS = 40
  DISCOVERY_MAX_ENTRIES = 40
  DISCOVERY_FALLBACK_CHARS = 8_000
  DEFAULT_STACK_KEYWORDS = [
    "EKS", "GKE", "Kubernetes", "kubectl", "Terraform", "Vault", "Consul", "Nomad", "Packer", "HashiCorp",
    "OpenTelemetry", "Elasticsearch", "Elastic", "Logstash", "Kibana", "CloudWatch", "GitHub Actions", "GitLab",
    "Bedrock", "AgentCore", "Vertex AI", "Gemini", "Claude", "Anthropic", "OpenAI", "MCP", "agentic", "A2A",
    "Gateway API", "service mesh", "Istio", "Envoy", "Cilium", "eBPF", "CNI", "Argo", "Helm", "Karpenter",
    "Cloud Run", "Lambda", "IAM", "VPC", "Prometheus", "Grafana", "GitOps", "Fargate", "ECS", "ECR", "KMS",
    "Secrets Manager", "Secret Manager", "Artifact Registry", "Cloud Build", "CDK", "Crossplane", "Backstage",
    "Autopilot", "node pool", "Container-Optimized OS", "Bottlerocket", "containerd", "SBOM", "supply chain"
  ].freeze
  DEFAULT_LANE_KEYWORDS = {
    "security" => ["CVE-", "vulnerab", "security bulletin", "advisory", "exploit", "GHSA-", "compromis", "malicious"],
    "lifecycle_deprecations" => ["deprecat", "end of support", "end-of-support", "end of life", "end-of-life", "retire",
                                 "sunset", "discontinu", "breaking", "shut down", "shutdown", "turndown",
                                 "no longer supported", "no longer available", "will be removed"],
    "availability_quotas_costs" => ["now available in", "available in the", "region", "quota", "pricing", "price",
                                    "cost", "free tier", "savings plan", "reserved", "spot", "per million"]
  }.freeze

  module_function

  def config(sources_data)
    custom = sources_data.is_a?(Hash) && sources_data["digest"].is_a?(Hash) ? sources_data["digest"] : {}
    {
      "stack_keywords" => Array(custom["stack_keywords"]).empty? ? DEFAULT_STACK_KEYWORDS : Array(custom["stack_keywords"]),
      "lane_keywords" => custom["lane_keywords"].is_a?(Hash) ? custom["lane_keywords"] : DEFAULT_LANE_KEYWORDS
    }
  end

  class Matcher
    def initialize(config)
      @stack = config["stack_keywords"].map { |word| [word, /(?<![\p{L}\p{N}])#{Regexp.escape(word)}/i] }
      @lanes = config["lane_keywords"].map { |lane, words| [lane, words.map { |word| Regexp.new(Regexp.escape(word), Regexp::IGNORECASE) }] }
    end

    def stack_hits(text)
      @stack.select { |_word, pattern| text.match?(pattern) }.map(&:first).uniq.first(6)
    end

    def lanes(text)
      @lanes.select { |_lane, patterns| patterns.any? { |pattern| text.match?(pattern) } }.map(&:first)
    end

    # Un élément est retenu s’il touche la stack ou une voie sécurité/lifecycle.
    def retained?(stack, lanes)
      !stack.empty? || (lanes & %w[security lifecycle_deprecations]).any?
    end
  end

  def build(root:, cache_dir:, collection:, date:, sources_data: {}, discovery_ids: [])
    root = Pathname.new(root)
    matcher = Matcher.new(config(sources_data))
    stats = { "retained" => 0, "titles_only" => 0, "page_blocks" => 0, "discovery_entries" => 0 }
    out = +"# Digest des deltas — radar du #{date.iso8601}\n\n"
    out << "Chaque ligne cite le fichier du cache à ouvrir de façon ciblée. `voies` et `stack` sont des étiquettes " \
           "par mots-clés : elles orientent la lecture, elles ne qualifient rien. Les éléments sans mot-clé sont " \
           "listés par titre seul ; ils restent à examiner si leur titre l’exige.\n"
    discovery, control = collection.partition { |result| discovery_ids.include?(result["source_id"]) }
    control.each do |result|
      out << "\n## #{result['source_id']} — "
      case [result["status"], result["kind"]]
      when %w[ok feed]
        out << "flux, #{result['items_total']} élément(s) du #{result['from']} au #{result['through']}"
        out << " ; flux plafonné : période #{result['truncated_period']['from']}/#{result['truncated_period']['through']} non couverte" if result["truncated_period"]
        out << " ; lacune #{result['gap']['from']}/#{result['gap']['through']}" if result["gap"]
        out << "\n\n"
        out << feed_section(root, result, matcher, stats)
      when %w[ok page]
        out << "page, #{result['chars']} caractères"
        out << " ; lacune #{result['gap']['from']}/#{result['gap']['through']}" if result["gap"]
        out << "\n\n"
        out << page_section(root, result, matcher, stats, Date.parse(result["from"]), Date.parse(result["through"]))
      else
        errors = Array(result["attempts"]).map { |attempt| "#{attempt['url']} : #{attempt['error']}" }.join(" ; ")
        out << "échec de collecte (#{errors}) — période #{result['from']}/#{result['through']} non couverte ; une seule relance web admise.\n"
      end
    end
    unless discovery.empty?
      out << "\n## Découverte\n\n"
      discovery.each do |result|
        out << "### #{result['source_id']}\n\n"
        if result["status"] == "ok"
          out << discovery_section(root, result, stats)
        else
          out << "échec de collecte.\n\n"
        end
      end
    end
    path = Pathname.new(cache_dir).join("digest.md")
    root.join(path).write(out)
    stats.merge("path" => path.to_s, "bytes" => out.bytesize)
  end

  def feed_section(root, result, matcher, stats)
    fields = result["item_fields"]
    rows = all_items(root, result, fields)
    return "Aucun élément dans le delta.\n" if rows.empty?

    retained = []
    titles = []
    rows.each do |item|
      file = Pathname.new(result["cache_dir"]).join(item["file"])
      text = root.join(file).file? ? root.join(file).read : ""
      body = item_body(text)
      if body.length >= WatchtowerRadarCollectionDigestBridge.digest_min_chars && !WatchtowerHtmlText.headings(body, limit: 2).empty?
        retained << digest_item(item, file, body, matcher, stats)
        next
      end
      haystack = "#{item['title']}\n#{body}"
      stack = matcher.stack_hits(haystack)
      lanes = matcher.lanes(haystack)
      if matcher.retained?(stack, lanes)
        stats["retained"] += 1
        retained << "- #{item['published_at']} · voies : #{lanes.empty? ? 'releases_features' : lanes.join(',')} · stack : #{stack.join(',')} · " \
                    "**#{item['title']}** — #{item['url']} — `#{file}`\n  #{WatchtowerHtmlText.excerpt(body, chars: EXCERPT_CHARS)}\n"
      else
        stats["titles_only"] += 1
        titles << "- #{item['published_at']} · #{item['title']} — #{item['url']} — `#{file}`\n"
      end
    end
    section = +""
    section << "### Éléments retenus par mots-clés\n\n#{retained.join}\n" unless retained.empty?
    section << "### Titres seuls (sans mot-clé de stack)\n\n#{titles.join}\n" unless titles.empty?
    section
  end

  # Un élément long à titres internes (digest quotidien d’un fournisseur) est découpé
  # par section : seules les sections intéressantes sont extraites, les autres nommées.
  def digest_item(item, file, body, matcher, stats)
    lines = body.lines
    sections = []
    current = nil
    lines.each_with_index do |line, index|
      if line.match?(/\A## \S/)
        current = { "title" => line.sub(/\A## /, "").strip, "line" => index + 1, "body" => +"" }
        sections << current
      elsif current
        current["body"] << line
      end
    end
    kept = []
    named = []
    sections.each do |section|
      haystack = "#{section['title']}\n#{section['body']}"
      stack = matcher.stack_hits(haystack)
      lanes = matcher.lanes(haystack)
      if matcher.retained?(stack, lanes)
        stats["retained"] += 1
        kept << "  - **#{section['title']}** (ligne #{section['line']}) · voies : #{lanes.empty? ? 'releases_features' : lanes.join(',')} · " \
                "stack : #{stack.join(',')}\n    #{WatchtowerHtmlText.excerpt(section['body'], chars: SECTION_EXCERPT_CHARS)}\n"
      else
        named << section["title"]
      end
    end
    stats["titles_only"] += named.length
    text = +"- #{item['published_at']} · **#{item['title']}** — #{item['url']} — `#{file}` (digest à sections)\n"
    text << kept.join
    text << "  - autres sections : #{named.join(' ; ')}\n" unless named.empty?
    text
  end

  # Le fichier du cache commence par le titre puis un bloc URL/Publié/Source : le corps vient après.
  def item_body(text)
    parts = text.split("\n\n", 3)
    parts.length == 3 ? parts[2] : text
  end

  def all_items(root, result, fields)
    index = root.join(result["index_path"])
    rows = index.file? ? index.read.lines.select { |line| line.start_with?("| 20") } : []
    return result["items"].map { |values| fields.zip(values).to_h } if rows.empty?

    rows.map do |line|
      cells = line.strip.split("|").map(&:strip).reject(&:empty?)
      { "published_at" => cells[0], "title" => cells[1], "url" => cells[2], "file" => Pathname.new(cells[3].to_s).basename.to_s }
    end
  end

  # Une page HTML normalisée est découpée en blocs datés ; seuls les blocs dont la
  # date tombe dans la fenêtre de collecte sont extraits, avec leur numéro de ligne.
  def page_section(root, result, matcher, stats, from, through)
    path = root.join(result["cache_path"])
    return "Fichier de cache absent.\n" unless path.file?

    lines = path.read.lines
    year_hint = through.year
    starts = []
    lines.each_with_index do |line, index|
      year_hint = Regexp.last_match(1).to_i if line.match?(/\A#+ /) && line.match(/\b(20\d{2})\b/)
      date = line_date(line, year_hint)
      next unless date

      next if line.match?(/\ALast updated/i)

      start = index
      probe = index - 1
      probe -= 1 while probe >= 0 && probe > index - 4 && lines[probe].strip.empty?
      start = probe if probe >= 0 && probe > index - 4 && lines[probe].match?(/\A#+ \S/)
      starts << [start, date]
    end
    blocks = []
    starts.each_with_index do |(start, date), position|
      next unless date >= from && date <= through

      finish = position + 1 < starts.length ? starts[position + 1][0] : lines.length
      body = lines[start...finish].join
      next if body.gsub(/\s+/, " ").strip.length < 40

      haystack = body
      stack = matcher.stack_hits(haystack)
      lanes = matcher.lanes(haystack)
      blocks << "- #{date.iso8601} · ligne #{start + 1} · voies : #{lanes.empty? ? 'releases_features' : lanes.join(',')} · stack : #{stack.join(',')}\n" \
                "  #{WatchtowerHtmlText.excerpt(body, chars: PAGE_BLOCK_CHARS)}\n"
    end
    stats["page_blocks"] += blocks.length
    text = +"Fichier : `#{result['cache_path']}`. "
    if blocks.empty?
      text << "Aucun bloc daté dans la fenêtre #{from.iso8601}/#{through.iso8601} ; titres : #{Array(result['headings']).first(12).join(' ; ')}\n"
    else
      text << "#{blocks.length} bloc(s) daté(s) dans la fenêtre #{from.iso8601}/#{through.iso8601}"
      text << " (#{blocks.length - PAGE_MAX_BLOCKS} non listés)" if blocks.length > PAGE_MAX_BLOCKS
      text << " :\n\n#{blocks.first(PAGE_MAX_BLOCKS).join}"
    end
    text
  end

  def line_date(line, year_hint)
    text = line.strip
    return nil if text.length > 160

    if (match = text.match(/\b(20\d{2})-(\d{2})-(\d{2})\b/))
      return safe_date(match[1].to_i, match[2].to_i, match[3].to_i)
    end
    if (match = text.match(/\b(#{MONTHS.join('|')})\s+(\d{1,2}),?\s+(20\d{2})\b/i))
      return safe_date(match[3].to_i, MONTHS.index(match[1].downcase) + 1, match[2].to_i)
    end
    if (match = text.match(/\b(\d{1,2})\s+(#{MONTHS.join('|')})\s+(20\d{2})\b/i))
      return safe_date(match[3].to_i, MONTHS.index(match[2].downcase) + 1, match[1].to_i)
    end
    if (match = text.match(/\A(#{(MONTHS + SHORT_MONTHS + ['sept']).join('|')})\.?\s+(\d{1,2})\z/i))
      name = match[1].downcase
      month = name == "sept" ? 8 : (MONTHS.index(name) || SHORT_MONTHS.index(name))
      return safe_date(year_hint, month + 1, match[2].to_i)
    end
    nil
  end

  def safe_date(year, month, day)
    Date.new(year, month, day)
  rescue ArgumentError
    nil
  end

  def discovery_section(root, result, stats)
    path = root.join(result["cache_path"])
    return "Fichier de cache absent.\n\n" unless path.file?

    text = path.read
    entries = case result["source_id"]
    when "github-trending" then github_trending_entries(text)
    when "trendshift" then trendshift_entries(text)
    else []
    end
    stats["discovery_entries"] += entries.length
    if entries.empty?
      "Fichier : `#{result['cache_path']}` (extrait brut, #{text.length} caractères).\n\n#{text[0, DISCOVERY_FALLBACK_CHARS]}\n\n"
    else
      "Fichier : `#{result['cache_path']}`. #{entries.length} dépôt(s) extraits :\n\n#{entries.first(DISCOVERY_MAX_ENTRIES).join}\n"
    end
  end

  def github_trending_entries(text)
    lines = text.lines.map(&:strip)
    entries = []
    index = 0
    while index < lines.length
      if lines[index] == "##" && (owner_line = lines[index + 1..index + 4].to_a.find { |line| line.match?(%r{\A\S+ /\z}) })
        owner = owner_line.sub(%r{ /\z}, "")
        repo_index = lines.index(owner_line) + 1
        repo_index += 1 while repo_index < lines.length && lines[repo_index].empty?
        repo = lines[repo_index]
        rest = lines[(repo_index + 1)..-1].to_a.take_while { |line| line != "##" }
        description = rest.find { |line| !line.empty? && !line.match?(/\A[\d,]+\z/) && line != "Built by" && !line.match?(/stars today\z/) && line != "Star" }
        today = rest.find { |line| line.match?(/stars today\z/) }
        stars = rest.select { |line| line.match?(/\A[\d,]+\z/) }
        entries << "- #{owner}/#{repo} — #{description} (#{stars.first} étoiles, #{today}) — https://github.com/#{owner}/#{repo}\n"
        index = repo_index + 1
      else
        index += 1
      end
    end
    entries
  end

  def trendshift_entries(text)
    lines = text.lines.map(&:strip)
    entries = []
    lines.each_with_index do |line, index|
      next unless line.match?(%r{\A[\w.-]+/[\w.-]+\z}) && !line.start_with?("Like ")

      rest = lines[(index + 1)..(index + 12)].to_a
      description = rest.find do |candidate|
        !candidate.empty? && !candidate.match?(/\A[\d ]+\z/) && candidate != "Mentioned on" && !candidate.start_with?("Like ", "# ", "New ") &&
          !candidate.match?(%r{\A[\w.-]+/[\w.-]+\z}) && candidate != "Bifrost Featured"
      end
      tags = rest.take_while { |candidate| !candidate.match?(%r{\A[\w.-]+/[\w.-]+\z}) }.select { |candidate| candidate.start_with?("# ") }.join(" ")
      entries << "- #{line} — #{description} #{tags}— https://github.com/#{line}\n"
    end
    entries.uniq
  end
end

# Seuil partagé avec le collecteur sans dépendance circulaire.
module WatchtowerRadarCollectionDigestBridge
  module_function

  def digest_min_chars
    1_500
  end
end
