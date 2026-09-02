# Radar architecture — 2026-09-02

## Vue d’ensemble

Déduplication appliquée sur `state/signals.yaml` et les rapports des 90 derniers jours. Cinq sujets sont retenus : trois mises à jour structurantes et deux signaux Elastic opérationnels. L’exposition réelle de la stack de Mehdi reste `à qualifier`.

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) | plateforme | SVM devient GA et RangeStream passe beta, avec un impact direct sur migrations et gros inventaires. | [Voir](#kubernetes-137--storage-version-migration-et-rangestream) |
| [Terraform 1.16](https://github.com/hashicorp/terraform/releases/tag/v1.16.0) | outil IaC | La release stabilise le stockage de données privées planifiées, `terraform_data.store` et les imports dans les modules. | [Voir](#terraform-116--état-et-actions-plus-expressifs) |
| [OpenTelemetry Collector 0.160](https://github.com/open-telemetry/opentelemetry-collector-releases) | plateforme observabilité | La cadence bimensuelle continue ; la gouvernance de versions et de composants devient une capacité de plateforme. | [Voir](#opentelemetry-collector-0160) |
| [Elastic Agent OTel runtime](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues) | agent observabilité | Des défauts silencieux affectent Kafka Kerberos et GCP Pub/Sub avec le runtime OTel sur certaines versions. | [Voir](#elastic-agent--défauts-du-runtime-otel) |
| [Elastic Cloud Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless) | service observabilité | Les changements du 27/08 ajoutent audit, agents et connecteurs, mais modifient aussi le périmètre de droits et de coûts. | [Voir](#elastic-cloud-serverless--changements-du-2708) |

## [Kubernetes 1.37 — Storage Version Migration et RangeStream](https://kubernetes.io/releases/1.37/)

- **Type :** plateforme.
- **Pitch rapide :** Kubernetes 1.37 fait passer Storage Version Migration (SVM) en disponibilité générale et RangeStream en beta avec etcd 3.7. Ces changements touchent respectivement la maintenance des versions stockées et la consommation mémoire des lectures de grands ensembles.
- **Utilité :** SVM peut réduire la dette opératoire liée aux migrations de versions de stockage, mais ajoute un contrôleur et des permissions à vérifier. RangeStream mérite un test sur clusters à grand nombre d’objets ; control plane, etcd et add-ons réellement déployés : **à qualifier**.
- **Preuves de traction :** **Fait** : l’index du blog Kubernetes annonce SVM GA le 31/08/2026 et RangeStream beta le 01/09/2026 ([blog officiel](https://kubernetes.io/blog/)). **Analyse** : ce sont des évolutions du control plane, plus importantes qu’un simple ajout d’API. **Inférence** : les plateformes riches en CRD peuvent gagner en prévisibilité mémoire, sous réserve de compatibilité etcd. Décision proposée : **tester** ; propriétaire : plateforme Kubernetes ; échéance : 2026-09-16 ; succès : migration d’un objet témoin et lecture d’un inventaire volumineux sans régression d’API server, mémoire ou temps de réponse.
- **Outils similaires :** mécanismes de migration propres aux distributions managées, scripts opérateur, upgrade etcd sans SVM ; la différence utile est l’intégration native au control plane Kubernetes.

### Pitch détaillé

Kubernetes 1.37 transforme deux tâches souvent traitées comme de la plomberie en fonctions explicites du control plane : maintenir la version de stockage d’objets et lire efficacement de grandes collections. Cela concerne directement les clusters riches en CRD, opérateurs et objets d’inventaire.

SVM doit être évalué comme une opération de maintenance avec droits, charge et reprise, pas comme une migration invisible. RangeStream dépend d’etcd 3.7 et ne dispense pas de contrôler les clients qui listent massivement l’API.

Le gain potentiel est une meilleure maîtrise des pics mémoire et de la dette de stockage. Le risque principal est une incompatibilité entre distribution, etcd, admission webhooks et add-ons. Décision : **tester** sur un cluster non critique, avec rollback documenté et mesures avant/après.

## [Terraform 1.16 — état et actions plus expressifs](https://github.com/hashicorp/terraform/releases/tag/v1.16.0)

- **Type :** outil IaC.
- **Pitch rapide :** Terraform 1.16.0, publié le 26/08/2026, stabilise des primitives utiles à l’IaC : données privées conservées dans le plan, bloc `terraform_data.store`, imports dans les modules et sortie JSON de commandes d’état.
- **Utilité :** ces fonctions peuvent améliorer les modules réutilisables, les migrations et l’automatisation de contrôles. Elles touchent le state, les providers et les secrets ; version du CLI, des providers et du backend réellement utilisés : **exposition inconnue**.
- **Preuves de traction :** **Fait** : la release officielle documente ces fonctionnalités et des changements d’upgrade le 26/08/2026 ([release 1.16.0](https://github.com/hashicorp/terraform/releases/tag/v1.16.0)). **Analyse** : la release stable confirme le signal alpha observé le 29/08 et rend possible un test contrôlé. **Inférence** : la sortie JSON peut simplifier la gouvernance sans parser du texte CLI. Décision proposée : **tester** ; propriétaire : IaC ; échéance : 2026-09-18 ; succès : module de migration testé sur backend non critique, state sensible non exposé et sortie JSON consommée par un contrôle CI.
- **Outils similaires :** OpenTofu, fork compatible à comparer ; Pulumi, modèle code-first ; outils natifs AWS/GCP, moins portables mais plus proches des APIs cloud.

## [OpenTelemetry Collector 0.160](https://github.com/open-telemetry/opentelemetry-collector-releases)

- **Type :** plateforme observabilité.
- **Pitch rapide :** la release `v0.160.0` du 31/08/2026 confirme la cadence bimensuelle du Collector. Le sujet architectural est la composition d’une distribution interne et la stabilité différente de ses receivers, processors et exporters.
- **Utilité :** une distribution contrôlée peut fournir un point de sortie commun vers ELK/APM, CloudWatch et d’autres backends. La version et les composants réellement utilisés sont **à qualifier** ; ne pas déduire la stabilité d’un composant de celle du core.
- **Preuves de traction :** **Fait** : le calendrier officiel liste `v0.160.0` le 31/08, après `v0.159.0` le 17/08 ([calendrier de release](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/release.md)). **Analyse** : la cadence rend l’upgrade prévisible mais impose pinning, tests et rollback. **Inférence** : une image interne minimale est préférable à une distribution générique non maîtrisée. Décision proposée : **surveiller** ; propriétaire : observabilité ; réexamen : 2026-09-16 ; succès : matrice composants/stabilité, test de charge et restauration de configuration automatisée.
- **Outils similaires :** Elastic Agent, distribution intégrée ; Vector, pipeline performant ; Fluent Bit, agent léger orienté collecte.

## [Elastic Agent — défauts du runtime OTel](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues)

- **Type :** agent observabilité.
- **Pitch rapide :** Elastic documente des défauts pouvant perdre silencieusement des données avec le runtime OTel : paramètres Kerberos ignorés pour Kafka et champs GCP Pub/Sub rejetés ou redirigés vers la Failure Store.
- **Utilité :** le risque porte sur l’intégrité de la télémétrie, pas seulement sur l’état « Healthy » de l’agent. Inventorier les versions 9.5.0–9.5.1, les intégrations Kafka/GCP et le runtime choisi ; exposition locale **inconnue**.
- **Preuves de traction :** **Fait** : la page officielle signale le problème Kafka découvert le 10/08/2026 et le problème GCP découvert le 05/08/2026, avec correctif annoncé en 9.5.2 ([known issues Elastic Agent](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues)). **Analyse** : l’absence d’erreur visible et l’acknowledgement Pub/Sub rendent une simple vérification de santé insuffisante. **Inférence** : des contrôles de complétude et de Failure Store doivent compléter la supervision agent. Décision proposée : **qualifier** ; propriétaire : observabilité ; échéance : 2026-09-05 ; succès : versions/runtime inventoriés, événement synthétique reçu dans la destination et aucune perte silencieuse constatée.
- **Outils similaires :** Filebeat process runtime, contournement documenté ; OpenTelemetry Collector, alternative indépendante ; Fluent Bit, agent plus ciblé logs.

## [Elastic Cloud Serverless — changements du 27/08](https://www.elastic.co/docs/release-notes/cloud-serverless)

- **Type :** service observabilité.
- **Pitch rapide :** le changelog Serverless du 27/08/2026 ajoute l’agent par défaut par espace Kibana, des actions d’écriture pour Jira/Gmail et `user.email` dans les audit logs. Ces capacités élargissent les workflows et la surface de gouvernance.
- **Utilité :** utile pour qualifier séparation des espaces, permissions, traçabilité et coûts des actions sortantes. Le projet Serverless réellement utilisé et ses intégrations sont **à qualifier** ; disponibilité ne prouve pas activation dans la stack.
- **Preuves de traction :** **Fait** : le changelog officiel date ces changements du 27/08/2026 et mentionne des corrections ML et d’audit ([changelog Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless)). **Analyse** : l’ajout de write actions transforme des connecteurs consultatifs en chemins de changement externe. **Inférence** : ces actions doivent être traitées comme des intégrations privilégiées avec validation humaine et journaux corrélés. Décision proposée : **qualifier** ; propriétaire : observabilité/sécurité ; échéance : 2026-09-12 ; succès : matrice de permissions, test contrôlé, audit corrélé et estimation de coût validés.
- **Outils similaires :** Elastic Hosted, plus configurable ; OpenSearch Dashboards, alternative de plateforme ; workflows externes avec approbation, moins intégrés mais plus contrôlables.

## Sujets écartés

- MCP, Agent Sandbox, agentgateway, Kubeflow, kgateway, Cloud Native Buildpacks, Nomad, Vault, OpenTelemetry GenAI/entity events/cardinality et ECS Action Logs : déjà présents dans les 90 derniers jours sans évolution substantielle supplémentaire vérifiée.
- Terraform 1.17 alpha : évolution intéressante mais déjà signalée le 29/08 ; la version stable 1.16 est retenue comme mise à jour distincte.
- Les résultats GitHub Trending, Trendshift et Google Trends : utilisés pour découverte, mais aucune preuve autonome suffisante n’a été retenue.

## Sources consultées

- [Kubernetes blog](https://kubernetes.io/blog/) et [Kubernetes 1.37](https://kubernetes.io/releases/1.37/)
- [Terraform 1.16.0](https://github.com/hashicorp/terraform/releases/tag/v1.16.0)
- [OpenTelemetry release calendar](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/release.md)
- [Elastic Agent known issues](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues)
- [Elastic Cloud Serverless changelog](https://www.elastic.co/docs/release-notes/cloud-serverless)
- [Elastic archive August 2026](https://www.elastic.co/blog/archive/2026/august) pour contrôle ECK et releases récentes

## Sources en échec

- Les URLs directes des articles Kubernetes SVM/RangeStream et l’article Elastic ECK 3.5 ont renvoyé une erreur d’ouverture. Les faits Kubernetes retenus sont confirmés par l’index officiel du blog ; ECK 3.5 n’est pas retenu comme sujet.
- Google Trends n’a pas fourni de comparaison désambiguïsée exploitable dans cette exécution.
