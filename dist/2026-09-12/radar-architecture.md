# Radar architecture — 12 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `3030130` total — entrée `3009768` (dont cache `2820352`, hors cache `189416`), sortie `20362`, raisonnement `3360` — mesure runtime Codex, durée `00:07:19`. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Couverture incomplète : les deltas AWS, Bedrock et GKE indiqués dans `Sources en échec` ne sont pas clos ; aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|

## Sujets écartés

- Exception minimum de sujets : 0 sujet(s) éligible(s) après les trois filtres ; Aucun candidat n'a été détecté dans les deltas primaires clos du 12/09. GitHub Trending et Trendshift ont été parcourus : aucune piste Cloud, Kubernetes, DevOps ou IA ne réunissait nouveauté substantielle, effet architectural et preuve primaire non dupliquée. Les voies AWS et GKE non closes sont exclues de toute conclusion d'absence de changement.
- Aucun candidat sélectionné : aucune fiche, aucun signal et aucune entrée de catalogue ne sont créés.

## Sources consultées

- Contrôle : [AWS What's New and service release notes](https://aws.amazon.com/about-aws/whats-new/recent/feed/) — consulté le 12/09/2026 ; delta non clos.
- Contrôle : [AWS security bulletins](https://aws.amazon.com/security/security-bulletins/rss/feed/) — consulté le 12/09/2026 ; delta non clos.
- Contrôle : [Amazon EKS Kubernetes version lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) — consulté le 12/09/2026 ; delta non clos.
- Contrôle : [Amazon Bedrock user guide document history](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html) — consulté le 12/09/2026 ; delta non clos.
- Contrôle : [Google Cloud release notes](https://cloud.google.com/release-notes) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [Google Cloud security bulletins](https://cloud.google.com/support/bulletins) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [Google Cloud deprecation policy](https://cloud.google.com/terms/deprecation) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [Google Kubernetes Engine release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes) — consulté le 12/09/2026 ; delta non clos.
- Contrôle : [Google Kubernetes Engine security bulletins](https://cloud.google.com/kubernetes-engine/security-bulletins) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [Vertex AI release notes](https://docs.cloud.google.com/vertex-ai/docs/release-notes) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — consulté le 12/09/2026 ; aucun changement retenu.
- Contrôle : [OpenAI API deprecations](https://developers.openai.com/api/docs/deprecations) — consulté le 12/09/2026 ; aucune dépréciation retenue.
- Contrôle : [Claude Platform release notes](https://platform.claude.com/docs/en/release-notes/overview) — consulté le 12/09/2026 ; aucun changement retenu.
- Découverte : [GitHub Trending and topic pages](https://github.com/trending) — consulté le 12/09/2026 ; aucune piste qualifiable.
- Découverte : [Trendshift live trending GitHub repositories](https://trendshift.io/) — consulté le 12/09/2026 ; aucune piste qualifiable.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins, aws-eks-lifecycle, aws-bedrock-history, gcp-release-notes, gcp-security-bulletins, gcp-deprecation-policy, gke-release-notes, gke-security-bulletins, vertex-ai-release-notes, openai-api-changelog, openai-api-deprecations, anthropic-release-notes]
discovery_sources: [github-trending, trendshift]
qualification_sources: []
coverage:
  - domain: AWS
    lane: releases_features
    sources: [aws-whats-new, aws-bedrock-history]
    scope: "Annonces AWS générales et historique Bedrock ; disponibilité fournisseur, pas exposition locale."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "RSS What's New non pris en charge ; historique Bedrock capturé le 06/09. Périodes manquantes : What's New 09–12/09, Bedrock 07–12/09."
  - domain: AWS
    lane: security
    sources: [aws-security-bulletins]
    scope: "Bulletins de sécurité AWS pour services et composants publiés par AWS ; exposition locale inconnue."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "RSS non pris en charge ; période du 09 au 12/09 non close."
  - domain: AWS
    lane: lifecycle_deprecations
    sources: [aws-eks-lifecycle, aws-bedrock-history]
    scope: "Versions et support EKS, lifecycle et disponibilité Bedrock ; inventaire local inconnu."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Capture EKS datée de deux semaines et historique Bedrock incomplet ; périodes manquantes EKS 09–12/09 et Bedrock 07–12/09."
  - domain: AWS
    lane: availability_quotas_costs
    sources: [aws-whats-new, aws-bedrock-history]
    scope: "Régions, quotas et coûts annoncés dans AWS What's New et l'historique Bedrock."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Aucun delta AWS n'a pu être clos : What's New 09–12/09 et Bedrock 07–12/09."
  - domain: GCP
    lane: releases_features
    sources: [gcp-release-notes, gke-release-notes, vertex-ai-release-notes]
    scope: "Notes générales GCP, versions et fonctionnalités GKE, mises à jour Vertex AI ; déploiement local inconnu."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-11"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Notes GCP et Vertex parcourues sans delta retenu ; page GKE inaccessible. Période GKE du 11 au 12/09 non close."
  - domain: GCP
    lane: security
    sources: [gcp-security-bulletins, gke-security-bulletins]
    scope: "Bulletins GCP et GKE ; le bulletin général ne clôt pas le delta propre à la page GKE."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-12"
    result: aucun changement retenu
    complete: true
    note: "Bulletins GCP et GKE parcourus ; aucun bulletin postérieur à GCP-2026-061."
  - domain: GCP
    lane: lifecycle_deprecations
    sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes]
    scope: "Politique de dépréciation GCP, lifecycle GKE et changements incompatibles Vertex AI."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-11"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Politique et Vertex parcourus sans delta ; page GKE inaccessible, période 11–12/09 non close."
  - domain: GCP
    lane: availability_quotas_costs
    sources: [gcp-release-notes, vertex-ai-release-notes]
    scope: "Disponibilités, régions, quotas et coûts GCP et Vertex AI ; contrats locaux inconnus."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-11"
    through: "2026-09-12"
    result: aucun changement retenu
    complete: true
    note: "Intervalle entièrement parcouru."
  - domain: IA
    lane: releases_features
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: "Fonctionnalités de plateformes IA AWS, GCP, OpenAI et Anthropic ; disponibilité locale inconnue."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic parcourus sans delta ; historique Bedrock incomplet du 07 au 12/09."
  - domain: IA
    lane: security
    sources: [aws-security-bulletins, gcp-security-bulletins]
    scope: "Bulletins AWS et GCP susceptibles d'affecter agents, connecteurs ou données IA."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Bulletins GCP parcourus sans delta ; flux AWS illisible du 09 au 12/09."
  - domain: IA
    lane: lifecycle_deprecations
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-deprecations, anthropic-release-notes]
    scope: "Dépréciations et changements incompatibles des plateformes IA ; usages locaux inconnus."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic parcourus sans delta ; historique Bedrock incomplet du 07 au 12/09."
  - domain: IA
    lane: availability_quotas_costs
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: "Disponibilité, régions, quotas et coûts des plateformes IA ; droits contractuels locaux inconnus."
    checked_at: "2026-09-12T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-12"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic parcourus sans delta ; historique Bedrock incomplet du 07 au 12/09."
```

## Sources en échec

- `aws-whats-new` — période `2026-09-09/2026-09-12` : RSS non pris en charge ; releases et disponibilité AWS incomplètes.
- `aws-security-bulletins` — période `2026-09-09/2026-09-12` : RSS non pris en charge ; sécurité AWS et IA incomplète.
- `aws-eks-lifecycle` — période `2026-09-09/2026-09-12` : Capture primaire trop ancienne pour clore le delta lifecycle EKS.
- `aws-bedrock-history` — période `2026-09-07/2026-09-12` : Historique capturé avec retard ; voies AWS et IA liées à Bedrock incomplètes.
- `gke-release-notes` — période `2026-09-11/2026-09-12` : Page primaire inaccessible ; voies GKE releases et lifecycle incomplètes.
