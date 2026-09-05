# Classement mensuel des technologies — août 2026

## Vue d’ensemble

32 nouveautés ou évolutions architecturales ont été classées à partir des radars et cartes d’août. Les simples correctifs CVE sont exclus du classement principal. Le haut du classement fait ressortir les contrats de plateforme (MCP, Kubernetes), l’isolation d’agents, l’observabilité et les standards de supply chain.

## Période et méthode

Période couverte : du **1er au 31 août 2026**. Ce premier classement rétrospectif regroupe les technologies effectivement analysées dans les radars des 27, 28, 29 et 30 août, ainsi que les cartes Elasticsearch, Agent Sandbox et MCP. Les sujets seulement repérés dans `state/signals.yaml` mais écartés ou insuffisamment documentés sont listés séparément.

Sources locales utilisées : `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml`, les quatre radars d’août et les trois cartes de service d’août. Les évolutions d’un même produit sont regroupées ; chaque technologie n’apparaît qu’une fois.

Formule cible : `30 % nouveaute_interet + 25 % impact_architectural + 20 % pertinence_stack + 15 % confiance_evidence + 10 % maturite_exploitation`. `Urgence` est affichée mais ne classe plus les nouveautés. Les dimensions normalisées n’étaient pas encore renseignées dans les signaux d’août : elles restent donc `inconnu`. `Maturité` est évaluée à partir du chemin de déploiement, de la documentation, de la maintenance, de la sécurité et de la réversibilité. La colonne `Score` est `n.c.` pour ne pas transformer silencieusement l’ancien `legacy_score` en score normalisé ; le rang est donc un jugement d’architecte fondé sur l’intérêt de nouveauté et les convergences observées. Le `legacy_score`, lorsqu’il existe, est conservé uniquement comme repère historique.

## Classement complet

| Rang | Technologie | Nature | Évolution du mois | Nouveauté | Impact | Pertinence stack | Confiance | Urgence | Maturité | Score | Tendance | Classe | Lien vers la preuve |
|---:|---|---|---|---:|---:|---:|---:|---:|---:|---|---|
| 1 | [Model Context Protocol 2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28) | standard | cœur stateless, transport et extensions formalisés | forte | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | forte | priorité nouveauté | [carte](../2026-08-29/carte-mcp.md) |
| 2 | [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) | plateforme | version, Storage Version Migration GA et RangeStream beta | forte | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | forte | priorité nouveauté | [radar](../2026-08-27/radar-architecture.md#kubernetes-137) |
| 3 | [Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox) | outil Kubernetes | CRD pour workloads d’agents singleton et persistants | forte | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | émergente | priorité nouveauté | [carte](../2026-08-28/carte-agent-sandbox.md) |
| 4 | [OpenTelemetry Collector 0.159](https://github.com/open-telemetry/opentelemetry-collector-releases) | observabilité | cadence bimensuelle et gouvernance par stabilité | forte | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | forte | priorité nouveauté | [radar](../2026-08-30/radar-architecture.md#opentelemetry-collector-0159) |
| 5 | [Cloud Native Buildpacks](https://buildpacks.io/) | standard/outillage CI | graduation CNCF, OCI Artifacts et trajectoire SBOM | forte | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | émergente | priorité nouveauté | [radar](../2026-08-30/radar-architecture.md#cloud-native-buildpacks-graduation) |
| 6 | [Kubeflow](https://www.kubeflow.org/) | plateforme IA/ML | graduation CNCF et cycle Data & AI Kubernetes | forte | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | émergente | priorité nouveauté | [radar](../2026-08-30/radar-architecture.md#kubeflow-graduation-cncf) |
| 7 | [AI Gateway](https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/) | pattern | patterns de gouvernance du trafic vers les modèles | forte | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | forte | priorité nouveauté | [radar](../2026-08-27/radar-architecture.md#ai-gateway) |
| 8 | [agentgateway 1.4](https://github.com/agentgateway/agentgateway/releases) | gateway IA | MCP 2026-07-28, OAuth exchange et contrôles LLM | forte | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | émergente | à qualifier | [radar](../2026-08-29/radar-architecture.md#agentgateway-14) |
| 9 | [kgateway 2.4](https://github.com/kgateway-dev/kgateway) | gateway Kubernetes | Gateway API, policies, backends AWS et routage de zone | forte | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | émergente | à qualifier | [radar](../2026-08-30/radar-architecture.md#kgateway-24) |
| 10 | [AgentOps et observabilité IA](https://github.com/topics/agent-observability) | pattern | traces, coûts, évaluations et actions des agents | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | forte | à qualifier | [radar](../2026-08-27/radar-architecture.md#agentops-et-observabilité-ia) |
| 11 | [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/) | standard | conventions de télémétrie pour modèles, tokens et outils | émergente | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | forte | à qualifier | [radar](../2026-08-27/radar-architecture.md#opentelemetry-genai) |
| 12 | [GitHub MCP allowlists](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/) | sécurité/gouvernance | autorisation centralisée des serveurs MCP | émergente | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | émergente | à qualifier | [radar](../2026-08-29/radar-architecture.md#gouvernance-mcp-github) |
| 13 | [Limites de cardinalité OpenTelemetry](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/) | observabilité | effets sur les ventilations de métriques | émergente | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | émergente | à qualifier | [radar](../2026-08-29/radar-architecture.md#limites-de-cardinalité-opentelemetry) |
| 14 | [Nomad 1.10](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x) | orchestrateur | identité de workload pour Vault et Consul | émergente | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | émergente | à qualifier | [radar](../2026-08-29/radar-architecture.md#nomad-110--identité-de-workload) |
| 15 | [Terraform 1.17 alpha](https://github.com/hashicorp/terraform) | IaC | évolutions de `terraform test` et `terraform query` | émergente | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | émergente | veille | [radar](../2026-08-29/radar-architecture.md#terraform-117-alpha) |
| 16 | [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/) | standard | packaging commun de skills et serveurs MCP | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | émergente | veille | [radar](../2026-08-29/radar-architecture.md#agent-plugins-10) |
| 17 | [Amazon ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/) | observabilité | détails des actions de déploiement et orchestration | émergente | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | stable | veille | [radar](../2026-08-29/radar-architecture.md#amazon-ecs-action-logs) |
| 18 | [Elasticsearch 9.5.2](https://www.elastic.co/elasticsearch) | service observabilité | carte du moteur, flux, déploiement et cycle de vie | moyenne | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | stable | à qualifier | [carte](../2026-08-27/carte-elasticsearch.md) |
| 19 | [OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack) | plateforme agents | control plane IaC pour agents cloud | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | veille | [radar](../2026-08-28/radar-architecture.md#openagentpack) |
| 20 | [Busbar](https://github.com/GetBusbar/busbar) | gateway IA | routage, budgets, failover et frontière d’exécution | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | veille | [radar](../2026-08-28/radar-architecture.md#busbar) |
| 21 | [OpenConnector](https://github.com/oomol-lab/open-connector) | gateway connecteurs | connecteurs SaaS via MCP, HTTP et OpenAPI | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | émergente | veille | [radar](../2026-08-28/radar-architecture.md#openconnector) |
| 22 | [PRAXIST](https://github.com/sapientinc/PRAXIST) | outil agents | recherche agentique mesurable et persistante | moyenne | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | signal faible | [radar](../2026-08-29/radar-architecture.md#praxist) |
| 23 | [WeMM-Embedding](https://github.com/Tencent/WeMM-Embedding) | modèle | embeddings multimodaux et retrieval | moyenne | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | signal faible | [radar](../2026-08-28/radar-architecture.md#wemm-embedding) |
| 24 | [go-modern-guidelines](https://github.com/JetBrains/go-modern-guidelines) | standard | pratiques Go destinées aux agents de code | moyenne | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | signal faible | [radar](../2026-08-28/radar-architecture.md#go-modern-guidelines) |
| 25 | [Archify](https://github.com/tt-a1i/archify) | outil architecture | génération de cartes interactives depuis code ou description | moyenne | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | signal faible | [radar](../2026-08-28/radar-architecture.md#archify) |
| 26 | [Tailcat](https://github.com/tailscale/tailcat) | outil réseau | diagnostic de type netcat sur data plane Tailscale | moyenne | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | faible | signal faible | [radar](../2026-08-28/radar-architecture.md#tailcat) |
| 27 | [Orca](https://github.com/stablyai/orca) | outil agents | exécution d’une flotte d’agents parallèles | moyenne | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | faible | signal faible | [radar](../2026-08-28/radar-architecture.md#orca) |
| 28 | [MCP Apps](https://modelcontextprotocol.io/specification/2026-07-28) | extension protocole | interface UI servie depuis un serveur MCP | émergente | inconnu | inconnu | inconnu | inconnu | 2/5 | n.c. | émergente | veille | [carte MCP](../2026-08-29/carte-mcp.md) |
| 29 | [OpenTelemetry entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/) | standard/pattern | inventaire temporel relié aux signaux d’observabilité | émergente | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | émergente | veille | [radar](../2026-08-29/radar-architecture.md#opentelemetry-entity-events) |
| 30 | [HashiCorp Support Cycle 2](https://www.hashicorp.com/en/long-term-support) | lifecycle | nouveau cycle de support postérieur à avril 2026 | moyenne | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | stable | veille | [radar](../2026-08-29/radar-architecture.md#hashicorp-support-cycle-2) |
| 31 | [Elastic Cloud Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations) | lifecycle | dépréciation d’API internes de monitoring | faible | inconnu | inconnu | inconnu | inconnu | 4/5 | n.c. | stable | veille | [radar](../2026-08-30/radar-architecture.md#elastic-cloud-serverless-dépréciation-du-monitoring-interne) |
| 32 | [Inférence cloud-native](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/) | pattern | GPU, cache, scheduling et serving Kubernetes | émergente | inconnu | inconnu | inconnu | inconnu | 3/5 | n.c. | forte | à qualifier | [radar](../2026-08-27/radar-architecture.md#inférence-cloud-native) |

## Tendances du mois

- **Standardisation de l’interface agent–outil–gateway — tendance forte.** MCP 2026-07-28, Agent Plugins 1.0, GitHub MCP allowlists, agentgateway et MCP Apps convergent sur le packaging, le routage, l’autorisation et la présentation des capacités. **Analyse :** l’agent devient une intégration gouvernée plutôt qu’un simple appel de modèle. **Limite :** les usages réels dans la stack restent inconnus.
- **Industrialisation de l’inférence sur Kubernetes — tendance forte.** Kubernetes 1.37, Agent Sandbox, Kubeflow, AI Gateway, kgateway et l’inférence cloud-native couvrent successivement runtime, isolation, cycle ML, routage et capacité. **Analyse :** le pattern de plateforme se structure en couches spécialisées. **Limite :** les projets ne forment pas une distribution cohérente et plusieurs fonctions restent beta ou émergentes.
- **Observabilité sémantique des agents — tendance forte.** AgentOps, OpenTelemetry GenAI, les limites de cardinalité, entity events et le Collector 0.159 déplacent l’attention des seules métriques vers coûts, tokens, outils, entités et stabilité des composants. **Analyse :** la qualité du signal devient une contrainte d’architecture. **Limite :** les conventions et implémentations ne sont pas toutes au même niveau de maturité.
- **Gouvernance de l’exécution et de l’egress — tendance émergente.** Agent Sandbox, Busbar, OpenAgentPack, OpenConnector et les allowlists MCP abordent isolation, budgets, connecteurs et autorisation. **Analyse :** la frontière de sécurité se déplace autour des capacités appelables par l’agent. **Limite :** les garanties annoncées ne sont pas comparables sans inventaire de versions et de menaces.
- **Supply chain et opérabilité déclaratives — tendance émergente.** Cloud Native Buildpacks, Terraform 1.17, HashiCorp Support Cycle 2 et ECS Action Logs relient artefacts, tests, lifecycle et traçabilité des changements. **Analyse :** l’architecture de plateforme inclut de plus en plus le contrat de livraison et de support. **Limite :** les changements sont de nature différente et ne prouvent pas une adoption commune.

## Lecture architecturale

1. **MCP 2026-07-28** arrive premier car il introduit plusieurs contrats nouveaux dans un même standard : stateless, transport HTTP routable, extensions et autorisation. Il est aussi relié à plusieurs signaux convergents du mois.
2. **Kubernetes 1.37** arrive deuxième parce qu’il représente une évolution de socle et alimente la tendance d’industrialisation Kubernetes de l’IA. Les fonctions beta ne doivent toutefois pas porter seules un contrôle critique.
3. **Agent Sandbox** arrive troisième : il rend concrète la frontière d’exécution des agents dans Kubernetes et relie CRD, identité, stockage, réseau et runtime. Sa nouveauté est forte, sa maturité encore émergente.
4. **OpenTelemetry Collector 0.159** arrive quatrième car la cadence et la gouvernance de stabilité rendent l’observabilité plus explicitement versionnée comme une plateforme.
5. **Cloud Native Buildpacks** arrive cinquième : la graduation et la trajectoire SBOM/OCI portent une évolution de supply chain plus structurante qu’un simple outil de build isolé.

## Par thème

- **Cloud AWS :** Amazon ECS Action Logs est le seul élément AWS retenu en août ; il renforce la reconstruction des changements opérateur dans ECS.
- **Cloud GCP :** aucun élément GCP spécifique n’a été retenu dans les livrables d’août ; le corpus est davantage orienté Kubernetes, agents et observabilité.
- **Kubernetes :** Kubernetes 1.37, Agent Sandbox, Kubeflow, kgateway et l’inférence cloud-native forment le noyau plateforme du mois.
- **Observabilité/ELK :** Elasticsearch, Elastic Cloud Serverless, OpenTelemetry Collector, GenAI, entity events et cardinality limits montrent que la collecte et sa sémantique sont des décisions d’architecture.
- **HashiCorp/IaC :** Terraform, Vault, Nomad et Support Cycle 2 couvrent respectivement validation IaC, sécurité, identité de workload et lifecycle fournisseur.
- **Sécurité :** GitHub MCP allowlists et les politiques de gateway sont les sujets classés liés au contrôle d’accès et à l’egress. Le correctif Vault CVE est hors classement principal.
- **IA/agents :** MCP, AgentOps, AI Gateway, agentgateway, Agent Plugins, OpenAgentPack, Busbar, OpenConnector, PRAXIST, WeMM-Embedding et MCP Apps convergent vers la standardisation des capacités et du routage.
- **OSS/platform engineering :** Cloud Native Buildpacks, Archify, Tailcat, Orca et go-modern-guidelines illustrent des outils de plateforme ou de développement dont la maturité est hétérogène.

## Mouvements du mois

**Première édition.** Il n’existe pas de classement mensuel précédent. Les signaux les plus structurants pour une prochaine comparaison sont MCP, Kubernetes, Agent Sandbox, OpenTelemetry Collector, Vault et Elastic Cloud Serverless. Les projets OSS à faible preuve restent dans la classe `signal faible` même lorsqu’ils ont une visibilité GitHub élevée.

## Sujets non classés

- **Vault CVE-2026-5006** : correctif de sécurité important mais sans nouveauté architecturale ; conservé ici pour mémoire, hors classement principal conformément à la nouvelle règle.
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
