# Radar architecture — 2026-08-27

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [AgentOps et observabilité IA](https://github.com/topics/agent-observability) | pattern | Couche de traces, coûts, évaluations et actions pour les agents. | [Voir la fiche](#agentops-et-observabilité-ia) |
| [AI Gateway](https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/) | pattern | Gateway spécialisée pour gouverner le trafic vers les modèles. | [Voir la fiche](#ai-gateway) |
| [Inférence cloud-native](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/) | pattern | Patterns Kubernetes pour servir des modèles avec GPU, cache et scheduling. | [Voir la fiche](#inférence-cloud-native) |
| [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/) | standard | Conventions de télémétrie pour modèles, tokens, outils et traces. | [Voir la fiche](#opentelemetry-genai) |
| [Kubernetes 1.37](https://kubernetes.io/releases/1.37/) | plateforme | Nouvelle version Kubernetes avec évolutions de plateforme. | [Voir la fiche](#kubernetes-137) |

## [AgentOps et observabilité IA](https://github.com/topics/agent-observability)

- **Pitch rapide :** les outils AgentOps ajoutent une visibilité sur les étapes d’un agent, ses appels modèles, ses outils, ses retries, ses coûts et ses évaluations. Ils répondent au manque de contexte laissé par un simple log de requête.
- **Utilité :** utile pour exploiter un agent comme un système distribué : corréler `trace_id`, modèle, outil, permission, coût et résultat. Commencer avec OpenTelemetry et les backends déjà disponibles avant d’ajouter un middleware dédié.
- **Preuves de traction :** topic GitHub `agent-observability` avec environ 360 dépôts, plusieurs projets mis à jour les 25–27/08, conventions GenAI OpenTelemetry et positionnement CloudWatch AWS. Outils similaires : OpenTelemetry + ELK/APM, CloudWatch Agent Observability, Langfuse ; le choix dépend de la rétention, de la confidentialité et de l’intégration.
- **Indicateur de tendance (29/08/2026) :** N/A — pattern sans dépôt canonique unique ; signaux répartis entre OTel, fournisseurs et projets AgentOps.

### Pitch détaillé

L’observabilité agentique ne consiste pas seulement à capturer le prompt et la réponse. Il faut reconstruire une exécution : modèle choisi, étapes, appels outils, décisions, erreurs, retries, tokens et coût. Le pattern est donc une extension de l’observabilité distribuée, avec des données sensibles et une cardinalité plus difficile à maîtriser.

La trajectoire la plus réversible est d’instrumenter une chaîne avec OpenTelemetry, d’exporter vers ELK/APM ou CloudWatch, puis de mesurer ce qui manque réellement. Un outil spécialisé devient pertinent seulement si l’évaluation, la visualisation des runs ou la gestion des coûts dépassent les capacités existantes. Décision : `tester` sur un agent non critique.

## [AI Gateway](https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/)

- **Pitch rapide :** une AI Gateway place une politique de contrôle entre les clients et les modèles ou fournisseurs. Elle regroupe routage, quotas, authentification, inspection, cache et guardrails au niveau plateforme.
- **Utilité :** utile lorsque plusieurs applications réimplémentent les mêmes règles de fournisseur, de région, de budget ou de fallback. L’autorisation métier doit rester dans l’application.
- **Preuves de traction :** groupe de travail AI Gateway Kubernetes, travaux CNCF autour de l’Inference Gateway et lien avec Gateway API. Outils similaires : Kong AI Gateway, Envoy AI Gateway, LiteLLM ; comparer intégration Kubernetes, sécurité, protocoles et charge opérationnelle.
- **Indicateur de tendance (29/08/2026) :** N/A — pattern/WG sans compteur unique ; signal officiel Kubernetes/CNCF.

### Pitch détaillé

Le sujet marque le déplacement de la gouvernance IA vers l’infrastructure. Une gateway peut imposer des quotas et une identité homogènes, mais elle devient aussi un composant critique du chemin de requête et un point de concentration des secrets et des logs.

Il faut distinguer les APIs et contrôleurs encore mouvants des fonctionnalités stables. Un test réaliste doit utiliser deux backends simulés et mesurer auth, routage, timeout, failover, latence et contrôle des permissions. Décision : `surveiller`, puis `tester` lorsqu’un besoin multi-modèle ou multi-cloud est confirmé.

## [Inférence cloud-native](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/)

- **Pitch rapide :** l’inférence moderne sur Kubernetes traite le modèle comme un workload spécialisé avec GPU, scheduling, cache KV, routage et métriques TTFT/TPOT. Elle dépasse le simple Deployment d’un serveur de modèle.
- **Utilité :** utile pour dimensionner un serving IA et arbitrer coût, débit, latence et placement matériel. Sans workload GPU réel, rester au stade de veille.
- **Preuves de traction :** llm-d présenté comme CNCF Sandbox, intégrations KServe/vLLM et travaux autour de DRA, LWS, Kueue et Gateway API ; Kubernetes 1.37.0 publié le 26/08. Outils similaires : KServe, Ray Serve, vLLM ; la comparaison porte sur scheduling, GPU, autoscaling et exploitation.
- **Indicateur de tendance (29/08/2026) :** llm-d ★4,3 k · forks 725 · push 29/08 ; vLLM ★90,4 k · forks 21,4 k · push 29/08.

### Pitch détaillé

Le problème central est d’aligner demande utilisateur, capacité GPU et état du modèle. Le chemin comprend gateway ou scheduler, serveur de modèle, ressources GPU, éventuel cache et télémétrie spécialisée ; les métriques classiques CPU/RAM ne suffisent pas pour expliquer TTFT, tokens/s ou coût.

La pertinence dépend entièrement du matériel, du modèle et du profil de charge. Il faut un test reproductible avec requêtes représentatives et comparaison à un Deployment classique. Décision : `surveiller` jusqu’à l’existence d’un workload d’inférence concret.

## [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/)

- **Pitch rapide :** OpenTelemetry formalise des attributs et événements pour instrumenter les appels modèles et outils. Il peut fournir une base commune à ELK, Elastic APM et CloudWatch.
- **Utilité :** éviter de verrouiller l’observabilité dans un fournisseur et permettre la corrélation des traces. Outils similaires : OpenInference, Langfuse et instrumentation native des fournisseurs.
- **Preuves de traction :** conventions GenAI et évolution du projet OpenTelemetry. Niveau `signal faible` pour les détails de stabilité et d’implémentation ; décisions de schéma à surveiller.
- **Indicateur de tendance (29/08/2026) :** Collector OTel ★7,5 k · forks 2,2 k · push 28/08 ; proxy d’activité de l’écosystème, pas mesure du sous-standard.

## [Kubernetes 1.37](https://kubernetes.io/releases/1.37/)

- **Pitch rapide :** Kubernetes 1.37 est une release de plateforme qui peut modifier APIs, compatibilités et opérations de cluster. Son intérêt architectural dépend des add-ons et distributions réellement utilisés.
- **Utilité :** vérifier les dépréciations, versions supportées et gains avant upgrade ; ne pas confondre release produit et tendance d’architecture.
- **Preuves de traction :** release officielle 1.37.0 le 26/08 et patch 1.37.1 ciblé au 15/09. Outils similaires : distributions Kubernetes managées AWS/GCP et distributions on-prem ; comparaison limitée à support et compatibilité.
- **Indicateur de tendance (29/08/2026) :** Kubernetes ★125,3 k · forks 43,9 k · issues 3,0 k · push 28/08.

## Sujets écartés

- Frameworks d’agents sans documentation de déploiement ou d’exploitation.
- Benchmarks de modèles sans protocole reproductible ni charge représentative.
- Releases ELK/APM sans impact sécurité, compatibilité ou capacité.

## Sources consultées

- [Kubernetes releases et AI Gateway WG](https://kubernetes.io/releases/1.37/), [CNCF llm-d](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/), [CNCF Inference Gateway](https://www.cncf.io/blog/2026/03/26/the-platform-under-the-model-how-cloud-native-powers-ai-engineering-in-production/).
- [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/), [AWS CloudWatch observability](https://aws.amazon.com/blogs/mt/this-month-in-aws-observability-july-2026/), [GitHub Agent Observability](https://github.com/topics/agent-observability).
- Sources de discussion non exploitables dans cette exécution : Hacker News RSS.
