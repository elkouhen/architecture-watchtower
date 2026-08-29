# IA, gateways et gouvernance MCP

| Élément | Type | Résumé | Niveau | Revue |
|---|---|---|---|---|
| Busbar | service/gateway | Routage, budgets, failover, secrets et audit pour appels IA. | émergente | [Radar 28/08](../dist/2026-08-28/radar-architecture.md#busbar) |
| WorkWeave/router | outil | Routage dynamique de modèles pour agents. | signal faible | [Radar 28/08](../dist/2026-08-28/radar-architecture.md#workweaverouter) |
| OpenConnector | service/gateway | Connecteurs SaaS gouvernés via OAuth, MCP, HTTP et OpenAPI. | traction | [Radar 28/08](../dist/2026-08-28/radar-architecture.md#openconnector) |
| agentgateway | gateway IA/MCP | Routage, autorisation, coûts et garde-fous pour agents et modèles. | émergente | [Radar 29/08](../dist/2026-08-29/radar-architecture.md#agentgateway-14) |
| AI Gateway | pattern | Gouvernance du trafic IA au niveau plateforme. | émergente | [Radar 27/08](../dist/2026-08-27/radar-architecture.md#ai-gateway) |
| Inference Gateway | pattern | Routage conscient du modèle, du GPU et de la santé d’endpoint. | émergente | [Radar 27/08](../dist/2026-08-27/radar-architecture.md#inférence-cloud-native) |
| Agent Plugins 1.0 | standard | Packaging portable de skills et serveurs MCP pour plusieurs clients. | émergente | [Radar 29/08](../dist/2026-08-29/radar-architecture.md#agent-plugins-10) |
| GitHub MCP allowlists | gouvernance/sécurité | Autorisation centralisée des serveurs MCP dans les clients Copilot. | à qualifier | [Radar 29/08](../dist/2026-08-29/radar-architecture.md#gouvernance-mcp-github) |
