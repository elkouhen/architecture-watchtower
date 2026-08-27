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
6. **Variantes de déploiement** : self-managed, managé, Kubernetes/serverless si pertinent ; responsabilité de l’équipe versus fournisseur, fonctionnalités perdues et hypothèse de choix.
7. **État Mehdi** : environnement, version, topologie, criticité, données, dépendances et owner. Toute information absente vaut `à qualifier` ; ne jamais déduire une exposition.
8. **Données et cycle de vie** : modèle, schéma, indexation, rétention, archivage, migration, sauvegarde/restauration, compatibilité et dates de support.
9. **Exploitation** : upgrades/rollback, observabilité, SLO/alertes, capacité, maintenance, compétences et modes de panne connus.
10. **Sécurité et responsabilités** : identité et rôles, secrets, chiffrement, réseau, audit, vulnérabilités connues et partage des responsabilités par mode.
11. **Économie et alternatives** : coûts/charge opérationnelle, option open source, équivalent GCP, équivalent AWS, verrouillage et réversibilité. Employer `pas d’équivalent direct` lorsque nécessaire.
12. **Quand l’utiliser / l’éviter** : critères de fit, anti-patterns et conditions de sortie.
13. **Évolutions depuis la dernière carte** : maximum cinq, avec date, fait vérifié, impact, score de pertinence sur 10, confiance et URL primaire.
14. **Laboratoire guidé** : objectif, prérequis, commandes ou étapes de déploiement minimal, scénario d’utilisation, observation attendue, nettoyage et critère de réussite en moins de 60 minutes.
15. **Décisions et actions** : action, propriétaire, échéance ou date de réexamen, livrable et critère de succès si un test est proposé.
16. **Validation de compréhension** : cinq questions d’architecte et une réponse attendue ou un exercice de restitution.
17. **Incertitudes et limites** : inventaire manquant, sources échouées, hypothèses et conséquences.
18. **Sources effectivement consultées** : URL, titre court, date de consultation et statut (`consultée` ou `échec`).

## Règles de précision

- Ne pas présenter la version publiée comme la version déployée.
- Ne pas présenter une alerte comme une exposition confirmée.
- Toujours expliquer au moins un déploiement local reproductible et un déploiement de production réaliste ; séparer clairement les deux.
- Décrire au moins un chemin d’utilisation concret, avec entrée, traitement, sortie et vérification.
- Faire progresser le niveau pédagogique : une carte de niveau `pratique` doit contenir un laboratoire exécutable, pas seulement des recommandations.
- Pour une Preview, beta ou disponibilité limitée, proposer un repli et interdire son usage comme contrôle critique de production.
- Tout test doit avoir une durée maximale, un owner et un critère de succès mesurable.
- Une carte globale peut dépasser deux pages si nécessaire, mais doit rester lisible : un schéma textuel, des tableaux courts et cinq évolutions maximum.

## Sortie et publication

Écrire dans `dist/<date_du_jour>/carte-<service>.md`, sans écraser une autre date. Le fichier doit être non vide et contenir au moins trois sources primaires, les sections obligatoires et des dates cohérentes.

Après validation, committer localement le fichier. Consigner le hash du commit dans le journal local si un journal de publication est utilisé. Ne pas envoyer la carte par email.

Répondre en français.
