# CARTE SERVICE — [ELASTICSEARCH](https://www.elastic.co/elasticsearch)

Date : 2026-08-27. Type : `service`. Version de référence documentée : Elastic Stack `9.5.2`. Version réellement déployée : `à qualifier`.

## 1. RÉSUMÉ DÉCISIONNEL

Elasticsearch est un moteur distribué de recherche et d’analytique pour documents, logs, événements, observabilité et recherche hybride/vectorielle. Pour ta stack, il se place dans ELK et peut compléter CloudWatch ; il ne remplace pas une base transactionnelle. Décision : `évaluer` la version et le mode de déploiement avant upgrade.

## 2. POSITION DANS LE SYSTÈME

```text
applications / agents / Kubernetes
        │ logs, événements, traces, documents
        ▼
Logstash / Elastic Agent / APM / OpenTelemetry
        ▼
Elasticsearch ──► Kibana, alertes, recherche, IA
        │
        └──── snapshots ───► repository externe
```

Producteurs : applications, Logstash, Elastic Agent, APM et OpenTelemetry. Consommateurs : Kibana, APIs de recherche, alertes, sécurité et applications IA. Les données de référence restent dans le système métier lorsqu’une réindexation est possible.

## 3. MODÈLE MENTAL

À l’écriture, un pipeline parse/enrichit, le mapping indexe les champs et le document va vers un shard primaire ; segments, translog et replicas contribuent à la durabilité. À la lecture, le nœud coordinateur interroge les shards concernés, fusionne les résultats et renvoie hits, scores et agrégations. Un replica et un snapshot ne répondent pas au même besoin : le premier aide la disponibilité, le second la reprise.

## 4. DÉPLOIEMENT

**Local :** Docker, un nœud, données non sensibles, sécurité adaptée au laboratoire.

**Production réaliste :** ECK sur Kubernetes si l’équipe veut opérer l’instance dans ses clusters ; Hosted/Serverless si la réduction de charge d’exploitation est prioritaire. Le choix dépend de la capacité à gérer TLS, stockage, upgrades, snapshots, réseau et coûts.

Pour un cluster distribué : séparer progressivement master, data, ingest et coordinating ; placer les replicas dans un autre domaine de panne ; tester la perte d’un nœud et la restauration d’un snapshot. Les détails de tiers hot/warm/cold/frozen ne sont pertinents que si la rétention le justifie.

## 5. DONNÉES ET CYCLE DE VIE

Mappings et templates doivent être versionnés. Utiliser data streams/rollover et ILM si les logs ont une rétention définie. Définir âge, taille, performance, coût et critère de suppression pour chaque tier. Les snapshots doivent être stockés hors cluster et restaurés périodiquement.

## 6. EXPLOITATION ET DIMENSIONNEMENT

| Charge | Ressource | Métrique | Décision |
|---|---|---|---|
| ingestion, parsing, merges | CPU + I/O | débit, CPU, merge time, rejets bulk | ajouter CPU/ingest ou accélérer le disque |
| recherches concurrentes | CPU + shards | p95/p99, search queue, fan-out | revoir requêtes/shards ou ajouter des nœuds |
| agrégations et mappings | RAM/heap | heap pressure, GC, breakers | revoir mapping/requête ou augmenter RAM |
| index chaud | filesystem cache + SSD | latence disque, IOPS, cache | augmenter cache ou utiliser stockage plus rapide |
| rétention/replicas | disque | volume, watermarks, merges | augmenter capacité ou déplacer vers un tier |

Calcul initial : `volume primaire × replicas × durée`, puis overhead d’indexation, merges, snapshots et marge avant watermark. Le heap JVM ne doit généralement pas dépasser 50 % de la RAM du nœud ; le reste sert notamment au filesystem cache. La capacité doit être validée avec les débits et requêtes réels, pas déduite d’une taille universelle.

## 7. SÉCURITÉ

RBAC, comptes de service distincts, TLS, clés à privilèges minimaux, réseau privé, audit si requis et filtrage des données sensibles APM/IA. Qualifier la responsabilité selon self-managed, ECK, Hosted ou Serverless.

## 8. CHOIX ET LIMITES

À utiliser pour recherche plein texte/hybride, logs, événements, observabilité et RAG mesuré. À éviter comme source unique pour transactions ACID, relations complexes ou données impossibles à réindexer/exporter. Comparer OpenSearch, base relationnelle ou object storage uniquement si le workload rend le choix réel.

## 9. ÉVOLUTIONS

- Elastic Stack `9.5.2` est la version actuelle documentée : https://www.elastic.co/docs/release-notes ;
- Logstash `9.5.2` possède des notes de version dédiées : https://www.elastic.co/docs/release-notes/logstash ;
- un incident Elastic Cloud APM Serverless a été résolu le 26 août : https://status.elastic.co/.

Impact : inventorier les versions, les endpoints APM et les repositories avant toute mise à niveau. Exposition de la stack : `inconnue`.

## 10. LABORATOIRE — 45 À 60 MINUTES

1. Démarrer Elasticsearch/Kibana `9.5.2` localement avec des données non sensibles.
2. Créer un index `products` avec mapping explicite et dix documents.
3. Exécuter recherche plein texte, filtre et agrégation.
4. Créer un alias de lecture et vérifier le découplage du nom physique.
5. Injecter un événement Logstash ou un document APM simulé et vérifier sa recherche.
6. Observer index, shards et métriques de base.

Succès : mapping, alias, flux d’ingestion et distinction cluster sain/sauvegarde sont démontrés ; deux différences local/production sont documentées.

## 11. INCERTITUDES ET SOURCES

Inconnus : version déployée, topologie, mode, régions, volumes, débit, rétention, SLO/RPO/RTO, coûts, données sensibles et owner. Sources consultées :

- https://www.elastic.co/docs/release-notes ;
- https://www.elastic.co/docs/release-notes/logstash ;
- https://www.elastic.co/docs/deploy-manage/distributed-architecture ;
- https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore ;
- https://www.elastic.co/docs/reference/elasticsearch/jvm-settings ;
- https://www.elastic.co/docs/deploy-manage/production-guidance/optimize-performance/size-shards.

Références vérifiées le 27 août 2026. Publication locale après validation du fichier.
