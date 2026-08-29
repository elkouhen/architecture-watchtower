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

## Kubernetes et inférence

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Kubernetes 1.37 | plateforme | Release Kubernetes à qualifier selon add-ons et distributions. | mature | [Radar 27/08](dist/2026-08-27/radar-architecture.md#kubernetes-137) |
| Inférence cloud-native | pattern | GPU, scheduling, cache KV, serving et métriques TTFT/TPOT. | traction | [Radar 27/08](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| llm-d / KServe / vLLM | outils | Serving et optimisation de l’inférence Kubernetes. | traction | [Radar 27/08](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| Archify | outil | Diagrammes d’architecture dérivés du code. | émergente | [Radar 28/08](dist/2026-08-28/radar-architecture.md#archify) |

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
