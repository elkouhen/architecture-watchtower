# Carte service — Elasticsearch

> **But :** comprendre Elasticsearch comme un architecte : usage, intégration, déploiement, exploitation et critères de décision.

| Repère | Valeur |
|---|---|
| Date | 2026-08-27 |
| Axe | Fondamental |
| Niveau | Compréhension → pratique |
| Version de référence | 9.5.2 — à distinguer de la version réellement déployée |
| Décision | Évaluer / maintenir sous contrôle |

## 1. Identité

Elasticsearch est développé par Elastic. Il s’agit d’une plateforme distribuée de recherche, d’analytique, d’observabilité, de sécurité et de recherche vectorielle.

**Prérequis :** HTTP/JSON, Docker et notions de stockage distribué. Kubernetes n’est pas requis pour le laboratoire local.

## 2. En une minute

Elasticsearch transforme des documents JSON en index interrogeables. Il convient à la recherche plein texte, aux agrégations, aux événements, aux logs, à l’observabilité, à la sécurité et à certains usages vectoriels.

Son compromis central : recherche rapide et flexible, mais forte exigence de discipline sur les mappings, shards, stockage, rétention, snapshots et requêtes.

> **Règle d’architecture :** Elasticsearch est généralement un index ou un read model réindexable, pas l’unique système de référence d’une transaction métier.

## 3. Position dans le système

```text
Applications / agents / pipelines
              │ documents JSON, logs, métriques, traces
              ▼
     Ingest pipelines et enrichissement
              ▼
       Cluster Elasticsearch
       ├── index / data stream
       ├── shards primaires
       └── replicas sur d’autres nœuds ou zones
              │
     ┌────────┴────────┐
     ▼                 ▼
  Recherche         Agrégations
     │                 │
     └──────► applications, Kibana, alertes, sécurité, IA

     Snapshots ───────► repository externe
```

### Producteurs

- Applications via REST ou SDK.
- Elastic Agent, Beats, Logstash, APM et OpenTelemetry/OTLP.

### Consommateurs

- Applications de recherche et APIs internes.
- Kibana, dashboards, alertes, Elastic Security et jobs analytiques.
- Retrievers ou applications IA pour la recherche hybride/vectorielle.

### Ce qu’Elasticsearch ne remplace pas automatiquement

- Une base transactionnelle et ses contraintes ACID.
- Un object storage ou une archive longue durée.
- Un bus d’événements.

## 4. Capacités et conséquences

| Capacité | Usage | Décision à prendre |
|---|---|---|
| Recherche plein texte | Trouver des documents par pertinence | Définir analyzers, mappings et tests de pertinence |
| Filtres et agrégations | Explorer événements et séries temporelles | Maîtriser cardinalité, fenêtres et mémoire |
| Observabilité | Logs, métriques, traces, APM | Définir ingestion, sampling, rollover et rétention |
| Sécurité | Corréler des signaux et enquêter | Contrôler RBAC, audit et accès aux données |
| Recherche vectorielle | Similarité et RAG | Mesurer rappel, latence, coût et repli lexical |
| Cycle de vie | Templates, aliases, data streams, ILM | Livrer ces objets comme du code versionné |

## 5. Modèle mental de fonctionnement

### Écriture

1. Le client envoie un document, souvent en bulk.
2. Un pipeline peut parser ou enrichir le document.
3. Le mapping détermine les champs indexés.
4. Le document est affecté à un shard primaire.
5. Les segments Lucene sont écrits ; translog et réplication participent à la durabilité.

### Lecture

1. La requête arrive sur un nœud coordinateur ou une API.
2. Les shards concernés exécutent la recherche.
3. Les résultats sont fusionnés, triés et agrégés.
4. L’application reçoit des hits, scores et agrégations.

### Résilience

- Un replica est une copie d’un shard primaire, idéalement sur un autre nœud ou une autre zone.
- Un cluster sain ne prouve pas que les données sont sauvegardées.
- Les snapshots vont vers un repository externe et doivent être restaurés en test réel.

### Rôles des nœuds

| Rôle | Responsabilité | Règle d’architecture |
|---|---|---|
| `master` | Élection, état du cluster, templates et métadonnées | Trois nœuds master-eligible dédiés dans une production multi-zone ; ne pas leur faire porter la charge data lourde |
| `data_content` | Documents relativement stables, catalogue et recherche | Optimiser pour requêtes et agrégations ; garder des replicas |
| `data_hot` | Écriture et recherche des données récentes | SSD rapides, CPU et I/O élevés ; point d’entrée des data streams |
| `data_warm` | Données moins écrites mais encore consultées | Moins de performance que hot, mais conserver la résilience nécessaire |
| `data_cold` | Données rarement consultées | Prioriser le coût ; searchable snapshots possibles |
| `data_frozen` | Données rarement consultées et immuables | Searchable snapshots partiels ; recherches plus lentes, repository obligatoire |
| `ingest` | Parsing, enrichissement et pipelines d’ingestion | Séparer ce rôle si les pipelines consomment beaucoup de CPU |
| `coordinating` | Réception, fan-out vers les shards et fusion des résultats | Dédié seulement lorsque le volume de requêtes le justifie |
| `ml` / `transform` | Machine learning et transforms | Isoler si les jobs sont lourds ou continus |

Un nœud peut porter plusieurs rôles. Au début, un petit cluster peut combiner les rôles ; à mesure que la charge augmente, séparer master, data, ingest, coordinating, ML et transform pour éviter qu’une saturation d’ingestion ou de recherche n’empêche l’élection du cluster.

### Haute disponibilité et multi-zone

- Répartir les nœuds master-eligible sur trois zones ou domaines de panne lorsque c’est possible.
- Placer les replicas dans une autre zone que leur shard primaire ; vérifier les règles d’allocation et les awareness attributes.
- Dimensionner chaque tier pour survivre à la perte du nœud ou de la zone prévue par le SLO.
- Contrôler régulièrement les shards non alloués, la couleur du cluster, les watermarks disque et les décisions d’allocation.
- Le quorum protège l’élection du master ; il ne remplace ni les replicas, ni les snapshots, ni le plan de reprise après sinistre.

## 6. Déploiements possibles

| Mode | Responsabilité principale de l’équipe | Quand l’envisager |
|---|---|---|
| Self-managed | Infrastructure, JVM, disques, réseau, TLS, upgrades, sauvegardes | Contrôle maximal, équipe experte |
| ECK | Kubernetes, CRDs, stockage, opérateur, sécurité, capacité | Elasticsearch standardisé sur Kubernetes |
| ECE | Plateforme ECE, capacité, réseau, versions, sauvegardes | Plusieurs déploiements à piloter |
| Hosted | Données, accès, topologie logique, coût, SLO, snapshots | Réduire la charge d’exploitation |
| Serverless | Projet, données, APIs, rétention, limites, coût | Accepter moins de réglages cluster |

**Point de vigilance :** Hosted et Serverless sont des offres Elastic sur AWS, Azure et GCP. Serverless n’expose pas les mêmes capacités que Hosted : vérifier fonctions, limites, licences et sortie.

### Dimensionnement initial

Le dimensionnement ci-dessous est un point de départ à valider par test. Ce ne sont pas des garanties de capacité.

### Hypothèses à recueillir

| Dimension | Mesure attendue |
|---|---|
| Écriture | documents/s, octets/s, taille moyenne, bulk, pics et refresh |
| Lecture | requêtes/s, concurrence, p95/p99, agrégations et taille des réponses |
| Données | volume primaire/jour, croissance, nombre de champs et documents supprimés |
| Durée | rétention hot/warm/cold/frozen et fréquence de consultation par âge |
| Résilience | replicas, zones, perte de nœud/zone, RPO/RTO et durée de recovery |
| Contraintes | SLA/SLO, chiffrement, région, budget et fenêtre de maintenance |

### Méthode de calcul

1. Estimer le volume brut journalier : `documents/jour × taille moyenne`.
2. Ajouter l’overhead d’indexation, les segments, les replicas et la marge de croissance.
3. Répartir le volume entre les tiers selon la politique de rétention.
4. Choisir le nombre de shards pour obtenir des shards d’environ **10 à 50 Go** et moins de **200 millions de documents par shard** comme repères initiaux Elastic.
5. Tester la topologie avec la charge de pointe et mesurer latence, heap, I/O, files d’attente et récupération.

### CPU, RAM, heap, disque et réseau

- **CPU :** dimensionner séparément ingestion, recherche et agrégations ; une recherche s’exécute par shard sur un thread, donc trop de shards augmente le fan-out et la concurrence.
- **RAM :** réserver assez de mémoire au système pour le filesystem cache ; le heap JVM ne doit pas dépasser 50 % de la mémoire disponible du nœud et `Xms` doit être égal à `Xmx` si le heap est fixé manuellement.
- **Heap :** surveiller GC, memory pressure, circuit breakers et files d’attente ; un heap plus grand ne corrige pas un mauvais mapping ou un sur-sharding.
- **Disque :** privilégier SSD/IOPS adaptés au tier hot ; provisionner la capacité utile, les replicas, les merges, les snapshots locaux éventuels et une marge avant watermark.
- **Réseau :** prévoir trafic client, réplication, recovery, snapshots et fan-out ; séparer ou prioriser les flux si les pics se concurrencent.
- **Validation :** aucune valeur CPU/RAM ne doit être présentée comme universelle ; publier les hypothèses, la charge de test et les seuils observés.

### Topologies de référence

| Niveau | Topologie indicative | Usage |
|---|---|---|
| Laboratoire | 1 nœud combiné, sécurité de test, aucun SLO | Comprendre APIs, mapping, shards et recherche |
| Petite production | 3 nœuds master/data répartis si possible, 1 replica, hot/content | Faible à moyenne charge, exploitation simple |
| Production multi-zone | 3 master dédiés, data hot/warm/cold selon rétention, ingest/coordinating dédiés si nécessaire, replicas et snapshots externes | SLO de disponibilité, croissance et séparation des charges |

**À confirmer par benchmark :** nombre de nœuds, vCPU, RAM, heap, type de disque, IOPS, nombre de shards et taille des bulk.

## 7. Données et cycle de vie

- **Modèle :** documents JSON, index/data streams, mappings, templates, aliases et pipelines.
- **Schéma :** mapping explicite pour les champs critiques ; surveiller dynamic mapping et nombre de champs.
- **Rétention :** rollover et suppression par âge, taille ou volume ; ILM selon le mode.
- **Tiers :** hot reçoit les écritures et les recherches fréquentes ; warm reçoit les données moins modifiées ; cold réduit le coût avec des recherches plus lentes ; frozen s’appuie exclusivement sur des searchable snapshots partiels et un repository externe.
- **Transition :** définir pour chaque phase l’âge d’entrée, le niveau de performance, le nombre de replicas, le coût cible et le critère de retour arrière. Les tiers warm, cold et frozen sont optionnels ; hot et content sont requis dans l’architecture versionnée.
- **Allocation :** utiliser la préférence `_tier_preference` et vérifier l’allocation effective ; une liste de tiers de repli évite qu’un index reste non alloué si le tier préféré est absent.
- **ILM/rollover :** déclencher le rollover par âge, taille ou nombre de documents ; tester la transition réelle des backing indices et la suppression finale.
- **Sauvegarde :** snapshot vers un repository hors cluster ; vérifier régulièrement le restore.
- **Migration :** reindexation, aliases, double écriture ou restauration contrôlée ; tester analyzers, mappings et clients.
- **Limite :** un snapshot n’est pas un rollback applicatif complet ; une restauration vers une version antérieure n’est pas présumée supportée.

## 8. Exploitation quotidienne

### À surveiller

- Disponibilité, p95/p99 de recherche et taux d’erreur.
- Rejets bulk, retard d’ingestion, refresh, merge et files d’attente.
- Shards non alloués, pression JVM/mémoire et espace disque.
- Recovery, taille des index, état des snapshots et temps de restauration.

### Pannes à prévoir

- Disque plein ou repository indisponible.
- Shard non alloué, surcharge heap ou requête coûteuse.
- Explosion du mapping, retard d’ingestion ou restauration trop lente.

### Cycle opérationnel

```text
mapping/templates → ingestion bulk → recherche
        ↓                 ↓             ↓
   rollover        capacité/disque   SLO/alertes
        ↓                 ↓             ↓
     snapshot → test de restore → upgrade planifié
```

## 9. Sécurité et responsabilités

### Contrôles minimaux

- Authentification, RBAC et comptes de service distincts.
- TLS HTTP/transport et secrets hors du code.
- API keys à durée contrôlée et privilèges minimaux par flux.
- Réseau privé, audit si requis et tests négatifs des rôles.

### Répartition

| Mode | Elastic gère davantage | L’équipe reste responsable de |
|---|---|---|
| Self-managed / ECK | — | TLS, secrets, réseau, rôles, disque, audit et rotation |
| Hosted / Serverless | Plateforme sous-jacente et contrôles opérés | Accès, données, rôles, clés, conformité et usage |

> Une alerte de vulnérabilité ne prouve pas l’exposition du parc : qualifier produit, version, mode et environnement.

## 10. Coûts et alternatives

- Les coûts dépendent de l’ingestion, du stockage, de la rétention, des requêtes, des replicas, de la région et du mode.
- **Base relationnelle :** préférable si transactions et relations sont centrales.
- **OpenSearch :** alternative distincte ; migration non transparente.
- **Object storage/data lake :** adapté à l’archive longue, pas équivalent à la recherche interactive.
- **Serverless :** moins d’infrastructure à gérer, mais dépendance accrue au modèle et aux limites de l’offre.

## 11. Quand l’utiliser — ou l’éviter

### L’utiliser pour

- Recherche plein texte ou hybride.
- Logs et événements à forte exploration.
- Agrégations temporelles et observabilité Elastic.
- Sécurité et recherche vectorielle avec métriques mesurables.

### L’éviter comme seul système de référence pour

- Transactions fortement cohérentes.
- Relations complexes ou contraintes ACID riches.
- Données impossibles à réindexer ou exporter.
- Rétention illimitée sans budget contrôlé.

## 12. Évolutions observées

**Fait :** les release notes consultées indiquent Elasticsearch 9.5.2 comme version publiée de référence.

**Fait :** la série 9.5 contient des corrections liées notamment à la sécurité, aux requêtes, aux snapshots et à la recherche vectorielle ; certaines capacités restent expérimentales ou en Tech Preview.

**Impact :** inventorier versions et repositories avant mise à niveau, avec un repli pour les fonctions expérimentales.

**Score :** 6/10 — confiance élevée sur les release notes ; exposition de l’environnement Mehdi inconnue.

## 13. Laboratoire guidé — 45 à 60 minutes

### Objectif et prérequis

Comprendre le chemin document → index → recherche et distinguer état du service, données et configuration. Docker installé, 2 Go de mémoire, aucune donnée sensible.

### Déployer

Sécurité désactivée uniquement pour ce laboratoire local :

```sh
docker run --name elasticsearch-lab --rm -p 9200:9200 \
  -e discovery.type=single-node \
  -e xpack.security.enabled=false \
  docker.elastic.co/elasticsearch/elasticsearch:9.5.2

curl http://localhost:9200/
curl http://localhost:9200/_cluster/health
```

### Manipuler

1. Créer `products` avec un mapping explicite pour `name`, `category`, `price` et `description`.
2. Indexer dix documents.
3. Exécuter une recherche plein texte et une agrégation par catégorie.
4. Créer l’alias `products-read` et vérifier le découplage du nom physique.
5. Comparer `GET /_cat/indices?v` et `GET /_cat/shards?v`.

### Résultat attendu

- Le mapping influence le comportement de recherche.
- L’alias découple les clients du nom d’index.
- Un cluster sain ne signifie pas que les données sont sauvegardées.
- Deux différences entre laboratoire et production sont documentées.

### Nettoyer

Arrêter le conteneur avec `Ctrl-C`. L’option `--rm` supprime le conteneur du laboratoire.

## 14. Décisions et actions

1. **Qualifier** — owner : plateforme/observabilité — échéance : 2026-09-03. Inventorier chaque déploiement, version, mode, région, flux, volume, SLO et owner. **Succès :** 100 % des déploiements connus et versionnés.
2. **Tester** — owner : plateforme — échéance : 2026-09-10. Réaliser snapshot/restore et upgrade sur données non sensibles. **Succès :** restore vérifié, RPO/RTO mesurés, requêtes critiques sans régression.
3. **Surveiller** — owner : sécurité — réexamen : 2026-09-03 puis quotidien. Relier release notes, EOL et avis Elastic aux versions. **Succès :** chaque version possède une fenêtre de support.
4. **Décider** — owner : architecture — après qualification. Choisir source de vérité, mode de déploiement et stratégie de sortie. **Succès :** décision documentée par workload et coût.

## 15. Questions de validation

1. Pourquoi Elasticsearch ne doit-il généralement pas être le système de référence d’une transaction métier ?
2. Quelle différence entre index, shard primaire, replica et alias ?
3. Que faut-il dimensionner séparément pour l’ingestion et la recherche ?
4. Pourquoi un snapshot ne suffit-il pas à garantir un rollback applicatif ?
5. Dans quel cas choisir Hosted, Serverless ou ECK plutôt que self-managed ?

**Preuve attendue :** restitution de cinq minutes avec schéma des flux, choix de déploiement justifié et plan de test de restauration.

## 16. Incertitudes et limites

- Version, topologie, workload, coûts, SLO, données sensibles, owner et exposition de la stack Mehdi inconnus.
- Les coûts ne sont pas chiffrables sans métriques d’ingestion, stockage, rétention et requêtes.
- Cette carte ne remplace ni l’inventaire, ni le threat model, ni le capacity plan, ni la preuve de restauration.
- Les fonctionnalités et responsabilités varient selon version, licence et mode de déploiement.

## 17. Sources

- [Elastic — Deploy](https://www.elastic.co/docs/deploy-manage/deploy)
- [Elastic — Distributed architecture](https://www.elastic.co/docs/deploy-manage/distributed-architecture)
- [Elastic — Deployment comparison](https://www.elastic.co/docs/deploy-manage/deploy/deployment-comparison)
- [Elastic — Security](https://www.elastic.co/docs/deploy-manage/security)
- [Elastic — Snapshot and restore](https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore)
- [Elastic — Cloud health and performance metrics](https://www.elastic.co/docs/deploy-manage/monitor/cloud-health-perf)
- [Elastic — Index lifecycle management](https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management)
- [Elastic — Data tiers: hot, warm, cold and frozen](https://www.elastic.co/docs/manage-data/lifecycle/data-tiers)
- [Elastic — Node roles](https://www.elastic.co/docs/deploy-manage/distributed-architecture/clusters-nodes/node-roles)
- [Elastic — Size your shards](https://www.elastic.co/docs/deploy-manage/production-guidance/optimize-performance/size-shards)
- [Elastic — JVM settings](https://www.elastic.co/docs/reference/elasticsearch/jvm-settings)
- [Elastic — Data tier allocation](https://www.elastic.co/docs/reference/elasticsearch/index-settings/data-tier-allocation)
- [Elastic — Product and version EOL policy](https://www.elastic.co/support/eol)
- [Elastic — Elasticsearch release notes](https://www.elastic.co/docs/release-notes/elasticsearch)
- Documents locaux : `state/signals.yaml`, `state/learning.yaml`, `dist/` et historique Git.

**Publication :** destinée au prochain commit local.
