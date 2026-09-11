# Radar architecture — 9 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `500443` total — entrée `487518` (dont cache `440832`, hors cache `46686`), sortie `12925`, raisonnement `1367` — mesure runtime Codex, durée `00:04:45`. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Couverture incomplète : les voies AWS et IA dépendantes de l’historique Bedrock restent non closes du 7 au 9 septembre ; aucune absence de changement n’est inférée pour cet intervalle.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) | plateforme · GCP | Un checkpoint CRIU non fiable peut contourner le contexte de sécurité demandé lors d’une restauration containerd. | [Fiche](#gke--restauration-containerd-avec-criu) |
| [GKE 2026-R38](https://cloud.google.com/kubernetes-engine/docs/release-notes) | plateforme · Mise à jour | Builds et cibles d’auto-upgrade changent par canal. | [Fiche](#gke-2026-r38) |
| [Apigee SemanticCacheLookup](https://cloud.google.com/release-notes#September_09_2026) | service · GCP | La mesure de distance devient configurable et change le sens de comparaison du seuil. | [Fiche](#apigee-semanticcachelookup) |
| [Cloud SDK — composant Minikube](https://cloud.google.com/sdk/docs/release-notes#58400_2026-09-09) | outil · GCP | Le composant Minikube empaqueté dans gcloud sera retiré après le 31 janvier 2027. | [Fiche](#cloud-sdk--composant-minikube) |
| [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog) | service · OpenAI | L’API Responses explique désormais les succès et échecs du cache de prompts. | [Fiche](#openai-prompt-cache-diagnostics) |

## [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061)

- **Pitch rapide :** Fait — GCP-2026-061 décrit un contournement du contexte de sécurité lors de la restauration d’un checkpoint non fiable avec containerd et CRIU ; les clusters GKE par défaut ne sont pas vulnérables. **Analyse :** le risque concerne les plateformes ayant explicitement ajouté un mécanisme de checkpoint/restauration non fiable, pas un cluster GKE standard.
- **Utilité :** Le bulletin fournisseur est publié, mais l’identifiant CVE était encore en attente au moment du contrôle. L’usage local de CRIU, la provenance des checkpoints et les versions déployées sont `à qualifier` ; niveau : normal. **Décision :** qualification par `sécurité/plateforme` avant le 17/09/2026 ; succès = inventaire confirmant l’absence de restauration CRIU non fiable, ou mesures correctives documentées.

## [GKE 2026-R38](https://cloud.google.com/kubernetes-engine/docs/release-notes)

- **Pitch rapide :** **Fait :** les notes GKE du 8 septembre publient R38 : elles ajoutent notamment `1.37.0-gke.3165000` au canal Rapid, retirent des builds antérieurs et changent les cibles générales d’auto-upgrade. **Analyse :** cette rotation modifie la trajectoire effective des clusters gérés, même sans changement de version mineure local.
- **Utilité :** Le changement fournisseur est documenté avec un déploiement zonal progressif. Régions, versions, canaux et fenêtres de maintenance GKE locaux sont non inventoriés ; niveau : signal faible et exposition locale `à qualifier`. **Décision :** qualification par `plateforme Kubernetes` avant le 16/09/2026 ; succès = inventaire des clusters et validation qu’aucune cible R38 ne franchit une contrainte connue.

## [Apigee SemanticCacheLookup](https://cloud.google.com/release-notes#September_09_2026)

- **Pitch rapide :** Fait — Apigee 1-18-0-apigee-4 ajoute plusieurs mesures de distance à SemanticCacheLookup et impose de recalibrer le seuil lorsqu’une mesure non par défaut est choisie. **Analyse :** cette flexibilité adapte le cache au modèle d’embeddings mais rend le seuil partie intégrante du contrat de qualité.
- **Utilité :** La fonctionnalité est documentée dans une version Apigee en déploiement progressif. La présence de SemanticCacheLookup et les métriques de faux positifs dans la stack sont `à qualifier` ; niveau : normal. **Décision :** qualification par `plateforme IA/API` avant le 24/09/2026 ; succès = mesure de distance, seuil et jeu de validation inventoriés pour chaque cache sémantique.

## [Cloud SDK — composant Minikube](https://cloud.google.com/sdk/docs/release-notes#58400_2026-09-09)

- **Pitch rapide :** Fait — Cloud SDK 584.0.0 déprécie son composant Minikube et prévoit son retrait après le 31 janvier 2027, sans supprimer les configurations et clusters existants. **Analyse :** la dépendance à l’empaquetage gcloud doit être remplacée par l’installation OSS standard dans les postes et images CI concernés.
- **Utilité :** La dépréciation officielle possède une date de retrait et une solution de remplacement documentée. L’usage local de `gcloud components install minikube` est `à qualifier` ; niveau : normal. **Décision :** qualification par `plateforme développeur` avant le 08/10/2026 ; succès = aucune image ou procédure maintenue ne dépend du composant Minikube de gcloud.

## [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog)

- **Pitch rapide :** Fait — Prompt Cache Diagnostics est disponible dans l’API Responses pour les modèles GPT-5.6 et ultérieurs et retourne notamment la raison d’un cache miss. **Analyse :** ces champs peuvent alimenter des SLO de cache et isoler les changements augmentant le coût hors cache.
- **Utilité :** Cette capacité GA de l’API Responses est à intégrer comme télémétrie. Les modèles utilisés, la politique de rétention et l’instrumentation locale sont `à qualifier` ; niveau : normal. **Décision :** qualification par `plateforme IA/FinOps` avant le 01/10/2026 ; succès = tableau de bord distinguant hits, misses et raisons de miss sur les principaux flux Responses.

## Sujets écartés

- Cinq changements publiés au plus tard le 9 septembre ont franchi les trois filtres lors de la reconstruction ; Agent Gateway avec Service Extensions, daté du 31 août, est resté hors de la sélection.
- Exception quota OSS : 0 nouveau(x) projet(s) OSS éligible(s) pour 2 requis ; aucune alerte obligatoire n’a été évincée.

## Sources consultées

- Rôles recopiés du manifest — contrôle : `aws-whats-new`, `aws-security-bulletins`, `aws-eks-lifecycle`, `aws-bedrock-history`, `gcp-release-notes`, `gcp-security-bulletins`, `gcp-deprecation-policy`, `gke-release-notes`, `gke-security-bulletins`, `vertex-ai-release-notes`, `openai-api-changelog`, `openai-api-deprecations`, `anthropic-release-notes` ; découverte : `github-trending` ; qualification : `gke-release-notes`, `gke-security-bulletins`, `gcp-release-notes`, `openai-api-changelog`.
- `gke-security-bulletins` — qualification — [GCP-2026-061](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) — GKE avec restauration de checkpoints containerd/CRIU ; GHSA-p7v4-vr35-mj6f ; périmètre fournisseur, exposition locale inconnue ; publié le 2026-09-09 ; date d’effet inconnue ; consulté le 2026-09-09 ; Le bulletin décrit l’élévation de privilèges via checkpoint CRIU non fiable et précise que GKE n’active pas cette capacité par défaut.
- `gke-release-notes` — qualification — [GKE release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes) — GKE 2026-R38 version updates (2026-09-08) ; déploiement zonal progressif, exposition locale inconnue ; publié le 2026-09-08 ; date d’effet inconnue ; consulté le 2026-09-09 ; R38 ajoute et retire des builds et modifie les cibles d’auto-upgrade.
- `gcp-release-notes` — qualification — [Apigee SemanticCacheLookup](https://cloud.google.com/release-notes#September_09_2026) — Apigee 1-18-0-apigee-4 et versions ultérieures ; déploiement progressif, exposition locale inconnue ; publié le 2026-09-09 ; date d’effet 2026-09-09 ; consulté le 2026-09-09 ; Les notes GCP documentent les nouvelles distances et le sens de comparaison du seuil à partir d’Apigee 1-18-0-apigee-4.
- `gcp-release-notes` — qualification — [Cloud SDK 584.0.0](https://cloud.google.com/sdk/docs/release-notes#58400_2026-09-09) — composant Minikube empaqueté dans gcloud ; exposition locale inconnue ; publié le 2026-09-09 ; date d’effet 2027-01-31 ; consulté le 2026-09-09 ; Les notes Cloud SDK 584.0.0 annoncent la dépréciation du composant Minikube et son retrait après le 31 janvier 2027.
- `openai-api-changelog` — qualification — [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — OpenAI Responses API, modèles GPT-5.6 et ultérieurs ; disponibilité locale inconnue ; publié le 2026-09-08 ; date d’effet 2026-09-08 ; consulté le 2026-09-09 ; Le changelog annonce Prompt Cache Diagnostics en GA et le schéma Responses expose les champs de diagnostic.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins, aws-eks-lifecycle, aws-bedrock-history, gcp-release-notes, gcp-security-bulletins, gcp-deprecation-policy, gke-release-notes, gke-security-bulletins, vertex-ai-release-notes, openai-api-changelog, openai-api-deprecations, anthropic-release-notes]
discovery_sources: [github-trending]
qualification_sources: [gke-release-notes, gke-security-bulletins, gcp-release-notes, openai-api-changelog]
coverage:
  - domain: AWS
    lane: releases_features
    sources: [aws-whats-new, aws-bedrock-history]
    scope: Annonces AWS et historique Bedrock ; disponibilité fournisseur, pas exposition locale.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: aucun changement retenu
    complete: false
    note: Historique Bedrock non clos du 07 au 09/09.
  - domain: AWS
    lane: security
    sources: [aws-security-bulletins]
    scope: Bulletins de sécurité AWS.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: aucun changement retenu
    complete: true
    note: Flux contrôlé.
  - domain: AWS
    lane: lifecycle_deprecations
    sources: [aws-eks-lifecycle, aws-bedrock-history]
    scope: Lifecycle EKS et historique Bedrock.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: échec
    complete: false
    note: Bedrock non clos du 07 au 09/09.
  - domain: AWS
    lane: availability_quotas_costs
    sources: [aws-whats-new, aws-bedrock-history]
    scope: Disponibilité, quotas et coûts AWS/Bedrock documentés.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: aucun changement retenu
    complete: false
    note: Historique Bedrock non clos du 07 au 09/09.
  - domain: GCP
    lane: releases_features
    sources: [gcp-release-notes, gke-release-notes, vertex-ai-release-notes]
    scope: Nouveautés GCP, GKE et Vertex AI ; disponibilité fournisseur, pas exposition locale.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: true
    note: GKE R38 retenu.
  - domain: GCP
    lane: security
    sources: [gcp-security-bulletins, gke-security-bulletins]
    scope: Bulletins de sécurité GCP et GKE.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: true
    note: GCP-2026-060 seulement enrichi d’un lien.
  - domain: GCP
    lane: lifecycle_deprecations
    sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes]
    scope: Politique GCP, cycles GKE et Vertex AI.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: true
    note: Cibles GKE modifiées.
  - domain: GCP
    lane: availability_quotas_costs
    sources: [gcp-release-notes, vertex-ai-release-notes]
    scope: Disponibilité et annonces de capacité GCP/Vertex AI.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: true
    note: Déploiement GKE zonal progressif.
  - domain: IA
    lane: releases_features
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: Fonctionnalités IA fournisseur ; disponibilité locale inconnue.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: false
    note: Historique Bedrock non clos du 07 au 09/09.
  - domain: IA
    lane: security
    sources: [aws-security-bulletins, gcp-security-bulletins]
    scope: Bulletins de sécurité liés aux plateformes IA.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: aucun changement retenu
    complete: true
    note: Flux contrôlés.
  - domain: IA
    lane: lifecycle_deprecations
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-deprecations, anthropic-release-notes]
    scope: Lifecycle des plateformes et APIs IA.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: aucun changement retenu
    complete: false
    note: Historique Bedrock non clos du 07 au 09/09.
  - domain: IA
    lane: availability_quotas_costs
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: Disponibilité, quotas et coûts IA documentés.
    checked_at: '2026-09-09T10:00:00+02:00'
    from: '2026-09-08'
    through: '2026-09-09'
    result: signal retenu
    complete: false
    note: Historique Bedrock non clos du 07 au 09/09.
```

Couverture incomplète : les voies AWS et IA dépendantes de l’historique Bedrock restent non closes du 7 au 9 septembre ; aucune absence de changement n’est inférée pour cet intervalle.

## Sources en échec

- `aws-bedrock-history` — période : `2026-09-07/2026-09-09` ; conséquence : Historique et fallback non suffisants pour clore la période ; voies AWS et IA dépendantes incomplètes.
