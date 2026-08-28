Produis le radar hebdomadaire des tendances Cloud, DevOps, architecture applicative et IA de Mehdi.

OBJECTIF
Détecter largement et le plus tôt possible ce qui émerge ou accélère dans l’architecture logicielle, puis sélectionner ce qui mérite l’attention de Mehdi. Le radar est volontairement agressif sur la remontée des projets intéressants : il préfère signaler tôt un projet encore immature, clairement marqué `signal faible`, plutôt que le découvrir après sa maturité. Il ne transforme jamais cette détection précoce en recommandation d’adoption. Ce n’est ni une sentinelle de sécurité ni une liste de releases des produits déjà connus. Il consacre environ 60 % de l’effort à la découverte large et 40 % au suivi approfondi de Kubernetes, ELK/observabilité et IA appliquée aux architectures.

CONTEXTE
Lis `state/context.yaml`, `state/signals.yaml` et les rapports locaux. Les sujets prioritaires sont ELK, Elastic APM, Logstash, Kubernetes et l’IA appliquée aux architectures : agents, RAG, middleware, inference gateways, évaluation, observabilité, sécurité et gouvernance.

POINT DE VUE D’ARCHITECTE DEVOPS/CLOUD
Pour chaque projet ou pattern, réponds d’abord à quatre questions concrètes : à quoi sert-il dans un système réel, quel problème d’architecture ou d’exploitation résout-il, comment le déployer et l’opérer, et dans quelles conditions ne faut-il pas l’utiliser ? Décris sa place dans les flux, ses dépendances, son identité, ses données, son observabilité, son coût opérationnel, sa mise à jour, son rollback et son retrait lorsque ces éléments influencent la décision. Une tendance n’est intéressante que si son utilité et son chemin de mise en œuvre sont intelligibles.

PÉRIODE ET SOURCES
Utilise trois fenêtres complémentaires : les dernières 48 heures pour les projets qui trendent ASAP, les nouveautés des sept derniers jours pour le rythme hebdomadaire, et les signaux d’émergence des 30 derniers jours pour éviter de rater une tendance qui démarre lentement. Pour les projets très récents, une seule preuve de découverte suffit pour les remonter dans le flux préliminaire.

- **Faits produit :** site officiel, documentation, release notes, changelog, dépôt officiel, page lifecycle et status page ;
- **Traction open source :** GitHub Trending, releases, croissance des stars, contributeurs, forks, issues, discussions et dépendances ;
- **Détection de momentum :** Trendshift, notamment les classements daily/weekly, les mentions live et les projets nouvellement détectés ;
- **Discussions terrain :** Hacker News, Lobsters, Reddit, forums GitHub, forums Elastic, Slack/Discord publics et Bluesky/Mastodon/X ;
- **Contexte :** CNCF Landscape, blogs d’ingénierie, retours d’expérience et articles de recherche.

Les réseaux sociaux, forums, classements — y compris Trendshift — et articles servent à découvrir une tendance. Ils ne confirment pas seuls une maturité, une compatibilité, une performance, une sécurité ou une recommandation. Toute affirmation technique importante doit être confirmée par une source primaire. Pour Trendshift, vérifie systématiquement le dépôt canonique, l’activité récente, le README, la licence, les releases et les signaux de sécurité avant de conserver un projet.

CONTRÔLE QUALITÉ
Avant la sortie, vérifie que chaque projet possède un pitch compréhensible, une date de signal, une URL canonique et un niveau de preuve explicite. Pour chaque affirmation technique, cherche une source primaire ; si elle manque, conserve le projet visible mais marque `signal faible` et indique exactement ce qui manque. Note les sources en échec et les corrections à reporter dans `state/feedback.yaml`.

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
MODE DE DÉTECTION AGRESSIVE
Fais d’abord remonter jusqu’à vingt candidats, et non dix, dès qu’un signal crédible ou précurseur est observé : projet nouvellement classé ou mentionné sur Trendshift, nouveau dépôt actif, accélération des commits/issues/releases, hausse rapide de contributeurs ou d’utilisateurs, projet mis en avant par plusieurs développeurs, release structurante, discussion technique, intégration par un projet reconnu, retour d’expérience, offre managée ou pattern repris par plusieurs équipes. Un seul signal suffit pour la détection. Pour les signaux des dernières 48 heures, un dépôt ou une release techniquement lisible peut être remonté même sans seconde preuve ; marque alors `signal faible`, indique la date exacte et la preuve manquante.

Ne filtre pas prématurément un projet parce qu’il a peu d’étoiles, peu de documentation ou peu d’historique : ce sont des informations de maturité, pas des critères d’invisibilité. En revanche, écarte les dépôts vides, les annonces sans artefact vérifiable, les copies sans différenciation technique et les sujets purement marketing.

Pour les sujets retenus dans le radar principal, cherche ensuite un deuxième indice indépendant et une source primaire lorsque le sujet porte une affirmation technique. Si ces éléments ne sont pas disponibles, conserve le sujet dans `Signaux à surveiller` au lieu de le supprimer.

La seconde preuve est obligatoire pour passer de la détection précoce à `émergente` ou `traction`, mais elle n’est pas obligatoire pour apparaître dans le rapport. Un projet découvert très récemment doit rester visible dans `Projets qui trendent maintenant` même si sa maturité, son adoption et son chemin de production sont encore inconnus.

Pour chaque tendance, indique son stade : `signal faible`, `émergente`, `traction`, `mature`, `en recul` ou `non confirmé`. Une hausse de popularité seule ne suffit pas pour recommander une adoption, mais elle reste utile comme signal de découverte. Écarte seulement les annonces marketing sans élément technique, les démonstrations sans code et les projets sans aucun chemin de déploiement identifiable.

Une fiche pédagogique ou une carte de service n’est déclenchée que si le sujet a un potentiel futur élevé et satisfait le seuil de maturité suivant : documentation officielle, chemin de déploiement reproductible et maintenance active. Sinon, conserve-le dans `Signaux à surveiller` avec la preuve manquante et une date de réexamen.

FORMAT DE CHAQUE TENDANCE

### Nom de la tendance

- **Pitch rapide :** en une ou deux phrases, explique ce que fait le projet ou le pattern, pour quel problème et quel type d’équipe il est utile ; utilise des mots simples et évite le marketing.
- **Utilité d’architecte :** indique le rôle concret dans un système, le problème résolu et le signal qui justifierait de l’introduire ;
- **Pourquoi maintenant :** événement ou évolution observée cette semaine ;
- **Preuves de traction :** signaux observés, avec dates et liens ; indique `signal faible` s’il n’y en a qu’un ;
- **Fait vérifié :** ce qui est confirmé par une source primaire ;
- **Analyse :** problème d’architecture résolu et pattern associé ;
- **Maturité :** stade, limites, dépendances et risques de verrouillage ;
- **Architecture cible :** composants, flux, données, identité, déploiement et exploitation ;
- **Mise en œuvre et exploitation :** prérequis, mode de déploiement, intégration à la stack, upgrade, rollback, supervision et condition de retrait ;
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
2. **Projets qui trendent maintenant** : jusqu’à dix projets détectés dans les dernières 48 heures ou les sept derniers jours, avec nom, URL canonique, **pitch rapide de 1–2 phrases**, date du signal, preuve de traction ou signal précurseur, intérêt architectural, stade (`signal faible` par défaut si nécessaire), preuve manquante et date de réexamen. Le pitch doit permettre de comprendre immédiatement le projet sans ouvrir ses sources. Cette section doit rester présente même si aucun projet n’est assez mûr pour une fiche.
3. **Tendances détaillées** : nombre variable, plafonné par une lecture de 30 minutes, avec le format ci-dessus. Chaque tendance retenue doit avoir une synthèse courte avant son développement.
4. **Signaux à surveiller** : jusqu’à dix candidats encore faibles, avec signal observé, source de découverte et information manquante pour les qualifier.
5. **À ne pas suivre** : maximum trois sujets écartés et motif.
6. **Laboratoire de la semaine**, uniquement si un candidat le justifie.
7. **Échéances ou releases importantes** uniquement si elles changent une décision.
8. **Sources consultées** : faits, signaux de traction, sources de découverte et sources en échec.

La priorité de détection est, dans cet ordre : fraîcheur du signal, vitesse d’accélération, potentiel futur, maturité et facilité d’adoption, pertinence pour la stack actuelle, puis valeur pédagogique. La maturité ne se déduit jamais de la popularité seule. La priorité de décision reste : potentiel futur, maturité, facilité d’adoption et pertinence pour la stack.

Ne remplis pas le rapport avec des versions de maintenance ou des nouveautés de produits connus, sauf si elles révèlent une tendance architecturale ou créent une décision. Ne produis aucune explication générale qui ne débouche pas sur une décision, une action, un test ou une qualification.

PUBLICATION LOCALE
Écris `dist/AAAA-MM-JJ/radar-architecture.md`, vérifie que chaque tendance possède un stade, un signal, un impact et une action ou une information manquante, puis committe localement le livrable. Même sans tendance qualifiée, produis les signaux faibles détectés et indique précisément ce qui manque pour les confirmer. Un radar vide n’est acceptable que si les sources de découverte ont réellement été consultées et qu’aucun signal exploitable n’a été trouvé.

Réponds en français, avec une lecture de moins de trente minutes. La section `Projets qui trendent maintenant` doit rester très scannable : une ou deux lignes de pitch par projet avant les tendances détaillées. Le pitch est une `Analyse` ou une `Inférence` clairement identifiée, jamais un fait présenté sans source.
