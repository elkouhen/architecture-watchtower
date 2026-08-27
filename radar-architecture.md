Produis le radar hebdomadaire des tendances Cloud, DevOps, architecture applicative et IA de Mehdi.

OBJECTIF
Détecter ce qui émerge ou accélère dans l’architecture logicielle, puis expliquer si cela mérite d’être testé dans une stack AWS/GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform. Le radar est un outil de découverte et de sélection ; ce n’est ni une sentinelle de sécurité ni une liste de releases des produits déjà connus.

CONTEXTE
Lis `state/context.yaml`, `state/signals.yaml` et les rapports locaux. Les sujets prioritaires sont ELK, Elastic APM, Logstash, Kubernetes et l’IA appliquée aux architectures : agents, RAG, middleware, inference gateways, évaluation, observabilité, sécurité et gouvernance.

PÉRIODE ET SOURCES
Recherche les signaux des sept derniers jours et les évolutions de fond des 90 derniers jours. Utilise les sources selon leur rôle :

- **Faits produit :** site officiel, documentation, release notes, changelog, dépôt officiel, page lifecycle et status page ;
- **Traction open source :** GitHub Trending, releases, croissance des stars, contributeurs, forks, issues, discussions et dépendances ;
- **Discussions terrain :** Hacker News, Lobsters, Reddit, forums GitHub, forums Elastic, Slack/Discord publics et Bluesky/Mastodon/X ;
- **Contexte :** CNCF Landscape, blogs d’ingénierie, retours d’expérience et articles de recherche.

Les réseaux sociaux, forums, classements et articles servent à découvrir une tendance. Ils ne confirment pas seuls une maturité, une compatibilité, une performance ou une recommandation. Toute affirmation technique importante doit être confirmée par une source primaire.

FAMILLES À EXPLORER
- patterns d’agents, outils, workflows et human-in-the-loop ;
- observabilité, évaluation, sécurité et gouvernance des systèmes IA ;
- model routing, inference gateways, serving et accélération ;
- Kubernetes pour workloads IA et plateformes internes ;
- OpenTelemetry, eBPF et observabilité runtime ;
- platform engineering, IDP, policy-as-code et workload identity ;
- ELK, Elastic APM, Logstash et alternatives lorsque le besoin d’architecture évolue ;
- stockage vectoriel, RAG, event-driven, serverless et nouvelles primitives Cloud.

SÉLECTION DES TENDANCES
Retient au maximum cinq tendances, en privilégiant les sujets qui montrent au moins deux signaux indépendants parmi : activité de dépôt, release significative, adoption/intégration par un projet reconnu, discussions techniques substantielles, retour d’expérience ou offre managée.

Pour chaque tendance, indique son stade : `signal`, `émergente`, `traction`, `mature`, `en recul` ou `non confirmé`. Une hausse de popularité seule ne suffit pas. Écarte les annonces marketing, démonstrations sans code, benchmarks non reproductibles et projets sans chemin de déploiement.

FORMAT DE CHAQUE TENDANCE

### Nom de la tendance

- **Pourquoi maintenant :** événement ou évolution observée cette semaine ;
- **Preuves de traction :** au moins deux signaux, avec dates et liens ;
- **Fait vérifié :** ce qui est confirmé par une source primaire ;
- **Analyse :** problème d’architecture résolu et pattern associé ;
- **Maturité :** stade, limites, dépendances et risques de verrouillage ;
- **Pertinence pour Mehdi :** lien concret avec AWS/GCP/Kubernetes/CI/CD/observabilité/Terraform ; `confirmée`, `possible` ou `inconnue` ;
- **Architecture cible :** composants, flux, données, identité, déploiement et exploitation ;
- **Test proposé :** environnement, durée, étapes, métriques et résultat attendu ;
- **Décision :** `surveiller`, `tester` ou `écarter` ;
- **Prévision :** horizon 1–3 mois, hypothèse, signaux attendus et décision si elle se confirme ou est infirmée.

Pour l’IA, précise toujours le modèle/fournisseur, les données, le middleware, le coût, la latence, l’évaluation, l’observabilité, les permissions, la validation humaine et le mécanisme de repli. Pour Kubernetes ou un middleware, précise comment le déployer, le mettre à jour et le retirer.

COMPARAISONS
Ne compare AWS, GCP, open source ou produits concurrents que si la tendance crée un choix réel. La comparaison doit se limiter aux critères qui changent la décision : capacité, intégration, sécurité, exploitation, coût, réversibilité et maturité.

LABORATOIRE
Propose au maximum un laboratoire prioritaire par semaine, de moins d’une heure, qui transforme une tendance en preuve. Il doit produire au moins un résultat exploitable : métriques, configuration, trace, benchmark reproductible, diagramme, incident injecté ou décision. Une carte de service détaillée peut être produite séparément.

SORTIE
1. **Les trois tendances à retenir** : une phrase sur le signal, l’intérêt architectural et l’action proposée.
2. **Tendances détaillées** : maximum cinq, avec le format ci-dessus.
3. **À ne pas suivre** : maximum trois sujets écartés et motif.
4. **Laboratoire de la semaine.**
5. **Échéances ou releases importantes** uniquement si elles changent une décision.
6. **Sources consultées** : faits, signaux de traction et sources en échec.

Ne remplis pas le rapport avec des versions de maintenance ou des nouveautés de produits connus, sauf si elles révèlent une tendance architecturale ou créent une décision. Ne produis aucune explication générale qui ne débouche pas sur une décision, une action, un test ou une qualification.

PUBLICATION LOCALE
Écris `dist/AAAA-MM-JJ/radar-architecture.md`, vérifie que chaque tendance possède des preuves, un stade, un impact et une action, puis committe localement le livrable. Même sans tendance confirmée, produis un heartbeat indiquant les familles et sources examinées.

Réponds en français, avec une lecture de moins de quinze minutes.
