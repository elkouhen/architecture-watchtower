# Index des outils et patterns étudiés

Index transversal des projets, services et patterns examinés dans les radars et cartes de services. Les entrées sont classées par thème ; le niveau indique le niveau d’intérêt ou de maturité observé au moment de la revue.

## Agents, orchestration et workflows IA

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| JiuwenSwarm | Orchestration multi-agents distribuée, skills, HITL et permissions d’outils. | émergente | [Radar du 29/08/2026](dist/2026-08-29/radar-architecture.md#jiuwenswarm) |
| PRAXIST | Boucle de recherche agentique persistante avec évaluation et preuves. | signal faible | [Radar du 29/08/2026](dist/2026-08-29/radar-architecture.md#praxist) |
| Hezo | Pattern d’équipe d’agents IA self-hosted. | signal faible | [Radar du 29/08/2026](dist/2026-08-29/radar-architecture.md#hezo) |
| Orca | Exécution et coordination d’une flotte d’agents parallèles. | signal faible | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#orca) |
| OpenAgentPack | Control plane déclaratif pour agents cloud. | émergente | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#openagentpack) |
| Agent Sandbox | CRD Kubernetes pour environnements d’agents isolés et persistants. | émergente | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#agent-sandbox) · [Carte de service](dist/2026-08-28/carte-agent-sandbox.md) |

## Gateways, modèles et intégration IA

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| Busbar | Gateway IA self-hosted pour routage, budgets, failover, secrets et audit. | émergente | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#busbar) |
| WorkWeave/router | Routage dynamique de modèles pour systèmes agentiques. | signal faible | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#workweaverouter) |
| OpenConnector | Gateway de connecteurs SaaS avec OAuth, scopes, MCP, HTTP et OpenAPI. | traction | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#openconnector) |
| AI Gateway | Pattern de gouvernance du trafic IA au niveau plateforme. | émergente | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#ai-gateway) |
| Inference Gateway | Routage conscient du modèle, du GPU et de la santé d’endpoint. | émergente | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |

## Observabilité et évaluation

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| AgentOps | Traces, coûts, évaluations, outils et retries des agents. | émergente | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#agentops-et-observabilité-ia) |
| OpenTelemetry GenAI | Conventions communes pour instrumenter modèles, tokens, outils et traces. | émergente | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#opentelemetry-genai) |
| Elastic / Elasticsearch | Recherche, observabilité et stockage de logs dans la stack cible. | étudié | [Carte Elasticsearch](dist/2026-08-27/carte-elasticsearch.md) |

## Kubernetes, plateforme et inférence

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| Kubernetes 1.37 | Release de plateforme à qualifier selon les add-ons et distributions. | mature | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#kubernetes-137) |
| Inférence cloud-native | GPU, scheduling, cache KV, serving et métriques TTFT/TPOT. | traction | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| llm-d / KServe / vLLM | Écosystème de serving et d’optimisation de l’inférence Kubernetes. | traction | [Radar du 27/08/2026](dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |

## Architecture et ingénierie logicielle

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| Archify | Génération de diagrammes d’architecture dérivés du code. | émergente | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#archify) |
| go-modern-guidelines | Contexte de règles Go pour les agents de code. | émergente | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#go-modern-guidelines) |
| AgentReady standard | Standard proposé pour évaluer la préparation d’un dépôt aux agents. | signal faible | [Radar du 29/08/2026](dist/2026-08-29/radar-architecture.md#agentready-standard) |

## Réseau et exploitation

| Outil ou pattern | Ce qu’il faut retenir | Niveau | Revue |
|---|---|---|---|
| Tailcat | Diagnostic réseau de type netcat sur le data plane Tailscale. | signal faible | [Radar du 28/08/2026](dist/2026-08-28/radar-architecture.md#tailcat) |
| Boop | Inbox de notifications développeur self-hosted. | signal faible | [Radar du 29/08/2026](dist/2026-08-29/radar-architecture.md#boop) |

## Règles de maintenance

- Ajouter une entrée lorsqu’un outil ou pattern fait l’objet d’une analyse dans un radar ou d’une carte de service.
- Conserver une seule entrée canonique par outil ; ajouter les nouveaux liens de revue à la même ligne.
- Utiliser un thème principal et, si nécessaire, un second thème dans la description plutôt que dupliquer l’entrée.
- Ne pas confondre présence dans l’index et recommandation d’adoption : le niveau et la revue font foi.
