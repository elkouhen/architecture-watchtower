# Architecture Watchtower

Veille locale en français pour l’architecture Cloud/DevOps, l’observabilité, la sécurité, l’IA appliquée et l’écosystème HashiCorp.

## Navigation

- [Catalogue canonique des éléments étudiés](docs/catalogue.md)
- [Rapports et cartes par date](docs/rapports.md)
- Prompts : [radar](radar-architecture.md), [carte de service](carte-service.md), [classement mensuel](classement-mensuel.md)
- [Contrats de validation, preuves et notation](docs/contrats-veille.md)
- [Algorithme graphique d’exécution du radar](docs/algorithme-radar.html)
- [Backlog de fiabilisation du radar](docs/backlog-radar.md)

## Livrables

- Radar quotidien : `dist/YYYY-MM-DD/radar-architecture.md`
- Classement mensuel : `dist/YYYY-MM-DD/classement-mensuel-AAAA-MM.md`
- [Radar du 7 novembre 2026](dist/2026-11-07/radar-architecture.md)
- [Radar du 12 septembre 2026](dist/2026-09-12/radar-architecture.md)
- [Radar du 11 septembre 2026](dist/2026-09-11/radar-architecture.md)
- [Radar du 10 septembre 2026](dist/2026-09-10/radar-architecture.md)
- [Radar du 9 septembre 2026](dist/2026-09-09/radar-architecture.md)
- [Radar du 8 septembre 2026](dist/2026-09-08/radar-architecture.md)
- [Radar du 7 septembre 2026](dist/2026-09-07/radar-architecture.md)
- [Classement d’août 2026](dist/2026-09-05/classement-mensuel-2026-08.md)
- [Radar du 5 septembre 2026](dist/2026-09-05/radar-architecture.md)
- [Radar du 6 septembre 2026](dist/2026-09-06/radar-architecture.md)
- [Radar du 4 septembre 2026](dist/2026-09-04/radar-architecture.md)
- Radar du 3 septembre 2026 : [`dist/2026-09-03/radar-architecture.md`](dist/2026-09-03/radar-architecture.md)
- Radar du 2 septembre 2026 : [`dist/2026-09-02/radar-architecture.md`](dist/2026-09-02/radar-architecture.md)
- Radar du 30 août 2026 : [`dist/2026-08-30/radar-architecture.md`](dist/2026-08-30/radar-architecture.md)
- Carte de service : `dist/YYYY-MM-DD/carte-<service>.md`
- [Carte GitLab Duo Agent Platform](dist/2026-09-05/carte-gitlab-duo-agent-platform.md) · CI/CD agentique · découverte
- Registre des signaux : [`state/signals.yaml`](state/signals.yaml)
- Registre des sources : [`state/sources.yaml`](state/sources.yaml)
- Manifests déterministes des radars : `state/radar-runs/YYYY-MM-DD.yaml`
- Progression d’apprentissage : [`state/learning.yaml`](state/learning.yaml)
- Validation locale : `ruby scripts/validate_watchtower.rb`
- Site local : `python3 -m venv .venv-docs`, `.venv-docs/bin/python -m pip install -r requirements-docs.txt`, puis `ruby scripts/build_site.rb` et `.venv-docs/bin/python -m mkdocs serve`
- Contrôle de fraîcheur : `ruby scripts/validate_watchtower.rb --daily`
- Génération instrumentée d’un radar : `ruby scripts/run_radar.rb` (dépôt propre requis ; échéances et collecte par script, qualification structurée, sélection Ruby, rédaction verrouillée, signaux et index par script, tokens cumulés et durée murale, validation et commit)
- Mesure du préfixe sans appel Codex : `ruby scripts/run_radar.rb --dry-run` (échéances simulées, collecte dans `.cache/radar/<date>/`, taille du contexte par composant)
- Échéances de signaux : `ruby scripts/review_due_signals.rb [--date AAAA-MM-JJ] [--dry-run]`
- Collecte locale des sources du radar : `ruby scripts/collect_radar_deltas.rb --date AAAA-MM-JJ [--update-registry]`
- Synchronisation des signaux depuis un manifest sélectionné : `ruby scripts/sync_radar_signals.rb --manifest state/radar-runs/AAAA-MM-JJ.yaml --report dist/AAAA-MM-JJ/radar-architecture.md`
- Index d’un radar : `ruby scripts/index_reports.rb --date AAAA-MM-JJ`
- Contexte préparé d’une carte : `ruby scripts/prepare_carte_context.rb --service <nom> [--url <URL>]`
- Contexte préparé du classement mensuel : `ruby scripts/prepare_classement_context.rb --month AAAA-MM`
- Régénération instrumentée d’un radar depuis son manifest verrouillé : `ruby scripts/run_radar.rb --date AAAA-MM-JJ --replace` (aucune recollecte ni resélection)
- Calcul manuel d’un manifest : `ruby scripts/select_radar_candidates.rb --manifest state/radar-runs/AAAA-MM-JJ.yaml`
- Collecte d’un flux RSS/Atom enregistré : `ruby scripts/collect_radar_source.rb --source ID --update-registry`
- PRD : [`PRD.md`](PRD.md)
- Tests : `for t in scripts/test_*.rb; do ruby "$t"; done`

## Principes

- Les sources primaires confirment les faits ; les tendances servent à découvrir.
- Les indicateurs GitHub ou de recherche sont datés et ne prouvent ni maturité ni adoption.
- La déduplication du radar porte sur les trois derniers mois.
- L’exposition réelle reste `à qualifier` tant que l’inventaire n’est pas établi.
- La preuve de publication est un commit Git local.
- Chaque nouveau radar prouve la couverture AWS/GCP/IA et vise 33 % de nouveaux projets open source, sauf exception prioritaire motivée.
- Le validateur bloque les doublons, les échéances actives dépassées et les index locaux incohérents.
- Le classement mensuel récapitule une seule fois par mois toutes les technologies observées, sans planifier de POC ou de laboratoire.

Le hook versionné `.githooks/pre-commit` exécute automatiquement la validation. Pour l’activer dans un nouveau clone : `git config core.hooksPath .githooks`.

La publication GitHub Pages est construite avec MkDocs Material. Les sources restent les fichiers Markdown versionnés ; `.mkdocs/` et `public/` sont des sorties locales régénérables et ne sont pas suivies par Git.

Le catalogue évite les doublons entre thèmes ; les rapports et cartes restent regroupés par date pour faciliter la navigation historique.
