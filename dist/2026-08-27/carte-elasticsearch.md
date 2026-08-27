# CARTE GLOBALE DU SERVICE — ELASTICSEARCH — 2026-08-27

## 1. IDENTITÉ
Service : Elasticsearch
Éditeur/projet : Elastic / Elasticsearch
Catégorie : plateforme distribuée de recherche, analytique, observabilité, sécurité et recherche vectorielle
URL canonique : https://www.elastic.co/docs
Version publiée de référence observée : 9.5.2. Ce n’est pas la version déployée chez Mehdi.
Statut de la carte : référence globale initiale ; la prochaine exécution recherchera les changements et complétera l’inventaire local.
Axe pédagogique : fondamental.
Niveau visé : compréhension, avec premier passage vers la pratique.
Prérequis : HTTP/JSON, Docker et notions de stockage distribué ; aucun prérequis Kubernetes pour le laboratoire local.

## 2. RÉSUMÉ DÉCISIONNEL
Fait : Elasticsearch est un moteur distribué qui indexe des documents JSON et les rend interrogeables par recherche, agrégations et APIs.
Analyse : il s’agit moins d’une base de données généraliste que d’une plateforme d’indexation et de recherche spécialisée, dont la performance dépend fortement du modèle de données, des mappings, des shards, du stockage et de la charge de requête.
Décision proposée : ÉVALUER / MAINTENIR sous contrôle. Utiliser pour recherche, événements et observabilité lorsque la latence de recherche et les agrégations justifient un moteur dédié ; conserver une source de vérité réindexable ou exportable.

## 3. POSITION DANS LE SYSTÈME
Problèmes résolus : trouver rapidement des documents, agréger des événements, explorer des logs/métriques/traces, détecter des signaux de sécurité ou effectuer de la recherche vectorielle.
Producteurs : applications via clients REST/SDK, Elastic Agent/Beats, Logstash, APM, OTLP et pipelines d’ingestion.
Consommateurs : applications de recherche, Kibana, dashboards, alertes, Elastic Security, jobs analytiques et assistants/retrievers IA.
Entrées : documents JSON, événements temporels, champs texte/keyword/numériques, vecteurs, métadonnées et pipelines.
Sorties : hits classés, agrégations, résultats ES|QL/SQL, données visualisées, alertes et APIs de supervision.
Compléments : Kibana est l’interface d’exploration/gestion ; Elastic Agent, Beats, Logstash et APM alimentent ou enrichissent la plateforme. Elasticsearch ne remplace pas automatiquement la base transactionnelle, l’object storage ni le bus d’événements.
Inférence : dans une architecture applicative, Elasticsearch doit généralement être un read model/index de recherche, non le seul système de référence d’une transaction métier.

## 4. CARTE FONCTIONNELLE
| Capacité | Ce que le service fournit | Conséquence d’architecture |
| Recherche | Recherche plein texte, filtres, tri, pagination et pertinence. | Mapping, analyse linguistique, index inversé et tests de pertinence deviennent des artefacts versionnés. |
| Analytique | Agrégations, ES|QL et exploration de séries temporelles. | Prévoir cardinalité, fenêtres temporelles, limites de mémoire et coût des requêtes. |
| Observabilité | Ingestion et analyse de logs, métriques, traces et APM avec l’écosystème Elastic. | Rétention, rollover, sampling et séparation des flux déterminent le coût. |
| Sécurité | Recherche et corrélation de signaux de sécurité, selon les produits/licences et le déploiement. | Contrôler RBAC, audit, rétention et accès aux données sensibles. |
| Vector search / IA | Stockage et recherche de vecteurs, enrichissement et endpoints d’inférence selon version/licence. | Tester rappel, latence, coût, fraîcheur et repli vers une recherche lexicale. |
| Gestion de données | Templates, mappings, pipelines, aliases, data streams, ILM ou Data Stream Lifecycle. | Ces objets doivent être livrés comme code et testés avec les données. |

Plan de données : ingestion → parsing/enrichissement → routage vers index/data stream → écriture dans les shards → recherche/agrégation → exposition aux consommateurs.
Plan de contrôle : configuration cluster → sécurité et utilisateurs → templates/pipelines/lifecycle → allocation et capacité → snapshots/restore → supervision et alertes.
Interfaces principales : HTTP/REST, clients officiels, Bulk API, APIs d’indexation/recherche, ingest pipelines, snapshots/SLM et interfaces Kibana.

## 5. CARTE D’ARCHITECTURE
Schéma logique :

```text
  Producteurs (apps, Agent/Beats, Logstash, APM, OTLP)
          │
          ▼
  Ingest nodes / pipelines ──► index ou data stream ──► shards primaires
                                                          │
                                      réplication         ▼
                                                shards replicas sur autres nœuds/zones
                                                          │
          ┌───────────────────────────────────────────────┴────────────────┐
          ▼                                                                ▼
  Coordinating nodes / APIs                                      Snapshots vers repository externe
          │
          ▼
  Applications, Kibana, alertes, sécurité, analytics et retrievers IA
```

Fait : un cluster répartit les documents en shards primaires et copies ; les rôles de nœuds et l’allocation structurent la capacité et la résilience.
Fait : segments Lucene, translog et réplication participent au chemin d’écriture ; les snapshots copient les segments disponibles des primaires vers un repository hors cluster.
Analyse : séparer les domaines de panne, éviter le sur-sharding, protéger les nœuds cluster-manager et mesurer séparément ingestion, recherche, merge, récupération et snapshot.
Limite : la limite de shards protège contre une dérive mais n’est pas une cible de dimensionnement ; trop de shards dégradent récupération et opérations.

## 6. VARIANTES DE DÉPLOIEMENT
| Mode | Ce qui est géré | Ce qui reste à décider | Points d’attention |
| Self-managed | L’équipe gère infrastructure et stack. | Nœuds, JVM, disques, réseau, TLS, upgrades, snapshots, SLO. | Charge d’exploitation et risque d’erreur élevés ; contrôle maximal. |
| ECK | Un opérateur Kubernetes orchestre Elastic sur Kubernetes. | Capacité Kubernetes, CRDs, stockage, upgrades, sécurité et sauvegardes. | Deux plans de cycle de vie : Kubernetes/ECK et Elastic Stack. |
| ECE | Elastic Cloud Enterprise orchestre des déploiements sur l’infrastructure choisie. | Plateforme ECE, capacité, réseau, versions et politique de sauvegarde. | Complexité de la plateforme multi-tenant. |
| Elastic Cloud Hosted | Elastic gère la plateforme ; l’équipe choisit déploiement, ressources et version. | Topologie logique, données, accès, coûts, snapshots et SLO. | Contrôle inférieur au self-managed ; dépendance au fournisseur. |
| Elastic Cloud Serverless | Elastic gère cluster, scaling, nœuds, shards et répliques. | Projet, données, rétention, APIs, limites et coût à l’usage. | ILM, réglages cluster et certaines fonctions ne sont pas disponibles ; prévoir la réversibilité. |

Fait : Hosted et Serverless sont disponibles sur AWS, Azure et GCP selon la comparaison Elastic ; Serverless automatise davantage et n’expose pas les mêmes capacités que Hosted.
État Mehdi : mode de déploiement à qualifier.

## 7. ÉTAT MEHDI
Environnement : à qualifier (production, préproduction ou laboratoire).
Version déployée : à qualifier.
Topologie et régions : à qualifier.
Volumes : à qualifier (documents/jour, taille primaire, croissance, indexation et requêtes).
Criticité : à qualifier (recherche applicative, logs, sécurité, métriques/traces, vecteurs, PII).
Dépendances : à qualifier (Kubernetes, stockage objet, réseau privé, clients, Kibana, Agent/Beats, Logstash, APM, OpenTelemetry).
SLO/RPO/RTO : à qualifier.
Owner : équipe plateforme/observabilité à nommer.
Exposition : inconnue ; cette carte ne prouve aucune exposition à une vulnérabilité.

## 8. DONNÉES ET CYCLE DE VIE
Modèle : documents JSON semi-structurés, index/data streams, mappings, templates, aliases, pipelines et feature states.
Schéma : mapping explicite recommandé pour les champs critiques ; surveiller le dynamic mapping et la croissance du nombre de champs.
Rétention : rollover et suppression par âge/taille/volume ; pour les déploiements versionnés, ILM peut gérer les phases et tiers. En Serverless, le Data Stream Lifecycle remplace ILM pour les besoins couverts.
Sauvegarde : snapshots vers un repository hors cluster ; ils peuvent inclure état cluster, templates, pipelines, ILM et feature states, mais pas les fichiers de configuration ni les repositories enregistrés.
Restauration : impossible vers une version antérieure ; tester un restore réel, les index métier et les feature states. Un snapshot n’est pas une stratégie de rollback applicatif.
Migration : reindexation, aliases, double écriture ou restauration contrôlée selon RPO/RTO ; tester clients, analyzers, mappings, templates et Kibana.
Support : la politique Elastic consultée indique une fin de maintenance du cœur 9.x au 15 octobre 2027 ; la série 8.x a une fin de maintenance au 15 janvier 2027 et une fin de support au 15 juillet 2027.

## 9. EXPLOITATION
Cycle normal : définir mapping/templates → ingérer en bulk → contrôler refresh/latence → rollover → mesurer shards/segments/disque → snapshot → vérifier restore → planifier upgrade.
Indicateurs : disponibilité recherche, p95/p99 latence, taux d’erreur, rejet bulk, retard d’ingestion, refresh/merge, shards non alloués, JVM/memory pressure, disque, snapshots, recovery et taille des queues.
Pannes à prévoir : disque plein, shard non alloué, split-brain/élection, surcharge heap, requête coûteuse, mapping explosion, retard d’ingestion, repository indisponible et restauration trop lente.
Upgrade/rollback : version, plugins, clients et compatibilité à inventorier ; tester sur environnement représentatif. Rollback binaire non présumé : utiliser chemin de version supporté, snapshots/reindex et plan de retour applicatif.
Observabilité : Fait : Elastic recommande Stack Monitoring en production et permet un déploiement de monitoring séparé pour conserver les données de diagnostic lors d’une panne.
Compétences : modélisation de recherche, Lucene/shards, capacity planning, tuning JVM/disque, lifecycle, sécurité, Kubernetes/ECK et tests de restauration.

## 10. SÉCURITÉ ET RESPONSABILITÉS
Contrôles : authentification, RBAC, TLS HTTP/transport, filtrage réseau, chiffrement au repos selon le mode, keystore et audit selon disponibilité/licence.
Self-managed/ECK : l’équipe configure et prouve TLS, secrets, disque, réseau, rôles, audit et rotation.
Hosted/Serverless : Elastic gère davantage de contrôles par défaut ; l’équipe reste responsable des rôles, accès, données, réseau autorisé, clés/API keys et conformité d’usage.
Mesures minimales : comptes de service distincts, privilèges minimaux par flux, API keys à durée contrôlée, secrets hors code, accès privé, audit activé si requis et test négatif des rôles.
Vulnérabilités : à qualifier par version et mode ; aucune alerte ne prouve l’exposition du parc Mehdi.

## 11. ÉCONOMIE ET ALTERNATIVES
| Option | Valeur | Charge / coût | Réversibilité |
| Self-managed / open source | Contrôle complet et fonctionnalités choisies. | Infrastructure + exploitation élevée ; vérifier licence et fonctionnalités. | Export/reindex possible, mais mappings, analyzers et APIs créent du couplage. |
| Elastic Cloud Hosted sur GCP | Elasticsearch managé sur GCP, pas un service natif Google. | Ressources provisionnées + gestion réseau/accès/contrat. | Snapshots et APIs Elastic ; tester sortie vers self-managed ou autre région. |
| Elastic Cloud Hosted sur AWS | Elasticsearch managé sur AWS ; OpenSearch Service est une alternative distincte. | Ressources provisionnées + réseau/accès/contrat. | Migration vers OpenSearch non transparente ; compatibilité à prouver. |
| Elastic Cloud Serverless | Faible charge d’infrastructure et scaling géré. | Paiement à l’usage ; coûts à corréler à ingestion, stockage et requêtes. | Couplage au modèle Serverless et aux APIs disponibles ; plan de sortie requis. |

## 12. QUAND L’UTILISER / L’ÉVITER
À utiliser pour : recherche plein texte ou hybride, logs/événements à forte exploration, agrégations temporelles, observabilité Elastic, sécurité et cas vectoriels avec métriques de qualité mesurables.
À éviter comme seul système de référence pour : transactions fortement cohérentes, relations complexes, écritures nécessitant contraintes ACID riches, données dont la réindexation est impossible ou rétention illimitée sans budget contrôlé.
À éviter en production critique : fonctions Preview/beta/Tech Preview sans repli, preuve de support, audit et test de restauration.

## 13. ÉVOLUTIONS DEPUIS LA DERNIÈRE CARTE
Mise à jour — Fait : les release notes consultées indiquent Elasticsearch 9.5.2 comme version publiée de référence et listent des mises à jour de bibliothèques ainsi que des corrections sur sécurité, requêtes, snapshots et recherche vectorielle.
Mise à jour — Fait : 9.5.0 ajoute la vérification de la protection contre l’écrasement dans l’analyse des repositories ; plusieurs capacités 9.5 restent expérimentales ou en Tech Preview.
Impact : inventorier les versions et repositories avant toute mise à niveau ; maintenir un repli pour les fonctions expérimentales.
Score : 6/10 ; confiance élevée pour les faits de release, exposition Mehdi inconnue.
Source primaire : https://www.elastic.co/docs/release-notes/elasticsearch

## 14. LABORATOIRE GUIDÉ — 45 À 60 MINUTES
Objectif : comprendre le cycle document → index → recherche et distinguer état du service, données et configuration.
Prérequis : Docker installé, 2 Go de mémoire disponibles, aucune donnée sensible.
Déploiement local minimal (sécurité désactivée uniquement pour le laboratoire) :

```sh
  docker run --name elasticsearch-lab --rm -p 9200:9200 -e discovery.type=single-node -e xpack.security.enabled=false docker.elastic.co/elasticsearch/elasticsearch:9.5.2
  curl http://localhost:9200/
  curl http://localhost:9200/_cluster/health
```

Étapes :

  1. Créer `products` avec un mapping explicite pour `name`, `category`, `price` et `description`.
  2. Indexer dix documents, puis exécuter une recherche plein texte et une agrégation par catégorie.
  3. Créer un alias `products-read`, modifier un document, puis vérifier l’alias.
  4. Comparer `GET /_cat/indices?v` et `GET /_cat/shards?v`.
Scénario d’utilisation : une application écrit un produit en JSON ; Elasticsearch l’analyse et l’indexe ; l’application recherche `chaussure running` et reçoit hits + score + agrégation.
Observations attendues : le mapping influence la recherche ; un alias découple le consommateur du nom physique ; la persistance dépend du stockage configuré ; un cluster sain ne signifie pas que les données sont sauvegardées.
Nettoyage : arrêter le conteneur avec Ctrl-C ; le mode `--rm` supprime le conteneur sans supprimer d’autres volumes Docker.
Critère de réussite : expliquer le chemin d’écriture et de recherche, produire une requête fonctionnelle, et citer deux différences entre laboratoire et production.
Source du déploiement : https://www.elastic.co/docs/deploy-manage/deploy

## 15. DÉCISIONS ET ACTIONS
1. **QUALIFIER** — owner : plateforme/observabilité — échéance : 2026-09-03 — inventaire de chaque déploiement, version, mode, région, flux, volumes, SLO et owner — succès : 100 % des déploiements connus et versionnés.
2. **TESTER** — owner : plateforme — échéance : 2026-09-10 — lab de snapshot/restore et upgrade sur données non sensibles, durée maximale 2 heures — succès : restore vérifié, RPO/RTO mesurés, aucune régression de requête critique.
3. **SURVEILLER** — owner : sécurité — réexamen : 2026-09-03 puis quotidien — release notes, EOL et avis Elastic reliés aux versions inventoriées — succès : chaque version possède une fenêtre de maintenance/support.
4. **DÉCIDER** — owner : architecture — réexamen : après qualification — choisir source de vérité, mode de déploiement et stratégie de sortie — succès : décision documentée par workload et coût.

## 16. VALIDATION DE COMPRÉHENSION
1. Pourquoi Elasticsearch ne doit-il généralement pas être le système de référence d’une transaction métier ?
2. Quelle différence entre index, shard primaire, replica et alias ?
3. Que faut-il dimensionner séparément pour l’ingestion et la recherche ?
4. Pourquoi un snapshot ne suffit-il pas à garantir un rollback applicatif ?
5. Dans quel cas choisir Hosted, Serverless ou ECK plutôt que self-managed ?
Réponse attendue : restitution orale ou écrite de cinq minutes avec un schéma des flux, un choix de déploiement justifié et un plan de test de restauration.

## 17. INCERTITUDES ET LIMITES
- Version, topologie, workload, coûts, SLO, données sensibles, owner et exposition de la stack Mehdi sont inconnus.
- Les coûts ne sont pas chiffrables sans ingestion, stockage, rétention, requêtes, région et mode.
- La carte décrit le service global ; elle ne remplace pas l’inventaire, le threat model, le capacity plan ni la preuve de restauration.
- Les fonctionnalités et responsabilités varient selon version, licence et mode de déploiement.
Statut de publication : à inclure dans le prochain commit local.

## 18. SOURCES EFFECTIVEMENT CONSULTÉES
[consultée] Elastic — Deploy : https://www.elastic.co/docs/deploy-manage/deploy
[consultée] Elastic — Distributed architecture : https://www.elastic.co/docs/deploy-manage/distributed-architecture
[consultée] Elastic — Detailed deployment comparison : https://www.elastic.co/docs/deploy-manage/deploy/deployment-comparison
[consultée] Elastic — Security : https://www.elastic.co/docs/deploy-manage/security
[consultée] Elastic — Snapshot and restore : https://www.elastic.co/docs/deploy-manage/tools/snapshot-and-restore
[consultée] Elastic — Cloud deployment health and performance metrics : https://www.elastic.co/docs/deploy-manage/monitor/cloud-health-perf
[consultée] Elastic — ILM concepts : https://www.elastic.co/docs/manage-data/lifecycle/index-lifecycle-management
[consultée] Elastic — Product and version EOL policy : https://www.elastic.co/support/eol
[consultée] Elastic — Elasticsearch release notes : https://www.elastic.co/docs/release-notes/elasticsearch
[consultée] Documents locaux — state/signals.yaml, dist/ et historique Git : consultés
[échec] Aucun échec de consultation retenu.
