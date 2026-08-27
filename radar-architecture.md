Produis le radar hebdomadaire Cloud, DevOps, architecture applicative et IA de Mehdi.

OBJECTIF
Transformer les évolutions de la semaine en choix d’architecture ou en expérimentations concrètes pour construire, déployer et exploiter des systèmes sur AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform.

CONTEXTE ET PÉRIODE
Lis `state/context.yaml`, `state/signals.yaml` et les rapports locaux. Analyse les sept derniers jours et déduplique avec les 90 derniers jours. Priorise ELK, Elastic APM, Logstash, Kubernetes et l’IA appliquée aux architectures : trends, patterns, agents, RAG, middlewares, évaluation, sécurité et observabilité.

SÉLECTION
Retient au maximum cinq sujets. Un sujet n’entre dans le radar que s’il possède au moins un impact plausible sur la stack, une action possible ou une expérimentation utile. Écarte les annonces marketing, benchmarks non reproductibles et tendances sans cas d’usage.

FORMAT DE CHAQUE SUJET
- **Changement :** fait vérifié, version/date et URL primaire ;
- **Pourquoi cela compte :** problème d’architecture ou d’exploitation concerné ;
- **Pertinence :** confirmée, possible ou inconnue pour la stack ;
- **Architecture concernée :** composants, flux et environnement impactés ;
- **Choix :** surveiller, évaluer, tester ou adopter ;
- **Plan concret :** étapes de déploiement ou d’intégration, avec Terraform/Kubernetes/CI-CD si pertinent ;
- **Exploitation :** métriques, alertes, sauvegarde, upgrade et panne principale ;
- **Test :** durée, prérequis, charge, résultat attendu et condition de passage ;
- **Owner et échéance :** personne ou équipe à désigner si inconnue ;
- **Prévision :** horizon 1–3 mois, hypothèse, signaux attendus et décision si elle se confirme ou est infirmée.

N’ajoute une comparaison AWS/GCP/open source que si elle modifie réellement le choix. Pour une Preview, beta ou disponibilité limitée, indique le repli et interdis son usage comme contrôle critique.

APPRENTISSAGE
Propose au maximum un laboratoire hebdomadaire prioritaire, réalisable en moins d’une heure. Il doit produire une preuve : configuration, métriques, résultat de test, diagramme ou décision. Une carte de service détaillée peut être demandée séparément.

SORTIE
1. Synthèse en trois décisions maximum : ce qui change, l’impact et quoi faire cette semaine.
2. Sujets retenus avec le format ci-dessus.
3. Échéances et fins de support réellement actionnables.
4. Laboratoire prioritaire.
5. Sources consultées et sources en échec.

Ne produis aucune explication générale qui ne débouche pas sur une décision, une action, un test ou une qualification. Si l’environnement ou la version sont inconnus, écris-le et propose l’étape minimale pour lever l’incertitude.

PUBLICATION LOCALE
Écris `dist/AAAA-MM-JJ/radar-architecture.md`, vérifie la présence de faits sourcés, d’actions et de critères de succès, puis committe localement le livrable. Même sans nouveauté, conserve un heartbeat court.

Réponds en français, avec une lecture de moins de quinze minutes.
