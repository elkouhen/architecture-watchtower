#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"
require "yaml"

ROOT = File.expand_path("..", __dir__)
OUTPUT = File.join(ROOT, "public")

def esc(value)
  CGI.escapeHTML(value.to_s)
end

def slug(value)
  value.to_s.downcase
       .unicode_normalize(:nfkd).encode("ASCII", replace: "")
       .gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-+\z/, "")
end

def inline_markdown(text)
  value = esc(text)
  value = value.gsub(/!\[([^\]]*)\]\(([^)]+)\)/, '<img alt="\1" src="\2">')
  value = value.gsub(/\[([^\]]+)\]\(([^)]+)\)/) do
    label = Regexp.last_match(1)
    href = Regexp.last_match(2)
    href = href.sub(/\.md(?=($|#))/, '.html') if href.end_with?(".md") || href.include?(".md#")
    "<a href=\"#{href}\">#{label}</a>"
  end
  value = value.gsub(/`([^`]+)`/, '<code>\1</code>')
  value = value.gsub(/\*\*([^*]+)\*\*/, '<strong>\1</strong>')
  value.gsub(/\*([^*]+)\*/, '<em>\1</em>')
end

def markdown_to_html(markdown)
  lines = markdown.lines.map(&:chomp)
  html = []
  index = 0
  paragraph = []
  list_type = nil
  in_code = false
  code_lines = []

  flush_paragraph = lambda do
    unless paragraph.empty?
      html << "<p>#{inline_markdown(paragraph.join(" ").strip)}</p>"
      paragraph.clear
    end
  end
  close_list = lambda do
    html << "</#{list_type}>" if list_type
    list_type = nil
  end

  while index < lines.length
    line = lines[index]
    if in_code
      if line.start_with?("```")
        html << "<pre><code>#{esc(code_lines.join("\n"))}</code></pre>"
        code_lines.clear
        in_code = false
      else
        code_lines << line
      end
      index += 1
      next
    end

    if line.start_with?("```")
      flush_paragraph.call
      close_list.call
      in_code = true
      index += 1
      next
    end

    if line.start_with?("|") && index + 1 < lines.length && lines[index + 1].start_with?("|")
      flush_paragraph.call
      close_list.call
      rows = []
      while index < lines.length && lines[index].start_with?("|")
        cells = lines[index].split("|")[1..-2].map(&:strip)
        rows << cells unless cells.all? { |cell| cell.match?(/\A:?-{3,}:?\z/) }
        index += 1
      end
      next if rows.empty?
      head = rows.shift
      table = ["<div class=\"table-wrap\"><table><thead><tr>"]
      head.each { |cell| table << "<th>#{inline_markdown(cell)}</th>" }
      table << "</tr></thead><tbody>"
      rows.each do |row|
        table << "<tr>"
        row.each { |cell| table << "<td>#{inline_markdown(cell)}</td>" }
        table << "</tr>"
      end
      table << "</tbody></table></div>"
      html << table.join
      next
    end

    if (match = line.match(/\A(#+)\s+(.+)\z/))
      flush_paragraph.call
      close_list.call
      level = [match[1].length, 4].min
      title = match[2].strip
      html << "<h#{level} id=\"#{slug(title.gsub(/\[|\]\([^)]*\)/, ""))}\">#{inline_markdown(title)}</h#{level}>"
    elsif line.match?(/\A\s*[-*]\s+/)
      flush_paragraph.call
      wanted = "ul"
      html << "<#{wanted}>" if list_type != wanted
      list_type = wanted
      html << "<li>#{inline_markdown(line.sub(/\A\s*[-*]\s+/, ""))}</li>"
    elsif line.match?(/\A\s*\d+\.\s+/)
      flush_paragraph.call
      wanted = "ol"
      html << "<#{wanted}>" if list_type != wanted
      list_type = wanted
      html << "<li>#{inline_markdown(line.sub(/\A\s*\d+\.\s+/, ""))}</li>"
    elsif line.strip.empty?
      flush_paragraph.call
      close_list.call
    else
      close_list.call if list_type
      paragraph << line.strip
    end
    index += 1
  end

  if in_code
    html << "<pre><code>#{esc(code_lines.join("\n"))}</code></pre>"
  end
  flush_paragraph.call
  close_list.call
  html.join("\n")
end

def page(title, body, depth: 0, active: nil)
  prefix = "../" * depth
  <<~HTML
    <!doctype html>
    <html lang="fr">
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <title>#{esc(title)} · Architecture Watchtower</title>
      <meta name="description" content="Veille Cloud, DevOps, architecture applicative et IA.">
      <link rel="stylesheet" href="#{prefix}assets/site.css">
    </head>
    <body>
      <header class="topbar">
        <a class="brand" href="#{prefix}index.html"><span class="brand-mark">◈</span> Architecture Watchtower</a>
        <nav><a href="#{prefix}index.html">Rapports</a><a href="#{prefix}catalogue.html">Catalogue</a><a href="https://github.com/elkouhen/architecture-watchtower" rel="noreferrer">Dépôt GitHub</a><button id="theme-toggle" type="button" aria-label="Changer de thème">☼</button></nav>
      </header>
      <main class="shell">
        <div class="ai-notice"><span>✦</span> Contenu entièrement géré par IA · <a href="https://github.com/elkouhen/architecture-watchtower" rel="noreferrer">voir le dépôt Git</a></div>
        #{body}
      </main>
      <footer class="footer">Veille locale · contenu entièrement géré par IA · <a href="https://github.com/elkouhen/architecture-watchtower" rel="noreferrer">dépôt GitHub</a> · générée le #{Date.today.strftime("%d/%m/%Y")}</footer>
      <script src="#{prefix}assets/site.js"></script>
    </body>
    </html>
  HTML
end

FileUtils.rm_rf(OUTPUT)
FileUtils.mkdir_p(File.join(OUTPUT, "assets"))

css = <<~CSS
  :root { color-scheme: light; --bg:#f8f9fb; --surface:#fff; --ink:#172033; --muted:#667085; --line:#e6e9ef; --accent:#5753c9; --accent-soft:#efefff; --shadow:0 12px 32px rgba(23,32,51,.05); }
  :root.dark { color-scheme: dark; --bg:#10131b; --surface:#171b25; --ink:#f1f3f8; --muted:#a4adbd; --line:#2a3140; --accent:#aaa5ff; --accent-soft:#272542; --shadow:0 12px 32px rgba(0,0,0,.16); }
  * { box-sizing:border-box; } body { margin:0; background:var(--bg); color:var(--ink); font:16px/1.65 Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }
  a { color:var(--accent); } .topbar { align-items:center; background:color-mix(in srgb,var(--bg) 88%,transparent); border-bottom:1px solid color-mix(in srgb,var(--line) 72%,transparent); display:flex; justify-content:space-between; padding:17px max(24px,calc((100vw - 1180px)/2)); position:sticky; top:0; z-index:5; backdrop-filter:blur(18px); }
  .brand { color:var(--ink); font-weight:800; text-decoration:none; letter-spacing:-.03em; } .brand-mark { color:var(--accent); margin-right:8px; } nav { align-items:center; display:flex; gap:22px; } nav a { color:var(--muted); font-size:.9rem; text-decoration:none; } nav a:hover { color:var(--accent); } button { background:var(--surface); border:1px solid var(--line); border-radius:999px; color:var(--ink); cursor:pointer; padding:7px 11px; }
  .shell { margin:0 auto; max-width:1180px; padding:56px 24px 96px; } .hero { align-items:end; background:radial-gradient(circle at 85% 15%,rgba(190,185,255,.5),transparent 28%),linear-gradient(135deg,#23264a 0%,#5753c9 100%); border:0; border-radius:28px; color:#fff; display:grid; gap:40px; grid-template-columns:1.4fr .6fr; margin-bottom:64px; overflow:hidden; padding:58px clamp(28px,6vw,72px); position:relative; } .hero::after { border:1px solid rgba(255,255,255,.15); border-radius:50%; content:""; height:360px; position:absolute; right:-130px; top:-180px; width:360px; } .eyebrow { color:var(--accent); font-size:.72rem; font-weight:800; letter-spacing:.14em; text-transform:uppercase; } .hero .eyebrow { color:#c9c6ff; } h1,h2,h3 { letter-spacing:-.045em; line-height:1.1; } h1 { font-size:clamp(2.8rem,6vw,5.9rem); margin:14px 0 20px; max-width:850px; } h2 { font-size:clamp(1.8rem,3vw,2.5rem); margin-top:48px; } h3 { font-size:1.1rem; } .hero p { color:rgba(255,255,255,.76); font-size:1.08rem; max-width:650px; } .signal-card { align-self:end; background:rgba(255,255,255,.11); border:1px solid rgba(255,255,255,.22); border-radius:18px; box-shadow:none; color:#fff; padding:22px; position:relative; z-index:1; } .signal-card strong { display:inline-block; font-size:2.6rem; letter-spacing:-.08em; margin-right:8px; } .signal-card span { color:rgba(255,255,255,.72); margin-right:18px; }
  .ai-notice { background:var(--accent-soft); border:1px solid color-mix(in srgb,var(--accent) 32%,var(--line)); border-radius:12px; color:var(--muted); font-size:.86rem; margin-bottom:26px; padding:10px 14px; } .ai-notice span { color:var(--accent); font-weight:800; margin-right:6px; } .ai-notice a { font-weight:700; text-decoration:none; }
  .toolbar { align-items:center; display:flex; flex-wrap:wrap; gap:12px; margin:24px 0; } input,select { background:var(--surface); border:1px solid var(--line); border-radius:10px; color:var(--ink); font:inherit; padding:11px 13px; } input { flex:1; min-width:240px; } .filters { display:flex; gap:8px; } .filter { background:var(--surface); border:1px solid var(--line); border-radius:999px; color:var(--muted); cursor:pointer; padding:8px 13px; } .filter.active { background:var(--accent-soft); border-color:var(--accent); color:var(--accent); }
  .report-grid { display:grid; gap:0; grid-template-columns:repeat(2,minmax(0,1fr)); } .report-card { background:transparent; border:0; border-bottom:1px solid var(--line); border-radius:0; box-shadow:none; display:flex; flex-direction:column; min-height:172px; padding:22px 18px 22px 0; transition:background .18s ease,padding .18s ease; } .report-card:nth-child(even) { padding-left:28px; } .report-card:hover { background:var(--surface); padding-left:12px; } .report-card:nth-child(even):hover { padding-left:40px; } .report-card[hidden] { display:none; } .card-meta { color:var(--muted); font-size:.8rem; } .report-card h3 { margin:8px 0; } .report-card p { color:var(--muted); margin:0 0 12px; } .card-link { font-weight:700; margin-top:auto; text-decoration:none; } .pill { background:transparent; border:1px solid color-mix(in srgb,var(--accent) 35%,var(--line)); border-radius:999px; color:var(--accent); display:inline-block; font-size:.72rem; font-weight:800; padding:3px 8px; } .novelties { margin:48px 0 70px; } .novelties > header { align-items:end; display:flex; justify-content:space-between; gap:20px; margin-bottom:22px; } .novelties h2 { margin:0; } .novelties-intro { color:var(--muted); margin:0; max-width:650px; } .novelty-grid { display:grid; gap:12px; grid-template-columns:repeat(3,minmax(0,1fr)); } .novelty-card { background:var(--surface); border:1px solid var(--line); border-radius:16px; box-shadow:var(--shadow); padding:22px; } .novelty-card:first-child,.novelty-card:last-child { border-radius:16px; } .novelty-card h3 { margin:10px 0 8px; } .novelty-card p { color:var(--muted); margin:7px 0; } .novelty-card .label { color:var(--accent); font-size:.7rem; font-weight:800; letter-spacing:.1em; text-transform:uppercase; } .novelty-card .novelty-link { display:inline-block; font-weight:700; margin-top:8px; text-decoration:none; }
  article { background:var(--surface); border:0; border-top:3px solid var(--accent); border-radius:0; box-shadow:none; padding:clamp(26px,5vw,64px); } article h1 { font-size:clamp(2rem,4vw,4rem); } article h2 { border-top:1px solid var(--line); padding-top:34px; } article h3 { margin-top:30px; } article p,article ul,article ol { max-width:850px; } article p { background:var(--surface); color:var(--ink); } article li { margin:7px 0; } article p code,article li code,article td code,article th code { background:var(--accent-soft); color:var(--ink); border-radius:5px; padding:2px 5px; } article pre { background:#101827 !important; border-radius:10px; color:#dbeafe !important; font:14px/1.55 ui-monospace,SFMono-Regular,Menlo,Monaco,Consolas,"Liberation Mono","Courier New",monospace; overflow:auto; padding:18px; white-space:pre-wrap; overflow-wrap:anywhere; tab-size:2; } article pre code { background:transparent !important; color:#dbeafe !important; display:block; border-radius:0; padding:0; white-space:inherit; } .table-wrap { overflow-x:auto; } table { border-collapse:collapse; margin:20px 0; min-width:700px; width:100%; } th,td { border:1px solid var(--line); padding:10px 12px; text-align:left; vertical-align:top; } th { background:var(--accent-soft); color:var(--ink); }
  .footer { color:var(--muted); font-size:.85rem; margin:0 auto; max-width:1180px; padding:0 24px 34px; } .empty { color:var(--muted); padding:35px 0; } .catalogue { background:var(--surface); border:1px solid var(--line); border-radius:18px; padding:24px; }
  @media (max-width:760px) { .topbar { padding:15px 18px; } nav a { display:none; } .shell { padding:42px 16px 64px; } .hero { grid-template-columns:1fr; } h1 { font-size:3.2rem; } .report-grid,.novelty-grid { grid-template-columns:1fr; } .report-card,.report-card:nth-child(even),.report-card:hover,.report-card:nth-child(even):hover { padding-left:0; } .novelties > header { align-items:start; flex-direction:column; } .novelty-card:first-child,.novelty-card:last-child { border-radius:0; } .signal-card { align-self:auto; } article { padding:22px 17px; } }
CSS
File.write(File.join(OUTPUT, "assets/site.css"), css)

js = <<~JS
  (() => {
    const root = document.documentElement;
    const saved = localStorage.getItem('watchtower-theme');
    if (saved === 'dark') root.classList.add('dark');
    const toggle = document.getElementById('theme-toggle');
    if (toggle) toggle.addEventListener('click', () => {
      root.classList.toggle('dark');
      localStorage.setItem('watchtower-theme', root.classList.contains('dark') ? 'dark' : 'light');
    });
    const search = document.getElementById('report-search');
    const cards = [...document.querySelectorAll('.report-card')];
    let kind = 'all';
    const filter = () => {
      const query = (search?.value || '').toLowerCase();
      cards.forEach(card => {
        const matchesText = card.textContent.toLowerCase().includes(query);
        const matchesKind = kind === 'all' || card.dataset.kind === kind;
        card.hidden = !(matchesText && matchesKind);
      });
    };
    search?.addEventListener('input', filter);
    document.querySelectorAll('.filter').forEach(button => button.addEventListener('click', () => {
      document.querySelectorAll('.filter').forEach(item => item.classList.remove('active'));
      button.classList.add('active'); kind = button.dataset.kind; filter();
    }));
  })();
JS
File.write(File.join(OUTPUT, "assets/site.js"), js)

reports = Dir.glob(File.join(ROOT, "dist", "*", "*.md")).sort.reverse
metadata = reports.map do |path|
  relative = path.sub(%r{\A#{Regexp.escape(ROOT)}/}, "")
  date = relative.split("/")[1]
  basename = File.basename(path, ".md")
  title = File.foreach(path).find { |line| line.start_with?("# ") }&.sub(/^#\s+/, "")&.strip || basename
  title = title.gsub(/\[([^\]]+)\]\([^)]+\)/, "\\1")
  kind = basename.start_with?("radar-") ? "radar" : basename.start_with?("carte-") ? "carte" : "mensuel"
  excerpt = File.foreach(path).find { |line| line.strip.length > 0 && !line.start_with?("#", "|", "-", "*") }&.strip.to_s
  output = File.join(OUTPUT, relative.sub(/\.md\z/, ".html"))
  FileUtils.mkdir_p(File.dirname(output))
  depth = relative.split("/").length - 1
  body = "<article><div class=\"eyebrow\">#{esc(date)} · #{esc(kind)}</div>#{markdown_to_html(File.read(path))}</article>"
  File.write(output, page(title, body, depth: depth))
  { date: date, title: title, kind: kind, excerpt: excerpt, href: relative.sub(/\.md\z/, ".html") }
end

kind_labels = { "radar" => "Radar", "carte" => "Carte", "mensuel" => "Revue mensuelle" }
cards = metadata.map do |item|
  <<~HTML
    <article class="report-card" data-kind="#{item[:kind]}">
      <div><span class="pill">#{kind_labels[item[:kind]]}</span> <span class="card-meta">#{esc(item[:date])}</span></div>
      <h3>#{esc(item[:title])}</h3>
      <p>#{esc(item[:excerpt].to_s[0, 230])}</p>
      <a class="card-link" href="#{item[:href]}">Lire le rapport →</a>
    </article>
  HTML
end.join

signals_path = File.join(ROOT, "state", "signals.yaml")
signals = if File.file?(signals_path)
  YAML.safe_load(File.read(signals_path), permitted_classes: [Date], aliases: true).fetch("signals", [])
else
  []
end
signal_status_labels = { "new" => "Nouveau", "open" => "Mis à jour", "closed" => "Historique", "deferred" => "Différé", "discarded" => "Écarté" }
novelty_cards = signals.sort_by { |signal| signal["last_seen"].to_s }.reverse.first(12).map do |signal|
  report = Array(signal["deliverables"]).find { |path| path.end_with?(".md") }
  next unless report
  href = report.sub(/\.md\z/, ".html")
  <<~HTML
    <article class="novelty-card">
      <div class="label">#{esc(signal_status_labels.fetch(signal["status"], signal["status"].to_s))} · #{esc(signal["last_seen"].to_s)}</div>
      <h3>#{esc(signal["product_version"].to_s)}</h3>
      <p><strong>Pourquoi c’est intéressant :</strong> #{esc(signal["subject"].to_s)}</p>
      <p><strong>Contexte :</strong> #{esc(signal["environment"].to_s)}</p>
      <a class="novelty-link" href="#{href}">Lire l’analyse →</a>
    </article>
  HTML
end.compact.join

counts = metadata.group_by { |item| item[:kind] }.transform_values(&:length)
index_body = <<~HTML
  <section class="hero">
    <div><div class="eyebrow">Veille Cloud · DevOps · Architecture · IA</div><h1>Comprendre ce qui change dans vos architectures.</h1><p>Un index vivant des radars, cartes de services et revues mensuelles générés localement.</p></div>
    <div class="signal-card"><strong>#{metadata.length}</strong><span>rapports disponibles</span><hr><strong>#{counts["mensuel"] || 0}</strong><span>revue mensuelle</span></div>
  </section>
  <section class="novelties">
    <header><div><div class="eyebrow">Les nouveautés expliquées</div><h2>Ce qui change</h2></div><p class="novelties-intro">Des fiches courtes pour comprendre le sujet, son intérêt architectural et son contexte avant d’ouvrir l’analyse complète.</p></header>
    <div class="novelty-grid">#{novelty_cards}</div>
  </section>
  <section>
    <div class="toolbar"><input id="report-search" type="search" placeholder="Rechercher un rapport, une technologie…" aria-label="Rechercher un rapport"><div class="filters"><button class="filter active" data-kind="all">Tous</button><button class="filter" data-kind="radar">Radars</button><button class="filter" data-kind="carte">Cartes</button><button class="filter" data-kind="mensuel">Revues</button></div></div>
    <div class="report-grid">#{cards}</div>
    <p class="empty" id="empty-note">Aucun rapport ne correspond à la recherche.</p>
  </section>
HTML
File.write(File.join(OUTPUT, "index.html"), page("Rapports", index_body))

catalogue = File.join(ROOT, "docs", "catalogue.md")
if File.file?(catalogue)
  catalogue_html = markdown_to_html(File.read(catalogue)).gsub('href="../dist/', 'href="dist/')
  body = "<article><div class=\"eyebrow\">Index transversal</div>#{catalogue_html}</article>"
  File.write(File.join(OUTPUT, "catalogue.html"), page("Catalogue", body))
end

puts "Generated #{metadata.length} reports in #{OUTPUT}"
