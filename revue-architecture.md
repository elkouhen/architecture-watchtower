Produis la revue mensuelle stratégique Cloud, DevOps, architecture et IA de Mehdi.

OBJECTIF
Décider quoi construire, déployer, exploiter, tester, continuer ou arrêter. La revue contrôle les résultats des actions précédentes ; elle ne compile pas les rapports hebdomadaires.

ENTRÉES
Lis `state/context.yaml`, les rapports `dist/` et `state/` des six derniers mois, en donnant priorité au dernier mois. Vérifie les faits déterminants auprès de sources primaires. Évalue les décisions par rapport à AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform.

REVUE DES PRÉVISIONS
Pour les prévisions du mois précédent, indique : prévision, résultat observé, écart, cause probable et ajustement de l’hypothèse. Ne formule une nouvelle prévision que si elle entraîne une décision ou une préparation concrète.

DÉCISIONS
Présente au maximum trois décisions, chacune avec :
- problème ou opportunité ;
- fait vérifié et source primaire ;
- impact sur une architecture ou une opération ;
- décision : `adopter`, `tester`, `évaluer`, `surveiller` ou `éviter` ;
- owner, échéance, coût/effort approximatif et critère de réussite ;
- risque principal, repli et condition de réexamen.

PLAN D’EXÉCUTION
Définis au maximum trois actions du mois suivant, classées par priorité. Pour chaque action : première étape, livrable attendu, owner, date et décision conditionnelle (« si… alors… »).

TESTS ET APPRENTISSAGE
Propose au maximum trois expérimentations. Chaque test doit avoir un problème concret, une hypothèse, un environnement, une durée maximale, des métriques, un résultat attendu et une décision de sortie. Priorise les tests qui améliorent la capacité à concevoir, déployer ou exploiter.

À ARRÊTER OU À REPORTER
Indique au maximum trois sujets à abandonner ou reporter, avec le motif : absence d’impact, immaturité, coût, doublon, non-exposition ou absence de preuve. Donne une condition de retour si elle existe.

FORMAT
1. Réponse directe : trois décisions maximum.
2. Résultats des actions et prévisions du mois précédent.
3. Décisions du mois.
4. Plan d’exécution et expérimentations.
5. Sujets arrêtés ou reportés.
6. Échéances des 90 prochains jours.
7. Sources et incertitudes.

N’ajoute une comparaison AWS/GCP/open source ou une analyse de compétences que si elle change une décision. N’invente ni exposition, ni owner, ni capacité. Utilise `à qualifier` lorsque l’information manque.

PUBLICATION LOCALE
Écris `dist/AAAA-MM-JJ/revue-architecture.md`, vérifie que chaque décision a une action et une preuve, puis committe localement le livrable. La preuve de publication est le hash du commit Git local.

Réponds en français, avec un ton direct et une lecture de moins de trente minutes.
