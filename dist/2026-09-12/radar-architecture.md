# Radar architecture — 12 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `3030130` total — entrée `3009768` (dont cache `2820352`, hors cache `189416`), sortie `20362`, raisonnement `3360` — mesure runtime Codex, durée `00:07:19`.

Couverture incomplète : les deltas AWS, Bedrock et GKE indiqués dans `Sources en échec` ne sont pas clos ; aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Vault CVE-2026-5006](https://discuss.hashicorp.com/t/hcsec-2026-32-vault-vulnerable-to-privilege-escalation-via-slash-injection-in-templated-policy-paths/77678) | service · Mise à jour | Correctif et exposition locale restent à qualifier. | [Fiche](#vault-cve-2026-5006) |
| [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) | plateforme · Mise à jour | Le risque est limité aux restaurations CRIU explicitement ajoutées. | [Fiche](#gke--restauration-containerd-avec-criu) |
| [Google Cloud Agent Gateway](https://cloud.google.com/release-notes#September_10_2026) | plateforme · Mise à jour | VPC-SC dépend de la date et de l’egress du déploiement. | [Fiche](#google-cloud-agent-gateway) |
| [Elastic Agent et runtime OTel](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues) | outil · Mise à jour | Les versions 9.5.0–9.5.1 peuvent perdre de la télémétrie silencieusement. | [Fiche](#elastic-agent-et-runtime-otel) |
| [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog) | service · Mise à jour | Les raisons de cache miss restent à instrumenter localement. | [Fiche](#openai-prompt-cache-diagnostics) |

## [Vault CVE-2026-5006](https://discuss.hashicorp.com/t/hcsec-2026-32-vault-vulnerable-to-privilege-escalation-via-slash-injection-in-templated-policy-paths/77678)

**Pitch rapide :** Fait — suivi de signal existant : Vault CVE-2026-5006 reste corrigée par Vault 2.0.4 et les branches maintenues documentées par HashiCorp. Analyse — sans inventaire des versions et policies templatisées, l’exposition ne peut pas être conclue.

**Utilité :** L’advisory est prioritaire pour la sécurité des secrets ; versions Vault, chemins de policies templatisées et exposition locale sont `à qualifier`. Décision : qualification par `sécurité/plateforme` avant le 19/09 ; succès = inventaire et confirmation de non-exposition ou du correctif.

## [GKE — restauration containerd avec CRIU](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061)

**Pitch rapide :** Fait — suivi de signal existant : GCP-2026-061 décrit le contournement du contexte de sécurité à la restauration d’un checkpoint CRIU non fiable ; GKE ne l’active pas par défaut. Analyse — le risque reste borné aux plateformes ayant explicitement ajouté ce mécanisme.

**Utilité :** Le risque peut aller jusqu’aux privilèges root, mais l’usage de CRIU, la provenance des checkpoints et les versions GKE sont `à qualifier`. Décision : qualification par `sécurité/plateforme` avant le 17/09 ; succès = absence confirmée de restauration CRIU non fiable ou mesures correctives documentées.

## [Google Cloud Agent Gateway](https://cloud.google.com/release-notes#September_10_2026)

**Pitch rapide :** Fait — suivi de signal existant : Agent Gateway applique VPC-SC seulement aux déploiements créés après le 8 septembre 2026 avec egress VPC ALL_TRAFFIC. Analyse — VPC-SC ne prouve pas la protection des instances plus anciennes.

**Utilité :** Date de création et chemin egress deviennent des propriétés de conformité ; les gateways et périmètres réels restent `à qualifier`. Décision : qualification par `réseau/sécurité IA` avant le 25/09 ; succès = inventaire des dates, egress et application effective de VPC-SC.

## [Elastic Agent et runtime OTel](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues)

**Pitch rapide :** Fait — suivi de signal existant : Elastic Agent documente des pertes silencieuses possibles avec le runtime OTel en 9.5.0–9.5.1 et le correctif 9.5.2. Analyse — la continuité de télémétrie ne peut être supposée sans connaître les pipelines déployés.

**Utilité :** Une perte silencieuse invalide potentiellement les garanties de collecte ; version Elastic Agent et usage OTel sont `à qualifier`. Décision : qualification par `observabilité` avant le 19/09 ; succès = inventaire des agents et absence des versions concernées ou correctif 9.5.2.

## [OpenAI Prompt Cache Diagnostics](https://developers.openai.com/api/docs/changelog)

**Pitch rapide :** Fait — suivi de signal existant : Prompt Cache Diagnostics expose dans Responses les raisons de cache miss pour les modèles GPT-5.6 et ultérieurs. Analyse — ces champs suivent coûts et latences hors cache sans constituer un contrôle de disponibilité.

**Utilité :** C’est une télémétrie utile pour FinOps, mais modèles, instrumentation, rétention et flux locaux restent `à qualifier`. Décision : qualification par `plateforme IA/FinOps` avant le 01/10 ; succès = tableau de bord distinguant hits, misses et raisons de miss.

## Sujets écartés

- Aucun nouveau candidat éligible n’a été trouvé dans les deltas clos du 12/09. Les cinq fiches retenues sont des suivis de signaux actifs revus le 12/09, classés par impact opérationnel ; ils ne comptent pas dans le quota OSS.
- Exception quota OSS : les cinq sujets sélectionnés sont des suivis (`Mise à jour`) ; le quota ne s’applique donc à aucun nouveau candidat.

## Sources consultées

- Suivi primaire : [HCSEC-2026-32 — Vault](https://discuss.hashicorp.com/t/hcsec-2026-32-vault-vulnerable-to-privilege-escalation-via-slash-injection-in-templated-policy-paths/77678) — Vault 2.0.4 / 1.21.9 / 1.20.14 / 1.19.20 ; publié le 28/08/2026, effet inconnue, revu le 12/09/2026 ; versions corrigées de CVE-2026-5006.
- Suivi primaire : [Elastic Agent known issues](https://www.elastic.co/docs/release-notes/elastic-agent/known-issues) — Elastic Agent 9.5.0–9.5.1, correctif 9.5.2 ; publié le 02/09/2026, effet inconnue, revu le 12/09/2026 ; pertes silencieuses possibles du runtime OTel.
- Suivi primaire : [GCP-2026-061](https://cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-061) — GKE/containerd/CRIU ; publié le 09/09/2026, effet inconnue, revu le 12/09/2026 ; conditions d’exposition et non-activation par défaut.
- Suivi primaire : [Google Cloud release notes](https://cloud.google.com/release-notes#September_10_2026) — Agent Gateway VPC-SC ; publié le 10/09/2026, effet le 08/09/2026, revu le 12/09/2026 ; condition de création et egress ALL_TRAFFIC.
- Suivi primaire : [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — Responses GPT-5.6+ ; publié et effectif le 08/09/2026, revu le 12/09/2026 ; diagnostics de cache.

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
qualification_sources: [hashicorp-security, elastic-official, gke-security-bulletins, gcp-release-notes, openai-api-changelog]
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
    result: signal retenu
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

- `aws-whats-new` — `2026-09-09/2026-09-12` — RSS non pris en charge ; releases et disponibilité AWS incomplètes.
- `aws-security-bulletins` — `2026-09-09/2026-09-12` — RSS non pris en charge ; sécurité AWS et IA incomplète.
- `aws-eks-lifecycle` — `2026-09-09/2026-09-12` — Capture primaire trop ancienne pour clore le delta lifecycle EKS.
- `aws-bedrock-history` — `2026-09-07/2026-09-12` — Historique capturé avec retard ; voies AWS et IA liées à Bedrock incomplètes.
- `gke-release-notes` — `2026-09-11/2026-09-12` — Page primaire inaccessible ; voies GKE releases et lifecycle incomplètes.
