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
- **Indicateur de tendance (29/08/2026) :** N/A — pattern sans dépôt canonique unique ; signaux répartis entre OTel, fournisseurs et projets AgentOps.

### Pitch détaillé

L’observabilité agentique ne consiste pas seulement à capturer le prompt et la réponse. Il faut reconstruire une exécution : modèle choisi, étapes, appels outils, décisions, erreurs, retries, tokens et coût. Le pattern est donc une extension de l’observabilité distribuée, avec des données sensibles et une cardinalité plus difficile à maîtriser.

La trajectoire la plus réversible est d’instrumenter une chaîne avec OpenTelemetry, d’exporter vers ELK/APM ou CloudWatch, puis de mesurer ce qui manque réellement. Un outil spécialisé devient pertinent seulement si l’évaluation, la visualisation des runs ou la gestion des coûts dépassent les capacités existantes.

## [AI Gateway](https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/)

- **Pitch rapide :** une AI Gateway place une politique de contrôle entre les clients et les modèles ou fournisseurs. Elle regroupe routage, quotas, authentification, inspection, cache et guardrails au niveau plateforme.
- **Utilité :** utile lorsque plusieurs applications réimplémentent les mêmes règles de fournisseur, de région, de budget ou de fallback. L’autorisation métier doit rester dans l’application.
- **Indicateur de tendance (29/08/2026) :** N/A — pattern/WG sans compteur unique ; signal officiel Kubernetes/CNCF.

### Pitch détaillé

Le sujet marque le déplacement de la gouvernance IA vers l’infrastructure. Une gateway peut imposer des quotas et une identité homogènes, mais elle devient aussi un composant critique du chemin de requête et un point de concentration des secrets et des logs.

Il faut distinguer les APIs et contrôleurs encore mouvants des fonctionnalités stables. une évaluation réaliste doit utiliser deux backends simulés et mesurer auth, routage, timeout, failover, latence et contrôle des permissions.

## [Inférence cloud-native](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/)

- **Pitch rapide :** l’inférence moderne sur Kubernetes traite le modèle comme un workload spécialisé avec GPU, scheduling, cache KV, routage et métriques TTFT/TPOT. Elle dépasse le simple Deployment d’un serveur de modèle.
- **Utilité :** utile pour dimensionner un serving IA et arbitrer coût, débit, latence et placement matériel. Sans workload GPU réel, rester au stade de veille.
- **Indicateur de tendance (29/08/2026) :** llm-d ★4,3 k · forks 725 · push 29/08 ; vLLM ★90,4 k · forks 21,4 k · push 29/08.

### Pitch détaillé

Le problème central est d’aligner demande utilisateur, capacité GPU et état du modèle. Le chemin comprend gateway ou scheduler, serveur de modèle, ressources GPU, éventuel cache et télémétrie spécialisée ; les métriques classiques CPU/RAM ne suffisent pas pour expliquer TTFT, tokens/s ou coût.

La pertinence dépend entièrement du matériel, du modèle et du profil de charge. Il faut une évaluation reproductible avec requêtes représentatives et comparaison à un Deployment classique.

## [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/)

- **Pitch rapide :** OpenTelemetry formalise des attributs et événements pour instrumenter les appels modèles et outils. Il peut fournir une base commune à ELK, Elastic APM et CloudWatch.
- **Utilité :** éviter de verrouiller l’observabilité dans un fournisseur et permettre la corrélation des traces. Outils similaires : OpenInference, Langfuse et instrumentation native des fournisseurs.
- **Indicateur de tendance (29/08/2026) :** Collector OTel ★7,5 k · forks 2,2 k · push 28/08 ; proxy d’activité de l’écosystème, pas mesure du sous-standard.

## [Kubernetes 1.37](https://kubernetes.io/releases/1.37/)

- **Pitch rapide :** Kubernetes 1.37 est une release de plateforme qui peut modifier APIs, compatibilités et opérations de cluster. Son intérêt architectural dépend des add-ons et distributions réellement utilisés.
- **Utilité :** vérifier les dépréciations, versions supportées et gains avant upgrade ; ne pas confondre release produit et tendance d’architecture.
- **Indicateur de tendance (29/08/2026) :** Kubernetes ★125,3 k · forks 43,9 k · issues 3,0 k · push 28/08.

## Sujets écartés

- Frameworks d’agents sans documentation de déploiement ou d’exploitation.
- Benchmarks de modèles sans protocole reproductible ni charge représentative.
- Releases ELK/APM sans impact sécurité, compatibilité ou capacité.

## Sources consultées

- [Kubernetes releases et AI Gateway WG](https://kubernetes.io/releases/1.37/), [CNCF llm-d](https://www.cncf.io/blog/2026/03/24/welcome-llm-d-to-the-cncf-evolving-kubernetes-into-sota-ai-infrastructure/), [CNCF Inference Gateway](https://www.cncf.io/blog/2026/03/26/the-platform-under-the-model-how-cloud-native-powers-ai-engineering-in-production/).
- [OpenTelemetry GenAI](https://opentelemetry.io/blog/2026/genai-observability/), [AWS CloudWatch observability](https://aws.amazon.com/blogs/mt/this-month-in-aws-observability-july-2026/), [GitHub Agent Observability](https://github.com/topics/agent-observability).
- Sources de discussion non exploitables dans cette exécution : Hacker News RSS.
