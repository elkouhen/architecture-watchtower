# Radar architecture — 7 novembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.

Exposition locale commune : à qualifier. Couverture incomplète : le radar n’a pas tourné depuis le 12/09 ; la collecte est plafonnée à trente jours et la période du 12/09 au 07/10 reste une lacune datée, à laquelle s’ajoute la période du 08/10 au 27/10 pour AWS What's New (flux limité à cent éléments). Aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Noyau Linux — CVE-2026-98432 (TCP IPv4)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-078) | plateforme · GCP | Une faille TCP IPv4 du noyau permet une évasion de conteneur ; correctifs GKE COS publiés, 1.37 et Ubuntu en attente. | [Fiche](#noyau-linux--cve-2026-98432-tcp-ipv4) |
| [EKS Network Policy Agent — contournement NetworkPolicy (CVE-2026-122266)](https://aws.amazon.com/security/security-bulletins/rss/2026-170-aws/) | service · AWS | L’agent NetworkPolicy d’EKS peut laisser passer du trafic entrant entre pods co-localisés. | [Fiche](#eks-network-policy-agent--contournement-networkpolicy-cve-2026-122266) |
| [Compromission des sous-CA eMudhra (CVE-2026-111943)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-071) | standard · GCP | Sous-CA emSign compromises : nœuds corrigés par le fournisseur, images applicatives à reconstruire. | [Fiche](#compromission-des-sous-ca-emudhra-cve-2026-111943) |
| [GKE — mise à niveau des nœuds en place](https://docs.cloud.google.com/kubernetes-engine/docs/release-notes#October_16_2026) | service · GCP | GKE peut désormais mettre à niveau un nœud en conservant sa VM, par défaut dès que maxUnavailable > 0. | [Fiche](#gke--mise-à-niveau-des-nœuds-en-place) |
| [google/skills](https://github.com/google/skills) | bibliothèque · Nouveau projet OSS | Catalogue Apache-2.0 de skills et plugins d’agents de code pour GKE, Cloud Run et la sécurité GCP. | [Fiche](#googleskills) |
| [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) | outil · Nouveau projet OSS | Skill d’audit de sécurité multi-agents avec vérificateur distinct et sorties JSON validées. | [Fiche](#cloudflaresecurity-audit-skill) |
| [solongate/agent-security](https://github.com/solongate/agent-security) | outil · Nouveau projet OSS | Garde locale pour agents de code : politiques d’outils, DLP et audit ; signal faible. | [Fiche](#solongateagent-security) |

## [Noyau Linux — CVE-2026-98432 (TCP IPv4)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-078)

- **Pitch rapide :** **Fait — GCP-2026-078 (04/11/2026) : CVE-2026-98432 dans la pile TCP IPv4 du noyau peut provoquer une panique ou une évasion de conteneur ; déclenchable localement sans CAP_NET_RAW ou à distance via des options IPv4 vers un listener du nœud ou du plan de contrôle. GKE Standard et Autopilot sont concernés ; correctifs COS publiés, 1.37 et Ubuntu en cours. AWS a publié le bulletin 2026-160-AWS le 31/10.** **Analyse :** tant qu’un nœud n’est pas corrigé, l’isolation par namespace ne protège plus les pools mutualisés.
- **Utilité :** Les correctifs COS existent pour GKE 1.32 à 1.36 (1.36.5-gke.1982000, 1.35.9-gke.1505000, 1.34.12-gke.1539000, 1.33.13-gke.2207000, 1.32.13-gke.2906000) ; ceux de GKE 1.37 et des images Ubuntu sont annoncés en cours. Les réseaux autorisés du plan de contrôle et les pare-feu réduisent le vecteur réseau, pas le vecteur local. Maturité : correctifs partiels ; niveau normal ; versions GKE/EKS et images de nœuds `à qualifier`. **Décision :** qualification par `plateforme Kubernetes` avant le 21/11 ; succès = inventaire des pools GKE/EKS avec version et image, et pools non corrigés planifiés.
- **Repères de comparaison :** canal de version plus récent pour la même mineure (GKE) ; images Bottlerocket/AL2023 côté EKS ; isolation par sandbox (gVisor, Kata) pour les charges non fiables.

## [EKS Network Policy Agent — contournement NetworkPolicy (CVE-2026-122266)](https://aws.amazon.com/security/security-bulletins/rss/2026-170-aws/)

- **Pitch rapide :** **Fait — Bulletin 2026-170-AWS (04/11/2026) : une isolation insuffisante de l’état de suivi de connexions eBPF dans aws-network-policy-agent peut permettre à un utilisateur adjacent authentifié de contourner l’application des NetworkPolicy en entrée sur des pods co-localisés. Versions affectées : agent < 1.3.7, add-on géré VPC CNI < 1.22.3.** **Analyse :** la segmentation entre équipes qui repose sur les NetworkPolicy natives d’EKS n’est plus garantie avant la mise à jour.
- **Utilité :** Le correctif passe par la mise à jour de l’add-on VPC CNI ; les clusters qui utilisent Cilium ou Calico pour appliquer les politiques ne dépendent pas de ce composant. Maturité : correctif publié ; niveau normal ; activation des NetworkPolicy natives et version de l’add-on `à qualifier`. **Décision :** qualification par `plateforme Kubernetes` avant le 21/11 ; succès = tous les clusters EKS utilisant les NetworkPolicy natives en VPC CNI ≥ 1.22.3.
- **Repères de comparaison :** Cilium ; Calico ; security groups par pod.

## [Compromission des sous-CA eMudhra (CVE-2026-111943)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-071)

- **Pitch rapide :** **Fait — GCP-2026-071 (23/10/2026, mis à jour le 27/10) : plusieurs clés privées de sous-CA eMudhra (emSign) ont été compromises (CVE-2026-111943). Les clients TLS non corrigés sont exposés à une interception MitM sur les connexions externes ; les conteneurs applicatifs n’héritent pas du magasin de confiance du nœud et doivent être mis à jour séparément. AWS a publié le bulletin 2026-150-AWS sur ses trust bundles le 25/10.** **Analyse :** la correction est partagée entre le fournisseur (nœuds, composants système) et les équipes qui construisent les images.
- **Utilité :** Le mTLS interne de GKE, adossé à une PKI privée par cluster, n’est pas touché ; les pulls d’images vers des registres externes et les webhooks externes sans `caBundle` explicite dépendent du magasin système. AWS a publié le bulletin 2026-150 (25/10) sur ses trust bundles. Maturité : correctifs GKE COS et Ubuntu publiés ; niveau normal ; images de base, cadence de reconstruction et webhooks `à qualifier`. **Décision :** qualification par `plateforme Kubernetes et sécurité` avant le 21/11 ; succès = images de base reconstruites sans les sous-CA compromises et nœuds au niveau corrigé.
- **Repères de comparaison :** épinglage d’une CA privée pour les webhooks ; magasin de confiance géré dans l’image de base ; analyse d’image ciblant ca-certificates.

## [GKE — mise à niveau des nœuds en place](https://docs.cloud.google.com/kubernetes-engine/docs/release-notes#October_16_2026)

- **Pitch rapide :** **Fait — Note GKE du 16/10/2026 : pour les pools CPU GKE Standard, GKE peut désormais mettre à niveau un nœud en mettant à jour la VM Compute Engine existante au lieu de la recréer, ce qui conserve sa capacité. Le comportement s’active avec des surge upgrades dont maxUnavailable est supérieur à 0 ; il s’applique à toutes les versions et le retrait passe par Cloud Customer Care.** **Analyse :** les échecs de mise à niveau par manque de capacité diminuent, mais l’hypothèse « nœud mis à niveau = VM neuve » ne tient plus.
- **Utilité :** Les runbooks, contrôles de durcissement ou nettoyages qui supposaient un disque et une VM recréés doivent être revus pour les pools concernés ; la documentation `maxUnavailable` liste les exceptions où GKE recrée encore l’instance. Maturité : comportement GA appliqué par défaut ; niveau normal ; pools avec `maxUnavailable` > 0 `à qualifier`. **Décision :** qualification par `plateforme Kubernetes` avant le 21/11 ; succès = liste des pools concernés et validation de leurs runbooks.
- **Repères de comparaison :** blue-green node pool upgrades ; surge avec `maxUnavailable` = 0 ; Auto-upgrade d’EKS Auto Mode.

## [google/skills](https://github.com/google/skills)

- **Pitch rapide :** **Fait — Le dépôt google/skills (Apache-2.0, 551 commits, environ 23 000 étoiles le 07/11/2026) publie environ 190 Agent Skills pour les produits Google, dont GKE, Cloud Run, BigQuery, IAM, Cloud Armor, Cloud Logging/Monitoring et le Well-Architected Framework ; installation par npx skills add ou par plugins Claude Code, Codex et Antigravity CLI.** **Inférence :** la connaissance opératoire injectée aux agents de code devient un artefact fournisseur versionné, comme un module Terraform.
- **Utilité :** Base de référence pour comparer des skills internes GKE/Cloud Run ; les plugins ajoutent des serveurs MCP, donc une revue de supply chain et une allowlist sont nécessaires. Maturité : dépôt actif sans release taguée ni engagement de support explicite ; découverte, niveau normal ; usage local `à qualifier`. **Décision :** surveillance par `architecture IA` jusqu’au 07/12 ; succès = liste des skills GKE/Cloud Run pertinents et de leurs dépendances MCP.
- **Repères de comparaison :** skills internes ; serveurs MCP fournisseurs ; documentation GCP indexée en RAG.

## [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill)

- **Pitch rapide :** **Fait — Le dépôt cloudflare/security-audit-skill (MIT, 14 commits, environ 64 500 étoiles le 07/11/2026) décrit un audit en six phases : reconnaissance, chasse guidée par un registre de couverture, validation par un vérificateur distinct, findings.json validé par schéma, revérification indépendante et rapport. Il exige un bac à sable imposé par l’OS pour exécuter du code cible.** **Analyse :** le pattern « celui qui vérifie n’est jamais celui qui trouve » est transposable à une étape CI de sécurité.
- **Utilité :** Les sorties schématisées facilitent l’intégration à un pipeline GitHub/GitLab, mais les résultats ne sont pas déterministes : selon les auteurs, une exécution trouve environ la moitié de ce que trouvent des exécutions répétées. Maturité : projet jeune sans release ; découverte, traction étayée par la popularité seulement ; coût et taux de faux positifs `à qualifier`. **Décision :** surveillance par `sécurité applicative` jusqu’au 07/12 ; succès = avis documenté sur l’intégration CI et ses prérequis d’isolation.
- **Repères de comparaison :** Semgrep ; CodeQL ; revue de sécurité assistée intégrée aux agents.

## [solongate/agent-security](https://github.com/solongate/agent-security)

- **Pitch rapide :** **Fait — Le dépôt solongate/agent-security (Apache-2.0, 356 étoiles le 07/11/2026, sans release) fournit une CLI Go qui charge des hooks pour Claude Code, Codex CLI, Antigravity CLI et OpenCode, applique des règles allow/deny par chemin, commande, fichier ou URL, détecte plus de 70 motifs de secrets (détection, masquage ou blocage) et tient un journal d’audit local.** **Analyse :** il matérialise une couche de politique côté poste pour les agents de code.
- **Utilité :** Les hooks ne protègent pas une session déjà ouverte et les badges de conformité affichés sont auto-déclarés ; l’intérêt est de comparer ce modèle aux politiques gérées natives des éditeurs. Maturité : projet jeune ; **signal faible** ; postes et agents concernés `à qualifier`. **Décision :** surveillance par `sécurité applicative` jusqu’au 07/12 ; succès = comparaison documentée avec les politiques gérées des agents utilisés.
- **Repères de comparaison :** politiques gérées des agents (allowlists MCP) ; DLP d’entreprise ; bac à sable de poste.

## Sujets écartés

- Hors capacité après classement déterministe et application du quota OSS (3 nouveaux projets OSS requis sur 7) : [OpenAI — retrait de GPT-4o et GPT-4.1](https://developers.openai.com/api/docs/deprecations) ; [Anthropic — version d’API 2026-10-21 et SDK majeurs](https://platform.claude.com/docs/en/release-notes/overview) ; [Managed OpenTelemetry for GKE](https://docs.cloud.google.com/release-notes#October_29_2026) ; [EKS Auto Mode — Gateway API](https://aws.amazon.com/about-aws/whats-new/2026/10/amazon-eks-auto-mode-kubernetes-gateway-api/) ; [Claude Models on Google Cloud (Anthropic managed)](https://platform.claude.com/docs/en/release-notes/overview). Le retrait de GPT-4o/GPT-4.1 le 14/01/2027 (remplaçant gpt-6-luna) et Managed OpenTelemetry for GKE (GA à partir de 1.37.1-gke.1697000) restent consignés dans le manifest ; aucune alerte obligatoire n’a été évincée.
- [Firecracker — CVE-2026-122192](https://aws.amazon.com/security/security-bulletins/rss/2026-169-aws/) — impact architectural non démontré : Limité aux VM restaurées depuis un snapshot avec backend File et balloon/virtio-mem ; aucun usage auto-hébergé de Firecracker déclaré dans la stack.
- [AWS for Fluent Bit 3.0.0](https://aws.amazon.com/about-aws/whats-new/2025/10/aws-fluent-bit-3-0-0-based-4-1-1) — changement non substantiel : Annonce d’octobre 2025 seulement mise à jour le 02/11/2026 (précision sur OpenTelemetry) : pas de changement nouveau.
- [Serveurs MCP AWS — CVE-2026-115413 et CVE-2026-115845](https://aws.amazon.com/security/security-bulletins/rss/2026-152-aws/) — impact architectural non démontré : Correctifs de composants isolés sans changement de contrat ; relevant de la maintenance CVE, pas d’une rupture d’architecture.
- [Security Command Center — arrêt de DSPM](https://docs.cloud.google.com/release-notes#November_05_2026) — impact architectural non démontré : Fonction non déclarée dans la stack ; effet architectural non établi.
- [Agent Registry — analyse de sécurité des skills](https://docs.cloud.google.com/release-notes#November_06_2026) — impact architectural non démontré : Statut mixte (CMEK en Preview) et prérequis Gemini Enterprise Agent Platform non déclaré : effet architectural non établi pour la stack.
- Rendement : 17 éléments qualifiés sur les deltas du 08/10 au 07/11 (38 bulletins AWS, 100 annonces AWS, 29 journées GCP, 6 journées GKE, 2 bulletins GKE, changelogs OpenAI/Anthropic/Bedrock) et les deux flux de découverte ; la période du 12/09 au 07/10 reste une lacune datée.

## Sources consultées

- `gke-security-bulletins` — contrôle et qualification — [Noyau Linux — CVE-2026-98432 (TCP IPv4)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-078) — GKE COS < 1.36.5-gke.1982000 / 1.35.9-gke.1505000 / 1.34.12-gke.1539000 / 1.33.13-gke.2207000 / 1.32.13-gke.2906000 ; 1.37 et Ubuntu en cours ; publié le 2026-11-04 ; effet inconnue ; consulté le 2026-11-07 ; Bulletin GKE : vecteurs local et réseau, versions corrigées COS, 1.37/Ubuntu en cours.
- `aws-security-bulletins` — contrôle et qualification — [Noyau Linux — CVE-2026-98432 (TCP IPv4)](https://aws.amazon.com/security/security-bulletins/rss/2026-160-aws/) — GKE COS < 1.36.5-gke.1982000 / 1.35.9-gke.1505000 / 1.34.12-gke.1539000 / 1.33.13-gke.2207000 / 1.32.13-gke.2906000 ; 1.37 et Ubuntu en cours ; publié le 2026-10-31 ; effet inconnue ; consulté le 2026-11-07 ; Bulletin AWS 2026-160 sur la même CVE (use-after-free TCP IPv4).
- `aws-security-bulletins` — contrôle et qualification — [EKS Network Policy Agent — contournement NetworkPolicy (CVE-2026-122266)](https://aws.amazon.com/security/security-bulletins/rss/2026-170-aws/) — aws-network-policy-agent < 1.3.7 ; add-on géré Amazon VPC CNI < 1.22.3 ; publié le 2026-11-04 ; effet inconnue ; consulté le 2026-11-07 ; Bulletin AWS : composant, vecteur, versions affectées.
- `gke-security-bulletins` — contrôle et qualification — [Compromission des sous-CA eMudhra (CVE-2026-111943)](https://docs.cloud.google.com/kubernetes-engine/security-bulletins#gcp-2026-071) — GKE COS ≥ 1.37.1-gke.3011000 / 1.36.5-gke.1817000 / 1.35.9-gke.1390000 / 1.34.12-gke.1508000 / 1.33.13-gke.2152000 ; trust bundles AWS ; publié le 2026-10-23 ; effet inconnue ; consulté le 2026-11-07 ; Bulletin GKE : périmètre, conteneurs applicatifs à corriger séparément, versions corrigées.
- `aws-security-bulletins` — contrôle et qualification — [Compromission des sous-CA eMudhra (CVE-2026-111943)](https://aws.amazon.com/security/security-bulletins/rss/2026-150-aws/) — GKE COS ≥ 1.37.1-gke.3011000 / 1.36.5-gke.1817000 / 1.35.9-gke.1390000 / 1.34.12-gke.1508000 / 1.33.13-gke.2152000 ; trust bundles AWS ; publié le 2026-10-25 ; effet inconnue ; consulté le 2026-11-07 ; Bulletin AWS 2026-150 : récupération de clé d’une CA intermédiaire eMudhra dans les trust bundles AWS.
- `gke-release-notes` — contrôle et qualification — [GKE — mise à niveau des nœuds en place](https://docs.cloud.google.com/kubernetes-engine/docs/release-notes#October_16_2026) — Toutes versions GKE (Standard, pools CPU) ; publié le 2026-10-16 ; effet 2026-10-16 ; consulté le 2026-11-07 ; Note de version : réutilisation de la VM, condition maxUnavailable > 0, retrait via le support.
- `github-trending` — découverte et qualification — [google/skills](https://github.com/google/skills) — main (551 commits, sans release taguée) ; publié le inconnue ; effet inconnue ; consulté le 2026-11-07 ; Dépôt lu : licence, périmètre des skills, modes d’installation, absence de release.
- `github-trending` — découverte et qualification — [cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill) — main (14 commits, sans release) ; publié le inconnue ; effet inconnue ; consulté le 2026-11-07 ; Dépôt lu : licence MIT, six phases, prérequis de bac à sable, absence de release.
- `trendshift` — découverte et qualification — [solongate/agent-security](https://github.com/solongate/agent-security) — main (491 commits, sans release) ; publié le inconnue ; effet inconnue ; consulté le 2026-11-07 ; Dépôt lu : licence, agents pris en charge, modèle de politique, limites des hooks.
- `aws-whats-new`, `aws-eks-lifecycle`, `aws-bedrock-history`, `gcp-deprecation-policy`, `vertex-ai-release-notes`, `openai-api-changelog`, `openai-api-deprecations` et `anthropic-release-notes` — contrôle — deltas du 08/10 au 07/11 lus dans le cache local le 2026-11-07 ; candidats retenus ou écartés listés ci-dessus.
- `github-trending` et `trendshift` — découverte — consultés le 2026-11-07 ; trois pistes OSS qualifiées sur leur dépôt.

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
qualification_sources: []
coverage:
- domain: AWS
  lane: releases_features
  sources:
  - aws-whats-new
  - aws-bedrock-history
  scope: Annonces AWS générales et historique Bedrock ; disponibilité fournisseur, pas exposition locale.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: 'Flux What''s New limité à ses 100 derniers éléments (28/10–06/11) : période 2026-10-08/2026-10-27 non parcourue ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).'
- domain: AWS
  lane: security
  sources:
  - aws-security-bulletins
  scope: Bulletins de sécurité AWS (services, SDK, agents, EKS) ; exposition locale inconnue.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: signal retenu
  complete: false
  note: Delta du 08/10 au 07/11 entièrement lu (38 bulletins) ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: AWS
  lane: lifecycle_deprecations
  sources:
  - aws-eks-lifecycle
  - aws-bedrock-history
  scope: Historique documentaire EKS et Bedrock ; inventaire local des versions inconnu.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Six entrées EKS (Argo CD, politiques gérées) et historique Bedrock lus ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: AWS
  lane: availability_quotas_costs
  sources:
  - aws-whats-new
  - aws-bedrock-history
  scope: Régions, quotas et coûts AWS/Bedrock annoncés ; pas d’exposition locale.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Période 2026-10-08/2026-10-27 non couverte par le flux What's New ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: GCP
  lane: releases_features
  sources:
  - gcp-release-notes
  - gke-release-notes
  scope: Notes de version Google Cloud agrégées et GKE ; disponibilité fournisseur, pas exposition locale.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: signal retenu
  complete: false
  note: 29 journées GCP et 6 journées GKE lues de façon ciblée ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: GCP
  lane: security
  sources:
  - gcp-security-bulletins
  - gke-security-bulletins
  scope: Bulletins de sécurité Google Cloud et GKE ; versions locales inconnues.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: signal retenu
  complete: false
  note: Bulletins GKE GCP-2026-071 et GCP-2026-078 lus ; page GCP ciblée sur les mêmes identifiants ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: GCP
  lane: lifecycle_deprecations
  sources:
  - gcp-deprecation-policy
  - gke-release-notes
  - gcp-release-notes
  scope: Politique de dépréciation, changements de comportement GKE et sections Breaking/Deprecated GCP.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: signal retenu
  complete: false
  note: Sections Breaking et Deprecated extraites sur la période ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: GCP
  lane: availability_quotas_costs
  sources:
  - gcp-release-notes
  - vertex-ai-release-notes
  scope: Disponibilités régionales et machines GCP ; le flux Vertex AI n’a plus d’élément depuis le 16/03/2026.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Flux Vertex AI figé (dernier élément 16/03/2026), relayé par les notes GCP agrégées ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: IA
  lane: releases_features
  sources:
  - openai-api-changelog
  - anthropic-release-notes
  - aws-bedrock-history
  scope: Changelogs OpenAI, Anthropic et Bedrock ; disponibilité fournisseur, usage local inconnu.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Entrées du 02/10 au 05/11 lues ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: IA
  lane: security
  sources:
  - aws-security-bulletins
  - gcp-security-bulletins
  scope: Bulletins AWS et GCP touchant SDK, serveurs MCP et agents ; exposition locale inconnue.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Bulletins MCP/Strands lus et écartés comme correctifs isolés ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: IA
  lane: lifecycle_deprecations
  sources:
  - openai-api-deprecations
  - anthropic-release-notes
  scope: Dépréciations de modèles et de versions d’API OpenAI et Anthropic.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Dépréciations du 14/10 et du 05/11 et version d’API Anthropic 2026-10-21 lues ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
- domain: IA
  lane: availability_quotas_costs
  sources:
  - anthropic-release-notes
  - openai-api-changelog
  scope: Canaux d’accès, régions, quotas et coûts des API IA.
  checked_at: '2026-11-07T09:30:00+01:00'
  from: '2026-10-08'
  through: '2026-11-07'
  result: aucun changement retenu
  complete: false
  note: Canal Claude sur Google Cloud et paliers de service OpenAI lus ; lacune 2026-09-12/2026-10-07 (collecte plafonnée à 30 jours après l’interruption des radars depuis le 12/09).
```

## Sources en échec

- `aws-whats-new` — `2026-09-09/2026-10-27` — Interruption du radar puis flux limité à 100 éléments : releases et disponibilité AWS non parcourues avant le 28/10 ; aucune absence de changement n’est déduite.
- `aws-security-bulletins` — `2026-09-09/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `aws-eks-lifecycle` — `2026-09-09/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `aws-bedrock-history` — `2026-09-07/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `gcp-release-notes` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `gcp-security-bulletins` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `gcp-deprecation-policy` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `gke-release-notes` — `2026-09-11/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `gke-security-bulletins` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `vertex-ai-release-notes` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `openai-api-changelog` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `openai-api-deprecations` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
- `anthropic-release-notes` — `2026-09-12/2026-10-07` — Interruption du radar de plus de trente jours : période antérieure au 08/10 non parcourue ; aucune absence de changement n’est déduite.
