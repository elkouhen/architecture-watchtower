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
