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
- **Pitch rapide :** la release `v1.17.0-alpha20260827` ajoute des blocs `backend` et `skip_cleanup` dans `terraform test`, ainsi qu’un flag expérimental `-policies` pour `terraform query`. Cela rapproche tests, état persistant et évaluation de policies dans le flux IaC.
- **Utilité :** intéressant pour réduire les re-créations d’infrastructure pendant des suites de tests et explorer la découverte de ressources gouvernée. Ne pas utiliser l’alpha dans un pipeline critique ; comparer avec les contrôles Terraform déjà en place.
- **Indicateurs de tendance (29/08/2026) :** GitHub ★49,6 k · forks 10,6 k · issues ouvertes 1,9 k · dernier push 27/08 ([métadonnées publiques](https://api.github.com/repos/hashicorp/terraform)). Visibilité/activité, pas preuve de maturité.
- **Preuves de traction :** **Fait** : release primaire datée du 27/08/2026 et Terraform 1.16.0 publié dans le même flux ([release GitHub](https://github.com/hashicorp/terraform/releases)). **Analyse** : le changement vise la boucle test/policy plutôt qu’un simple ajout de provider. **Inférence** : il peut simplifier des tests d’intégration coûteux, mais la stabilité et le contrat des flags restent à qualifier. **Décision proposée** : surveiller ; propriétaire IaC ; réexamen 05/09/2026.
- **Outils similaires :** Terratest pour les tests en code, OpenTofu pour l’exécution IaC, Sentinel/OPA pour les policies ; aucun équivalent direct de l’ensemble alpha.

## [HashiCorp Support Cycle 2](https://www.hashicorp.com/en/long-term-support)

- **Type :** lifecycle/support.
- **Pitch rapide :** HashiCorp documente que les versions sorties après avril 2026 suivent le modèle IBM Support Cycle 2, tandis que certaines versions antérieures restent couvertes par LTS ou par un addendum de support.
- **Utilité :** ce changement influence le choix de version, les fenêtres de maintenance, les contrats de support et la trajectoire de migration pour Terraform, Vault, Consul et Nomad. Il faut séparer HCP, Enterprise et éditions communautaires.
- **Indicateurs de tendance (29/08/2026) :** N/A — signal de lifecycle fournisseur, sans dépôt unique ni compteur pertinent ; source officielle [HashiCorp LTS](https://www.hashicorp.com/en/long-term-support).
- **Preuves de traction :** **Fait** : la page officielle distingue les versions antérieures à mars 2025, celles de mars 2025 à avril 2026 et celles postérieures à avril 2026 ([politique LTS](https://www.hashicorp.com/en/long-term-support)). **Analyse** : la version n’est plus seulement un choix fonctionnel, mais aussi un choix de cycle de support. **Inférence** : un inventaire fournisseur/version devient nécessaire avant une consolidation HashiCorp. **Décision proposée** : qualifier ; propriétaire plateforme/IaC ; réexamen 12/09/2026.
- **Outils similaires :** politiques de support Kubernetes, lifecycle GitLab et support éditeur AWS/GCP ; la différence utile est la coexistence de HCP, Enterprise et self-managed.

## [Vault 2.0.4 et CVE-2026-5006](https://developer.hashicorp.com/vault/docs/updates/release-notes)

- **Type :** service de sécurité/secrets.
- **Pitch rapide :** Vault 2.0.4 corrige CVE-2026-5006, liée à une injection de slash dans des chemins de policies templatisés, et ajoute des métriques de registre d’agents et d’utilisation de secrets engines.
- **Utilité :** la correction est pertinente pour toute installation Vault qui utilise des identités dans des policies templatisées. Il faut identifier les versions, les chemins concernés et les logs d’accès avant de conclure à l’exposition.
- **Indicateurs de tendance (29/08/2026) :** GitHub ★36,2 k · forks 4,7 k · issues ouvertes 1,4 k · dernier push 28/08 ([métadonnées publiques](https://api.github.com/repos/hashicorp/vault)). Indicateur de visibilité, distinct du risque CVE.
- **Preuves de traction :** **Fait** : l’avis HashiCorp du 24/08 indique que les versions jusqu’à 2.0.3 sont affectées et que les correctifs sont 2.0.4, 1.21.9, 1.20.14 et 1.19.20 ([HCSEC-2026-32](https://discuss.hashicorp.com/t/hcsec-2026-32-vault-vulnerable-to-privilege-escalation-via-slash-injection-in-templated-policy-paths/77678)). **Fait** : les release notes décrivent aussi des guardrails SCIM et métriques d’usage ([Vault 2.x](https://developer.hashicorp.com/vault/docs/updates/release-notes)). **Décision proposée** : qualifier immédiatement ; propriétaire sécurité/plateforme ; échéance 05/09/2026.
- **Outils similaires :** AWS Secrets Manager, GCP Secret Manager et CyberArk ; Vault conserve un avantage de contrôle self-managed, avec davantage de charge opératoire.

## [Nomad 1.10 — identité de workload](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x)

- **Type :** orchestrateur.
- **Pitch rapide :** Nomad 1.10 retire les anciens flux de tokens pour Vault et Consul au profit de l’identité de workload ; la série 1.10 ajoute aussi l’export de journaux et des labels de node pool sur des métriques d’évaluation bloquée.
- **Utilité :** le sujet relie directement orchestration, secrets, service discovery et observabilité. Une migration exige de revoir jobspecs, rôles Vault/Consul, TTL, déploiement et rollback.
- **Indicateurs de tendance (29/08/2026) :** GitHub ★16,8 k · forks 2,1 k · issues ouvertes 1,6 k · dernier push 28/08 ([métadonnées publiques](https://api.github.com/repos/hashicorp/nomad)). Activité élevée, adoption réelle à qualifier.
- **Preuves de traction :** **Fait** : les release notes détaillent la suppression des workflows de tokens et la migration vers Workload Identity ([Nomad 1.10](https://developer.hashicorp.com/nomad/docs/release-notes/v1-10-x)). **Fait** : la documentation décrit le JWT signé, les claims et les identités par tâche ([Workload Identity](https://developer.hashicorp.com/nomad/docs/concepts/workload-identity)). **Décision proposée** : qualifier ; propriétaire plateforme ; réexamen 12/09/2026.
- **Outils similaires :** Kubernetes ServiceAccount projected tokens, ECS task roles et SPIFFE/SPIRE ; comparer le modèle d’identité et la charge d’intégration avec Vault.

## [Agent Plugins 1.0](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/)

- **Type :** standard/packaging agentique.
- **Pitch rapide :** Agent Plugins 1.0 permet de distribuer dans un même paquet une skill et une configuration MCP à plusieurs clients compatibles, avec un manifeste `plugin.json` et des espaces de noms spécifiques au client.
- **Utilité :** ce format peut réduire la duplication des extensions d’agents et fournir un point de gouvernance commun pour les outils d’ingénierie. Il faut contrôler marketplace, permissions, secrets et versionnement.
- **Indicateurs de tendance (29/08/2026) :** N/A — standard publié via le changelog GitHub ; pas de dépôt canonique unique ni compteur applicable.
- **Preuves de traction :** **Fait** : support généralement disponible dans VS Code, Copilot CLI, SDK et application Copilot ([annonce GitHub](https://github.blog/changelog/2026-08-12-agent-plugins-1-0-in-vs-code-copilot-cli-and-the-copilot-app/)). **Analyse** : le packaging devient une frontière de distribution et de politique, pas seulement un dossier de configuration. **Inférence** : un dépôt de plugins approuvés pourrait devenir un composant de plateforme interne. **Décision proposée** : surveiller ; propriétaire architecture/engineering ; réexamen 12/09/2026.
- **Outils similaires :** MCP directement, extensions VS Code et plugins spécifiques à chaque assistant ; le gain annoncé est la portabilité du paquet.

## [Gouvernance MCP GitHub](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/)

- **Type :** gouvernance/sécurité.
- **Pitch rapide :** les paramètres administrés permettent d’autoriser ou bloquer les serveurs MCP selon URL, commande ou nom, avec une politique fail-closed et des règles cumulatives entre niveaux.
- **Utilité :** c’est un contrôle concret sur l’accès des agents aux outils externes. Le nom seul n’est pas une frontière de sécurité ; privilégier URL canonique et commande exacte, puis journaliser les exceptions.
- **Indicateurs de tendance (29/08/2026) :** N/A — fonctionnalité produit GitHub, mesurée par disponibilité officielle plutôt que par étoiles.
- **Preuves de traction :** **Fait** : la fonctionnalité est annoncée comme généralement disponible le 06/08/2026 et s’applique à l’application Copilot, CLI et VS Code ([changelog GitHub](https://github.blog/changelog/2026-08-06-mcp-allowlists-in-enterprise-managed-settings/)). **Décision proposée** : qualifier l’écart entre cette politique et les contrôles actuels ; propriétaire sécurité/engineering ; réexamen 05/09/2026.
- **Outils similaires :** proxy egress, registre MCP interne et policy-as-code OPA ; GitHub agit ici au niveau du client agent, pas comme firewall général.

## [OpenTelemetry entity events](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/)

- **Type :** standard/pattern d’inventaire.
- **Pitch rapide :** les entity events transportent l’état et le cycle de vie d’entités via OTLP afin de construire un graphe temporel reliant hôtes, services, interfaces et volumes aux métriques, logs et traces.
- **Utilité :** le pattern peut réduire l’écart entre observabilité comportementale et inventaire réel, notamment pour qualifier une exposition ou une dépendance. Le modèle et les conventions sont encore en développement : ne pas en faire une source d’autorité de production.
- **Indicateurs de tendance (29/08/2026) :** OpenTelemetry Collector ★7,5 k · forks 2,2 k · dernier push 28/08 ([métadonnées publiques](https://api.github.com/repos/open-telemetry/opentelemetry-collector)). Proxy de visibilité du projet, pas mesure d’adoption du modèle entity events.
- **Preuves de traction :** **Fait** : l’article OpenTelemetry du 14/08/2026 décrit un flux event-sourced, bi-temporel, et précise que le modèle n’est pas encore stable ([article officiel](https://opentelemetry.io/blog/2026/consuming-opentelemetry-entity-events/)). **Analyse** : l’identité et l’historique deviennent des primitives d’observabilité. **Décision proposée** : surveiller ; propriétaire observabilité ; réexamen 30/09/2026.
- **Outils similaires :** CMDB, service catalog Backstage et graphes de topologie propriétaires ; le pattern OTel se différencie par un transport OTLP générique.

## [Limites de cardinalité OpenTelemetry](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/)

- **Type :** observabilité.
- **Pitch rapide :** les SDK peuvent limiter les combinaisons d’attributs en mémoire ; en cas de dépassement, les totaux restent corrects mais les requêtes filtrées ou groupées peuvent sous-compter.
- **Utilité :** le sujet concerne directement SLO, alertes et coûts d’Elastic, CloudWatch ou Prometheus. Il faut surveiller `otel.metric.overflow`, revoir les attributs non bornés et dimensionner la limite selon la temporality.
- **Indicateurs de tendance (29/08/2026) :** OpenTelemetry Collector ★7,5 k · forks 2,2 k · dernier push 28/08 ([métadonnées publiques](https://api.github.com/repos/open-telemetry/opentelemetry-collector)). Proxy de visibilité ; le guide reste une source opérationnelle récente.
- **Preuves de traction :** **Fait** : le guide officiel du 06/08/2026 indique une limite par défaut de 2 000 combinaisons et décrit le point de donnée overflow ([guide OpenTelemetry](https://opentelemetry.io/blog/2026/cardinality-limits-in-opentelemetry/)). **Analyse** : une métrique peut conserver son total tout en perdant sa fiabilité par dimension. **Inférence** : l’overflow doit devenir une alerte de qualité de données dans la plateforme. **Décision proposée** : qualifier ; propriétaire observabilité ; échéance 12/09/2026.
- **Outils similaires :** limites de séries Prometheus, quotas de dimensions CloudWatch et règles de cardinalité côté backend ; le contrôle SDK intervient plus tôt dans le flux.

## [agentgateway 1.4](https://github.com/agentgateway/agentgateway/releases)

- **Type :** gateway IA/MCP.
- **Pitch rapide :** agentgateway 1.4 ajoute le support MCP `2026-07-28`, l’autorisation entreprise Cross App Access, l’échange de tokens OAuth, un modèle `AgentgatewayModel` expérimental et des garde-fous plus riches.
- **Utilité :** le projet matérialise une frontière d’exécution entre agents, modèles et outils : routage, identité, coûts et politiques. Le support MCP récent et les changements de CRD imposent un test de compatibilité avant toute adoption.
- **Indicateurs de tendance (29/08/2026) :** GitHub ★4,6 k · forks 780 · issues ouvertes 257 · dernier push 27/08 ([métadonnées publiques](https://api.github.com/repos/agentgateway/agentgateway)). Release v1.4 publiée le 27/07.
- **Preuves de traction :** **Fait** : release v1.4.0 du 27/07/2026, avec chart Helm standalone, Gateway API v1.6 et correction d’un avis de sécurité MCP ([release primaire](https://github.com/agentgateway/agentgateway/releases)). **Fait** : la release documente aussi coût/token, routage virtuel et failover. **Décision proposée** : surveiller puis qualifier ; propriétaire IA/plateforme ; réexamen 12/09/2026.
- **Outils similaires :** Envoy AI Gateway, LiteLLM et Kong AI Gateway ; comparer protocole MCP, profondeur Kubernetes, politiques et observabilité.

## [Amazon ECS Action Logs](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/)

- **Type :** service observabilité Cloud.
- **Pitch rapide :** ECS Action Logs fournit des enregistrements horodatés des actions réalisées par ECS pendant les déploiements de services et les mises à jour de daemon.
- **Utilité :** ces événements peuvent compléter CloudTrail, métriques et logs applicatifs pour expliquer un changement de capacité ou de placement. Il faut vérifier rétention, coût, intégration SIEM et corrélation avec les traces de déploiement.
- **Indicateurs de tendance (29/08/2026) :** N/A — fonctionnalité de service AWS, sans dépôt public canonique ; signal principal : annonce officielle du 21/07/2026.
- **Preuves de traction :** **Fait** : AWS annonce la fonctionnalité le 21/07/2026, disponible dans toutes les régions AWS, y compris GovCloud ([annonce AWS](https://aws.amazon.com/about-aws/whats-new/2026/07/amazon-ecs-action-logs/)). **Analyse** : la visibilité des actions du control plane devient une donnée d’exploitation distincte des logs de workload. **Décision proposée** : surveiller ; propriétaire Cloud/observabilité ; réexamen 30/09/2026.
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
