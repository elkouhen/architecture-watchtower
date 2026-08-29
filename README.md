# Architecture Watchtower

Veille locale en français pour l’architecture Cloud/DevOps, l’observabilité, la sécurité, l’IA appliquée et l’écosystème HashiCorp.

## Navigation

- [Catalogue canonique des éléments étudiés](docs/catalogue.md)
- [Rapports et cartes par date](docs/rapports.md)

## Livrables

- Radar quotidien : `dist/YYYY-MM-DD/radar-architecture.md`
- Carte de service : `dist/YYYY-MM-DD/carte-<service>.md`
- Registre des signaux : [`state/signals.yaml`](state/signals.yaml)
- Registre des sources : [`state/sources.yaml`](state/sources.yaml)
- Progression d’apprentissage : [`state/learning.yaml`](state/learning.yaml)
- PRD : [`PRD.md`](PRD.md)
- Carte du jour : [Model Context Protocol (MCP)](dist/2026-08-29/carte-mcp.md)

## Principes

- Les sources primaires confirment les faits ; les tendances servent à découvrir.
- Les indicateurs GitHub ou de recherche sont datés et ne prouvent ni maturité ni adoption.
- La déduplication du radar porte sur les trois derniers mois.
- L’exposition réelle reste `à qualifier` tant que l’inventaire n’est pas établi.
- La preuve de publication est un commit Git local.

Le catalogue évite les doublons entre thèmes ; les rapports et cartes restent regroupés par date pour faciliter la navigation historique.
