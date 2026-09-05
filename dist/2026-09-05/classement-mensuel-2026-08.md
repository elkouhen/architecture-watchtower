# Classement mensuel des technologies — août 2026

## Vue d’ensemble

33 technologies ont été classées à partir des radars et cartes d’août. Le haut du classement est dominé par la sécurité et le lifecycle (Vault, Elastic), puis par les contrats de plateforme (MCP, Kubernetes) et l’isolation d’agents (Agent Sandbox).

## Période et méthode

Période couverte : du **1er au 31 août 2026**. Ce premier classement rétrospectif regroupe les technologies effectivement analysées dans les radars des 27, 28, 29 et 30 août, ainsi que les cartes Elasticsearch, Agent Sandbox et MCP. Les sujets seulement repérés dans `state/signals.yaml` mais écartés ou insuffisamment documentés sont listés séparément.

Sources locales utilisées : `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml`, les quatre radars d’août et les trois cartes de service d’août. Les évolutions d’un même produit sont regroupées ; chaque technologie n’apparaît qu’une fois.

Formule cible : `30 % impact_architectural + 25 % pertinence_stack + 20 % confiance_evidence + 15 % urgence + 10 % maturite_exploitation`. Les quatre premières dimensions n’étaient pas encore renseignées dans les signaux d’août : elles restent donc `inconnu`. `Maturité` est évaluée à partir du chemin de déploiement, de la documentation, de la maintenance, de la sécurité et de la réversibilité. La colonne `Score` est `n.c.` pour ne pas transformer silencieusement l’ancien `legacy_score` en score normalisé ; le rang est donc un jugement d’architecte fondé sur l’impact documenté, l’urgence et la qualité des preuves. Le `legacy_score`, lorsqu’il existe, est conservé comme repère historique entre parenthèses.

## Classement complet

| Rang | Technologie | Nature | Évolution du mois | Impact | Pertinence stack | Confiance | Urgence | Maturité | Score | Classe | Lien vers la preuve |
|---:|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| 1 | [Vault 2.0.4 / CVE-2026-5006](https://developer.hashicorp.com/vault/docs/updates/release-notes) | incident/sécurité | correctif de privilèges | inconnu | inconnu | inconnu | inconnu | 5/5 | n.c. (8) | priorité architecture | [radar](../2026-08-29/radar-architecture.md#vault-204-et-cve-2026-5006) |
| 2 | [Elastic Cloud Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations) | lifecycle | dépréciation d’API internes de monitoring | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (8) | priorité architecture | [radar](../2026-08-30/radar-architecture.md#elastic-cloud-serverless-dépréciation-du-monitoring-interne) |
| 3 | [Model Context Protocol 2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28) | standard | cœur stateless, transport et extensions formalisés | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (8) | priorité architecture | [carte](../2026-08-29/carte-mcp.md) |
| 4 | [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) | plateforme | version, Storage Version Migration GA et RangeStream beta | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (8) | priorité architecture | [radar](../2026-08-27/radar-architecture.md#kubernetes-137) |
| 5 | [Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox) | outil Kubernetes | CRD pour workloads d’agents singleton et persistants | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (8) | priorité architecture | [carte](../2026-08-28/carte-agent-sandbox.md) |
| 6 | [OpenTelemetry Collector 0.159](https://github.com/open-telemetry/opentelemetry-collector-releases) | observabilité | cadence bimensuelle et gouvernance par stabilité | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-30/radar-architecture.md#opentelemetry-collector-0159) |
| 7 | [Cloud Native Buildpacks](https://buildpacks.io/) | standard/outillage CI | graduation CNCF, OCI Artifacts et trajectoire SBOM | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-30/radar-architecture.md#cloud-native-buildpacks-graduation) |
| 8 | [Kubeflow](https://www.kubeflow.org/) | plateforme IA/ML | graduation CNCF et cycle Data & AI Kubernetes | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-30/radar-architecture.md#kubeflow-graduation-cncf) |
| 9 | [AI Gateway](https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/) | pattern | patterns de gouvernance du trafic vers les modèles | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | à qualifier | [radar](../2026-08-27/radar-architecture.md#ai-gateway) |
| 10 | [agentgateway 1.4](https://github.com/agentgateway/agentgateway/releases) | gateway IA | MCP 2026-07-28, OAuth exchange et contrôles LLM | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (7) | à qualifier | [radar](../2026-08-29/radar-architecture.md#agentgateway-14) |
| 11 | [kgateway 2.4](https://github.com/kgateway-dev/kgateway) | gateway Kubernetes | Gateway API, policies, backends AWS et routage de zone | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (7) | à qualifier | [radar](../2026-08-30/radar-architecture.md#kgateway-24) |
| 12 | [AgentOps et observabilité IA](https://github.com/topics/agent-observability) | pattern | traces, coûts, évaluations et actions des agents | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | à qualifier | [radar](../2026-08-27/radar-architecture.md#agentops-et-observabilité-ia) |
| 13 | [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/) | standard | conventions de télémétrie pour modèles, tokens et outils | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (7) | à qualifier | [radar](../2026-08-27/radar-architecture.md#opentelemetry-genai) |
| 14 | [Limites de cardinalité OpenTelemetry](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/) | observabilité | effets sur les ventilations de métriques | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-29/radar-architecture.md#limites-de-cardinalité-opentelemetry) |
| 15 | [GitHub MCP allowlists](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/) | sécurité/gouvernance | autorisation centralisée des serveurs MCP | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-29/radar-architecture.md#gouvernance-mcp-github) |
| 16 | [Nomad 1.10](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x) | orchestrateur | identité de workload pour Vault et Consul | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | à qualifier | [radar](../2026-08-29/radar-architecture.md#nomad-110--identité-de-workload) |
| 17 | [Terraform 1.17 alpha](https://github.com/hashicorp/terraform) | IaC | évolutions de `terraform test` et `terraform query` | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (8) | veille | [radar](../2026-08-29/radar-architecture.md#terraform-117-alpha) |
| 18 | [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/) | standard | packaging commun de skills et serveurs MCP | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | veille | [radar](../2026-08-29/radar-architecture.md#agent-plugins-10) |
| 19 | [Amazon ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/) | observabilité | détails des actions de déploiement et orchestration | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (7) | veille | [radar](../2026-08-29/radar-architecture.md#amazon-ecs-action-logs) |
| 20 | [Elasticsearch 9.5.2](https://www.elastic.co/elasticsearch) | service observabilité | carte du moteur, flux, déploiement et cycle de vie | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | à qualifier | [carte](../2026-08-27/carte-elasticsearch.md) |
| 21 | [OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack) | plateforme agents | control plane IaC pour agents cloud | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | veille | [radar](../2026-08-28/radar-architecture.md#openagentpack) |
| 22 | [Busbar](https://github.com/GetBusbar/busbar) | gateway IA | routage, budgets, failover et frontière d’exécution | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | veille | [radar](../2026-08-28/radar-architecture.md#busbar) |
| 23 | [OpenConnector](https://github.com/oomol-lab/open-connector) | gateway connecteurs | connecteurs SaaS via MCP, HTTP et OpenAPI | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (7) | veille | [radar](../2026-08-28/radar-architecture.md#openconnector) |
| 24 | [PRAXIST](https://github.com/sapientinc/PRAXIST) | outil agents | recherche agentique mesurable et persistante | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (6) | signal faible | [radar](../2026-08-29/radar-architecture.md#praxist) |
| 25 | [WeMM-Embedding](https://github.com/Tencent/WeMM-Embedding) | modèle | embeddings multimodaux et retrieval | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (6) | signal faible | [radar](../2026-08-28/radar-architecture.md#wemm-embedding) |
| 26 | [go-modern-guidelines](https://github.com/JetBrains/go-modern-guidelines) | standard | pratiques Go destinées aux agents de code | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (6) | signal faible | [radar](../2026-08-28/radar-architecture.md#go-modern-guidelines) |
| 27 | [Archify](https://github.com/tt-a1i/archify) | outil architecture | génération de cartes interactives depuis code ou description | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. (6) | signal faible | [radar](../2026-08-28/radar-architecture.md#archify) |
| 28 | [Tailcat](https://github.com/tailscale/tailcat) | outil réseau | diagnostic de type netcat sur data plane Tailscale | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (6) | signal faible | [radar](../2026-08-28/radar-architecture.md#tailcat) |
| 29 | [Orca](https://github.com/stablyai/orca) | outil agents | exécution d’une flotte d’agents parallèles | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | signal faible | [radar](../2026-08-28/radar-architecture.md#orca) |
| 30 | [MCP Apps](https://modelcontextprotocol.io/specification/2026-07-28) | extension protocole | interface UI servie depuis un serveur MCP | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | signal faible | [carte MCP](../2026-08-29/carte-mcp.md) |
| 31 | [OpenTelemetry entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/) | standard/pattern | inventaire temporel relié aux signaux d’observabilité | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (7) | veille | [radar](../2026-08-29/radar-architecture.md#opentelemetry-entity-events) |
| 32 | [HashiCorp Support Cycle 2](https://www.hashicorp.com/en/long-term-support) | lifecycle | nouveau cycle de support postérieur à avril 2026 | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. (8) | à qualifier | [radar](../2026-08-29/radar-architecture.md#hashicorp-support-cycle-2) |
| 33 | [Inférence cloud-native](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/) | pattern | GPU, cache, scheduling et serving Kubernetes | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. (7) | à qualifier | [radar](../2026-08-27/radar-architecture.md#inférence-cloud-native) |

## Lecture architecturale

1. **Vault CVE-2026-5006** arrive premier car un incident de sécurité et une condition d’exposition inconnue priment sur la popularité ou la nouveauté. Le rang reflète la nécessité de relier le correctif aux versions réellement déployées, pas une preuve d’exposition.
2. **Elastic Cloud Serverless** arrive deuxième : une dépréciation d’API internes peut casser l’observabilité sans changement applicatif visible. La présence d’Elastic dans la stack étudiée rend la qualification du mode d’intégration plus importante qu’un simple signal de tendance.
3. **MCP 2026-07-28** arrive troisième parce qu’il modifie le contrat entre agents, clients, gateways et serveurs : stateless, transport HTTP routable, extensions et autorisation. Sa portée est transversale, mais l’usage réel dans la stack reste à qualifier.
4. **Kubernetes 1.37** arrive quatrième : version de plateforme, migration de stockage et évolutions d’API touchent directement le cycle de vie des clusters. Les fonctions beta ne doivent pas porter seules un contrôle critique.
5. **Agent Sandbox** arrive cinquième : il matérialise la frontière d’exécution des agents dans Kubernetes et relie CRD, identité, stockage, réseau et runtime. Sa maturité et son niveau d’isolation restent plus incertains que ceux de Kubernetes lui-même.

## Par thème

- **Cloud AWS :** Amazon ECS Action Logs est le seul élément AWS retenu en août ; il renforce la reconstruction des changements opérateur dans ECS.
- **Cloud GCP :** aucun élément GCP spécifique n’a été retenu dans les livrables d’août ; le corpus est davantage orienté Kubernetes, agents et observabilité.
- **Kubernetes :** Kubernetes 1.37, Agent Sandbox, Kubeflow, kgateway et l’inférence cloud-native forment le noyau plateforme du mois.
- **Observabilité/ELK :** Elasticsearch, Elastic Cloud Serverless, OpenTelemetry Collector, GenAI, entity events et cardinality limits montrent que la collecte et sa sémantique sont des décisions d’architecture.
- **HashiCorp/IaC :** Terraform, Vault, Nomad et Support Cycle 2 couvrent respectivement validation IaC, sécurité, identité de workload et lifecycle fournisseur.
- **Sécurité :** Vault CVE, GitHub MCP allowlists et les politiques de gateway sont les sujets les plus directement liés au contrôle d’accès et à l’egress.
- **IA/agents :** MCP, AgentOps, AI Gateway, agentgateway, Agent Plugins, OpenAgentPack, Busbar, OpenConnector, PRAXIST, WeMM-Embedding et MCP Apps convergent vers la standardisation des capacités et du routage.
- **OSS/platform engineering :** Cloud Native Buildpacks, Archify, Tailcat, Orca et go-modern-guidelines illustrent des outils de plateforme ou de développement dont la maturité est hétérogène.

## Mouvements du mois

**Première édition.** Il n’existe pas de classement mensuel précédent. Les signaux les plus structurants pour une prochaine comparaison sont MCP, Kubernetes, Agent Sandbox, OpenTelemetry Collector, Vault et Elastic Cloud Serverless. Les projets OSS à faible preuve restent dans la classe `signal faible` même lorsqu’ils ont une visibilité GitHub élevée.

## Sujets non classés

- **Hermes Agent** et **Stately Agent** : signaux locaux repérés mais non retenus dans un radar complet avec preuve d’utilité architecturale suffisante.
- **JiuwenSwarm** : signal de tendance issu de Trendshift ; absence de qualification primaire et opérationnelle dans le livrable d’août.
- **Boop** : projet de notifications développeur intéressant mais périphérique au périmètre Cloud, DevOps, architecture et IA retenu ce mois-là.
- **Hezo** et **AgentReady** : signaux faibles écartés du suivi actif ; maturité et preuves insuffisantes.
- **WorkWeave/router** : motif d’écart documenté dans le radar et le registre ; le sujet reste une idée de pattern, pas une technologie classable sur preuve suffisante.
- Les incidents et évolutions d’Elastic, Kubernetes et MCP sont regroupés par technologie ; aucune ligne supplémentaire n’est créée pour les doublons de signal ou de carte.

## Sujets écartés

Les sujets non classés ci-dessus sont écartés du classement chiffré faute de preuve primaire ou d’analyse architecturale suffisante dans les livrables d’août. Ils restent distincts des technologies classées avec la mention `signal faible`.

## Sources consultées

Les sources primaires sont celles référencées dans les rapports locaux : Kubernetes, Elastic, OpenTelemetry, HashiCorp, MCP, CNCF, GitHub, AWS et les dépôts des projets étudiés. Les sources de découverte Trendshift et GitHub Trending n’ont pas été utilisées seules pour classer une technologie.

## Sources en échec

Aucun échec de source n’est enregistré dans les livrables locaux d’août. L’exposition réelle de la stack et la disponibilité régionale de certains services restent toutefois inconnues.

## Sources et limites

Rapports locaux utilisés : [radar du 27/08](../2026-08-27/radar-architecture.md), [radar du 28/08](../2026-08-28/radar-architecture.md), [radar du 29/08](../2026-08-29/radar-architecture.md), [radar du 30/08](../2026-08-30/radar-architecture.md), [carte Elasticsearch](../2026-08-27/carte-elasticsearch.md), [carte Agent Sandbox](../2026-08-28/carte-agent-sandbox.md) et [carte MCP](../2026-08-29/carte-mcp.md).

Les preuves primaires importantes sont les documentations et dépôts Kubernetes, HashiCorp, Elastic, OpenTelemetry, GitHub, MCP, CNCF, AWS et les projets OSS référencés directement dans les livrables. Les signaux de GitHub Trending ou Trendshift ont servi à découvrir des projets, jamais à conclure seuls à leur maturité.

Limites : les environnements réellement déployés restent inconnus ; les quatre dimensions normalisées n’existaient pas encore dans les signaux d’août ; les métriques de popularité sont des observations datées et ne prouvent ni adoption ni sécurité ; plusieurs projets étaient alpha, beta ou émergents. Aucun POC, laboratoire ou échéance d’adoption n’est déduit de ce classement.
