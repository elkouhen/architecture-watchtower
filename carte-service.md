# Carte quotidienne d’un service — consigne

## Objectif

Produis chaque jour une carte précise d’un service Cloud, DevOps, observabilité, sécurité ou architecture demandé. La carte doit être exploitable par un architecte : elle décrit le rôle du service, ses dépendances, ses modes de déploiement, ses contraintes opérationnelles et les changements récents qui peuvent modifier une décision.

La carte n’est ni une brochure marketing ni une recommandation d’adoption. Elle distingue toujours `Fait`, `Analyse`, `Inférence` et `Décision proposée`.

## Entrées et déduplication

1. Lire cette consigne avant la recherche.
2. Consulter `state/signals.yaml` pour les signaux déjà connus.
3. Rechercher les cartes locales `dist/*/carte-<service>.txt` et les rapports de veille locaux sur les 30 derniers jours ; compléter avec `state/signals.yaml` si le service y est cité.
4. Ne signaler une évolution que si la version, le statut, la sécurité, le coût, la compatibilité, la date de support ou la recommandation a changé. Sinon conserver la carte comme `heartbeat` sans inventer de nouveauté.
5. Prioriser la documentation, les release notes, les avis de sécurité, les pages de lifecycle, les dépôts et les matrices de compatibilité officielles. Une source secondaire sert uniquement à expliquer un fait déjà confirmé.

## Formalisation obligatoire

Chaque fichier doit contenir les champs suivants, dans cet ordre :

1. **Identité** : service, éditeur/projet, catégorie, date de la carte, URL canonique, dernière version ou `non déterminée`.
2. **Résumé décisionnel** : rôle, cas d’usage, décision actuelle (`surveiller`, `évaluer`, `tester`, `adopter`, `éviter`) et justification en trois lignes maximum.
3. **État Mehdi** : environnement, version, topologie, criticité, données, dépendances et owner. Toute information absente vaut `à qualifier` ; ne jamais déduire une exposition.
4. **Modèle d’architecture** : composants, flux, état, partitionnement/réplication, haute disponibilité, reprise après sinistre et limites de dimensionnement.
5. **Exploitation** : déploiement, upgrades/rollback, sauvegarde/restauration, observabilité, SLO/alertes, capacité, maintenance et compétences nécessaires.
6. **Sécurité** : identité et rôles, secrets, chiffrement en transit et au repos, réseau, audit, vulnérabilités connues et responsabilités par mode de déploiement.
7. **Données et compatibilité** : rétention, migration, compatibilité client/API/index ou schéma, breaking changes, lifecycle et dates de support.
8. **Comparaison** : option open source, équivalent GCP, équivalent AWS, coût/charge opérationnelle, verrouillage et réversibilité. Employer `pas d’équivalent direct` lorsque nécessaire.
9. **Évolutions depuis la dernière carte** : maximum cinq, avec date, fait vérifié, impact, score de pertinence sur 10, confiance et URL primaire.
10. **Décisions et actions** : action, propriétaire, échéance ou date de réexamen, livrable et critère de succès si un test est proposé.
11. **Incertitudes et limites** : inventaire manquant, sources échouées, hypothèses et conséquences.
12. **Sources effectivement consultées** : URL, titre court, date de consultation et statut (`consultée` ou `échec`).

## Règles de précision

- Ne pas présenter la version publiée comme la version déployée.
- Ne pas présenter une alerte comme une exposition confirmée.
- Pour une Preview, beta ou disponibilité limitée, proposer un repli et interdire son usage comme contrôle critique de production.
- Tout test doit avoir une durée maximale, un owner et un critère de succès mesurable.
- Une carte reste concise : deux pages de texte environ, cinq évolutions maximum.

## Sortie et publication

Écrire dans `dist/<date_du_jour>/carte-<service>.txt`, sans écraser une autre date. Le fichier doit être non vide et contenir au moins trois sources primaires, les sections obligatoires et des dates cohérentes.

Après validation, committer localement le fichier. Consigner le hash du commit dans le journal local si un journal de publication est utilisé. Ne pas envoyer la carte par email.

Répondre en français.
