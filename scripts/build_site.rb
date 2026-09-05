#!/usr/bin/env ruby
# frozen_string_literal: true

require "cgi"
require "date"
require "fileutils"

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
        <nav><a href="#{prefix}index.html">Rapports</a><a href="#{prefix}catalogue.html">Catalogue</a><button id="theme-toggle" type="button" aria-label="Changer de thème">☼</button></nav>
      </header>
      <main class="shell">
        #{body}
      </main>
      <footer class="footer">Veille locale · générée le #{Date.today.strftime("%d/%m/%Y")}</footer>
      <script src="#{prefix}assets/site.js"></script>
    </body>
    </html>
  HTML
end

FileUtils.rm_rf(OUTPUT)
FileUtils.mkdir_p(File.join(OUTPUT, "assets"))

css = <<~CSS
  :root { color-scheme: light; --bg:#f5f7fb; --surface:#fff; --ink:#142033; --muted:#64748b; --line:#dbe3ef; --accent:#3b5ccc; --accent-soft:#e8edff; --shadow:0 16px 45px rgba(38,55,91,.08); }
  :root.dark { color-scheme: dark; --bg:#0e1524; --surface:#141e31; --ink:#edf3ff; --muted:#9eacc2; --line:#293850; --accent:#9bb2ff; --accent-soft:#202e55; --shadow:0 16px 45px rgba(0,0,0,.18); }
  * { box-sizing:border-box; } body { margin:0; background:var(--bg); color:var(--ink); font:16px/1.65 Inter,ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif; }
  a { color:var(--accent); } .topbar { align-items:center; background:color-mix(in srgb,var(--surface) 92%,transparent); border-bottom:1px solid var(--line); display:flex; justify-content:space-between; padding:18px max(24px,calc((100vw - 1180px)/2)); position:sticky; top:0; z-index:5; backdrop-filter:blur(16px); }
  .brand { color:var(--ink); font-weight:800; text-decoration:none; letter-spacing:-.02em; } .brand-mark { color:var(--accent); margin-right:8px; } nav { align-items:center; display:flex; gap:20px; } nav a { color:var(--muted); font-size:.92rem; text-decoration:none; } nav a:hover { color:var(--accent); } button { background:var(--accent-soft); border:1px solid var(--line); border-radius:9px; color:var(--ink); cursor:pointer; padding:7px 10px; }
  .shell { margin:0 auto; max-width:1180px; padding:58px 24px 80px; } .hero { display:grid; gap:28px; grid-template-columns:1.35fr .65fr; margin-bottom:44px; } .eyebrow { color:var(--accent); font-size:.78rem; font-weight:800; letter-spacing:.12em; text-transform:uppercase; } h1,h2,h3 { letter-spacing:-.035em; line-height:1.15; } h1 { font-size:clamp(2.5rem,6vw,5.6rem); margin:12px 0 18px; max-width:850px; } h2 { font-size:2rem; margin-top:48px; } h3 { font-size:1.2rem; } .hero p { color:var(--muted); font-size:1.15rem; max-width:680px; } .signal-card { align-self:end; background:linear-gradient(145deg,var(--accent),#728ef2); border-radius:24px; box-shadow:var(--shadow); color:white; padding:28px; } .signal-card strong { display:block; font-size:2.7rem; letter-spacing:-.06em; } .signal-card span { opacity:.85; }
  .toolbar { align-items:center; display:flex; flex-wrap:wrap; gap:12px; margin:24px 0; } input,select { background:var(--surface); border:1px solid var(--line); border-radius:10px; color:var(--ink); font:inherit; padding:11px 13px; } input { flex:1; min-width:240px; } .filters { display:flex; gap:8px; } .filter { background:var(--surface); border:1px solid var(--line); border-radius:999px; color:var(--muted); cursor:pointer; padding:8px 13px; } .filter.active { background:var(--accent-soft); border-color:var(--accent); color:var(--accent); }
  .report-grid { display:grid; gap:16px; grid-template-columns:repeat(2,minmax(0,1fr)); } .report-card { background:var(--surface); border:1px solid var(--line); border-radius:18px; box-shadow:var(--shadow); display:flex; flex-direction:column; min-height:220px; padding:23px; transition:transform .18s ease,border-color .18s ease; } .report-card:hover { border-color:var(--accent); transform:translateY(-3px); } .report-card[hidden] { display:none; } .card-meta { color:var(--muted); font-size:.82rem; } .report-card h3 { margin:10px 0; } .report-card p { color:var(--muted); margin:0 0 18px; } .card-link { font-weight:700; margin-top:auto; text-decoration:none; } .pill { background:var(--accent-soft); border-radius:999px; color:var(--accent); display:inline-block; font-size:.76rem; font-weight:700; padding:4px 9px; }
  article { background:var(--surface); border:1px solid var(--line); border-radius:22px; box-shadow:var(--shadow); padding:clamp(24px,5vw,58px); } article h1 { font-size:clamp(2rem,4vw,4rem); } article h2 { border-top:1px solid var(--line); padding-top:34px; } article h3 { margin-top:30px; } article p,article ul,article ol { max-width:850px; } article li { margin:7px 0; } article code { background:var(--accent-soft); border-radius:5px; padding:2px 5px; } pre { background:#101827; border-radius:12px; color:#dbeafe; overflow:auto; padding:18px; } .table-wrap { overflow-x:auto; } table { border-collapse:collapse; margin:20px 0; min-width:700px; width:100%; } th,td { border:1px solid var(--line); padding:10px 12px; text-align:left; vertical-align:top; } th { background:var(--accent-soft); color:var(--ink); }
  .footer { color:var(--muted); font-size:.85rem; margin:0 auto; max-width:1180px; padding:0 24px 34px; } .empty { color:var(--muted); padding:35px 0; } .catalogue { background:var(--surface); border:1px solid var(--line); border-radius:18px; padding:24px; }
  @media (max-width:760px) { .topbar { padding:15px 18px; } nav a { display:none; } .shell { padding:38px 16px 60px; } .hero { grid-template-columns:1fr; } h1 { font-size:3.1rem; } .report-grid { grid-template-columns:1fr; } .signal-card { align-self:auto; } article { padding:22px 17px; } }
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

counts = metadata.group_by { |item| item[:kind] }.transform_values(&:length)
index_body = <<~HTML
  <section class="hero">
    <div><div class="eyebrow">Veille Cloud · DevOps · Architecture · IA</div><h1>Comprendre ce qui change avant de décider.</h1><p>Un index vivant des radars, cartes de services et revues mensuelles générés localement.</p></div>
    <div class="signal-card"><strong>#{metadata.length}</strong><span>rapports disponibles</span><hr><strong>#{counts["mensuel"] || 0}</strong><span>revue mensuelle</span></div>
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
