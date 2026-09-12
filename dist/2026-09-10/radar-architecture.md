# Radar architecture — 10 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `192834` total — entrée `188921` (dont cache `156160`, hors cache `32761`), sortie `3913`, raisonnement `996` — mesure runtime Codex, durée `00:01:46`. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Exposition locale commune : à qualifier. Couverture incomplète : plusieurs deltas AWS, GKE et Bedrock n’ont pas pu être clos ; aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Agent Gateway avec Service Extensions](https://cloud.google.com/service-extensions/docs/release-notes#August_31_2026) | plateforme · GCP | L’autorisation du trafic agentique peut être déléguée à une extension. | [Fiche](#agent-gateway-avec-service-extensions) |

## [Agent Gateway avec Service Extensions](https://cloud.google.com/service-extensions/docs/release-notes#August_31_2026)

- **Pitch rapide :** **Fait — Agent Gateway prend en charge Service Extensions en GA pour évaluer les requêtes et déléguer l'autorisation du trafic agentique à des services Google ou personnalisés.** **Analyse :** cette extension offre un point central de politique, mais son indisponibilité ne doit pas créer un défaut d’ouverture implicite.
- **Utilité :** La capacité sépare le routage agentique de la décision d’autorisation et permet d’intégrer un moteur personnalisé. Maturité : intégration déclarée GA ; niveau `signal faible`, sans traction indépendante étayée ; usage d’Agent Gateway, modèle de décision, latence et comportement de repli `à qualifier`. **Décision :** surveillance par `architecture IA/sécurité` avant le 01/10 ; succès = décision documentée sur le point d’autorisation, le mode de repli et les SLO si Agent Gateway est retenu.
- **Repères de comparaison :** autorisation dans l’application ; proxy `ext_authz` ; politiques IAM natives sans extension personnalisée.

## Sujets écartés

- Exception minimum de sujets : 1 sujet(s) éligible(s) après les trois filtres ; Cinq pistes ont été examinées : Agent Gateway avec Service Extensions est le seul changement distinct du 09/09 qui franchit les trois filtres ; GKE CRIU, Apigee SemanticCacheLookup, Cloud SDK Minikube et OpenAI Prompt Cache Diagnostics répètent des sujets publiés le 09/09 sans delta substantiel.
- Exception quota OSS : 0 nouveau(x) projet(s) OSS éligible(s) pour 1 requis ; aucune alerte obligatoire n’a été évincée.

## Sources consultées

- `gcp-security-bulletins` — contrôle et qualification — [GCP-2026-061](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) — GKE avec restauration de checkpoints containerd/CRIU ; GHSA-p7v4-vr35-mj6f ; périmètre GKE, exposition locale inconnue ; publié le 2026-09-09 ; effet inconnu ; consulté le 2026-09-10 ; le bulletin décrit l'élévation de privilèges via checkpoint CRIU non fiable et précise que GKE n'active pas cette capacité par défaut.
- `gcp-release-notes` — contrôle et qualification — [Agent Gateway avec Service Extensions](https://cloud.google.com/service-extensions/docs/release-notes#August_31_2026) — Google Cloud Agent Gateway et Service Extensions GA ; environnement inconnu ; publié et effectif le 2026-08-31 ; consulté le 2026-09-10 ; les notes Service Extensions annoncent l'intégration Agent Gateway en disponibilité générale.
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
