# Radar architecture — 2026-08-28

Fenêtres observées : 48 h pour le momentum immédiat, 7 jours pour les évolutions récentes, 30 jours pour les signaux d’émergence. Trendshift a été utilisé comme source de découverte ; les affirmations techniques sont confirmées dans les dépôts primaires lorsque possible.

## 1. Les trois tendances à retenir

1. **Les artefacts d’architecture deviennent exécutables et vérifiables.** Archify est fortement remonté sur Trendshift et transforme une description de système ou un dépôt en carte interactive validable. Action : surveiller puis tester sur un petit dépôt, sans lui déléguer la vérité architecturale.
2. **Le routage dynamique des modèles devient une brique de plateforme.** WorkWeave/router matérialise le pattern « endpoint unique, choix de modèle en amont ». Action : qualifier la latence, les règles, les données envoyées et le coût avant tout essai.
3. **Les plateformes d’agents se structurent autour de primitives d’exécution.** Agent Sandbox, OpenAgentPack et les projets repérés sur Trendshift convergent vers isolation, cycle de vie, outils et gouvernance. Action : poursuivre le test Kubernetes Agent Sandbox, mais traiter les nouveaux projets comme des signaux faibles.

## 2. Projets qui trendent maintenant

| Projet | Pitch rapide | Signal et stade | Intérêt architectural / manque | Réexamen |
|---|---|---|---|---|
| [tt-a1i/archify](https://github.com/tt-a1i/archify) | Produit des cartes d’architecture interactives à partir d’un dépôt ou d’une description, avec une représentation intermédiaire typée et des sorties HTML/SVG autonomes. Utile aux équipes plateforme et architecture qui veulent rendre une vue système révisable. | Trendshift daily, rang 2, 28/08 ; `émergente` | Source primaire lisible ; manque de preuve d’adoption et de robustesse sur grands dépôts. | 05/09 |
| [workweave/router](https://github.com/workweave/router) | Propose un point d’entrée de routage pour choisir un modèle selon la requête ou la politique. Le pattern peut centraliser coût, latence et fallback des agents. | Trendshift daily, rang 10, 28/08 ; `signal faible` | README primaire à qualifier plus finement, métriques annoncées non vérifiées indépendamment. | 05/09 |
| [Tencent/WeMM-Embedding](https://github.com/Tencent/WeMM-Embedding) | Famille d’embeddings multimodaux destinée à rapprocher compréhension et recherche de contenus texte, image ou autres modalités. Intéressant pour des RAG où les documents ne sont pas uniquement textuels. | Trendshift daily, rang 23, 28/08 ; `signal faible` | Déploiement, licence, coût GPU et qualité sur données métier à vérifier. | 12/09 |
| [tailscale/tailcat](https://github.com/tailscale/tailcat) | Outil de type netcat qui utilise le data plane Tailscale sans dépendre de son control plane. Il pourrait simplifier certains diagnostics réseau dans des environnements maillés. | Trendshift daily, rang 13, 28/08 ; `signal faible` | Cas d’usage opérationnel prometteur, mais sécurité, packaging et support à qualifier. | 05/09 |
| [stablyai/orca](https://github.com/stablyai/orca) | Environnement pour exécuter et coordonner une flotte d’agents en parallèle. Il cible un problème de cycle de vie et de supervision plutôt qu’un simple chatbot. | Trendshift daily, rang 17, 28/08 ; `signal faible` | Architecture et garanties d’isolation encore à qualifier ; pas de preuve de production. | 12/09 |
| [sapientinc/PRAXIST](https://github.com/sapientinc/PRAXIST) | Système de recherche autonome qui tente de rendre les expérimentations mesurables et exécutables par ordinateur. À surveiller pour les pipelines d’expérimentation reproductibles. | Trendshift daily, rang 5, 28/08 ; `signal faible` | Domaine et modèle de sécurité à clarifier ; faible lien direct avec la plateforme actuelle. | 12/09 |
| [modelstudioai/OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack) | Control plane déclaratif pour décrire, déployer et gouverner des agents cloud. Le rapprochement avec IaC peut rendre les agents versionnables et auditables. | Signal local récent et présence Trendshift ; `émergente` | Dépôt primaire disponible ; maturité, sécurité des outils et dépendances managées à confirmer. | 12/09 |
| [kubernetes-sigs/agent-sandbox](https://github.com/kubernetes-sigs/agent-sandbox) | CRD et contrôleur Kubernetes pour gérer des environnements isolés et persistants d’agents. Il fournit un chemin plus explicite pour le cycle de vie, les outils et l’observabilité. | v0.5.6 le 20/08 ; `émergente` | Preuves primaires et exemples disponibles ; version encore pré-1.0 et intégration à tester. | 12/09 |

## 3. Tendances détaillées

### Artefacts d’architecture exécutables — Archify

- **Pitch rapide :** Archify transforme une description de système ou un codebase en représentation structurée puis en diagramme interactif autonome. Il sert à accélérer la compréhension et la revue, pas à remplacer une décision d’architecture.
- **Utilité d’architecte :** produire une première carte des composants, flux et dépendances lors d’un onboarding, d’une revue ou d’une analyse d’impact ; l’introduire si le coût de maintenir les diagrammes dépasse celui de les régénérer.
- **Pourquoi maintenant :** Trendshift le classe deuxième dans sa vue daily du 28/08, avec une forte accélération de visibilité.
- **Preuves de traction :** classement Trendshift ; dépôt primaire actif, 185 commits et 1,6 k forks observés le 28/08. Le classement est un signal de découverte, pas une preuve d’adoption.
- **Fait vérifié :** le dépôt décrit une IR JSON typée, une validation/rendu Node.js, des sorties HTML/SVG autonomes et des comparaisons avant/après.
- **Analyse :** le pattern est celui d’une documentation dérivée du code, contrôlée dans CI ; la valeur est la réduction de divergence entre architecture déclarée et architecture observée.
- **Maturité :** `émergente` ; version de développement v2.16.0-dev.0, dépendance au parsing et à l’interprétation IA, risque de fausse assurance.
- **Architecture cible :** job CI ou outil local → extraction/IR → validation humaine → artefact HTML/SVG publié avec le commit ; aucune donnée sensible hors dépôt sans politique explicite.
- **Mise en œuvre et exploitation :** commencer en local sur un dépôt non sensible ; versionner les sorties, vérifier les liens et les composants manquants, comparer les diffs, conserver un rendu manuel de repli. Retirer si les diagrammes deviennent plus trompeurs que la documentation existante.
- **Test proposé :** 45 minutes sur un service avec Kubernetes et observabilité ; comparer carte générée et manifestes/README, relever faux positifs, composants absents et temps de génération. Résultat attendu : une carte exploitable et une liste d’écarts vérifiables.
- **Décision :** `tester` en sandbox, puis `surveiller` pour l’usage CI.
- **Prévision :** à 1–3 mois, le signal sera confirmé si releases, intégrations CI et exemples reproductibles augmentent ; sinon conserver comme outil ponctuel.

### Routage de modèles pour agents — WorkWeave/router

- **Pitch rapide :** un routeur de modèles place une politique de sélection entre l’application et plusieurs fournisseurs ou modèles. Il vise à arbitrer coût, latence, capacité et qualité sans modifier chaque agent.
- **Utilité d’architecte :** centraliser fallback, quotas et règles par cas d’usage ; pertinent quand plusieurs modèles coexistent et que les décisions de choix deviennent difficiles à maintenir dans le code applicatif.
- **Pourquoi maintenant :** rang 10 daily Trendshift le 28/08 et mise en avant d’un endpoint unique.
- **Preuves de traction :** signal Trendshift unique, donc `signal faible` ; la promesse de réduction de coût/latence n’est pas retenue comme fait.
- **Fait vérifié :** le dépôt canonique existe ; les détails de déploiement et les métriques annoncées doivent encore être confirmés par lecture complète et essai.
- **Analyse :** pattern inference gateway/policy engine ; il ajoute une dépendance critique et peut masquer les différences de qualité entre modèles.
- **Maturité :** `non confirmé` ; risques : fuite de données vers le mauvais fournisseur, explosion des dimensions de coût, latence de décision et verrouillage de configuration.
- **Architecture cible :** client agent → gateway authentifiée → politique/routage → fournisseur ; journaliser modèle choisi, version, latence, tokens, coût estimé, score d’évaluation et fallback.
- **Mise en œuvre et exploitation :** ne tester qu’avec données synthétiques ; imposer allowlist de modèles, budgets, timeout, circuit breaker, redaction et traces ; rollback par retour au fournisseur fixe.
- **Test proposé :** comparer un endpoint fixe et le routeur sur 50 requêtes synthétiques ; mesurer p95, taux d’erreur, coût et score de qualité. Aucun passage production sans preuve primaire et contrôles de données.
- **Décision :** `surveiller`.
- **Prévision :** confirmer si une release, une documentation de déploiement et des traces reproductibles apparaissent avant le 05/09 ; sinon classer en signal faible persistant.

### Exécution isolée des agents — Agent Sandbox

- **Pitch rapide :** Agent Sandbox fournit une ressource Kubernetes dédiée aux workloads singleton persistants d’agents, avec cycle de vie contrôlé et intégrations d’outils. Il répond au besoin d’isoler des agents qui manipulent état, fichiers ou commandes.
- **Utilité d’architecte :** séparer exécution agentique et plan de contrôle, avec quotas, identité et observabilité Kubernetes ; à envisager quand un agent nécessite un environnement durable plutôt qu’une simple invocation stateless.
- **Pourquoi maintenant :** v0.5.6 publiée le 20/08 avec améliorations de contrôleur, warm pool, statut de scheduling, outils filesystem MCP et métriques Prometheus.
- **Preuves de traction :** release primaire et documentation du projet ; maturité `émergente`, pas preuve de production généralisée.
- **Fait vérifié :** la release mentionne ServiceMonitor/PrometheusRule, suspend/resume et exemples ; le projet reste pré-1.0.
- **Analyse :** pattern sandbox par workload, utile pour limiter blast radius et gérer l’état ; la surface de permissions est plus importante qu’avec un job classique.
- **Maturité :** `émergente` ; dépend de Kubernetes, runtime de conteneur, stockage persistant et politiques réseau/identité.
- **Architecture cible :** API agent → orchestrateur → AgentSandbox → pod isolé → outils MCP/stockage ; traces et métriques séparées, NetworkPolicy restrictive, service account minimal et approbation humaine pour actions sensibles.
- **Mise en œuvre et exploitation :** installer en cluster de test, définir quotas et PDB si pertinent, observer création/suspension/reprise, tester upgrade et suppression avec volumes. Prévoir un worker/job classique comme repli.
- **Test proposé :** 45 minutes avec un agent synthétique ; créer, suspendre, reprendre puis supprimer un sandbox, injecter une erreur d’outil et vérifier métriques, logs, isolation réseau et nettoyage. Succès : aucun accès hors allowlist et état récupérable.
- **Décision :** `tester` en environnement non productif.
- **Prévision :** à 1–3 mois, passer à une qualification plateforme si la compatibilité runtime, la documentation et la stabilité des CRD progressent.

### Embeddings multimodaux — WeMM-Embedding

- **Pitch rapide :** WeMM-Embedding explore des représentations communes pour la recherche multimodale. Il peut compléter un pipeline RAG lorsque les données utiles combinent texte, images ou documents riches.
- **Utilité d’architecte :** décider si l’indexation multimodale réduit le nombre de pipelines spécialisés ; à introduire seulement avec un jeu d’évaluation métier et une stratégie de stockage/rafraîchissement maîtrisée.
- **Pourquoi maintenant :** rang 23 daily Trendshift le 28/08, dans une vague de projets d’infrastructure IA.
- **Preuves de traction :** signal Trendshift unique ; `signal faible`.
- **Fait vérifié :** le dépôt Tencent présente une famille de modèles d’embeddings multimodaux ; les performances, licences et exigences d’inférence restent à qualifier.
- **Analyse :** ajoute un service d’encodage et un index vectoriel, avec coût GPU et problèmes de version d’embedding ; le changement de modèle impose souvent une réindexation.
- **Maturité :** `non confirmé` pour un usage production ; risque de qualité insuffisante sur le vocabulaire métier et de dépendance GPU.
- **Architecture cible :** ingestion → extraction/redaction → encodeur versionné → index vectoriel → retrieval → reranking/LLM ; journaliser version, modalité, score et provenance.
- **Mise en œuvre et exploitation :** tester offline, isoler les modèles, mesurer coût par document et latence, prévoir double index et rollback de l’encodeur.
- **Test proposé :** jeu de 100 requêtes texte+image annotées ; comparer rappel@k, latence p95 et coût à la baseline textuelle. Succès : gain mesurable sans régression de sécurité ni provenance.
- **Décision :** `surveiller`.
- **Prévision :** requalifier au 12/09 si une release, une licence claire et un benchmark reproductible sont disponibles.

## 4. Signaux à surveiller

- **open-connector/open-connector** — Trendshift le met en avant comme gateway de connecteurs pour agents ; dépôt primaire non suffisamment récupéré pendant cette veille. Réexaminer le 05/09.
- **SenteLabsAI/OpenExecutive** — multi-agent exécutif remonté rang 9 ; qualifier architecture, permissions et cas d’usage réel avant de retenir le projet.
- **K-Dense-AI/scientific-agent-skills** — catalogue de skills validées remonté rang 6 ; vérifier maintenance, isolation et provenance des skills.
- **openJiuwen-ai/jiuwenswarm** — plateforme d’agents remontée rang 7 ; manque de preuve de déploiement opérable.
- **vercel-labs/vgpu** — bibliothèque WebGPU remontée rang 24 ; intérêt possible pour l’inférence/runtime, mais faible lien avec la stack serveur actuelle.
- **ai-engineer-notebooks** — visibilité Trendshift rang 12 ; contenu pédagogique à distinguer d’un composant exploitable.

## 5. À ne pas suivre

- `ManacleMelodyKnife/gpu-cpu-miner-crypto-silent` : dépôt suspect et sans intérêt architectural légitime ; écarté.
- Projets vidéo ou frontend remontés uniquement pour leur démonstration : pas de conséquence claire sur une plateforme Cloud/DevOps.
- Benchmarks et annonces de modèles sans artefact de déploiement, d’évaluation ou de gouvernance : insuffisants pour une décision d’architecture.

## 6. Laboratoire de la semaine

**Archify sur un dépôt de service réel mais non sensible (45 minutes).** Générer la carte, vérifier cinq composants et trois flux contre les manifestes et la documentation, puis enregistrer les écarts et le temps de génération. Décision attendue : usage ponctuel, intégration CI expérimentale ou abandon.

## 7. Échéances ou releases importantes

- **05/09/2026 :** requalifier Archify, WorkWeave/router, Tailcat et open-connector avec README, licence, release et chemin de déploiement.
- **12/09/2026 :** réexaminer WeMM-Embedding, Orca, OpenAgentPack et Agent Sandbox ; décider si une carte de service est justifiée.

## 8. Sources consultées

- Découverte et momentum : [Trendshift](https://trendshift.io/), classement daily et projets nouvellement détectés le 28/08/2026.
- Sources primaires : [Archify](https://github.com/tt-a1i/archify), [WorkWeave/router](https://github.com/workweave/router), [WeMM-Embedding](https://github.com/Tencent/WeMM-Embedding), [Tailcat](https://github.com/tailscale/tailcat), [Orca](https://github.com/stablyai/orca), [OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack), [Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox/releases).
- Source en échec ou insuffisante : dépôt [open-connector](https://github.com/open-connector/open-connector) non exploitable pendant la collecte ; conservé seulement comme signal à qualifier.

## Contrôle qualité

- Chaque projet principal possède un pitch, une date de signal, une URL canonique, un stade et une action ou preuve manquante.
- Les classements Trendshift sont traités comme des signaux de découverte ; ils ne suffisent pas à établir la maturité, la sécurité ou la performance.
- Les environnements de la stack et l’exposition réelle n’ont pas été inférés : ils restent `unknown`/`à qualifier`.
