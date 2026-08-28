Produis le radar hebdomadaire des tendances Cloud, DevOps, architecture applicative et IA de Mehdi.

OBJECTIF
Détecter largement ce qui émerge ou accélère dans l’architecture logicielle, puis sélectionner ce qui mérite l’attention de Mehdi. Le radar est un outil de découverte et de sélection ; ce n’est ni une sentinelle de sécurité ni une liste de releases des produits déjà connus. Il consacre environ 60 % de l’effort à la découverte large et 40 % au suivi approfondi de Kubernetes, ELK/observabilité et IA appliquée aux architectures.

CONTEXTE
Lis `state/context.yaml`, `state/signals.yaml` et les rapports locaux. Les sujets prioritaires sont ELK, Elastic APM, Logstash, Kubernetes et l’IA appliquée aux architectures : agents, RAG, middleware, inference gateways, évaluation, observabilité, sécurité et gouvernance.

PÉRIODE ET SOURCES
Utilise deux fenêtres complémentaires : les nouveautés des sept derniers jours pour le rythme hebdomadaire, et les signaux d’émergence des 30 derniers jours pour éviter de rater une tendance qui démarre lentement. Utilise les sources selon leur rôle :

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

EXCLUSIONS
Écarte les annonces de modèles, benchmarks ou levées de fonds sans conséquence architecturale démontrée, les nouveautés purement applicatives/frontend et les releases de maintenance sans impact de sécurité, compatibilité, architecture ou exploitation.

SÉLECTION DES TENDANCES
Fais d’abord remonter jusqu’à dix candidats dès qu’un signal crédible est observé : nouveau dépôt actif, hausse d’activité, release structurante, discussion technique, intégration par un projet reconnu, retour d’expérience, offre managée ou pattern repris par plusieurs équipes. Un seul signal suffit pour la détection, mais marque alors le sujet `signal faible` et ne propose pas d’adoption.

Pour les sujets retenus dans le radar principal, cherche ensuite un deuxième indice indépendant et une source primaire lorsque le sujet porte une affirmation technique. Si ces éléments ne sont pas disponibles, conserve le sujet dans `Signaux à surveiller` au lieu de le supprimer.

Pour chaque tendance, indique son stade : `signal faible`, `émergente`, `traction`, `mature`, `en recul` ou `non confirmé`. Une hausse de popularité seule ne suffit pas pour recommander une adoption, mais elle reste utile comme signal de découverte. Écarte seulement les annonces marketing sans élément technique, les démonstrations sans code et les projets sans aucun chemin de déploiement identifiable.

Une fiche pédagogique ou une carte de service n’est déclenchée que si le sujet a un potentiel futur élevé et satisfait le seuil de maturité suivant : documentation officielle, chemin de déploiement reproductible et maintenance active. Sinon, conserve-le dans `Signaux à surveiller` avec la preuve manquante et une date de réexamen.

FORMAT DE CHAQUE TENDANCE

### Nom de la tendance

- **Pourquoi maintenant :** événement ou évolution observée cette semaine ;
- **Preuves de traction :** signaux observés, avec dates et liens ; indique `signal faible` s’il n’y en a qu’un ;
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
2. **Tendances détaillées** : nombre variable, plafonné par une lecture de 30 minutes, avec le format ci-dessus. Chaque tendance retenue doit avoir une synthèse courte avant son développement.
3. **Signaux à surveiller** : jusqu’à cinq candidats encore faibles, avec signal observé, source de découverte et information manquante pour les qualifier.
4. **À ne pas suivre** : maximum trois sujets écartés et motif.
5. **Laboratoire de la semaine**, uniquement si un candidat le justifie.
6. **Échéances ou releases importantes** uniquement si elles changent une décision.
7. **Sources consultées** : faits, signaux de traction, sources de découverte et sources en échec.

La priorité de sélection est, dans cet ordre : potentiel futur, maturité et facilité d’adoption, pertinence pour la stack actuelle, puis valeur pédagogique. La maturité ne se déduit jamais de la popularité seule.

Ne remplis pas le rapport avec des versions de maintenance ou des nouveautés de produits connus, sauf si elles révèlent une tendance architecturale ou créent une décision. Ne produis aucune explication générale qui ne débouche pas sur une décision, une action, un test ou une qualification.

PUBLICATION LOCALE
Écris `dist/AAAA-MM-JJ/radar-architecture.md`, vérifie que chaque tendance possède un stade, un signal, un impact et une action ou une information manquante, puis committe localement le livrable. Même sans tendance qualifiée, produis les signaux faibles détectés et indique précisément ce qui manque pour les confirmer. Un radar vide n’est acceptable que si les sources de découverte ont réellement été consultées et qu’aucun signal exploitable n’a été trouvé.

Réponds en français, avec une lecture de moins de quinze minutes.
