# RADAR DES TENDANCES — 2026-08-27

Période : nouveautés des 7 derniers jours et signaux d’émergence des 30 derniers jours. Stack de référence : AWS, GCP, Kubernetes, GitHub/GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform.

## LES TROIS TENDANCES À RETENIR

1. **L’observabilité des agents IA devient une couche d’exploitation distincte.** Les projets se structurent autour des traces, évaluations, coûts et actions ; commencer par OpenTelemetry + ELK/APM avant d’ajouter un produit.
2. **Les AI Gateways déplacent la gouvernance IA au niveau de la plateforme.** Routage, quotas, identité, failover et politiques deviennent des fonctions d’infrastructure Kubernetes.
3. **L’inférence IA devient un workload Kubernetes spécialisé.** Le sujet n’est plus seulement de déployer un modèle, mais de gérer GPU, scheduling, cache KV, TTFT/TPOT et répartition prefill/decode.

## 1. AgentOps et observabilité des agents IA — ÉMERGENTE / TRACTION

**Pourquoi maintenant :** le topic GitHub `agent-observability` présente 360 dépôts ; plusieurs projets d’observabilité, d’évaluation et d’exploitation ont été mis à jour les 25–27 août. C’est un signal d’écosystème, pas une preuve d’adoption.

**Preuves de traction :**

- plusieurs projets couvrent contrôle de runs, coûts, traces, monitoring et évaluation : https://github.com/topics/agent-observability ;
- OpenTelemetry documente des conventions GenAI pour les appels modèle, tokens, outils et traces : https://opentelemetry.io/blog/2026/genai-observability/ ;
- AWS positionne aussi l’observabilité des coding agents dans CloudWatch : https://aws.amazon.com/blogs/mt/this-month-in-aws-observability-july-2026/.

**Problème architectural :** un log de requête ne permet pas de savoir quel modèle, outil, retry, permission ou étape d’agent a produit le résultat.

**Architecture cible :** application/agent → instrumentation OpenTelemetry → collecte → CloudWatch et/ou ELK/APM ; conserver les prompts et sorties sensibles filtrés, avec corrélation par `trace_id`, modèle, outil, coût et version.

**Pertinence :** confirmée pour l’axe IA + observabilité ; intégration réelle à qualifier.

**Test proposé :** une semaine, sur un agent non critique. Mesurer durée, tokens, coût, erreurs, appels outils et retries ; vérifier qu’une exécution est retrouvable de bout en bout dans ELK ou CloudWatch.

**Décision :** `tester`. Ne choisir un middleware dédié que si OpenTelemetry + ELK/APM/CloudWatch ne couvrent pas les besoins.

**Prévision :** les solutions compatibles avec les conventions OpenTelemetry et les outils existants progresseront plus facilement. Si un produit impose un format fermé ou stocke des données sensibles sans contrôle, le garder en expérimentation.

## 2. AI Gateway et inference gateway — ÉMERGENTE

**Pourquoi maintenant :** Kubernetes travaille sur des primitives de gateway adaptées au trafic IA. Le groupe AI Gateway décrit token rate limiting, contrôle d’accès fin, inspection de payload, routage, cache et guardrails : https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/.

**Preuves de traction :**

- le groupe de travail Kubernetes porte des propositions autour des APIs déclaratives et du routage IA ;
- le CNCF décrit l’Inference Gateway et le routage selon modèle, adaptateur LoRA et santé d’endpoint : https://www.cncf.io/blog/2026/03/26/the-platform-under-the-model-how-cloud-native-powers-ai-engineering-in-production/ ;
- les sujets sont reliés à Gateway API, SIG Network et à des projets d’inférence Kubernetes.

**Problème architectural :** éviter que chaque application implémente séparément authentification fournisseur, quotas, routage multi-modèle, failover et règles de région.

**Architecture cible :** client → Gateway API/AI Gateway → politique identité/quotas → modèle ou fournisseur AWS/GCP → traces et métriques → CloudWatch/ELK/APM. L’autorisation métier reste dans l’application.

**Pertinence :** possible pour une future plateforme IA Kubernetes ; aucun cluster IA ni besoin de routage multi-fournisseur n’est confirmé.

**Test proposé :** deux heures maximum, avec deux backends simulés. Tester auth, quotas, routage par modèle, timeout, failover et absence de permission d’écriture sur le cluster.

**Décision :** `surveiller`, puis `tester` si un cas multi-modèle ou multi-cloud apparaît.

**Prévision :** les APIs standardisées peuvent éviter un middleware propriétaire, mais les implémentations resteront mouvantes. Si la fonction est Preview ou dépend d’une GatewayClass spécifique, conserver un proxy de repli.

## 3. Kubernetes comme plateforme d’inférence — TRACTION

**Pourquoi maintenant :** le CNCF positionne l’inférence distribuée comme un workload cloud-native. `llm-d` est présenté comme un projet CNCF Sandbox pour relier Kubernetes, KServe, vLLM, routage conscient du cache et réplication multi-nœuds : https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/.

**Faits vérifiés :** Kubernetes `1.37.0` est sorti le 26 août 2026 ; la branche est supportée et le prochain patch `1.37.1` est ciblé au 15 septembre : https://kubernetes.io/releases/1.37/. Le CNCF indique aussi que les besoins d’inférence concernent scheduling, Gateway API, DRA, LWS et Kueue.

**Problème architectural :** un Deployment Kubernetes classique ne suffit pas à optimiser GPU, placement, cache KV, temps jusqu’au premier token et débit de génération.

**Architecture cible :** Gateway/inference scheduler → pods model server → ressources GPU/DRA → cache et stockage → métriques TTFT/TPOT, tokens/s, saturation GPU et coût.

**Pertinence :** possible ; aucun workload GPU ou serving de modèle n’est confirmé dans la stack.

**Test proposé :** lab local conceptuel ou cluster GPU isolé si disponible ; comparer un service Kubernetes classique à un routage conscient du modèle, avec latence, débit et coût comme mesures.

**Décision :** `surveiller` pour l’instant ; `tester` uniquement avec un workload d’inférence réel.

**Prévision :** la convergence se fera autour de primitives Kubernetes ouvertes, mais les performances dépendront fortement du matériel et du modèle. Ne pas transformer les benchmarks fournisseurs en capacité garantie.

## 4. OpenTelemetry GenAI — SIGNAL DE STANDARDISATION

**Signal :** OpenTelemetry a atteint le statut de projet graduated et travaille sur les conventions sémantiques GenAI, l’injection zéro code et la gouvernance des schémas : https://opentelemetry.io/blog/2026/otel-grad-now-what/.

**Analyse :** ce n’est pas un nouveau produit à adopter, mais une direction qui peut éviter de multiplier des agents propriétaires pour l’IA. Elle complète CloudWatch, ELK et Elastic APM plutôt qu’elle ne les remplace automatiquement.

**Test proposé :** instrumenter une seule chaîne LLM, exporter métriques et traces, puis vérifier cardinalité, filtrage des contenus, coût de collecte et corrélation avec les logs applicatifs.

**Décision :** `tester` comme convention d’instrumentation, pas comme migration globale.

## SIGNAUX À SURVEILLER

- **Control planes self-hosted pour agents** : des projets récents proposent dispatch, suivi des runs, dépenses et exploitation de plusieurs runtimes : https://github.com/topics/agent-observability. Manque : preuves de production, sécurité et compatibilité avec Kubernetes.
- **AI agent harnesses et skills** : le topic `ai-agents` compte plus de 80 000 dépôts et plusieurs projets ont été mis à jour le 27 août : https://github.com/topics/ai-agents. Manque : distinguer productivité développeur, framework d’orchestration et plateforme opérable.
- **Kubernetes 1.37** : release récente à qualifier pour les add-ons et distributions managées, mais ce n’est pas en soi une tendance d’architecture : https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/.

## LABORATOIRE PRIORITAIRE

Construire une chaîne minimale d’observabilité GenAI : un appel modèle simulé, un appel outil, une erreur et un retry ; instrumenter avec OpenTelemetry ; exporter vers un backend déjà disponible ; produire une trace corrélée avec latence, tokens, coût et résultat de l’outil. Succès : une exécution est explicable sans lire le code source et aucune donnée sensible n’est exposée.

## À NE PAS SUIVRE CETTE SEMAINE

- nouveaux frameworks d’agents sans documentation de déploiement et d’exploitation ;
- benchmarks de modèles sans protocole reproductible ni charge représentative ;
- releases ELK/APM isolées qui ne changent ni la compatibilité, ni la sécurité, ni la capacité de la chaîne.

## SOURCES CONSULTÉES

Sources primaires : Kubernetes, CNCF, OpenTelemetry, AWS Cloud Operations, GitHub Topics. Sources de discussion RSS non exploitables dans cette exécution : Hacker News RSS. Les signaux GitHub sont utilisés pour la découverte, jamais comme preuve d’adoption.
