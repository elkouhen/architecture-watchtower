# Radar architecture — 2026-08-29

Sources de découverte : Trendshift daily du 29/08/2026 et Google Trends. Trendshift indique aujourd’hui JiuwenSwarm en rang 1, PRAXIST en rang 2 et Archify en rang 4 ; Google Trends a été consulté mais aucune comparaison exploitable n’a pu être récupérée dans cet environnement. Les signaux de découverte ne prouvent pas à eux seuls maturité, sécurité ou adoption.

## openJiuwen-ai/jiuwenswarm

- **Pitch rapide :** JiuwenSwarm est une plateforme d’agents collaboratifs capables de décomposer une tâche, d’orchestrer plusieurs agents, d’appeler des outils et de fonctionner sur une machine ou un cluster. Elle cible les workflows complexes qui nécessitent des étapes, de la supervision humaine et une réutilisation des skills.
- **Utilité :** intéressante pour étudier un orchestrateur multi-agents avec workflows déterministes, budget de tokens, permissions d’outils et exécution distribuée. Elle peut inspirer une plateforme interne, mais ne doit pas être introduite avant d’avoir clarifié isolation, secrets, coûts et observabilité.
- **Preuves de traction :** Trendshift daily rang 1 le 29/08, dépôt primaire avec 2 274 commits, 4,8 k stars, 793 forks, 792 issues et 325 pull requests ; ces chiffres indiquent une forte activité mais pas une maturité de production. Fait vérifié : le README documente déploiement local/cluster, HITL, skills, permissions avec approbation, APIs OpenAI-compatible et métriques de cycle de vie encore limitées.

### Description précise — si le sujet mérite un approfondissement

Architecture possible : orchestrateur leader → agents spécialisés → outils/MCP → systèmes externes, avec registre de skills, budget par tâche, identité par agent et validation humaine pour les actions sensibles. Le dépôt propose installation Python, Docker et exécution distribuée ; le premier test doit rester local, sur données synthétiques, avec allowlist d’outils, limites réseau et traces de chaque étape. Décision proposée : `surveiller`, puis `tester` seulement après vérification de la licence, du modèle de permissions, de l’observabilité et du comportement en reprise sur erreur.

## sapientinc/PRAXIST

- **Pitch rapide :** PRAXIST transforme une recherche technique en processus persistant avec pairs parallèles, évaluations propres à chaque tâche, preuves durables et synthèse entre générations. Il est utile lorsque l’objectif est mesurable mais que la meilleure méthode reste inconnue.
- **Utilité :** signal intéressant pour les plateformes d’expérimentation et d’évaluation d’agents : il rapproche recherche, exécution, preuves et décision. Pour un architecte, la valeur potentielle est la reproductibilité des essais, pas l’autonomie sans contrôle.
- **Preuves de traction :** Trendshift daily rang 2 le 29/08 ; dépôt primaire avec 4 commits, 244 forks et 1 issue. Fait vérifié : le README documente runtime Python, tâches de recherche, intégrations d’agents et scripts d’installation ; la maturité opérationnelle et la licence Fair Source doivent être examinées avant usage.

### Description précise — si le sujet mérite un approfondissement

Architecture possible : planificateur → pairs de recherche parallèles → outils/modèles → stockage d’évidence → évaluateur → synthèse versionnée. Tester avec une question technique bornée, un budget fixe et un corpus connu ; mesurer coût, durée, couverture des sources, reproductibilité et taux d’erreurs. Décision proposée : `tester` en environnement isolé si la politique de données et la licence sont compatibles ; aucun accès direct à des systèmes de production.

## tt-a1i/archify

- **Pitch rapide :** Archify génère des diagrammes d’architecture, de workflow, de séquence et de cycle de vie à partir d’un codebase ou d’une description, sous forme d’artefacts HTML/SVG vérifiables. Il peut accélérer les revues et l’onboarding lorsque la documentation dérive du code.
- **Utilité :** utile pour produire une première vue exploitable d’un système et détecter les écarts entre documentation et implémentation. Il mérite un test CI limité si les sorties sont relues par un humain et comparées aux manifestes, traces ou contrats réels.
- **Preuves de traction :** Trendshift daily rang 4 le 29/08 ; dépôt primaire précédemment vérifié avec IR JSON typée, validation/rendu Node.js, sorties autonomes et activité importante. Le gain de qualité sur grands dépôts reste à mesurer.

### Description précise — si le sujet mérite un approfondissement

Architecture possible : dépôt → extraction/IR → validation → HTML/SVG publié avec le commit. Tester 45 minutes sur un service non sensible : comparer cinq composants et trois flux générés aux manifestes Kubernetes et à la documentation, puis mesurer omissions et faux liens. Décision proposée : `tester` en local, avec rendu manuel de repli et interdiction d’utiliser le diagramme comme source d’autorité unique.

## GetBusbar/busbar

- **Pitch rapide :** Busbar est une gateway IA self-hosted qui centralise routage multi-modèles, failover, budgets, credentials et preuves d’exécution. Elle se place entre les applications ou agents et les fournisseurs de modèles ou d’outils.
- **Utilité :** candidat prioritaire pour étudier le pattern AI execution gateway et la gouvernance du chemin synchrone. Il faut le comparer à une gateway existante en tenant compte de la latence, de la couverture fournisseurs, du risque de panne centralisée et de la gestion des secrets.
- **Preuves de traction :** projet featured sur Trendshift le 29/08 ; dépôt primaire documentant binaire Rust, Helm, Prometheus/OTLP, mTLS, pools pondérés et circuit breakers. Les benchmarks annoncés restent à reproduire.

## oomol-lab/open-connector

- **Pitch rapide :** OpenConnector fournit une gateway de connecteurs pour agents avec OAuth, scopes, politiques, logs, MCP, HTTP et OpenAPI. Elle garde les credentials derrière le runtime et propose des déploiements Docker, Kubernetes, Cloudflare ou Fly.io.
- **Utilité :** utile pour étudier la séparation entre agent et accès aux SaaS, notamment l’identité, les permissions et les contrats d’actions. Le sujet mérite une qualification sécurité avant toute connexion à des données réelles.
- **Preuves de traction :** projet featured sur Trendshift le 29/08 ; dépôt primaire documentant Helm, PostgreSQL, migrations explicites, tokens runtime, allow/block policies et logs redigés, avec 5,4 k stars et 461 forks observés précédemment. Les scopes et exécuteurs fournisseurs doivent être audités.

## JetBrains/go-modern-guidelines

- **Pitch rapide :** ce dépôt fournit des consignes destinées aux agents de code pour écrire du Go moderne. Il transforme des conventions d’ingénierie en contexte versionné, complémentaire du lint, des tests et de la revue humaine.
- **Utilité :** intéressant pour tester le pattern `engineering policy as agent context` et réduire les corrections répétitives dans les dépôts Go. Il ne doit pas remplacer les contrôles de compilation, sécurité ou comportement.
- **Preuves de traction :** Trendshift daily du 28/08 et GitHub Trending Go #1 signalé le 27/08 ; dépôt primaire public sous Apache-2.0. L’impact sur les défauts et le temps de revue reste à mesurer.

## Sujets écartés

- Crypto-miner remonté par Trendshift : écarté pour risque évident et absence d’intérêt architectural.
- Projets purement vidéo, UI ou desktop : écartés car sans impact Cloud/DevOps démontré.
- Google Trends : aucun résultat n’est utilisé comme preuve, l’exploration ciblée n’ayant pas été récupérée.

## Sources consultées

- [Trendshift](https://trendshift.io/) : classement daily, featured et mentions live du 29/08/2026.
- [JiuwenSwarm](https://github.com/openJiuwen-ai/jiuwenswarm), [PRAXIST](https://github.com/sapientinc/PRAXIST), [Archify](https://github.com/tt-a1i/archify), [Busbar](https://github.com/GetBusbar/busbar), [OpenConnector](https://github.com/oomol-lab/open-connector), [go-modern-guidelines](https://github.com/JetBrains/go-modern-guidelines) : vérification primaire.
- [Google Trends](https://trends.google.com/trends/) : page consultée ; exploration multi-termes indisponible dans l’environnement.
