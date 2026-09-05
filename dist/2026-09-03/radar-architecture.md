# Radar architecture — 3 septembre 2026

Fenêtre de collecte : 48 h (signaux ASAP), 7 jours (nouveautés) et 30 jours (tendances lentes). Déduplication locale appliquée sur 90 jours. Les environnements réels restent `exposition inconnue` tant que l’inventaire n’est pas confirmé.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Cloud Run Agent Identity](https://cloud.google.com/run/docs/release-notes) | Nouveau hors OSS · service | Identités managées pour agents/MCP et enregistrement Agent Registry. | [fiche](#cloud-run--identités-dagents-et-agent-registry) |
| [GKE Multi-Cloud bulletin GCP-2026-058](https://cloud.google.com/kubernetes-engine/security-bulletins) | Nouveau hors OSS · sécurité | Correctif d’une vérification d’autorisation manquante dans les APIs Multi-Cloud. | [fiche](#gke-multi-cloud--correctif-dautorisation) |
| [Claude Fable 5.1](https://platform.claude.com/docs/en/release-notes/overview) | Nouveau hors OSS · modèle | Contexte 1M et sorties longues pour workloads agentiques. | [fiche](#claude-fable-51--contexte-et-tâches-longues) |
| [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) | Nouveau projet OSS · outil | Harness d’agents « everything-is-a-plugin », encore en developer preview. | [fiche](#deepseek-harness--harness-dagents-par-plugins) |
| [OmniRoute](https://github.com/diegosouzapw/OmniRoute) | Nouveau projet OSS · gateway | Point d’entrée multi-fournisseurs avec fallback et routage par quotas. | [fiche](#omniroute--gateway-multi-fournisseurs) |
| [Arcbox](https://github.com/arcboxlabs/arcbox) | Nouveau projet OSS · isolation | Micro-VM/machines OCI isolées pour agents, avec démarrage annoncé inférieur à 100 ms. | [fiche](#arcbox--isolation-dagents-compatible-oci) |
| [LLMRouter](https://github.com/ulab-uiuc/LLMRouter) | Nouveau projet OSS · bibliothèque | Bibliothèque de routage de modèles pour déplacer la décision hors de l’application. | [fiche](#llmrouter--routage-de-modèles) |

## [Cloud Run — identités d’agents et Agent Registry](https://cloud.google.com/run/docs/release-notes)

- **Pitch rapide :** Le 01/09, Cloud Run permet d’utiliser les fonctionnalités Agent Platform avec des identités d’agents gérées par Google et l’enregistrement automatique dans Agent Registry (Preview). L’exposition réelle est inconnue.
- **Utilité :** À qualifier pour un service MCP ou agent déployé sur Cloud Run : comparer IAM explicite, identité système, rotation et journalisation avant tout basculement. Prévoir un chemin de repli avec compte de service dédié tant que le registre reste en Preview.
- **Outils similaires :** Workload Identity Federation (contrôle IAM plus explicite), Agentgateway (routage MCP), Cloud Run IAM/IAP (protection d’entrée).

## [GKE Multi-Cloud — correctif d’autorisation](https://cloud.google.com/kubernetes-engine/security-bulletins)

- **Pitch rapide :** Le bulletin GCP-2026-058 du 02/09 décrit une vérification de permission projet manquante dans les APIs GKE Multi-Cloud ; Google indique que les clusters sont corrigés et qu’aucune action client n’est requise.
- **Utilité :** Vérifier si l’organisation utilise des APIs Multi-Cloud ou des comptes ayant des rôles larges. Conserver la preuve du correctif fournisseur et revoir les permissions de service ; l’exposition locale reste inconnue.
- **Outils similaires :** GKE standard (surface Multi-Cloud absente), AWS EKS Anywhere (contrôles distincts), Policy Controller (contrôles de conformité complémentaires).

## [Claude Fable 5.1 — contexte et tâches longues](https://platform.claude.com/docs/en/release-notes/overview)

- **Pitch rapide :** Les notes Anthropic du 01/09 annoncent Claude Fable 5.1, avec contexte 1M tokens, sortie maximale 128k et adaptive thinking, destiné aux tâches agentiques longues.
- **Utilité :** Revoir la découpe des tâches et le budget de contexte dans les workflows RAG/agents. Mesurer coût, latence, taux d’erreur et qualité sur un jeu d’évaluation ; garder un modèle de repli et une validation humaine pour les actions.
- **Outils similaires :** modèles OpenAI à long contexte (API distincte), Gemini via Vertex AI (gouvernance GCP), routage LiteLLM (abstraction/fallback).

## [DeepSeek Harness — harness d’agents par plugins](https://github.com/deepseek-ai/deepseek-harness)

- **Pitch rapide :** Le dépôt public DeepSeek Harness décrit un harness open source MIT où les capacités sont des plugins ; il est explicitement en developer preview avec changements incompatibles possibles.
- **Utilité :** Étudier le découplage entre boucle d’agent, plugins et UI locale pour un environnement de évaluation. Isoler les plugins, limiter les permissions et ne pas l’exposer en production sans politique de repli.
- **Outils similaires :** LangGraph (graphe explicite), OpenAI Agents SDK (SDK fournisseur), CrewAI (orchestration multi-agents).

## [OmniRoute — gateway multi-fournisseurs](https://github.com/diegosouzapw/OmniRoute)

- **Pitch rapide :** OmniRoute est un projet MIT qui expose un endpoint vers de nombreux fournisseurs/modèles, avec fallback tenant compte des quotas et intégrations MCP/A2A.
- **Utilité :** évaluer comme couche de routage devant des workloads non critiques afin de séparer choix de modèle, quotas et application. Exiger chiffrement, gestion des secrets, traces par fournisseur et plafond de coût avant essai.
- **Outils similaires :** LiteLLM (proxy/routage mature), Envoy AI Gateway (intégration réseau), Portkey (gouvernance managée).

## [Arcbox — isolation d’agents compatible OCI](https://github.com/arcboxlabs/arcbox)

- **Pitch rapide :** Arcbox propose en Rust des machines isolées (kernel, filesystem, réseau) compatibles OCI pour exécuter des agents, avec un démarrage annoncé inférieur à 100 ms.
- **Utilité :** Piste pour exécuter du code généré ou des outils d’agents avec une frontière plus forte qu’un simple conteneur. Vérifier le modèle de menace, l’isolation réelle, le runtime hôte et la collecte de logs avant évaluation.
- **Outils similaires :** Firecracker (micro-VM éprouvée), Kata Containers (isolation Kubernetes), Cloud Run sandbox (service managé Preview).

## [LLMRouter — routage de modèles](https://github.com/ulab-uiuc/LLMRouter)

- **Pitch rapide :** LLMRouter est une bibliothèque open source de l’UIUC pour décider quel modèle appeler, afin d’externaliser le routage de la logique applicative.
- **Utilité :** À surveiller pour des politiques coût/latence/qualité mesurées. Demander une licence et une release stable avant intégration ; instrumenter chaque décision de route et conserver un fallback déterministe.
- **Outils similaires :** LiteLLM Router (proxy), vLLM (serving, pas décision multi-modèles), RouteLLM (routage orienté qualité/coût).

## Sujets écartés

- **AWS :** aucun changement urgent confirmé dans les pages publiques contrôlées le 03/09 ; les voies sécurité, lifecycle et quotas/coûts restent couvertes et feront l’objet d’un rattrapage si une source revient en erreur.
- **Vertex AI / OpenAI :** pages contrôlées, aucun changement récent avec preuve primaire suffisamment architectural pour ce cycle.
- **Autres dépôts OSS en tendance :** écartés lorsqu’ils n’avaient pas de licence ou d’artefact primaire vérifiable ; le quota de 33 % est atteint avec quatre projets sur sept sujets.

## Sources consultées

- **AWS —** [What's New](https://aws.amazon.com/new/), [bulletins sécurité](https://aws.amazon.com/security/security-bulletins/), [lifecycle EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) et [historique Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html), contrôle du 03/09 ; borne de reprise : dernier succès du journal local, puis rattrapage jusqu’à 30 jours ; **aucun changement retenu**.
- **GCP —** [Cloud Run release notes](https://cloud.google.com/run/docs/release-notes) (signal retenu : Agent Identity/Registry, 01/09), [GKE release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes), [bulletins GKE](https://cloud.google.com/kubernetes-engine/security-bulletins) (signal retenu : GCP-2026-058, 02/09), [policy de dépréciation](https://cloud.google.com/terms/deprecation) et [Vertex AI release notes](https://cloud.google.com/vertex-ai/docs/core-release-notes), contrôle du 03/09 ; borne de reprise : dernier succès fiable, fenêtre rattrapée 30 jours.
- **IA —** [Claude release notes](https://platform.claude.com/docs/en/release-notes/overview) (signal retenu : Fable 5.1, 01/09), [OpenAI changelog](https://developers.openai.com/api/docs/changelog), [OpenAI deprecations](https://developers.openai.com/api/docs/deprecations), Bedrock et Vertex AI, contrôle du 03/09 ; borne de reprise : dernier succès fiable, fenêtre rattrapée 30 jours.
- **OSS / découverte puis confirmation primaire —** [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness), [OmniRoute](https://github.com/diegosouzapw/OmniRoute), [Arcbox](https://github.com/arcboxlabs/arcbox), [LLMRouter](https://github.com/ulab-uiuc/LLMRouter), dépôts contrôlés le 03/09 ; GitTrend utilisé uniquement pour découverte le 02/09.

## Sources en échec

- Aucune source primaire bloquante pour ce cycle. Les pages Cloud Run et Claude ont été consultées directement ; toute exposition dans la stack reste à qualifier.
