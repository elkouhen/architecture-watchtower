# Radar architecture — 2026-08-30

## Vue d’ensemble

Déduplication appliquée sur `state/signals.yaml` et les rapports des 90 derniers jours. Cinq sujets nouveaux ou substantiellement distincts ont été retenus ; les autres candidats n’apportaient pas d’évolution architecturale vérifiable suffisante.

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Kubeflow](https://www.kubeflow.org/) | plateforme IA/ML | Sa graduation CNCF confirme une plateforme Kubernetes couvrant le cycle de vie Data & AI. | [Voir](#kubeflow-graduation-cncf) |
| [kgateway 2.4](https://github.com/kgateway-dev/kgateway) | gateway Kubernetes | La série 2.4 étend Gateway API, les policies, la découverte AWS et le routage de zone. | [Voir](#kgateway-24) |
| [Cloud Native Buildpacks](https://buildpacks.io/) | standard/outillage CI | La graduation CNCF renforce le build source-vers-OCI standardisé et les workflows SBOM. | [Voir](#cloud-native-buildpacks-graduation) |
| [Elastic Cloud Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations) | service observabilité | Deux anciennes API internes de Stack Monitoring sont dépréciées au profit de Metricbeat ou Elastic Agent. | [Voir](#elastic-cloud-serverless-dépréciation-du-monitoring-interne) |
| [OpenTelemetry Collector 0.159](https://github.com/open-telemetry/opentelemetry-collector-releases) | bibliothèque/plateforme observabilité | La cadence bimensuelle et la prochaine 0.160 imposent de traiter le Collector comme un composant versionné de plateforme. | [Voir](#opentelemetry-collector-0159) |

## [Kubeflow — graduation CNCF](https://www.kubeflow.org/)

- **Type :** plateforme IA/ML.
- **Pitch rapide :** Kubeflow regroupe sur Kubernetes le traitement de données, les environnements interactifs, l’entraînement distribué, le fine-tuning, l’inférence et le serving. La graduation CNCF du 17/08/2026 en fait un candidat de plateforme à qualifier, pas une preuve que toute sa distribution convient à la production.
- **Utilité :** il peut fournir une surface commune entre data scientists, ML engineers et équipe plateforme, notamment pour rendre reproductibles les workloads GPU et les déploiements hybrides. La stack réelle de Mehdi est **exposition inconnue** ; qualifier d’abord les sous-projets retenus, les CRD, les besoins GPU, les coûts opératoires et le chemin de retrait.
- **Preuves de traction :** **Fait** : la CNCF annonce la graduation, un audit de sécurité tiers, une gouvernance formalisée et l’usage de sous-projets par plusieurs entreprises ([annonce CNCF](https://www.cncf.io/announcements/2026/08/17/cncf-announces-kubeflows-graduation-solidifying-the-standard-for-cloud-native-ai-operations/)). **Fait** : la feuille de route mentionne orchestration LLM, fine-tuning et workloads agentiques. **Analyse** : le jalon réduit le risque de gouvernance et de pérennité du projet, mais ne supprime pas la complexité d’exploitation. **Inférence** : Kubeflow peut devenir une couche de plateforme pour AI/ML si les golden paths, quotas, observabilité et politiques sont opérables. Décision proposée : **qualifier** ; propriétaire : plateforme IA ; échéance : 2026-09-12 ; succès : déployer un pipeline minimal entraînement → registre → endpoint avec coûts, traces et rollback mesurés.
- **Outils similaires :** [KServe](https://kserve.github.io/website/), plus ciblé serving ; [Ray](https://www.ray.io/), plus ciblé calcul distribué ; [MLflow](https://mlflow.org/), plus ciblé suivi et cycle de vie des modèles.

### Pitch détaillé

Kubeflow change la question « comment lancer un notebook ou un modèle ? » en « comment opérer un cycle de vie Data & AI cohérent sur Kubernetes ? ». Sa valeur est la continuité entre expérimentation, entraînement et serving, avec des primitives que la plateforme peut entourer de quotas, identité, réseau et observabilité.

Le produit vise les organisations qui veulent mutualiser des GPU et éviter une succession de plateformes spécialisées par équipe. Son fonctionnement général reste Kubernetes-native : opérateurs, CRD, workloads et services composent un plan de contrôle autour des pipelines et des runtimes. Le détail de chaque sous-projet, des versions compatibles et du stockage durable reste à qualifier.

Le bénéfice architectural est la portabilité du modèle d’exploitation ; la limite est le nombre de composants et de chemins possibles. Les risques principaux sont le blast radius du cluster, le coût GPU, la sécurité des notebooks et la dérive entre modèle, code et données. Décision : **tester** sur un périmètre isolé, avec validation humaine des modèles et repli vers un serving existant.

## [kgateway 2.4](https://github.com/kgateway-dev/kgateway)

- **Type :** gateway Kubernetes.
- **Pitch rapide :** kgateway est un control plane/data plane Envoy basé sur Gateway API. La série 2.4 ajoute notamment Gateway API 1.6, routage de zone, policies au niveau Gateway, découverte d’instances EC2 et des contrôles OAuth/JWKS ; la release 2.4.1 corrige un risque de compatibilité pendant les rolling upgrades.
- **Utilité :** il mérite une étude si la plateforme doit unifier API gateway, routage multi-zone, politiques et backends AWS dans des ressources Kubernetes. Le point critique est la mise à jour control plane/data plane : tester compatibilité, rollback, EDS, CRD et comportement en cas de backend invalide ; exposition réelle **à qualifier**.
- **Preuves de traction :** **Fait** : `v2.4.0` publiée le 23/07/2026 documente ces fonctionnalités et plusieurs changements incompatibles ([release v2.4.0](https://github.com/kgateway-dev/kgateway/releases/tag/v2.4.0)). **Fait** : `v2.4.1` du 27/07 corrige le gel possible des mises à jour EDS lors d’une mise à niveau progressive ([release v2.4.1](https://github.com/kgateway-dev/kgateway/releases/tag/v2.4.1)). **Fait** : le projet indique 5,7 k étoiles et 802 forks lors de la mesure du 30/08 ([dépôt GitHub](https://github.com/kgateway-dev/kgateway)). **Analyse** : la correction de compatibilité est plus importante pour l’exploitation que le volume d’étoiles. Décision proposée : **tester** ; propriétaire : plateforme réseau ; échéance : 2026-09-19 ; succès : upgrade contrôlé sans endpoint stale, avec tests de policy et métriques de routage.
- **Outils similaires :** [Envoy Gateway](https://gateway.envoyproxy.io/), plus directement centré Gateway API ; [Istio](https://istio.io/), plus large service mesh ; [Traefik Proxy](https://traefik.io/traefik/), plus simple pour des cas d’exposition courants.

### Pitch détaillé

kgateway rapproche la gestion du trafic north-south et certaines politiques d’application dans le modèle déclaratif Gateway API. L’intérêt n’est pas seulement d’ajouter un proxy, mais de rendre les règles, références de secrets, backends cloud et signaux de routage inspectables comme des objets Kubernetes.

La série 2.4 élargit la surface : policies au niveau Gateway, découverte EC2, OAuth/JWKS et routage de zone. Cela peut réduire des configurations parallèles, mais augmente le nombre de contrats à versionner. Le control plane et les proxies doivent être mis à jour selon une stratégie compatible avec les problèmes EDS déjà corrigés.

Le principal risque est une panne de routage silencieuse ou un état de proxy obsolète pendant l’upgrade. Décision : **tester**, avec un cluster de préproduction, une matrice de versions, des routes synthétiques et un rollback vérifié.

## [Cloud Native Buildpacks — graduation CNCF](https://buildpacks.io/)

- **Type :** standard/outillage CI.
- **Pitch rapide :** Cloud Native Buildpacks transforme du code source en images OCI en détectant le langage, en installant les dépendances et en construisant des couches réutilisables. La graduation CNCF du 11/08/2026 confirme sa maturité de gouvernance et met en avant SBOM, rebase d’images et compatibilité future avec OCI Artifacts/WebAssembly.
- **Utilité :** le pattern peut créer un golden path de build pour des équipes qui veulent réduire les Dockerfiles spécifiques tout en centralisant les correctifs de buildpack. Il faut comparer la transparence du build, la maîtrise des versions, les exceptions natives et l’intégration registry/signature/SBOM ; aucun pipeline local n’est supposé l’utiliser.
- **Preuves de traction :** **Fait** : la CNCF annonce la graduation, un audit de sécurité tiers et un badge OpenSSF Best Practices ([annonce CNCF](https://www.cncf.io/announcements/2026/08/11/cncf-announces-graduation-of-cloud-native-buildpacks-advancing-the-standard-for-container-builds/)). **Fait** : la source décrit des déploiements d’entreprise et une feuille de route SBOM/OCI. **Analyse** : la maturité du standard peut simplifier la maintenance de la chaîne de build, mais le résultat dépend des buildpacks sélectionnés et de leur cycle de patch. Décision proposée : **surveiller puis tester** ; propriétaire : plateforme CI ; réexamen : 2026-09-19 ; succès : même application produite avec image reproductible, SBOM vérifiable et rebase documenté.
- **Outils similaires :** [Docker BuildKit](https://docs.docker.com/build/), plus flexible et explicite ; [Cloud Native Buildpacks Paketo](https://paketo.io/), distribution de buildpacks ; [Nixpacks](https://nixpacks.com/), approche source-vers-image plus opinionated.

## [Elastic Cloud Serverless — dépréciation du monitoring interne](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations)

- **Type :** service observabilité.
- **Pitch rapide :** Elastic déprécie, à compter du 26/08/2026, les API `_monitoring/bulk` et `_monitoring/migrate/alerts` utilisées par l’ancienne collecte interne de Stack Monitoring. Elastic recommande de migrer vers Metricbeat ou Elastic Agent.
- **Utilité :** c’est une échéance de compatibilité pour les intégrations qui appellent encore ces endpoints ; cela peut modifier collecte, dashboards, droits et coûts dans un environnement Serverless. L’exposition locale est **inconnue** : rechercher les appels dans les intégrations et vérifier le mode Cloud Serverless avant toute action.
- **Preuves de traction :** **Fait** : la page officielle date la dépréciation du 26/08 et indique un avertissement à chaque appel ([dépréciations Serverless](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations)). **Fait** : l’action recommandée est de migrer vers Metricbeat ou Elastic Agent. **Analyse** : il s’agit d’une dette d’intégration et non d’un incident de sécurité. Décision proposée : **qualifier** ; propriétaire : observabilité ; échéance : 2026-09-06 ; succès : zéro appel legacy en test, mêmes alertes validées et coût/rétention comparés.
- **Outils similaires :** Elastic Agent, recommandé par Elastic ; Metricbeat, option ciblée ; OpenTelemetry Collector, alternative vendor-neutral à qualifier selon les signaux nécessaires.

## [OpenTelemetry Collector 0.159](https://github.com/open-telemetry/opentelemetry-collector-releases)

- **Type :** bibliothèque/plateforme observabilité.
- **Pitch rapide :** la release `0.159.0` du 17/08/2026 s’inscrit dans une cadence bimensuelle, avec `0.160.0` planifiée au 31/08. Le Collector reste une plateforme de distribution dont les composants ont des niveaux de stabilité différents ; le sujet est donc la gouvernance d’upgrade autant que la version.
- **Utilité :** pour une architecture multi-backends, cette cadence permet de recevoir des processors/exporters récents, mais impose une image interne, une sélection explicite des composants et des tests de configuration. La distribution réellement utilisée est **à qualifier** ; ne pas confondre la version du core, de contrib et des distributions commerciales.
- **Preuves de traction :** **Fait** : le calendrier officiel liste `v0.159.0` le 17/08 et `v0.160.0` le 31/08 ([calendrier de release](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/release.md)). **Fait** : la documentation rappelle que les modules stables passent en 1.x après une procédure de stabilisation ; les versions 0.x ne garantissent donc pas toutes le même contrat. **Analyse** : une cadence prévisible aide la maintenance mais augmente le risque de dérive entre composants. Décision proposée : **surveiller** ; propriétaire : observabilité ; réexamen : 2026-09-14 ; succès : matrice de composants, tests de charge et rollback de configuration automatisés.
- **Outils similaires :** Elastic Agent, distribution intégrée ; [Vector](https://vector.dev/), pipeline performant orienté logs/métriques ; Fluent Bit, agent léger pour collecte et forwarding.

## Sujets écartés

- Kubernetes 1.37, Elastic Stack 9.5.2, Agent Sandbox, MCP, agentgateway, Terraform, Vault, Nomad, OpenTelemetry GenAI/entity events/cardinality et ECS Action Logs : déjà présents dans les 90 derniers jours sans évolution substantielle vérifiée aujourd’hui.
- OpenObserve 0.92.2 et Vector 0.58 : releases récentes repérées, mais les éléments vérifiables disponibles ne démontrent pas un changement architectural assez fort pour ce radar.
- Les résultats GitHub Trending, topics et recherches Google : utilisés au mieux pour découverte ; aucune preuve primaire suffisante n’a été retenue seule. Google Trends n’a pas été utilisé comme preuve : pas de comparaison désambiguïsée exploitable dans cette exécution.

## Sources consultées

- [CNCF — Kubeflow graduation](https://www.cncf.io/announcements/2026/08/17/cncf-announces-kubeflows-graduation-solidifying-the-standard-for-cloud-native-ai-operations/)
- [CNCF — Cloud Native Buildpacks graduation](https://www.cncf.io/announcements/2026/08/11/cncf-announces-graduation-of-cloud-native-buildpacks-advancing-the-standard-for-container-builds/)
- [kgateway releases](https://github.com/kgateway-dev/kgateway/releases)
- [Elastic Cloud Serverless deprecations](https://www.elastic.co/docs/release-notes/cloud-serverless/deprecations)
- [OpenTelemetry Collector release calendar](https://github.com/open-telemetry/opentelemetry-collector/blob/main/docs/release.md)
- [Kubernetes releases](https://kubernetes.io/releases/), [Elastic release notes](https://www.elastic.co/docs/release-notes), [GitHub releases](https://github.com/explore) pour déduplication et contrôle des sujets déjà vus.

## Sources en échec

- Aucune source primaire retenue n’a échoué de manière bloquante. Les flux de découverte GitHub/Google Trends n’ont pas fourni de preuve autonome suffisante et ne sont pas utilisés comme faits.
