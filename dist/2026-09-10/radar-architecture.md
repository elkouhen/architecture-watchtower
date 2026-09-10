# Radar architecture — 10 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.

Exposition locale commune : à qualifier. Couverture incomplète : plusieurs deltas AWS, GKE et Bedrock n’ont pas pu être clos ; aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) | plateforme · Nouveau hors OSS | Un checkpoint non fiable peut contourner le contexte de sécurité demandé. | [Fiche](#gke--restauration-containerd-avec-criu) |
| [Apigee SemanticCacheLookup](https://cloud.google.com/release-notes#September_09_2026) | service · Nouveau hors OSS | Les distances deviennent configurables et imposent de recalibrer le seuil. | [Fiche](#apigee-semanticcachelookup) |
| [Cloud SDK — composant Minikube](https://cloud.google.com/sdk/docs/release-notes#58400_2026-09-09) | outil · Nouveau hors OSS | Le composant Minikube de gcloud sera retiré après janvier 2027. | [Fiche](#cloud-sdk--composant-minikube) |
| [Agent Gateway avec Service Extensions](https://cloud.google.com/service-extensions/docs/release-notes#August_31_2026) | plateforme · Nouveau hors OSS | L’autorisation du trafic agentique peut être déléguée à une extension. | [Fiche](#agent-gateway-avec-service-extensions) |
| [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog) | service · Nouveau hors OSS | L’API expose les raisons des succès et échecs du cache de prompts. | [Fiche](#openai-prompt-cache-diagnostics) |

## [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061)

- **Pitch rapide :** **Fait — GCP-2026-061 décrit un contournement du contexte de sécurité lors de la restauration d'un checkpoint non fiable avec containerd et CRIU ; les clusters GKE par défaut ne sont pas vulnérables.** **Analyse :** le risque concerne les plateformes qui ont explicitement ajouté un mécanisme de checkpoint/restauration non fiable, pas un cluster GKE standard.
- **Utilité :** Le bulletin documente un impact pouvant aller jusqu’à une exécution root avec capacités élevées et filtres seccomp non appliqués. Maturité : bulletin fournisseur publié, identifiant CVE encore en attente ; niveau normal ; usage local de CRIU, provenance des checkpoints et versions déployées `à qualifier`. **Décision :** qualification par `sécurité/plateforme` avant le 17/09 ; succès = inventaire confirmant l’absence de restauration CRIU non fiable, ou versions et mesures correctives documentées pour chaque cluster concerné.
- **Repères de comparaison :** clusters GKE par défaut sans restauration CRIU ; admission refusant les checkpoints non fiables ; isolation renforcée des workloads concernés.

## [Apigee SemanticCacheLookup](https://cloud.google.com/release-notes#September_09_2026)

- **Pitch rapide :** **Fait — Apigee 1-18-0-apigee-4 ajoute plusieurs mesures de distance à SemanticCacheLookup et impose de recalibrer le seuil lorsqu'une mesure non par défaut est choisie.** **Analyse :** le seuil devient une partie explicite du contrat de qualité du cache sémantique.
- **Utilité :** Le choix entre produit scalaire, cosinus, L2 au carré et L1 permet d’aligner la comparaison sur les embeddings, mais une ancienne valeur de seuil ne conserve pas nécessairement sa signification. Maturité : fonctionnalité documentée dans une version Apigee en déploiement progressif ; niveau normal ; présence du cache et métriques de faux positifs `à qualifier`. **Décision :** qualification par `plateforme IA/API` avant le 24/09 ; succès = mesure, seuil et jeu de validation inventoriés pour chaque cache sémantique utilisé.
- **Repères de comparaison :** cache exact par clé ; cache sémantique applicatif ; absence de cache pour les réponses sensibles.

## [Cloud SDK — composant Minikube](https://cloud.google.com/sdk/docs/release-notes#58400_2026-09-09)

- **Pitch rapide :** **Fait — Cloud SDK 584.0.0 déprécie son composant Minikube et prévoit son retrait après le 31 janvier 2027, sans supprimer les configurations et clusters existants.** **Analyse :** les installations qui dépendent de l’empaquetage gcloud doivent adopter la distribution OSS standard.
- **Utilité :** Le changement touche les postes, images CI et scripts de bootstrap utilisant `gcloud components install minikube`, pas Minikube lui-même. Maturité : dépréciation officielle avec date et voie de remplacement ; niveau normal ; dépendances locales `à qualifier`. **Décision :** qualification par `plateforme développeur` avant le 08/10 ; succès = aucune image ou procédure maintenue ne dépend du composant Minikube de gcloud.
- **Repères de comparaison :** installation binaire officielle Minikube ; gestionnaire de paquets du poste ; clusters de développement distants.

## [Agent Gateway avec Service Extensions](https://cloud.google.com/service-extensions/docs/release-notes#August_31_2026)

- **Pitch rapide :** **Fait — Agent Gateway prend en charge Service Extensions en GA pour évaluer les requêtes et déléguer l'autorisation du trafic agentique à des services Google ou personnalisés.** **Analyse :** cette extension offre un point central de politique, mais son indisponibilité ne doit pas créer un défaut d’ouverture implicite.
- **Utilité :** La capacité sépare le routage agentique de la décision d’autorisation et permet d’intégrer un moteur personnalisé. Maturité : intégration déclarée GA ; niveau normal ; usage d’Agent Gateway, modèle de décision, latence et comportement de repli `à qualifier`. **Décision :** surveillance par `architecture IA/sécurité` avant le 01/10 ; succès = décision documentée sur le point d’autorisation, le mode de repli et les SLO si Agent Gateway est retenu.
- **Repères de comparaison :** autorisation dans l’application ; proxy `ext_authz` ; politiques IAM natives sans extension personnalisée.

## [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog)

- **Pitch rapide :** **Fait — Prompt Cache Diagnostics est disponible dans l'API Responses pour les modèles GPT-5.6 et ultérieurs et retourne notamment la raison d'un cache miss.** **Analyse :** ces champs peuvent rendre observable la part de coût et de latence liée aux changements de préfixe ou de modèle.
- **Utilité :** La télémétrie distingue les jetons manqués et certaines causes de miss ; elle aide à diagnostiquer le cache sans en faire un contrôle de disponibilité. Maturité : capacité GA de Responses ; niveau normal ; modèles, rétention et instrumentation locale `à qualifier`. **Décision :** qualification par `plateforme IA/FinOps` avant le 01/10 ; succès = tableau de bord distinguant hits, misses et raisons de miss sur les principaux flux Responses.
- **Repères de comparaison :** métriques d’usage agrégées ; traces applicatives ; estimation hors ligne des préfixes réutilisables.

## Sujets écartés

- Exception quota OSS : 0 nouveau(x) projet(s) OSS éligible(s) pour 2 requis ; aucune alerte obligatoire n’a été évincée.
- Vingt pistes ont été examinées : cinq ont franchi les filtres ; les autres étaient des doublons récents, des changements trop locaux ou des projets applicatifs sans effet architectural démontré.
- Trendshift : OpenConnector, Arcbox et DeepSeek Harness étaient déjà présents dans la fenêtre locale de 90 jours, sans évolution substantielle vérifiée.
- OpenAI GPT Image 2.5 et plusieurs disponibilités régionales Gemini : changements vérifiés mais effet de plateforme insuffisant face aux sujets retenus.

## Sources consultées

- `gcp-security-bulletins` — contrôle et qualification — [GCP-2026-061](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) — GKE/containerd avec restauration CRIU ; publié le 2026-09-09 ; effet inconnu ; consulté le 2026-09-10 ; contournement du contexte de sécurité via checkpoint non fiable, capacité non activée par défaut dans GKE.
- `gcp-release-notes` — contrôle et qualification — [Google Cloud release notes du 9 septembre](https://cloud.google.com/release-notes#September_09_2026) — borne de reprise 2026-09-09 ; consulté le 2026-09-10 ; Apigee SemanticCacheLookup et changements Cloud SDK qualifiés.
- `openai-api-changelog` — contrôle et qualification — [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — borne de reprise 2026-09-09 ; entrée Prompt Cache Diagnostics publiée le 2026-09-08 et rattrapée le 2026-09-10.
- `gcp-deprecation-policy`, `vertex-ai-release-notes`, `openai-api-deprecations` et `anthropic-release-notes` — contrôle — bornes de reprise au 2026-09-09 ; consultés le 2026-09-10 ; aucun autre changement retenu.
- `aws-whats-new`, `aws-security-bulletins`, `aws-eks-lifecycle`, `aws-bedrock-history`, `gke-release-notes` et `gke-security-bulletins` — contrôle — tentés le 2026-09-10 ; deltas incomplets détaillés ci-dessous.
- `github-trending` et `trendshift` — découverte — consultés le 2026-09-10 ; Trendshift exposait 24 entrées, sans nouveau projet OSS qualifié.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources:
- aws-whats-new
- aws-security-bulletins
- aws-eks-lifecycle
- aws-bedrock-history
- gcp-release-notes
- gcp-security-bulletins
- gcp-deprecation-policy
- gke-release-notes
- gke-security-bulletins
- vertex-ai-release-notes
- openai-api-changelog
- openai-api-deprecations
- anthropic-release-notes
discovery_sources:
- github-trending
- trendshift
qualification_sources:
- gcp-release-notes
- gcp-security-bulletins
- openai-api-changelog
coverage:
- domain: AWS
  lane: releases_features
  sources: [aws-whats-new, aws-bedrock-history]
  scope: "Annonces AWS générales et historique Bedrock ; disponibilité fournisseur, pas exposition locale."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Flux What's New non pris en charge, fallback trop ancien ; historique Bedrock arrêté au 05/09 et fallback inaccessible. Périodes manquantes : What's New 09–10/09, Bedrock 07–10/09."
- domain: AWS
  lane: security
  sources: [aws-security-bulletins]
  scope: "Bulletins de sécurité AWS pour services et composants publiés par AWS ; exposition locale inconnue."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Flux RSS non pris en charge et fallback daté d'une semaine ; période du 09 au 10/09 non close."
- domain: AWS
  lane: lifecycle_deprecations
  sources: [aws-eks-lifecycle, aws-bedrock-history]
  scope: "Versions, support standard/étendu et coûts EKS ; lifecycle et disponibilité Bedrock."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Pages EKS et fallback capturés avec deux à trois semaines de retard ; Bedrock reste incomplet du 07 au 10/09."
- domain: AWS
  lane: availability_quotas_costs
  sources: [aws-whats-new, aws-bedrock-history]
  scope: "Régions, quotas et coûts annoncés dans AWS What's New et l'historique Bedrock."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Aucun des deux deltas n'a pu être clos : What's New 09–10/09 et Bedrock 07–10/09."
- domain: GCP
  lane: releases_features
  sources: [gcp-release-notes, gke-release-notes, vertex-ai-release-notes]
  scope: "Notes générales GCP, versions/fonctionnalités GKE et mises à jour Vertex AI ; déploiement local inconnu."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Le delta général GCP et Vertex AI est clos, mais la page GKE détaillée a expiré et son fallback datait du 07/09 ; volet GKE du 09 au 10/09 incomplet."
- domain: GCP
  lane: security
  sources: [gcp-security-bulletins, gke-security-bulletins]
  scope: "Bulletins GCP et GKE ; le bulletin général GCP-2026-061 ne prouve pas une configuration GKE locale avec CRIU."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "GCP-2026-061 est qualifié via le bulletin général ; la capture du bulletin GKE ne le contenait pas encore et son fallback datait de deux semaines. Volet GKE non clos."
- domain: GCP
  lane: lifecycle_deprecations
  sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes]
  scope: "Politique de dépréciation GCP, lifecycle GKE et changements incompatibles Vertex AI."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Politique GCP et Vertex AI contrôlées ; le delta lifecycle GKE du 09 au 10/09 reste inaccessible."
- domain: GCP
  lane: availability_quotas_costs
  sources: [gcp-release-notes, vertex-ai-release-notes]
  scope: "Disponibilités, régions, quotas et coûts annoncés par GCP et Vertex AI ; exposition et contrats locaux inconnus."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: aucun changement retenu
  complete: true
  note: "Intervalle entièrement parcouru ; disponibilité régionale Gemini et autres changements datés du 09/09 examinés."
- domain: IA
  lane: releases_features
  sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
  scope: "Fonctionnalités de plateformes et modèles IA AWS, GCP, OpenAI et Anthropic ; disponibilité locale inconnue."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 10/09."
- domain: IA
  lane: security
  sources: [aws-security-bulletins, gcp-security-bulletins]
  scope: "Bulletins AWS et GCP susceptibles d'affecter runtimes, agents, connecteurs ou données IA."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-09"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Bulletins GCP contrôlés ; flux et fallback AWS insuffisamment frais pour clore le 09–10/09."
- domain: IA
  lane: lifecycle_deprecations
  sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-deprecations, anthropic-release-notes]
  scope: "Dépréciations et changements incompatibles des plateformes IA ; usages et modèles locaux inconnus."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 10/09."
- domain: IA
  lane: availability_quotas_costs
  sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
  scope: "Disponibilité, régions, quotas et coûts des plateformes IA ; droits contractuels et exposition locale inconnus."
  checked_at: "2026-09-10T12:00:00+02:00"
  from: "2026-09-07"
  through: "2026-09-10"
  result: échec
  complete: false
  note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 10/09."
```

## Sources en échec

- `aws-whats-new` — `2026-09-09/2026-09-10` — Flux RSS non pris en charge et fallback trop ancien ; AWS releases/features et disponibilité restent incomplets.
- `aws-security-bulletins` — `2026-09-09/2026-09-10` — Flux RSS non pris en charge et fallback trop ancien ; sécurité AWS et IA partiellement couverte.
- `aws-eks-lifecycle` — `2026-09-09/2026-09-10` — Captures primaire et fallback trop anciennes pour clore le delta lifecycle EKS.
- `aws-bedrock-history` — `2026-09-07/2026-09-10` — Historique arrêté au 05/09 et fallback inaccessible ; voies AWS et IA liées à Bedrock incomplètes.
- `gke-release-notes` — `2026-09-09/2026-09-10` — Page détaillée expirée et fallback daté du 07/09 ; releases et lifecycle GKE incomplets.
- `gke-security-bulletins` — `2026-09-09/2026-09-10` — Capture sans GCP-2026-061 et fallback trop ancien ; le bulletin général GCP qualifie le candidat mais ne clôt pas la source GKE.
- `github-trending` — `2026-09-09/2026-09-10` — La liste de dépôts n'était pas exposée par la page ni par Explore ; découverte assurée uniquement par Trendshift.
