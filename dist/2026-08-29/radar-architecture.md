# Radar architecture — 2026-08-29

## openJiuwen-ai/jiuwenswarm

- **Pitch rapide :** JiuwenSwarm est une plateforme d’agents collaboratifs capables de décomposer une tâche, d’orchestrer plusieurs agents, d’appeler des outils et de fonctionner sur une machine ou un cluster. Elle cible les workflows complexes qui nécessitent des étapes, de la supervision humaine et une réutilisation des skills.
- **Utilité :** intéressante pour étudier un orchestrateur multi-agents avec workflows déterministes, budget de tokens, permissions d’outils et exécution distribuée. Elle peut inspirer une plateforme interne, mais ne doit pas être introduite avant d’avoir clarifié isolation, secrets, coûts et observabilité.
- **Preuves de traction :** Trendshift daily rang 1 le 29/08, dépôt primaire avec 2 274 commits, 4,8 k stars, 793 forks, 792 issues et 325 pull requests ; ces chiffres indiquent une forte activité mais pas une maturité de production. Fait vérifié : le README documente déploiement local/cluster, HITL, skills, permissions avec approbation, APIs OpenAI-compatible et métriques de cycle de vie encore limitées.

### Description précise

Architecture possible : orchestrateur leader → agents spécialisés → outils/MCP → systèmes externes, avec registre de skills, budget par tâche, identité par agent et validation humaine pour les actions sensibles. Le dépôt propose installation Python, Docker et exécution distribuée ; le premier test doit rester local, sur données synthétiques, avec allowlist d’outils, limites réseau et traces de chaque étape. Décision proposée : `surveiller`, puis `tester` seulement après vérification de la licence, du modèle de permissions, de l’observabilité et du comportement en reprise sur erreur.

## sapientinc/PRAXIST

- **Pitch rapide :** PRAXIST transforme une recherche technique en processus persistant avec pairs parallèles, évaluations propres à chaque tâche, preuves durables et synthèse entre générations. Il est utile lorsque l’objectif est mesurable mais que la meilleure méthode reste inconnue.
- **Utilité :** signal intéressant pour les plateformes d’expérimentation et d’évaluation d’agents : il rapproche recherche, exécution, preuves et décision. Pour un architecte, la valeur potentielle est la reproductibilité des essais, pas l’autonomie sans contrôle.
- **Preuves de traction :** Trendshift daily rang 2 le 29/08 ; dépôt primaire avec 4 commits, 244 forks et 1 issue. Fait vérifié : le README documente runtime Python, tâches de recherche, intégrations d’agents et scripts d’installation ; la maturité opérationnelle et la licence Fair Source doivent être examinées avant usage.

### Description précise

Architecture possible : planificateur → pairs de recherche parallèles → outils/modèles → stockage d’évidence → évaluateur → synthèse versionnée. Tester avec une question technique bornée, un budget fixe et un corpus connu ; mesurer coût, durée, couverture des sources, reproductibilité et taux d’erreurs. Décision proposée : `tester` en environnement isolé si la politique de données et la licence sont compatibles ; aucun accès direct à des systèmes de production.

## Sujets non republies

Archify, Busbar, OpenConnector, go-modern-guidelines, WorkWeave/router, WeMM-Embedding, Tailcat, Orca et Agent Sandbox ont déjà été présentés dans les rapports précédents. Leur présence persistante ou leur changement de rang Trendshift ne constitue pas une évolution substantielle ; ils ne sont donc pas répétés dans ce radar.

## Sources consultées

- [Trendshift](https://trendshift.io/) : classement daily du 29/08/2026 ; JiuwenSwarm rang 1 et PRAXIST rang 2.
- [JiuwenSwarm](https://github.com/openJiuwen-ai/jiuwenswarm) et [PRAXIST](https://github.com/sapientinc/PRAXIST) : vérification primaire.
- [Google Trends](https://trends.google.com/trends/) : page consultée, mais exploration multi-termes indisponible dans l’environnement ; aucun signal de recherche utilisé.
