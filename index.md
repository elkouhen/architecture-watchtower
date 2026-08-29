# Index des outils et patterns étudiés

Index transversal des projets, services et patterns analysés dans les radars et cartes de services. Le type distingue la nature de l’élément ; la présence dans l’index ne constitue pas une recommandation d’adoption.

## Agents et orchestration

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| JiuwenSwarm | plateforme | Orchestration multi-agents distribuée, skills, HITL et permissions. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#jiuwenswarm) |
| PRAXIST | outil | Recherche agentique persistante avec évaluation et preuves. | signal faible | [Radar 29/08](dist/2026-08-29/radar-architecture.md#praxist) |
| Hezo | plateforme | Équipe d’agents IA self-hosted. | signal faible | [Radar 29/08](dist/2026-08-29/radar-architecture.md#hezo) |
| Orca | outil | Coordination d’une flotte d’agents parallèles. | signal faible | [Radar 28/08](dist/2026-08-28/radar-architecture.md#orca) |
| OpenAgentPack | plateforme | Control plane déclaratif pour agents cloud. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#openagentpack) |
| Agent Sandbox | outil Kubernetes | CRD pour environnements d’agents isolés et persistants. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#agent-sandbox) · [Carte](dist/2026-08-28/carte-agent-sandbox.md) |

## Gateways et IA

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Busbar | service/gateway | Routage, budgets, failover, secrets et audit pour appels IA. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#busbar) |
| WorkWeave/router | outil | Routage dynamique de modèles pour agents. | signal faible | [Radar 28/08](dist/2026-08-28/radar-architecture.md#workweaverouter) |
| OpenConnector | service/gateway | Connecteurs SaaS gouvernés via OAuth, MCP, HTTP et OpenAPI. | traction | [Radar 28/08](dist/2026-08-28/radar-architecture.md#openconnector) |
| agentgateway | gateway IA/MCP | Routage, autorisation, coûts et garde-fous pour agents et modèles. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#agentgateway-14) |
| AI Gateway | pattern | Gouvernance du trafic IA au niveau plateforme. | émergente | [Radar 27/08](dist/2026-08-27/radar-architecture.md#ai-gateway) |
| Inference Gateway | pattern | Routage conscient du modèle, du GPU et de la santé d’endpoint. | émergente | [Radar 27/08](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |

## Observabilité et standards

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| AgentOps | pattern | Traces, coûts, évaluations, outils et retries des agents. | émergente | [Radar 27/08](dist/2026-08-27/radar-architecture.md#agentops-et-observabilité-ia) |
| OpenTelemetry GenAI | standard | Conventions pour modèles, tokens, outils et traces. | émergente | [Radar 27/08](dist/2026-08-27/radar-architecture.md#opentelemetry-genai) |
| Elastic / Elasticsearch | service | Recherche, observabilité et stockage de logs. | étudié | [Carte Elasticsearch](dist/2026-08-27/carte-elasticsearch.md) |
| go-modern-guidelines | standard | Règles Go utilisables comme contexte d’agents de code. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#go-modern-guidelines) |
| AgentReady standard | standard | Critères proposés de préparation d’un dépôt aux agents. | signal faible | [Radar 29/08](dist/2026-08-29/radar-architecture.md#agentready-standard) |
| OpenTelemetry entity events | standard/pattern | Événements d’entités pour un inventaire temporel relié à l’observabilité. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#opentelemetry-entity-events) |
| OpenTelemetry cardinality limits | observabilité | Limitation SDK et overflow des dimensions métriques. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#limites-de-cardinalite-opentelemetry) |

## Kubernetes et inférence

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Kubernetes 1.37 | plateforme | Release Kubernetes à qualifier selon add-ons et distributions. | mature | [Radar 27/08](dist/2026-08-27/radar-architecture.md#kubernetes-137) |
| Inférence cloud-native | pattern | GPU, scheduling, cache KV, serving et métriques TTFT/TPOT. | traction | [Radar 27/08](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| llm-d / KServe / vLLM | outils | Serving et optimisation de l’inférence Kubernetes. | traction | [Radar 27/08](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| Archify | outil | Diagrammes d’architecture dérivés du code. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#archify) |

## HashiCorp et IaC

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Terraform | outil/IaC | Tests d’infrastructure et évaluation expérimentale de policies dans Terraform 1.17 alpha. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#terraform-117-alpha) |
| HashiCorp Support Cycle 2 | lifecycle | Évolution du modèle de support des versions HashiCorp postérieures à avril 2026. | à qualifier | [Radar 29/08](dist/2026-08-29/radar-architecture.md#hashicorp-support-cycle-2) |
| Vault | service/sécurité | Correctif CVE-2026-5006 et métriques d’usage dans Vault 2.0.4. | à qualifier | [Radar 29/08](dist/2026-08-29/radar-architecture.md#vault-204-et-cve-2026-5006) |
| Nomad | orchestrateur | Identité de workload pour l’accès à Vault et Consul. | à qualifier | [Radar 29/08](dist/2026-08-29/radar-architecture.md#nomad-110-identite-de-workload) |

## Cloud et exploitation

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Amazon ECS Action Logs | service observabilité | Journal des actions du control plane ECS pendant déploiements et mises à jour. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#amazon-ecs-action-logs) |

## Gouvernance des agents

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Agent Plugins 1.0 | standard | Packaging portable de skills et serveurs MCP pour plusieurs clients. | émergente | [Radar 29/08](dist/2026-08-29/radar-architecture.md#agent-plugins-10) |
| GitHub MCP allowlists | gouvernance/sécurité | Autorisation centralisée des serveurs MCP dans les clients Copilot. | à qualifier | [Radar 29/08](dist/2026-08-29/radar-architecture.md#gouvernance-mcp-github) |

## Réseau et exploitation

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Tailcat | outil | Diagnostic réseau sur le data plane Tailscale. | signal faible | [Radar 28/08](dist/2026-08-28/radar-architecture.md#tailcat) |
| Boop | service | Inbox de notifications développeur self-hosted. | signal faible | [Radar 29/08](dist/2026-08-29/radar-architecture.md#boop) |

## Règles de maintenance

- Ajouter une entrée lorsqu’un élément est analysé dans un radar ou une carte.
- Conserver une entrée canonique par outil et compléter ses liens de revue.
- Classer par thème principal sans dupliquer inutilement l’élément.
- Ne jamais confondre présence dans l’index, maturité et recommandation d’adoption.
