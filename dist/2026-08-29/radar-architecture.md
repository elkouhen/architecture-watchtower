# Radar architecture — 2026-08-29

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Terraform](https://github.com/hashicorp/terraform) | outil/IaC | Terraform 1.17 alpha fait évoluer les tests d’infrastructure et l’évaluation de policies. | [Voir](#terraform-117-alpha) |
| [HashiCorp Support Cycle 2](https://www.hashicorp.com/en/long-term-support) | lifecycle | Le modèle de support change pour les versions HashiCorp sorties après avril 2026. | [Voir](#hashicorp-support-cycle-2) |
| [Vault](https://developer.hashicorp.com/vault/docs/updates/release-notes) | service/sécurité | Vault 2.0.4 corrige une vulnérabilité de privilèges et ajoute des métriques d’usage. | [Voir](#vault-204-et-cve-2026-5006) |
| [Nomad](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x) | orchestrateur | Nomad renforce l’identité de workload et l’observabilité opérateur. | [Voir](#nomad-110-identite-de-workload) |
| [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/) | standard | Un même paquet peut distribuer une skill et un serveur MCP à plusieurs clients agents. | [Voir](#agent-plugins-10) |
| [GitHub MCP allowlists](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/) | gouvernance | Les entreprises peuvent imposer une politique centralisée d’autorisation des serveurs MCP. | [Voir](#gouvernance-mcp-github) |
| [OpenTelemetry entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/) | standard/pattern | Les événements d’entités ouvrent une piste vers un inventaire temporel relié aux signaux d’observabilité. | [Voir](#opentelemetry-entity-events) |
| [OpenTelemetry cardinality limits](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/) | observabilité | La limite de cardinalité protège la mémoire mais peut rendre les ventilations de métriques incomplètes. | [Voir](#limites-de-cardinalite-opentelemetry) |
| [agentgateway](https://github.com/agentgateway/agentgateway/releases) | gateway IA | La version 1.4 ajoute MCP 2026-07-28, autorisation entreprise, OAuth exchange et contrôles LLM. | [Voir](#agentgateway-14) |
| [Amazon ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/) | service observabilité | ECS expose les actions détaillées de déploiement et d’orchestration. | [Voir](#amazon-ecs-action-logs) |

## [Terraform 1.17 alpha](https://github.com/hashicorp/terraform)

- **Type :** outil/IaC.
- **Pitch rapide :** la release `v1.17.0-alpha20260827` ajoute des blocs `backend` et `skip_cleanup` dans `terraform évaluation`, ainsi qu’un flag expérimental `-policies` pour `terraform query`. Cela rapproche tests, état persistant et évaluation de policies dans le flux IaC.
- **Utilité :** intéressant pour réduire les re-créations d’infrastructure pendant des suites de tests et explorer la découverte de ressources gouvernée. Ne pas utiliser l’alpha dans un pipeline critique ; comparer avec les contrôles Terraform déjà en place.
- **Outils similaires :** Terratest pour les tests en code, OpenTofu pour l’exécution IaC, Sentinel/OPA pour les policies ; aucun équivalent direct de l’ensemble alpha.

## [HashiCorp Support Cycle 2](https://www.hashicorp.com/en/long-term-support)

- **Type :** lifecycle/support.
- **Pitch rapide :** HashiCorp documente que les versions sorties après avril 2026 suivent le modèle IBM Support Cycle 2, tandis que certaines versions antérieures restent couvertes par LTS ou par un addendum de support.
- **Utilité :** ce changement influence le choix de version, les fenêtres de maintenance, les contrats de support et la trajectoire de migration pour Terraform, Vault, Consul et Nomad. Il faut séparer HCP, Enterprise et éditions communautaires.
- **Outils similaires :** politiques de support Kubernetes, lifecycle GitLab et support éditeur AWS/GCP ; la différence utile est la coexistence de HCP, Enterprise et self-managed.

## [Vault 2.0.4 et CVE-2026-5006](https://developer.hashicorp.com/vault/docs/updates/release-notes)

- **Type :** service de sécurité/secrets.
- **Pitch rapide :** Vault 2.0.4 corrige CVE-2026-5006, liée à une injection de slash dans des chemins de policies templatisés, et ajoute des métriques de registre d’agents et d’utilisation de secrets engines.
- **Utilité :** la correction est pertinente pour toute installation Vault qui utilise des identités dans des policies templatisées. Il faut identifier les versions, les chemins concernés et les logs d’accès avant de conclure à l’exposition.
- **Outils similaires :** AWS Secrets Manager, GCP Secret Manager et CyberArk ; Vault conserve un avantage de contrôle self-managed, avec davantage de charge opératoire.

## [Nomad 1.10 — identité de workload](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x)

- **Type :** orchestrateur.
- **Pitch rapide :** Nomad 1.10 retire les anciens flux de tokens pour Vault et Consul au profit de l’identité de workload ; la série 1.10 ajoute aussi l’export de journaux et des labels de node pool sur des métriques d’évaluation bloquée.
- **Utilité :** le sujet relie directement orchestration, secrets, service discovery et observabilité. Une migration exige de revoir jobspecs, rôles Vault/Consul, TTL, déploiement et rollback.
- **Outils similaires :** Kubernetes ServiceAccount projected tokens, ECS task roles et SPIFFE/SPIRE ; comparer le modèle d’identité et la charge d’intégration avec Vault.

## [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/)

- **Type :** standard/packaging agentique.
- **Pitch rapide :** Agent Plugins 1.0 permet de distribuer dans un même paquet une skill et une configuration MCP à plusieurs clients compatibles, avec un manifeste `plugin.json` et des espaces de noms spécifiques au client.
- **Utilité :** ce format peut réduire la duplication des extensions d’agents et fournir un point de gouvernance commun pour les outils d’ingénierie. Il faut contrôler marketplace, permissions, secrets et versionnement.
- **Outils similaires :** MCP directement, extensions VS Code et plugins spécifiques à chaque assistant ; le gain annoncé est la portabilité du paquet.

## [Gouvernance MCP GitHub](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/)

- **Type :** gouvernance/sécurité.
- **Pitch rapide :** les paramètres administrés permettent d’autoriser ou bloquer les serveurs MCP selon URL, commande ou nom, avec une politique fail-closed et des règles cumulatives entre niveaux.
- **Utilité :** c’est un contrôle concret sur l’accès des agents aux outils externes. Le nom seul n’est pas une frontière de sécurité ; privilégier URL canonique et commande exacte, puis journaliser les exceptions.
- **Outils similaires :** proxy egress, registre MCP interne et policy-as-code OPA ; GitHub agit ici au niveau du client agent, pas comme firewall général.

## [OpenTelemetry entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/)

- **Type :** standard/pattern d’inventaire.
- **Pitch rapide :** les entity events transportent l’état et le cycle de vie d’entités via OTLP afin de construire un graphe temporel reliant hôtes, services, interfaces et volumes aux métriques, logs et traces.
- **Utilité :** le pattern peut réduire l’écart entre observabilité comportementale et inventaire réel, notamment pour qualifier une exposition ou une dépendance. Le modèle et les conventions sont encore en développement : ne pas en faire une source d’autorité de production.
- **Outils similaires :** CMDB, service catalog Backstage et graphes de topologie propriétaires ; le pattern OTel se différencie par un transport OTLP générique.

## [Limites de cardinalité OpenTelemetry](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/)

- **Type :** observabilité.
- **Pitch rapide :** les SDK peuvent limiter les combinaisons d’attributs en mémoire ; en cas de dépassement, les totaux restent corrects mais les requêtes filtrées ou groupées peuvent sous-compter.
- **Utilité :** le sujet concerne directement SLO, alertes et coûts d’Elastic, CloudWatch ou Prometheus. Il faut surveiller `otel.metric.overflow`, revoir les attributs non bornés et dimensionner la limite selon la temporality.
- **Outils similaires :** limites de séries Prometheus, quotas de dimensions CloudWatch et règles de cardinalité côté backend ; le contrôle SDK intervient plus tôt dans le flux.

## [agentgateway 1.4](https://github.com/agentgateway/agentgateway/releases)

- **Type :** gateway IA/MCP.
- **Pitch rapide :** agentgateway 1.4 ajoute le support MCP `2026-07-28`, l’autorisation entreprise Cross App Access, l’échange de tokens OAuth, un modèle `AgentgatewayModel` expérimental et des garde-fous plus riches.
- **Utilité :** le projet matérialise une frontière d’exécution entre agents, modèles et outils : routage, identité, coûts et politiques. Le support MCP récent et les changements de CRD imposent une évaluation de compatibilité avant toute adoption.
- **Outils similaires :** Envoy AI Gateway, LiteLLM et Kong AI Gateway ; comparer protocole MCP, profondeur Kubernetes, politiques et observabilité.

## [Amazon ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/)

- **Type :** service observabilité Cloud.
- **Pitch rapide :** ECS Action Logs fournit des enregistrements horodatés des actions réalisées par ECS pendant les déploiements de services et les mises à jour de daemon.
- **Utilité :** ces événements peuvent compléter CloudTrail, métriques et logs applicatifs pour expliquer un changement de capacité ou de placement. Il faut vérifier rétention, coût, intégration SIEM et corrélation avec les traces de déploiement.
- **Outils similaires :** CloudTrail, Kubernetes Events et AWS Copilot/deployment logs ; ECS Action Logs cible plus précisément l’action d’orchestration ECS.

## Sujets écartés

- Kubernetes 1.37, Elastic Stack 9.5.2, Agent Sandbox, Busbar, OpenConnector, PRAXIST et les autres sujets des radars des 27–28/08 : déjà présents dans la fenêtre de trois mois, sans évolution substantielle retenue aujourd’hui. Les détails de sécurité et de release consultés ont été utilisés pour contrôle, pas pour répéter la fiche.
- Les signaux GitHub Trending/Trendshift sans artefact primaire ou sans impact Cloud/DevOps démontré : découverte insuffisante pour entrer dans les dix sujets.

## Sources consultées

- HashiCorp : [Terraform releases](https://github.com/hashicorp/terraform/releases), [Vault release notes](https://developer.hashicorp.com/vault/docs/updates/release-notes), [Vault HCSEC-2026-32](https://discuss.hashicorp.com/t/hcsec-2026-32-vault-vulnerable-to-privilege-escalation-via-slash-injection-in-templated-policy-paths/77678), [Nomad release notes](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x), [Workload Identity](https://developer.hashicorp.com/nomad/docs/concepts/workload-identity), [LTS](https://www.hashicorp.com/en/long-term-support).
- Kubernetes : [releases](https://kubernetes.io/releases/) et [Kubernetes 1.37](https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/) consultés pour déduplication.
- Elastic : [release notes](https://www.elastic.co/docs/release-notes) consultées pour déduplication et vérification de l’état 9.5.2.
- OpenTelemetry : [entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/) et [cardinality limits](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/).
- GitHub : [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/) et [MCP allowlists](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/).
- [agentgateway releases](https://github.com/agentgateway/agentgateway/releases) et [AWS ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/).

## Sources en échec

- Aucun échec bloquant. Les sources de découverte Trendshift et Google Trends n’ont pas été utilisées comme preuve dans cette exécution ; aucune exploration multi-termes Google Trends exploitable n’a été retenue.
