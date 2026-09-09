# Radar architecture — 9 septembre 2026

<!-- watchtower:2 -->
> **Tokens utilisés :** `246011` total — entrée `244803` (dont cache `200448`, hors cache `44355`), sortie `1208`, raisonnement `461` — mesure runtime Codex. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Exposition locale commune : inconnue (régions, versions, canaux et fenêtres de maintenance GKE non inventoriés).

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [GKE 2026-R38](https://cloud.google.com/kubernetes-engine/docs/release-notes) | plateforme · Mise à jour | Builds et cibles d’auto-upgrade changent par canal. | [Fiche](#gke-2026-r38) |

## [GKE 2026-R38](https://cloud.google.com/kubernetes-engine/docs/release-notes)

| Champ | Valeur |
|---|---|
| Type | plateforme · Mise à jour |
| Pitch rapide | **Pitch rapide :** **Fait :** les notes GKE du 8 septembre publient R38 : elles ajoutent notamment `1.37.0-gke.3165000` au canal Rapid, retirent des builds antérieurs et changent les cibles générales d’auto-upgrade. **Analyse :** cette rotation modifie la trajectoire effective des clusters gérés, même sans changement de minor local. |
| Utilité | **Utilité :** maturité : documenté ; niveau de découverte : traction étayée par les notes primaires. Les équipes GKE doivent comparer canaux, exclusions de maintenance et APIs dépréciées aux nouvelles cibles avant le 16 septembre ; propriétaire : plateforme Kubernetes ; critère de succès : inventaire des clusters et validation qu’aucune cible R38 ne franchit une contrainte connue. Disponibilité par zone progressive et exposition locale inconnue. Réf. : S1. |
| Repères de comparaison | GKE R37 (déjà suivi) ; auto-upgrade contrôlé par exclusion de maintenance ; gestion manuelle des versions. |

## Sujets écartés

- Exception quota OSS : aucun nouveau projet open source n’a passé les trois filtres dans la fenêtre du jour ; le seul sujet retenu est une mise à jour GKE substantielle.
- GCP-2026-060 : mise à jour du 8 septembre limitée à l’ajout d’un lien vers le bulletin Cluster Toolkit, sans nouveau correctif ni périmètre.
- Claude Platform : `ant` CLI 1.30.0 date du 3 septembre et ne constitue pas une évolution distincte depuis les radars récents.

## Sources consultées

- S1 — `gke-release-notes` — contrôle et qualification — [GKE release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes) — consultée le 2026-09-09 ; reprise 2026-09-08 ; R38, publié le 2026-09-08, ajoute/retire des builds et modifie les cibles d’auto-upgrade ; signal retenu.
- S2 — `gcp-release-notes` — contrôle — [Google Cloud release notes](https://cloud.google.com/release-notes) — consultée le 2026-09-09 ; reprise 2026-09-08 ; R38 et changements du 8 septembre parcourus ; signal retenu.
- S3 — `gcp-security-bulletins` — contrôle — [Google Cloud security bulletins](https://cloud.google.com/support/bulletins) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S4 — `gke-security-bulletins` — contrôle — [GKE security bulletins](https://cloud.google.com/kubernetes-engine/security-bulletins) — consultée le 2026-09-09 ; reprise 2026-09-06 ; aucun changement retenu.
- S5 — `gcp-deprecation-policy` — contrôle — [Google Cloud deprecation policy](https://cloud.google.com/terms/deprecation) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S6 — `vertex-ai-release-notes` — contrôle — [Vertex AI release notes](https://docs.cloud.google.com/vertex-ai/docs/release-notes) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S7 — `openai-api-changelog` — contrôle — [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S8 — `openai-api-deprecations` — contrôle — [OpenAI API deprecations](https://developers.openai.com/api/docs/deprecations) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S9 — `anthropic-release-notes` — contrôle — [Claude Platform release notes](https://platform.claude.com/docs/en/release-notes/overview) — consultée le 2026-09-09 ; reprise 2026-09-06 ; aucun changement retenu.
- S10 — `aws-whats-new` — contrôle — [AWS What’s New RSS](https://aws.amazon.com/about-aws/whats-new/recent/feed/) — consultée le 2026-09-09 ; reprise 2026-09-09 ; aucun changement retenu.
- S11 — `aws-security-bulletins` — contrôle — [AWS security bulletins RSS](https://aws.amazon.com/security/security-bulletins/rss/feed/) — consultée le 2026-09-09 ; reprise 2026-09-09 ; aucun changement retenu.
- S12 — `aws-eks-lifecycle` — contrôle — [EKS Kubernetes lifecycle](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) — consultée le 2026-09-09 ; reprise 2026-09-08 ; aucun changement retenu.
- S13 — `aws-bedrock-history` — contrôle — [Amazon Bedrock document history](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html) — consultée le 2026-09-09 ; reprise 2026-09-07 ; couverture partielle, voir échecs.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins, aws-eks-lifecycle, aws-bedrock-history, gcp-release-notes, gcp-security-bulletins, gcp-deprecation-policy, gke-release-notes, gke-security-bulletins, vertex-ai-release-notes, openai-api-changelog, openai-api-deprecations, anthropic-release-notes]
discovery_sources: []
qualification_sources: [gke-release-notes]
coverage:
    - {domain: AWS, lane: releases_features, sources: [aws-whats-new, aws-bedrock-history], scope: "Annonces AWS et historique Bedrock ; disponibilité fournisseur, pas exposition locale.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: false, note: "Historique Bedrock non clos du 07 au 09/09."}
    - {domain: AWS, lane: security, sources: [aws-security-bulletins], scope: "Bulletins de sécurité AWS.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: true, note: "Flux contrôlé."}
    - {domain: AWS, lane: lifecycle_deprecations, sources: [aws-eks-lifecycle, aws-bedrock-history], scope: "Lifecycle EKS et historique Bedrock.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "échec", complete: false, note: "Bedrock non clos du 07 au 09/09."}
    - {domain: AWS, lane: availability_quotas_costs, sources: [aws-whats-new, aws-bedrock-history], scope: "Disponibilité, quotas et coûts AWS/Bedrock documentés.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: false, note: "Historique Bedrock non clos du 07 au 09/09."}
    - {domain: GCP, lane: releases_features, sources: [gcp-release-notes, gke-release-notes, vertex-ai-release-notes], scope: "Nouveautés GCP, GKE et Vertex AI ; disponibilité fournisseur, pas exposition locale.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "signal retenu", complete: true, note: "GKE R38 retenu."}
    - {domain: GCP, lane: security, sources: [gcp-security-bulletins, gke-security-bulletins], scope: "Bulletins de sécurité GCP et GKE.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: true, note: "GCP-2026-060 seulement enrichi d’un lien."}
    - {domain: GCP, lane: lifecycle_deprecations, sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes], scope: "Politique GCP, cycles GKE et Vertex AI.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "signal retenu", complete: true, note: "Cibles GKE modifiées."}
    - {domain: GCP, lane: availability_quotas_costs, sources: [gcp-release-notes, vertex-ai-release-notes], scope: "Disponibilité et annonces de capacité GCP/Vertex AI.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "signal retenu", complete: true, note: "Déploiement GKE zonal progressif."}
    - {domain: IA, lane: releases_features, sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes], scope: "Fonctionnalités IA fournisseur ; disponibilité locale inconnue.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: false, note: "Historique Bedrock non clos du 07 au 09/09."}
    - {domain: IA, lane: security, sources: [aws-security-bulletins, gcp-security-bulletins], scope: "Bulletins de sécurité liés aux plateformes IA.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: true, note: "Flux contrôlés."}
    - {domain: IA, lane: lifecycle_deprecations, sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-deprecations, anthropic-release-notes], scope: "Lifecycle des plateformes et APIs IA.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: false, note: "Historique Bedrock non clos du 07 au 09/09."}
    - {domain: IA, lane: availability_quotas_costs, sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes], scope: "Disponibilité, quotas et coûts IA documentés.", checked_at: "2026-09-09T10:00:00+02:00", from: "2026-09-08", through: "2026-09-09", result: "aucun changement retenu", complete: false, note: "Historique Bedrock non clos du 07 au 09/09."}
```

Couverture incomplète : les voies AWS et IA dépendantes de l’historique Bedrock restent non closes du 7 au 9 septembre ; aucune absence de changement n’est inférée pour cet intervalle.

## Sources en échec

- `aws-bedrock-history` — historique et fallback non suffisants pour clore du 2026-09-07 au 2026-09-09 ; conséquence : voies AWS/IA dépendantes déclarées incomplètes.
