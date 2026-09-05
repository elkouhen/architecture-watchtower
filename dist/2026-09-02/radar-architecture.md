# Radar architecture — 2026-09-02

## Vue d’ensemble

Déduplication appliquée sur `state/signals.yaml` et les rapports des 90 derniers jours. Six sujets sont retenus : **trois nouveautés** et **trois mises à jour**. L’exposition réelle de la stack de l'utilisateur reste `à qualifier`.

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Cloudflare Computer](https://blog.cloudflare.com/cloudflare-computer/) | nouveau · plateforme | Runtime de travail pour agents, combinant isolate, sandbox et navigateur. | [Voir](#cloudflare-computer--un-ordinateur-pour-les-agents) |
| [Cloudflare Agents](https://blog.cloudflare.com/agents-on-cloudflare/) | nouveau · service | Déploiement et observabilité de sessions d’agents hébergées. | [Voir](#cloudflare-agents--déployer-et-observer-des-agents) |
| [LitmusChaos](https://litmuschaos.io/) | nouveau · plateforme | Chaos engineering Kubernetes pour évaluer la résilience par expériences contrôlées. | [Voir](#litmuschaos--évaluer-la-résilience-des-plateformes) |
| [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) | mise à jour · plateforme | SVM devient GA et RangeStream passe beta, avec un impact sur migrations et inventaires volumineux. | [Voir](#kubernetes-137--storage-version-migration-et-rangestream) |
| [Terraform 1.16](https://github.com/hashicorp/terraform/releases/tag/v1.16.0) | mise à jour · outil IaC | Le state, les imports et la sortie JSON deviennent plus expressifs. | [Voir](#terraform-116--état-et-actions-plus-expressifs) |
| [OpenTelemetry Collector 0.160](https://github.com/open-telemetry/opentelemetry-collector-releases) | mise à jour · observabilité | La cadence bimensuelle renforce le besoin de distributions et composants maîtrisés. | [Voir](#opentelemetry-collector-0160) |

## [Cloudflare Computer — un ordinateur pour les agents](https://blog.cloudflare.com/cloudflare-computer/)

- **Type :** nouveau · plateforme.
- **Pitch rapide :** **Nouveau.** Cloudflare présente le 3 août 2026 `@cloudflare/computer`, un runtime qui masque le choix entre isolate, sandbox conteneurisée et navigateur pour donner à chaque agent un environnement de travail. Il vise les tâches de code, de manipulation de fichiers et de création de documents.
- **Utilité :** ce modèle peut réduire le couplage entre boucle d’agent et infrastructure d’exécution. Il faut qualifier isolation, persistance, accès réseau, coûts à la session et limites de conformité avant tout usage sensible ; exposition : **inconnue**.
- **Outils similaires :** Agent Sandbox, contrôle Kubernetes ; Docker Sandboxes, isolation conteneur ; navigateur distant, plus spécialisé.

## [Cloudflare Agents — déployer et observer des agents](https://blog.cloudflare.com/agents-on-cloudflare/)

- **Type :** nouveau · service.
- **Pitch rapide :** **Nouveau.** Cloudflare Agents, annoncé le 04/08/2026, regroupe les sessions d’agents déployés et expose des traces, avec export vers une destination compatible OpenTelemetry. Le service fournit une couche opératoire autour du runtime et des sessions durables.
- **Utilité :** intéressant pour évaluer l’observabilité d’agents sans construire immédiatement un control plane. Il faut qualifier rétention, données sensibles dans les traces, granularité des coûts, permissions et repli vers une collecte OTel contrôlée ; exposition : **inconnue**.
- **Outils similaires :** LangSmith, observabilité LLM ; OpenTelemetry Collector, contrôle de pipeline ; Elastic Observability, intégration au SIEM/APM.

## [LitmusChaos — tester la résilience des plateformes](https://litmuschaos.io/)

- **Type :** nouveau · plateforme.
- **Pitch rapide :** **Nouveau.** LitmusChaos est une plateforme open source de chaos engineering, centrée sur des expériences contrôlées pour révéler les faiblesses d’infrastructures et de workloads Kubernetes. Le bilan CNCF du 06/08/2026 signale six releases au premier semestre et un usage à grande échelle documenté.
- **Utilité :** le projet peut transformer des hypothèses de résilience en tests répétables dans les pipelines ou sur des fenêtres contrôlées. Il faut limiter le rayon d’action, protéger les environnements et définir les SLO observés ; usage actuel : **à qualifier**.
- **Outils similaires :** Chaos Mesh, chaos natif Kubernetes ; Gremlin, service commercial ; tests de panne ciblés, moins riches mais plus simples à gouverner.

## [Kubernetes 1.37 — Storage Version Migration et RangeStream](https://kubernetes.io/releases/1.37/)

- **Type :** mise à jour · plateforme.
- **Pitch rapide :** SVM passe en disponibilité générale et RangeStream en beta avec etcd 3.7. Ces évolutions touchent la maintenance des versions stockées et la mémoire des lectures de grands ensembles.
- **Utilité :** SVM peut réduire la dette de migration ; RangeStream mérite une évaluation sur clusters riches en CRD. Distribution, etcd et add-ons réellement déployés : **à qualifier**.
- **Outils similaires :** mécanismes de migration des distributions managées ; scripts opérateur ; upgrade etcd sans SVM.

## [Terraform 1.16 — état et actions plus expressifs](https://github.com/hashicorp/terraform/releases/tag/v1.16.0)

- **Type :** mise à jour · outil IaC.
- **Pitch rapide :** Terraform 1.16.0 stabilise le stockage de données privées planifiées, `terraform_data.store`, les imports dans les modules et des sorties JSON d’état. La release date du 26/08/2026.
- **Utilité :** ces primitives peuvent améliorer les modules et les contrôles CI, mais touchent le state, les providers et les secrets ; versions CLI/providers/backend : **exposition inconnue**.
- **Outils similaires :** OpenTofu, fork compatible ; Pulumi, code-first ; outils natifs cloud, plus spécifiques.

## [OpenTelemetry Collector 0.160](https://github.com/open-telemetry/opentelemetry-collector-releases)

- **Type :** mise à jour · observabilité.
- **Pitch rapide :** la release `v0.160.0` du 31/08/2026 confirme la cadence bimensuelle du Collector. Le sujet architectural est la composition et la stabilité distincte des receivers, processors et exporters.
- **Utilité :** une distribution interne peut fournir un point de sortie commun vers ELK/APM et les clouds. Version et composants réellement utilisés : **à qualifier** ; la stabilité du core ne garantit pas celle des composants.
- **Outils similaires :** Elastic Agent, distribution intégrée ; Vector, pipeline performant ; Fluent Bit, agent léger.

## Sujets écartés

- Elastic Agent OTel et Elastic Cloud Serverless : mises à jour opérationnelles utiles mais écartées pour respecter le plafond de 50 % de mises à jour.
- MCP, Agent Sandbox, agentgateway, Kubeflow, kgateway, Cloud Native Buildpacks, Nomad, Vault, OpenTelemetry GenAI/entity events/cardinality et ECS Action Logs : déjà présents dans les 90 derniers jours sans évolution substantielle vérifiée.
- AWS Blocks : nouveauté intéressante mais annoncée le 16/06/2026 ; hors fenêtre de découverte de 30 jours, conservée pour une qualification ultérieure si une preuve récente apparaît.

## Sources consultées

- [Cloudflare Computer](https://blog.cloudflare.com/cloudflare-computer/)
- [Cloudflare Agents](https://blog.cloudflare.com/agents-on-cloudflare/)
- [Bilan LitmusChaos par la CNCF](https://www.cncf.io/blog/2026/08/06/litmuschaos-q1-q2-2026-update-community-contributions-and-project-progress/)
- [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) et [blog Kubernetes](https://kubernetes.io/blog/)
- [Terraform 1.16.0](https://github.com/hashicorp/terraform/releases/tag/v1.16.0)
- [Calendrier OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/release.md)

## Sources en échec

- Les URLs directes des articles Kubernetes SVM/RangeStream et Elastic ECK n’ont pas été retenues après échec d’ouverture ; les faits Kubernetes sont limités aux pages officielles accessibles.
- Google Trends n’a pas fourni de comparaison désambiguïsée exploitable dans cette exécution.
