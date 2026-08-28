# RADAR DES TENDANCES — 2026-08-28

**Période :** 48 dernières heures pour l’alerte ASAP, 7 jours pour le rythme hebdomadaire, 30 jours pour l’émergence.
**Lecture cible :** moins de 30 minutes. Les projets très récents sont visibles même lorsqu’ils sont immatures.

## LES TROIS TENDANCES À RETENIR

1. **L’infrastructure d’exécution des agents se densifie :** Agent Sandbox, Hermes et Stately Agent publient des briques concrètes autour de l’exécution, de la persistance, de la durabilité et des outils ; `surveiller` le pattern, `tester` Agent Sandbox.
2. **Les agents deviennent des ressources déclaratives et gouvernables :** OpenAgentPack propose un workflow `validate → plan → apply` pour des agents gérés ; `signal faible`, mais très pertinent pour Terraform/GitOps.
3. **Le socle Kubernetes/observabilité IA continue de se structurer :** AI Gateway et OpenTelemetry GenAI restent des axes de standardisation ; `surveiller` tant que les APIs et intégrations ne sont pas stabilisées.

## PROJETS QUI TRENDENT MAINTENANT

| Projet | Pitch rapide | Signal daté | Stade / manque |
|---|---|---|---|
| [Hermes Agent](https://github.com/NousResearch/hermes-agent) | Runtime d’agent open source qui regroupe modèles, outils MCP, navigation et exécution dans un produit installable ; utile aux équipes qui veulent opérer un agent self-hosted. | v0.20.6 publiée le 27 août ; 209 commits depuis la release | `signal faible` ; vérifier sécurité, déploiement et gouvernance |
| [Stately Agent](https://github.com/statelyai/agent) | Bibliothèque qui décrit un agent comme une machine d’état ; utile pour rendre les transitions, validations humaines et reprises après panne explicites et testables. | `2.0.0-alpha.21` publiée le 27 août | `signal faible` ; API alpha et preuve terrain manquante |
| [Agent Sandbox](https://github.com/kubernetes-sigs/agent-sandbox) | Contrôleur Kubernetes qui fournit à chaque agent un environnement isolé, persistant et identifiable ; utile aux plateformes qui exécutent du code ou des outils par session. | v0.5.6 publiée le 20 août ; nouvelle télémétrie et lifecycle warm pool | `émergente` ; tester isolation et CRD |
| [OpenAgentPack](https://github.com/modelstudioai/OpenAgentPack) | Control plane de type Terraform pour décrire dans Git les prompts, outils, skills, MCP et fournisseurs d’un agent ; utile aux équipes qui veulent review, rollback et drift detection. | dépôt repéré dans les signaux d’infrastructure agent du 25–28 août | `signal faible` ; 23 étoiles, beta et APIs mouvantes |
| [AgentField](https://github.com/Agent-Field/AgentField) | Projet présenté comme un control plane pour déployer, mettre à l’échelle et sécuriser des agents backend observables et identifiés ; intéressant pour une plateforme agent centralisée. | release `v0.1.135` signalée le 27 août par un tracker | `signal faible` ; release à confirmer sur le dépôt primaire |
| [Go UTCP](https://github.com/universal-tool-calling-protocol/go-utcp) | Bibliothèque Go destinée à découvrir et appeler des outils via plusieurs transports ; intéressante pour comparer une couche d’outillage alternative ou complémentaire à MCP. | release `v1.12.3` signalée le 27 août | `signal faible` ; adoption, sécurité et relation avec MCP à qualifier |

Ces entrées sont des détections précoces. Un signal de release ou de traction ne prouve ni maturité, ni sécurité, ni compatibilité avec la stack de Mehdi.

## TENDANCES DÉTAILLÉES

### 1. Agent Sandbox : lifecycle et observabilité des runtimes d’agents — ÉMERGENTE / TRACTION

- **Pitch rapide :** Agent Sandbox transforme une session d’agent en ressource Kubernetes persistante et identifiable, avec un cycle de vie géré par contrôleur. Il vise les équipes plateforme qui doivent exécuter des agents ou du code généré dans des environnements séparés.
- **Pourquoi maintenant :** la release v0.5.6 renforce la fiabilité du contrôleur, le cycle de vie des warm pools, le diagnostic de scheduling, les métriques suspend/resume et l’intégration Prometheus.
- **Preuves de traction :** release officielle du 20 août, dépôt Kubernetes SIG Apps actif, exemples Pi coding agent, E2B envd et n8n. Source primaire : https://github.com/kubernetes-sigs/agent-sandbox/releases/tag/v0.5.6.
- **Fait vérifié :** v0.5.6 ajoute notamment le miroir des conditions `PodScheduled`, des métriques SDK, des outils filesystem MCP bornés et des ressources `ServiceMonitor`/`PrometheusRule` opt-in.
- **Analyse :** le projet évolue d’un simple CRD de pod singleton vers une primitive opérable pour des sessions agents persistantes et potentiellement préchauffées.
- **Maturité :** `émergente` ; chemin de déploiement reproductible et maintenance active, mais isolation runtime, compatibilité CRD et coût restent à prouver.
- **Architecture cible :** contrôleur versionné, namespace dédié, ServiceAccount minimal, NetworkPolicy deny-by-default, PVC borné, métriques Prometheus vers OTel/ELK, runtime isolé si le code est hostile.
- **Test proposé :** Kind + v0.5.6 ; créer/reprendre/suspendre/supprimer une session, vérifier métriques, persistance et refus réseau. Durée 45 minutes. Succès : zéro ressource orpheline, état persistant et egress interdit bloqué.
- **Décision :** `tester`.
- **Prévision :** les extensions warm pool et observabilité vont accélérer les usages agents Kubernetes, mais la production dépendra de l’isolation et de la stabilité API dans 1–3 mois.

### 2. Hermes Agent : convergence runtime, MCP et opérations — SIGNAL FAIBLE / ACCÉLÉRATION

- **Pitch rapide :** Hermes Agent est un runtime d’agent installable qui orchestre modèles, outils MCP, navigation et tâches persistantes. Il intéresse surtout les équipes qui évaluent un agent self-hosted complet plutôt qu’un simple SDK.
- **Pourquoi maintenant :** v0.20.6 a été publiée le 27 août et agrège environ 525 PR depuis la release précédente, avec MCP distant, contrôles d’update, garde-fous d’exécution, cache de résultats, clés et opérations de flotte.
- **Preuves de traction :** release primaire du 27 août : https://github.com/NousResearch/hermes-agent/releases/tag/v2026.8.27.
- **Fait vérifié :** la release annonce Docker/hosted deployments, catalogue MCP, contrôles de runtime et mécanismes d’update ; le dépôt est très actif.
- **Analyse :** le projet illustre un agent qui devient une plateforme opérable : fournisseurs, outils, sessions, mises à jour, secrets et canaux d’exécution deviennent des composants d’infrastructure.
- **Maturité :** `signal faible` pour un standard d’entreprise ; activité forte mais surface large, modèle de menace et support opérationnel à qualifier.
- **Architecture cible :** runtime en conteneur non privilégié, secrets hors image, allowlist MCP, egress contrôlé, traces des tool calls, journal d’update signé et repli vers une version précédente.
- **Test proposé :** instance isolée avec outil fictif ; mesurer permissions, logs, rollback et comportement en timeout. Ne pas installer en production.
- **Décision :** `surveiller`.
- **Prévision :** si les contrats MCP, l’installation et les contrôles de sécurité se stabilisent, le projet peut devenir un cas de référence de runtime agent self-hosted ; réexaminer le 5 septembre.

### 3. OpenAgentPack : agents-as-code et plan d’exécution — SIGNAL FAIBLE

- **Pitch rapide :** OpenAgentPack veut gérer un agent comme une infrastructure déclarative : une définition Git décrit ses instructions, outils, skills, MCP et fournisseur, puis `plan/apply` montre et applique les changements. Il vise les équipes DevOps qui veulent gouverner les agents par pull request.
- **Pourquoi maintenant :** le projet propose un control plane IaC open source pour gérer des agents cloud par Git/YAML avec `validate → plan → apply`, détection de drift et adaptateurs multi-fournisseurs.
- **Preuves de traction :** dépôt public avec 70 commits, workflow et quickstart documentés ; source primaire : https://github.com/modelstudioai/OpenAgentPack.
- **Fait vérifié :** le README indique un statut beta, une déclaration `agents.yaml`, des providers Bailian/Qoder/Claude/Volcengine Ark et une matrice de capacités.
- **Analyse :** le pattern transpose GitOps/Terraform aux prompts, tools, skills, MCP, credentials references et environnements d’agents.
- **Maturité :** `signal faible` ; 23 étoiles et beta, APIs et schéma annoncés comme susceptibles de changer.
- **Architecture cible :** dépôt Git, validation hors ligne en CI, plan dans une merge request, credentials injectés par secret manager, apply avec approbation et état séparé par environnement.
- **Test proposé :** déclaration minimale d’un agent fictif ; varier prompt/tool/provider, observer le plan, le drift et le rollback sans compte Cloud réel. Durée 30 minutes.
- **Décision :** `surveiller`.
- **Prévision :** le besoin agents-as-code va croître ; décision dépendante de la portabilité réelle et des contrats fournisseurs dans 1–3 mois.

### 4. Stately Agent : machines d’état et exécution durable — SIGNAL FAIBLE / ACCÉLÉRATION

- **Pitch rapide :** Stately Agent modélise l’agent comme une machine d’état avec événements, outils et reprises durables. Il vise les équipes qui doivent tester les branches d’un workflow et reprendre proprement après interruption ou approbation humaine.
- **Pourquoi maintenant :** la release `2.0.0-alpha.21`, publiée le 27 août, met à jour l’intégration AI SDK v7 et clarifie le placement des paramètres de raisonnement côté hôte ; les releases précédentes ajoutent déjà un runtime durable et une reprise par journal.
- **Preuves de traction :** releases officielles rapprochées les 21 et 27 août : https://github.com/statelyai/agent/releases.
- **Fait vérifié :** le projet expose des agents comme machines d’état et décrit `runDurableAgent`, journalisation, reprise et exécution sans rejouer les appels déjà journalisés.
- **Analyse :** le pattern traite les agents comme des workflows explicites, versionnables et rejouables, ce qui rapproche l’orchestration IA des systèmes durable-workflow.
- **Maturité :** `signal faible` ; version alpha, dépendances XState/AI SDK évolutives et absence de validation dans la stack réelle.
- **Architecture cible :** machine versionnée, journal durable, executors côté hôte, secrets et choix de modèle hors définition, traces des transitions et approbation humaine.
- **Test proposé :** simuler un agent avec appel modèle et validation humaine, tuer le processus, reprendre depuis le journal et vérifier qu’un appel terminé n’est pas rejoué.
- **Décision :** `surveiller`.
- **Prévision :** les workflows durables deviennent un pattern clé pour agents fiables ; réexaminer après une release non-alpha ou une intégration de production documentée.

## SIGNAUX À SURVEILLER

- **AI Gateway Kubernetes / Gateway API Inference Extension :** travaux officiels et APIs en évolution ; preuve manquante : conformance et support du contrôleur choisi. https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/ ; https://kubernetes.io/blog/2025/06/05/introducing-gateway-api-inference-extension/ ; réexamen 15 septembre.
- **OpenTelemetry GenAI :** dépôt dédié et conventions de spans ; preuve manquante : support documenté par Elastic APM et SDK retenu. https://github.com/open-telemetry/semantic-conventions-genai ; réexamen 30 septembre.
- **AgentField :** release `v0.1.135` détectée par un tracker ; preuve manquante : confirmation du tag et documentation primaire de déploiement/observabilité. https://github.com/Agent-Field/AgentField ; réexamen 5 septembre.
- **Go UTCP :** release récente signalée ; preuve manquante : sécurité du protocole, adoption et comparaison concrète avec MCP. https://github.com/universal-tool-calling-protocol/go-utcp ; réexamen 5 septembre.

## À NE PAS SUIVRE CETTE SEMAINE

- Benchmarks LLM isolés sans artefact de déploiement ou protocole reproductible.
- Annonces de modèles sans changement démontré de routage, coût, sécurité ou exploitation.
- Dépôts purement frontend, copies sans différenciation technique et releases de maintenance sans conséquence d’architecture.

## LABORATOIRE DE LA SEMAINE

**Agent Sandbox v0.5.6 sur Kind**, 45–60 minutes : installer la release figée, créer une session, vérifier persistance et métriques, tenter un egress interdit, suspendre/reprendre puis supprimer. Critère : permissions minimales, métriques exploitables, état conservé et nettoyage complet.

## ÉCHÉANCES OU RELEASES IMPORTANTES

- **5 septembre 2026 :** requalifier Hermes, AgentField et Go UTCP avec une seconde preuve primaire.
- **12 septembre 2026 :** sortie du laboratoire Agent Sandbox.
- **15 septembre 2026 :** requalifier Kubernetes 1.37 et AI Gateway.
- **30 septembre 2026 :** vérifier l’interopérabilité OpenTelemetry GenAI / Elastic APM.

## SOURCES CONSULTÉES

Sources primaires : Agent Sandbox v0.5.6, Hermes Agent v0.20.6, Stately Agent alpha.21, OpenAgentPack, Kubernetes AI Gateway, OpenTelemetry GenAI et Kubernetes releases. Sources de découverte : GitHub releases/topics et trackers ; utilisées uniquement pour détecter les projets et signalées lorsqu’elles ne sont pas confirmées par une source primaire. Sources locales : `state/context.yaml`, `state/signals.yaml`, radar du 27 août.
