# Démarche d’amélioration continue

## Objectif

Améliorer séparément la qualité de l’analyse et la qualité du sourcing, sans augmenter le bruit. La veille doit devenir plus rapide pour détecter les projets intéressants, plus fiable dans ses faits et plus concrète sur l’utilisation, le déploiement et l’exploitation.

## Boucle de travail

1. **Détecter :** rechercher largement dans les fenêtres du radar ou de la carte demandée et consigner les sources consultées, y compris les échecs.
2. **Qualifier :** séparer `Fait`, `Analyse`, `Inférence` et `Décision`; confirmer les affirmations techniques avec une source primaire.
3. **Livrer :** produire le rapport avec pitch, utilité, mise en œuvre, limites et action lorsque ces éléments sont connus.
4. **Évaluer :** inscrire le retour dans `state/feedback.yaml` : exactitude, source, valeur architecturale, clarté, action et bruit.
5. **Réexaminer :** comparer le signal aux faits observés à la date prévue et classer le résultat `confirmed`, `useful`, `noise`, `missed` ou `pending`.
6. **Améliorer :** ne modifier qu’une règle de prompt ou de sourcing à la fois, puis vérifier son effet sur un rapport suivant.

## Rythme

- **Après chaque radar ou carte :** corriger les erreurs certaines et noter les sources en échec.
- **Chaque semaine :** examiner les signaux bruyants, les projets utiles et les sujets manqués ; ajouter au plus trois feedbacks prioritaires.
- **Chaque mois :** calculer les tendances de qualité, revoir les sources et décider d’une seule évolution de prompt.
- **Chaque trimestre :** retirer les sources mortes, vérifier la couverture des domaines et réviser les seuils de sélection.

## Indicateurs

- exactitude factuelle moyenne ;
- part des faits importants appuyés par une source primaire ;
- délai entre première détection et première source primaire ;
- ratio signaux utiles / signaux remontés ;
- nombre de faux positifs (`noise`) ;
- nombre de signaux manqués (`missed`) ;
- part des tendances avec pitch, utilité et chemin de mise en œuvre ;
- délai entre signal, expérimentation et décision.

## Règle de décision

Une amélioration n’est conservée que si elle augmente la valeur architecturale ou la fiabilité sans dégrader fortement la fraîcheur de détection. Un projet immature peut être remonté tôt, mais doit rester explicitement `signal faible` et ne pas devenir une recommandation d’adoption.

## Responsabilités

Les owners et seuils opérationnels restent `à qualifier` tant que la stack réelle n’est pas accessible. Les commits Git locaux constituent la preuve des livraisons ; aucun rapport ne doit être envoyé par un connecteur externe.
