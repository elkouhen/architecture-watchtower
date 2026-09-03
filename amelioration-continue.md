# Démarche d’amélioration continue

## Objectif

Améliorer séparément la qualité de l’analyse et la qualité du sourcing, sans augmenter le bruit. La veille doit devenir plus rapide pour détecter les projets intéressants, plus fiable dans ses faits et plus concrète sur l’utilisation, le déploiement et l’exploitation.

## Boucle de travail

1. **Reprendre :** déterminer la borne de collecte à partir du dernier `last_success` de chaque source et rattraper tout intervalle manquant dans la limite de trente jours.
2. **Détecter :** contrôler AWS, GCP et IA sur les quatre voies obligatoires, rechercher largement dans les fenêtres du radar ou de la carte demandée et consigner les sources consultées, y compris les échecs.
3. **Réexaminer :** traiter les signaux arrivés à échéance avant d’en sélectionner de nouveaux et dater le motif de fermeture, report ou maintien.
4. **Qualifier :** séparer `Fait`, `Analyse`, `Inférence` et `Décision`; confirmer les affirmations techniques avec une source primaire et noter séparément impact, urgence, pertinence stack et confiance.
5. **Livrer :** produire le rapport avec pitch, utilité, mise en œuvre, limites et action lorsque ces éléments sont connus.
6. **Valider :** exécuter `ruby scripts/validate_watchtower.rb --report <livrable>` et corriger tout échec avant commit.
7. **Évaluer :** inscrire le retour dans `state/feedback.yaml` : exactitude, source, valeur architecturale, clarté, action et bruit.
8. **Améliorer :** ne modifier qu’une règle de prompt ou de sourcing à la fois, puis vérifier son effet sur un rapport suivant.

## Rythme

- **À chaque radar :** prouver la couverture AWS/GCP/IA, mettre à jour le journal de collecte et traiter les échéances atteintes.
- **Après chaque radar ou carte :** corriger les erreurs certaines, noter les sources en échec et exécuter le validateur.
- **Chaque semaine :** examiner les signaux bruyants, les projets utiles et les sujets manqués ; ajouter au plus trois feedbacks prioritaires.
- **Chaque mois :** calculer les tendances de qualité, revoir les sources et décider d’une seule évolution de prompt.
- **Chaque trimestre :** retirer les sources mortes, vérifier la couverture des domaines et réviser les seuils de sélection.

## Indicateurs

- exactitude factuelle moyenne ;
- part des faits importants appuyés par une source primaire ;
- délai entre première détection et première source primaire ;
- taux de voies AWS/GCP/IA contrôlées avec succès ;
- âge du dernier succès par source et volume d’intervalle rattrapé ;
- part de nouveaux projets open source dans la sélection, cible 33 % sauf exception motivée ;
- ratio signaux utiles / signaux remontés ;
- nombre de faux positifs (`noise`) ;
- nombre de signaux manqués (`missed`) ;
- part des tendances avec pitch, utilité et chemin de mise en œuvre ;
- délai entre signal, expérimentation et décision.
- nombre d’échéances dépassées sans réexamen, cible zéro.

## Règle de décision

Une amélioration n’est conservée que si elle augmente la valeur architecturale ou la fiabilité sans dégrader fortement la fraîcheur de détection. Un projet immature peut être remonté tôt, mais doit rester explicitement `signal faible` et ne pas devenir une recommandation d’adoption.

## Responsabilités

Les owners et seuils opérationnels restent `à qualifier` tant que la stack réelle n’est pas accessible. Les commits Git locaux constituent la preuve des livraisons ; aucun rapport ne doit être envoyé par un connecteur externe.
