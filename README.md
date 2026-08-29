# Architecture Watchtower

Veille locale en français pour l’architecture Cloud/DevOps, l’observabilité, la sécurité, l’IA appliquée et l’écosystème HashiCorp.

## Navigation

- [Agents et orchestration](docs/agents.md)
- [IA, gateways et gouvernance MCP](docs/ia-gateways.md)
- [Observabilité et standards](docs/observability.md)
- [HashiCorp et Cloud](docs/hashicorp-cloud.md)
- [Kubernetes, inférence et réseau](docs/kubernetes-reseau.md)

## Livrables

- Radar quotidien : `dist/YYYY-MM-DD/radar-architecture.md`
- Carte de service : `dist/YYYY-MM-DD/carte-<service>.md`
- Registre des signaux : [`state/signals.yaml`](state/signals.yaml)
- Registre des sources : [`state/sources.yaml`](state/sources.yaml)
- Progression d’apprentissage : [`state/learning.yaml`](state/learning.yaml)
- PRD : [`PRD.md`](PRD.md)

## Principes

- Les sources primaires confirment les faits ; les tendances servent à découvrir.
- Les indicateurs GitHub ou de recherche sont datés et ne prouvent ni maturité ni adoption.
- La déduplication du radar porte sur les trois derniers mois.
- L’exposition réelle reste `à qualifier` tant que l’inventaire n’est pas établi.
- La preuve de publication est un commit Git local.

L’index détaillé est réparti dans les pages thématiques ci-dessus pour conserver une page d’accueil lisible.
