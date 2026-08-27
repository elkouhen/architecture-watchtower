# Carte quotidienne d’un service — consigne

## Objectif

Produis chaque jour une carte précise d’un produit Cloud, DevOps, observabilité, sécurité ou architecture. La carte est un dossier d’apprentissage pour Mehdi : elle doit permettre de comprendre le modèle mental du produit, de l’utiliser, de le déployer et d’en discuter les compromis comme un architecte.

La carte n’est ni une brochure marketing ni une recommandation d’adoption. Elle distingue toujours `Fait`, `Analyse`, `Inférence` et `Décision proposée`.

## Entrées et déduplication

1. Lire cette consigne avant la recherche.
2. Consulter `state/signals.yaml` pour les signaux déjà connus.
3. Rechercher les cartes locales `dist/*/carte-<service>.md` et les rapports de veille locaux sur les 30 derniers jours ; compléter avec `state/signals.yaml` si le service y est cité.
4. Ne signaler une évolution que si la version, le statut, la sécurité, le coût, la compatibilité, la date de support ou la recommandation a changé. Sinon conserver la carte comme `heartbeat` sans inventer de nouveauté.
5. Prioriser la documentation, les release notes, les avis de sécurité, les pages de lifecycle, les dépôts et les matrices de compatibilité officielles. Une source secondaire sert uniquement à expliquer un fait déjà confirmé.

## Sélection pédagogique

Chaque exécution choisit un produit selon l’un de ces axes :

- **Fondamental** : produit structurant à connaître (Kubernetes, Kafka, Elasticsearch, Terraform, PostgreSQL, Redis, CI/CD) ;
- **Tendance** : produit ou capacité qui progresse et mérite une évaluation ;
- **Pont** : produit qui relie plusieurs concepts déjà étudiés.

La sélection doit indiquer le niveau (`découverte`, `compréhension`, `pratique`, `transmissible`), les prérequis et la raison d’apprentissage du jour. Une nouveauté médiatique sans cas d’usage ni laboratoire reste `à surveiller`.

## Formalisation obligatoire

Chaque fichier doit contenir les champs suivants, dans cet ordre :

1. **Identité** : service, éditeur/projet, catégorie, date de la carte, URL canonique, dernière version ou `non déterminée`.
2. **Résumé décisionnel** : rôle, cas d’usage, décision actuelle (`surveiller`, `évaluer`, `tester`, `adopter`, `éviter`) et justification en trois lignes maximum.
3. **Position dans le système** : problèmes résolus, utilisateurs, producteurs, consommateurs, entrées, sorties, données traversantes et services remplacés ou complémentaires.
4. **Carte fonctionnelle** : capacités principales, sous-composants, APIs/interfaces, traitements synchrones et asynchrones, plan de données et plan de contrôle.
5. **Carte d’architecture** : diagramme textuel des flux, état, partitionnement/réplication, haute disponibilité, reprise après sinistre et limites de dimensionnement.
   Pour tout service distribué ou stateful, détailler obligatoirement :
   - les rôles des composants ou nœuds et leurs responsabilités (par exemple control plane, master, data, ingest, worker, coordinator) ;
   - les communications entre rôles, les dépendances, les ports/interfaces et les chemins de panne ;
   - le partitionnement, la réplication, le quorum, l’élection, le placement multi-zone et le rééquilibrage ;
   - les classes de stockage ou de données (par exemple hot, warm, cold, frozen), leurs critères d’entrée/sortie, leur coût et leurs performances ;
   - les flux d’écriture, de lecture, de réplication, de sauvegarde/restauration et de migration ;
   - un diagramme séparant clairement plan de données, plan de contrôle et chemins d’administration.
6. **Variantes de déploiement** : self-managed, managé, Kubernetes/serverless si pertinent ; responsabilité de l’équipe versus fournisseur, fonctionnalités perdues et hypothèse de choix.
7. **Données et cycle de vie** : modèle, schéma, indexation, rétention, archivage, migration, sauvegarde/restauration, compatibilité et dates de support.
8. **Exploitation** : upgrades/rollback, observabilité, SLO/alertes, capacité, maintenance, compétences et modes de panne connus.
   La capacité doit comporter une première hypothèse chiffrée : charge CPU, mémoire et heap, stockage utile et provisionné, IOPS/latence disque, réseau, croissance, rétention, réplication et marge de sécurité. Relie explicitement chaque hypothèse de charge à la ressource sollicitée, à la métrique de confirmation et à l’action de redimensionnement. Explique ce qui sature en premier et quelles métriques permettent de le confirmer.
9. **Sécurité et responsabilités** : identité et rôles, secrets, chiffrement, réseau, audit, vulnérabilités connues et partage des responsabilités par mode.
10. **Économie et alternatives** : coûts/charge opérationnelle, option open source, équivalent GCP, équivalent AWS, verrouillage et réversibilité. Employer `pas d’équivalent direct` lorsque nécessaire.
11. **Quand l’utiliser / l’éviter** : critères de fit, anti-patterns et conditions de sortie.
12. **Évolutions depuis la dernière carte** : maximum cinq, avec date, fait vérifié, impact, score de pertinence sur 10, confiance et URL primaire.
13. **Laboratoire guidé** : objectif, prérequis, commandes ou étapes de déploiement minimal, scénario d’utilisation, observation attendue, nettoyage et critère de réussite en moins de 60 minutes.
14. **Incertitudes et limites** : inventaire manquant, sources échouées, hypothèses et conséquences.
15. **Sources effectivement consultées** : URL, titre court, date de consultation et statut (`consultée` ou `échec`).

## Règles de précision

- Ne pas présenter la version publiée comme la version déployée.
- Ne pas présenter une alerte comme une exposition confirmée.
- Toujours expliquer au moins un déploiement local reproductible et un déploiement de production réaliste ; séparer clairement les deux.
- Décrire au moins un chemin d’utilisation concret, avec entrée, traitement, sortie et vérification.
- Pour un service distribué, fournir une section de dimensionnement explicite :
  - hypothèses d’entrée (débit, taille moyenne, pics, rétention, requêtes concurrentes, SLA/SLO, RPO/RTO) ;
  - méthode de calcul ou ordres de grandeur, avec unités et marge ;
  - tableau « charge → ressource → métrique → décision », notamment pour CPU, RAM/heap, filesystem cache, stockage/IOPS et réseau ;
  - répartition CPU/RAM/heap, stockage/IOPS et réseau par rôle ;
  - au moins trois topologies : laboratoire, petite production et production multi-zone ;
  - seuils de saturation, signaux d’alerte et procédure de redimensionnement ;
  - distinction entre capacité théorique du produit et capacité validée par test.
- Pour les services à données chaudes et froides, expliquer la politique de transition, le mécanisme de migration, les performances attendues, le coût relatif, la restauration et le comportement en cas de retour vers un tier précédent.
- Pour Elasticsearch ou un moteur comparable, traiter explicitement les rôles master/data/ingest/coordinating, les shards primaires/replicas, l’allocation multi-zone, les tiers hot/warm/cold/frozen, le sizing CPU-RAM-heap-disque-IOPS-réseau, le nombre de shards et la stratégie de rollover/ILM. Si le concept n’existe pas pour le service étudié, écrire `non applicable` et expliquer l’équivalent.
- Faire progresser le niveau pédagogique : une carte de niveau `pratique` doit contenir un laboratoire exécutable, pas seulement des recommandations.
- Pour une Preview, beta ou disponibilité limitée, proposer un repli et interdire son usage comme contrôle critique de production.
- Tout test doit avoir une durée maximale, un owner et un critère de succès mesurable.
- Toute prévision doit préciser son horizon, son hypothèse, les signaux attendus et la décision à prendre si elle se confirme ou est infirmée.
- Une carte globale peut dépasser deux pages si nécessaire, mais doit rester lisible : une hiérarchie de titres cohérente, des paragraphes courts, des listes, des tableaux courts, un schéma textuel dans un bloc `text`, les commandes dans un bloc `sh` et cinq évolutions maximum. Ne jamais utiliser un titre Markdown pour une simple action, une question ou une ligne de liste.

## Sortie et publication

Écrire dans `dist/<date_du_jour>/carte-<service>.md`, sans écraser une autre date. Le fichier doit être non vide et contenir au moins trois sources primaires, les sections obligatoires et des dates cohérentes.

Après validation, committer localement le fichier. Consigner le hash du commit dans le journal local si un journal de publication est utilisé. Ne pas envoyer la carte par email.

Répondre en français.
