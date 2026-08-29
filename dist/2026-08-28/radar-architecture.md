# Radar architecture — 2026-08-28

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| Archify | outil | Génère des cartes d’architecture interactives à partir d’un dépôt ou d’une description. | [Voir la fiche](#archify) |
| WorkWeave/router | outil | Route les requêtes d’agents vers différents modèles. | [Voir la fiche](#workweaverouter) |
| WeMM-Embedding | modèle | Embeddings multimodaux pour compréhension et retrieval. | [Voir la fiche](#wemm-embedding) |
| Tailcat | outil | Outil de type netcat sur le data plane Tailscale. | [Voir la fiche](#tailcat) |
| Orca | outil | Environnement pour une flotte d’agents parallèles. | [Voir la fiche](#orca) |
| PRAXIST | outil | Recherche agentique mesurable et persistante. | [Voir la fiche](#praxist) |
| OpenAgentPack | plateforme | Control plane déclaratif pour agents cloud. | [Voir la fiche](#openagentpack) |
| Agent Sandbox | outil Kubernetes | CRD Kubernetes pour workloads d’agents isolés et persistants. | [Voir la fiche](#agent-sandbox) |
| Busbar | service/gateway | Gateway IA self-hosted pour routage, budgets et failover. | [Voir la fiche](#busbar) |
| OpenConnector | service/gateway | Gateway de connecteurs SaaS pour agents via MCP, HTTP et OpenAPI. | [Voir la fiche](#openconnector) |
| go-modern-guidelines | standard | Consignes Go destinées aux agents de code. | [Voir la fiche](#go-modern-guidelines) |

## Archify

- **Pitch rapide :** Archify transforme une description de système ou un codebase en représentation structurée puis en diagramme interactif autonome. Il sert à accélérer compréhension et revue, pas à remplacer la décision d’architecture.
- **Utilité :** produire une première carte des composants, flux et dépendances lors d’un onboarding ou d’une analyse d’impact. Le signal justifiant un test est la divergence persistante entre documentation et système réel.
- **Preuves de traction :** Trendshift daily rang 2 le 28/08 ; dépôt primaire actif avec IR JSON typée, validation/rendu Node.js et sorties HTML/SVG. Outils similaires : Structurizr, Mermaid et Backstage TechDocs ; Archify se différencie par la génération interactive dérivée du code.

### Pitch détaillé

Archify appartient au mouvement de documentation dérivée du code : l’outil produit un artefact relisible et révisable à partir d’éléments techniques plutôt qu’un diagramme entièrement maintenu à la main. Cela peut réduire la divergence documentaire, surtout lors des revues et de l’onboarding.

Sa valeur dépend toutefois de la fidélité de l’extraction et de la validation humaine. Un usage raisonnable est un job local ou CI qui publie un rendu versionné, avec repli manuel ; il ne faut pas en faire la source d’autorité unique. Décision : `tester` sur un dépôt non sensible.

## WorkWeave/router

- **Pitch rapide :** routeur de modèles pour systèmes agentiques, présenté comme un endpoint unique capable de choisir un modèle selon la requête. Le sujet touche directement coût, latence et résilience des plateformes IA.
- **Utilité :** surveiller le pattern inference gateway/policy engine lorsque plusieurs modèles coexistent. Les métriques annoncées et le chemin de déploiement restent à qualifier.
- **Preuves de traction :** Trendshift daily rang 10 le 28/08 ; signal unique, donc `signal faible`. Outils similaires : LiteLLM, OpenRouter et Portkey ; comparer fournisseur, politiques, données et observabilité.

## WeMM-Embedding

- **Pitch rapide :** famille d’embeddings multimodaux Tencent pour compréhension et recherche de contenus texte, image ou autres modalités. Elle peut compléter un RAG de documents riches.
- **Utilité :** surveiller les architectures de retrieval multimodal et leurs coûts GPU. Licence, qualité sur données métier et stratégie de réindexation restent à qualifier.
- **Preuves de traction :** Trendshift daily rang 23 le 28/08 et dépôt primaire identifié. Outils similaires : CLIP, BGE-M3 et modèles d’embeddings managés ; comparaison à faire sur rappel, coût et réversibilité.

## Tailcat

- **Pitch rapide :** outil proche de netcat mais transporté sur le data plane Tailscale sans dépendre du control plane. Il vise le diagnostic de connectivité dans des réseaux maillés.
- **Utilité :** utile potentiellement pour isoler rapidement un problème de chemin réseau dans un environnement distribué. Sécurité, packaging et support doivent être vérifiés avant usage opérationnel.
- **Preuves de traction :** Trendshift daily rang 13 le 28/08. Outils similaires : netcat, curl et Tailscale ping ; Tailcat se distingue par le chemin de transport.

## Orca

- **Pitch rapide :** environnement pour exécuter et coordonner une flotte d’agents en parallèle. Il cible le cycle de vie d’agents de code plutôt qu’une simple conversation.
- **Utilité :** surveiller les patterns de fleet management, supervision et isolation des agents. Le modèle de permissions et le déploiement restent à qualifier.
- **Preuves de traction :** Trendshift daily rang 17 le 28/08 et dépôt primaire identifié. Outils similaires : OpenHands, Coder et Agent Sandbox ; périmètres différents.

## PRAXIST

- **Pitch rapide :** système de recherche autonome qui coordonne des pairs, des évaluations et des preuves durables. Il peut inspirer des pipelines d’expérimentation reproductibles.
- **Utilité :** surveiller les boucles de recherche agentique avec critères mesurables. Licence, sécurité et coût opérationnel restent à qualifier.
- **Preuves de traction :** Trendshift daily rang 5 le 28/08 et dépôt primaire public. Outils similaires : MLflow, LangSmith et AutoGPT ; aucun équivalent direct complet.

## OpenAgentPack

- **Pitch rapide :** control plane déclaratif pour décrire, déployer et gouverner des agents cloud. Il rapproche les agents des pratiques IaC et du versionnement de plateforme.
- **Utilité :** intéressant lorsque les agents deviennent des workloads récurrents à gérer par une équipe plateforme. Maturité et sécurité des outils restent à confirmer.
- **Preuves de traction :** signal local et présence Trendshift ; dépôt primaire disponible. Outils similaires : Terraform, Kubernetes Operators et Agent Sandbox ; modèle de ressources à comparer.

## Agent Sandbox

- **Pitch rapide :** CRD et contrôleur Kubernetes pour gérer des environnements isolés et persistants d’agents. Il apporte un chemin explicite pour cycle de vie, outils et observabilité.
- **Utilité :** étudier l’isolation et l’état durable d’agents qui exécutent commandes ou manipulent des fichiers. Version pré-1.0 et intégration runtime à qualifier.
- **Preuves de traction :** release primaire v0.5.6 le 20/08, avec warm pool, suspend/resume et métriques Prometheus. Outils similaires : Kubernetes Jobs, gVisor et Kata Containers ; périmètres complémentaires.

## Busbar

- **Pitch rapide :** Busbar est une gateway IA self-hosted qui centralise routage multi-modèles, failover, budgets, credentials et preuves d’exécution. Elle se place entre applications/agents et fournisseurs de modèles ou outils.
- **Utilité :** candidat prioritaire pour le pattern AI execution gateway et la gouvernance du chemin synchrone. Il faut mesurer latence, couverture fournisseurs et risque de panne centralisée.
- **Preuves de traction :** featured Trendshift le 28/08 ; dépôt primaire documentant binaire Rust, Helm, Prometheus/OTLP, mTLS et circuit breakers. Outils similaires : LiteLLM, Kong AI Gateway et Envoy AI Gateway.

### Pitch détaillé

Busbar veut devenir une frontière d’exécution gouvernée : les secrets et politiques restent côté plateforme, tandis que les applications conservent leurs SDK et changent principalement de base URL. Le pattern est séduisant pour homogénéiser budgets, quotas, routage et preuves d’exécution.

Le compromis est la centralisation : une panne ou une mauvaise politique affecte tout le trafic IA. Un test avec deux fournisseurs et des requêtes synthétiques doit mesurer surcharge, failover, coûts, traces et comportement streaming. Décision : `tester` en environnement non productif.

## OpenConnector

- **Pitch rapide :** OpenConnector connecte les agents aux SaaS avec OAuth, scopes, politiques, logs, MCP, HTTP et OpenAPI, en gardant les credentials derrière le runtime. Il propose des chemins Docker, Kubernetes, Cloudflare et Fly.io.
- **Utilité :** étudier la séparation entre agent et accès aux outils externes, notamment identité, permissions et contrats d’actions. Une qualification sécurité est obligatoire avant toute donnée réelle.
- **Preuves de traction :** featured Trendshift le 28/08 ; dépôt primaire avec Helm, PostgreSQL, migrations explicites et 5,4 k stars/461 forks observés. Outils similaires : Composio, Pipedream et n8n ; comparer contrôle des secrets, catalogue et réversibilité.

### Pitch détaillé

OpenConnector déplace la complexité des intégrations SaaS hors de l’agent : celui-ci choisit une action et une connexion, tandis que le runtime gère OAuth, scopes, exécution et journalisation. C’est un pattern intéressant pour des agents qui doivent agir dans les outils déjà utilisés par les équipes.

La surface de risque est importante : credentials, refresh tokens, exécuteurs et permissions doivent être isolés et auditables. Le bon premier pas est un déploiement local ou Kubernetes avec un seul fournisseur et une action en lecture seule. Décision : `tester` sur données non sensibles.

## go-modern-guidelines

- **Pitch rapide :** dépôt JetBrains de consignes destinées aux agents qui écrivent du Go moderne. Il transforme des conventions d’ingénierie en contexte versionné.
- **Utilité :** surveiller le pattern `engineering policy as agent context` pour réduire les corrections répétitives. Les règles doivent compléter lint, tests et revue humaine.
- **Preuves de traction :** Trendshift daily rang 15 et GitHub Trending Go #1 signalé le 27/08 ; dépôt public Apache-2.0. Outils similaires : golangci-lint, règles de repository et fichiers AGENTS.md.

## Sujets écartés

- Crypto-miner remonté par Trendshift : risque évident et aucun intérêt architectural.
- Projets vidéo/frontend ou annonces de modèles sans artefact de déploiement, d’évaluation ou de gouvernance.

## Sources consultées

- [Trendshift](https://trendshift.io/) : classement daily et projets featured du 28/08/2026.
- Dépôts primaires : [Archify](https://github.com/tt-a1i/archify), [WorkWeave/router](https://github.com/workweave/router), [WeMM-Embedding](https://github.com/Tencent/WeMM-Embedding), [Tailcat](https://github.com/tailscale/tailcat), [Orca](https://github.com/stablyai/orca), [PRAXIST](https://github.com/sapientinc/PRAXIST), [OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack), [Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox), [Busbar](https://github.com/GetBusbar/busbar), [OpenConnector](https://github.com/oomol-lab/open-connector), [go-modern-guidelines](https://github.com/JetBrains/go-modern-guidelines).
- [Google Trends](https://trends.google.com/trends/) consulté ; exploration multi-termes indisponible, aucun signal de recherche utilisé.
