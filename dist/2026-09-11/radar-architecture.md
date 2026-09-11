# Radar architecture — 11 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `2997139` total — entrée `2955706` (dont cache `2712576`, hors cache `243130`), sortie `41433`, raisonnement `4247` — mesure runtime Codex. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Exposition locale commune : à qualifier. Couverture incomplète : plusieurs deltas AWS, GKE et Bedrock n’ont pas pu être clos ; aucune absence de changement n’en est déduite.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Google Cloud Agent Gateway](https://cloud.google.com/release-notes#September_10_2026) | service · GCP | VPC-SC ne protège que certains nouveaux déploiements configurés en egress total. | [Fiche](#google-cloud-agent-gateway) |
| [Claude Managed Agents](https://platform.claude.com/docs/en/release-notes/overview) | plateforme · Anthropic | Une politique serveur évalue chaque appel d’outil ou MCP. | [Fiche](#claude-managed-agents) |
| [Gemini Enterprise Agent Platform Sandboxes](https://cloud.google.com/release-notes#September_10_2026) | plateforme · GCP | Les sandboxes agentiques deviennent GA avec des contrôles réseau, de chiffrement et de persistance. | [Fiche](#gemini-enterprise-agent-platform-sandboxes) |
| [Google Cloud IAM MCP Server](https://cloud.google.com/release-notes#September_10_2026) | service · GCP | Un agent peut désormais administrer rôles personnalisés et deny policies via un serveur MCP GA. | [Fiche](#google-cloud-iam-mcp-server) |
| [OpenAI Agents API](https://developers.openai.com/api/docs/changelog) | plateforme · OpenAI | Une beta managée réunit sessions durables, orchestration, outils et sandboxes. | [Fiche](#openai-agents-api) |
| [Cloud SQL Remote MCP Server](https://cloud.google.com/release-notes#September_10_2026) | service · GCP | La désactivation temporaire de sqlcommenter retire un signal de traçabilité SQL. | [Fiche](#cloud-sql-remote-mcp-server) |
| [llmfit](https://github.com/AlexsJones/llmfit) | outil · Nouveau projet OSS | L’outil rapproche inventaire matériel, modèles, quantification et mesures locales. | [Fiche](#llmfit) |

## [Google Cloud Agent Gateway](https://cloud.google.com/release-notes#September_10_2026)

- **Pitch rapide :** **Fait — Agent Gateway applique VPC-SC seulement aux déploiements créés après le 8 septembre 2026 avec un modèle de connectivité VPC configuré en egress ALL_TRAFFIC.** **Analyse :** une activation déclarative de VPC-SC ne suffit donc pas à protéger les anciennes instances.
- **Utilité :** L’âge du déploiement et son chemin d’egress deviennent des propriétés de conformité. Maturité : capacité fournisseur disponible avec conditions documentées ; niveau normal ; instances, dates de création, templates réseau et périmètres VPC-SC `à qualifier`. **Décision :** qualification par `réseau/sécurité IA` avant le 25/09 ; succès = inventaire des gateways avec date de création, mode egress et application effective de VPC-SC.
- **Repères de comparaison :** recréation d’une gateway conforme ; contrôle réseau externe ; absence d’exposition via Agent Gateway.

## [Claude Managed Agents](https://platform.claude.com/docs/en/release-notes/overview)

- **Pitch rapide :** **Fait — Claude Managed Agents ajoute une politique auto qui autorise, refuse ou suspend chaque appel d'agent ou d'outil MCP et expose l'évaluation dans les événements.** **Analyse :** ce contrôle centralise l’autorisation dynamique et son audit.
- **Utilité :** La logique fournisseur doit rester observable et bornée par des permissions statiques minimales. Maturité : capacité de plateforme documentée ; niveau normal ; règles d’évaluation, garanties, faux positifs, conservation des événements et usage local `à qualifier`. **Décision :** qualification par `sécurité/plateforme IA` avant le 02/10 ; succès = modèle de décision, permissions minimales, approbations et audit comparés aux contrôles existants.
- **Repères de comparaison :** approbation humaine systématique ; politiques statiques minimales ; moteur d’autorisation externe.

## [Gemini Enterprise Agent Platform Sandboxes](https://cloud.google.com/release-notes#September_10_2026)

- **Pitch rapide :** **Fait — Google annonce GA les sandboxes Computer Use et Shell et documente VPC Service Controls, Private Service Connect, CMEK ainsi que la pause/reprise avec conservation d'état.** **Analyse :** il s’agit d’une primitive managée d’isolation et de persistance pour agents.
- **Utilité :** Les contrôles réseau et de chiffrement sont structurants, mais les garanties runtime et le coût doivent être comparés aux sandboxes Kubernetes déjà étudiées. Maturité : GA fournisseur ; niveau normal ; régions, quotas, coût, isolation runtime et workloads concernés `à qualifier`. **Décision :** qualification par `plateforme IA/sécurité` avant le 02/10 ; succès = frontières réseau, chiffrement, persistance, quotas et coûts comparés aux besoins réels.
- **Repères de comparaison :** Agent Sandbox sur Kubernetes ; microVM dédiées ; exécution éphémère sans état.

## [Google Cloud IAM MCP Server](https://cloud.google.com/release-notes#September_10_2026)

- **Pitch rapide :** **Fait — Google rend GA son serveur MCP IAM distant, utilisable par des applications IA pour inspecter et gérer les rôles personnalisés et les deny policies.** **Analyse :** une interface d’administration IAM devient ainsi un outil d’agent.
- **Utilité :** Cette frontière critique exige autorisations minimales, approbation humaine et journalisation. Maturité : disponibilité générale annoncée ; niveau normal ; comptes GCP, clients MCP, permissions et contrôles d’approbation `à qualifier`. **Décision :** qualification par `sécurité/plateforme IA` avant le 02/10 ; succès = cas d’usage, scopes minimaux, approbations et audit définis avant toute activation.
- **Repères de comparaison :** workflows IAM déclaratifs ; console et API sous contrôle humain ; serveur MCP interne à capacités réduites.

## [OpenAI Agents API](https://developers.openai.com/api/docs/changelog)

- **Pitch rapide :** **Fait — OpenAI publie en beta l'Agents API avec harness Codex managé, sessions durables, reprise, streaming, outils/MCP et sandboxes hébergées ou externes.** **Analyse :** la plateforme peut déplacer orchestration, état, reprise et exécution vers un service managé.
- **Utilité :** Ce contrat redessine la frontière build-versus-buy d’une plateforme d’agents, mais une beta ne doit pas porter seule un contrôle critique et requiert une solution de repli. Maturité : public beta ; niveau normal ; SLA, régions, quotas, coûts, réversibilité de l’état et garanties de sandbox `à qualifier`. **Décision :** qualification par `architecture/plateforme IA` avant le 02/10 ; succès = contrats d’état, reprise, sécurité, coûts et réversibilité comparés à une orchestration interne.
- **Repères de comparaison :** orchestration interne ; framework agent auto-hébergé ; service managé avec état externalisé.

## [Cloud SQL Remote MCP Server](https://cloud.google.com/release-notes#September_10_2026)

- **Pitch rapide :** **Fait — Le 10 septembre, Google a temporairement désactivé l'ajout des tags sqlcommenter via sql_commenter_enabled pour les requêtes des serveurs MCP Cloud SQL MySQL et PostgreSQL.** **Analyse :** les chaînes d’audit ou de corrélation dépendantes de ces commentaires perdent temporairement ce signal.
- **Utilité :** La rupture est active sans date de rétablissement, mais ne démontre aucune exposition locale. Maturité : service managé au comportement temporairement dégradé et documenté ; niveau normal ; usage du serveur MCP, dépendance aux tags et mécanisme alternatif `à qualifier`. **Décision :** qualification par `plateforme données/observabilité` avant le 25/09 ; succès = dépendances à sqlcommenter inventoriées et mécanisme de traçabilité alternatif confirmé si nécessaire.
- **Repères de comparaison :** audit natif Cloud SQL ; corrélation par attributs de trace ; journalisation applicative explicite.

## [llmfit](https://github.com/AlexsJones/llmfit)

- **Pitch rapide :** **Fait — llmfit inspecte CPU, RAM, GPU et VRAM, estime l'adéquation des modèles et quantifications, expose une API et peut enregistrer des benchmarks locaux.** **Analyse :** l’outil peut préfiltrer les choix de placement et de dimensionnement d’inférence.
- **Utilité :** Ses estimations communautaires ne constituent ni un benchmark d’adoption ni une preuve de performance sur le matériel cible. Maturité : projet actif avec binaire, conteneur, API et documentation ; niveau normal ; précision, chaîne d’installation, maintenance et usage Kubernetes `à qualifier`. **Décision :** surveillance par `plateforme IA` avant le 09/10 ; succès = méthode d’estimation et provenance des mesures évaluées sur un inventaire matériel réel, si une validation est demandée.
- **Repères de comparaison :** benchmark local direct ; calculateurs fournisseur ; profiling d’un serveur d’inférence.

## Sujets écartés

- Exception quota OSS : 1 nouveau(x) projet(s) OSS éligible(s) pour 3 requis ; aucune alerte obligatoire n’a été évincée.
- Quatorze candidats représentatifs ont été examinés : douze changements des deltas primaires et deux pistes OSS issues de GitHub Trending. Dix franchissent les trois filtres ; quatre sont arrêtés pour absence de nouveauté substantielle ou d'effet architectural suffisant. Les autres entrées des flux étaient hors périmètre, applicatives, sponsorisées ou des doublons récents.
- Les candidats éligibles non retenus l’ont été hors capacité après le classement déterministe ; `vercel-labs/skills` n’apporte pas de changement substantiel distinct et Gemini Enterprise for Slack n’a pas d’effet architectural démontré.

## Sources consultées

- `gcp-release-notes` — contrôle et qualification — [Google Cloud release notes du 10 septembre](https://cloud.google.com/release-notes#September_10_2026) — services Agent Gateway, Gemini Enterprise Agent Platform Sandboxes, IAM MCP Server et Cloud SQL Remote MCP Server ; publié et effectif le 2026-09-10 ; consulté le 2026-09-11 ; faits repris dans les fiches correspondantes.
- `anthropic-release-notes` — contrôle et qualification — [Claude Platform release notes](https://platform.claude.com/docs/en/release-notes/overview) — Claude Managed Agents ; publié et effectif le 2026-09-10 ; consulté le 2026-09-11 ; politique auto et événements d’évaluation documentés.
- `openai-api-changelog` — contrôle et qualification — [OpenAI API changelog](https://developers.openai.com/api/docs/changelog) — OpenAI Agents API public beta ; publié et effectif le 2026-09-10 ; consulté le 2026-09-11 ; sessions durables, reprise, outils et sandboxes documentés.
- `llmfit-repository` — qualification — [dépôt llmfit](https://github.com/AlexsJones/llmfit) — version de dépôt observée le 2026-09-11 ; date de publication et date d’effet inconnues ; consulté le 2026-09-11 ; licence MIT, détection matérielle, recommandations, API, conteneur et benchmarks documentés.
- `gcp-security-bulletins`, `gcp-deprecation-policy`, `gke-release-notes`, `vertex-ai-release-notes` et `openai-api-deprecations` — contrôle — consultés le 2026-09-11 ; aucun autre changement retenu.
- `aws-whats-new`, `aws-security-bulletins`, `aws-eks-lifecycle`, `aws-bedrock-history` et `gke-security-bulletins` — contrôle — tentés le 2026-09-11 ; deltas incomplets détaillés ci-dessous.
- `github-trending` et `trendshift` — découverte — consultés le 2026-09-11 ; deux pistes OSS examinées, dont llmfit qualifié.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins, aws-eks-lifecycle, aws-bedrock-history, gcp-release-notes, gcp-security-bulletins, gcp-deprecation-policy, gke-release-notes, gke-security-bulletins, vertex-ai-release-notes, openai-api-changelog, openai-api-deprecations, anthropic-release-notes]
discovery_sources: [github-trending, trendshift]
qualification_sources: [gcp-release-notes, openai-api-changelog, anthropic-release-notes, llmfit-repository, vercel-agent-skills]
coverage:
  - domain: AWS
    lane: releases_features
    sources: [aws-whats-new, aws-bedrock-history]
    scope: "Annonces AWS générales et historique Bedrock ; disponibilité fournisseur, pas exposition locale."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Flux What's New non pris en charge et fallback sans annonces ; historique Bedrock capturé avec retard. Périodes manquantes : What's New 09–11/09, Bedrock 07–11/09."
  - domain: AWS
    lane: security
    sources: [aws-security-bulletins]
    scope: "Bulletins de sécurité AWS pour services et composants publiés par AWS ; exposition locale inconnue."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Flux RSS non pris en charge et fallback arrêté au 31/08 ; période du 09 au 11/09 non close."
  - domain: AWS
    lane: lifecycle_deprecations
    sources: [aws-eks-lifecycle, aws-bedrock-history]
    scope: "Versions et support EKS, lifecycle et disponibilité Bedrock ; inventaire local inconnu."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Capture EKS datée de deux semaines et historique Bedrock incomplet ; périodes manquantes EKS 09–11/09 et Bedrock 07–11/09."
  - domain: AWS
    lane: availability_quotas_costs
    sources: [aws-whats-new, aws-bedrock-history]
    scope: "Régions, quotas et coûts annoncés dans AWS What's New et l'historique Bedrock."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Aucun des deux deltas n'a pu être clos : What's New 09–11/09 et Bedrock 07–11/09."
  - domain: GCP
    lane: releases_features
    sources: [gcp-release-notes, gke-release-notes, vertex-ai-release-notes]
    scope: "Notes générales GCP, versions et fonctionnalités GKE, mises à jour Vertex AI ; déploiement local inconnu."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-10"
    through: "2026-09-11"
    result: signal retenu
    complete: true
    note: "Intervalle entièrement parcouru ; changements du 10/09 consignés comme candidats avant sélection."
  - domain: GCP
    lane: security
    sources: [gcp-security-bulletins, gke-security-bulletins]
    scope: "Bulletins GCP et GKE ; le bulletin général ne clôt pas le delta propre à la page GKE."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Bulletins généraux GCP contrôlés ; la page GKE capturée le 10/09 ne contient toujours pas GCP-2026-061. Volet GKE du 09 au 11/09 non clos."
  - domain: GCP
    lane: lifecycle_deprecations
    sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes]
    scope: "Politique de dépréciation GCP, lifecycle GKE et changements incompatibles Vertex AI."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-10"
    through: "2026-09-11"
    result: aucun changement retenu
    complete: true
    note: "Intervalle entièrement parcouru ; aucune nouvelle dépréciation dans le delta."
  - domain: GCP
    lane: availability_quotas_costs
    sources: [gcp-release-notes, vertex-ai-release-notes]
    scope: "Disponibilités, régions, quotas et coûts GCP et Vertex AI ; contrats locaux inconnus."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-10"
    through: "2026-09-11"
    result: signal retenu
    complete: true
    note: "Intervalle entièrement parcouru ; changements de disponibilité et de facturation consignés comme candidats avant sélection."
  - domain: IA
    lane: releases_features
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: "Fonctionnalités de plateformes IA AWS, GCP, OpenAI et Anthropic ; disponibilité locale inconnue."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 11/09."
  - domain: IA
    lane: security
    sources: [aws-security-bulletins, gcp-security-bulletins]
    scope: "Bulletins AWS et GCP susceptibles d'affecter agents, connecteurs ou données IA."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-09"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Bulletins GCP contrôlés ; flux et fallback AWS insuffisamment frais pour clore le 09–11/09."
  - domain: IA
    lane: lifecycle_deprecations
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-deprecations, anthropic-release-notes]
    scope: "Dépréciations et changements incompatibles des plateformes IA ; usages locaux inconnus."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 11/09."
  - domain: IA
    lane: availability_quotas_costs
    sources: [aws-bedrock-history, vertex-ai-release-notes, openai-api-changelog, anthropic-release-notes]
    scope: "Disponibilité, régions, quotas et coûts des plateformes IA ; droits contractuels locaux inconnus."
    checked_at: "2026-09-11T12:00:00+02:00"
    from: "2026-09-07"
    through: "2026-09-11"
    result: échec
    complete: false
    note: "Vertex AI, OpenAI et Anthropic contrôlés ; historique Bedrock incomplet du 07 au 11/09."
```

## Sources en échec

- `aws-whats-new` — `2026-09-09/2026-09-11` — RSS non pris en charge et fallback sans annonces ; releases et disponibilité AWS incomplètes.
- `aws-security-bulletins` — `2026-09-09/2026-09-11` — RSS non pris en charge et fallback arrêté au 31/08 ; sécurité AWS et IA incomplète.
- `aws-eks-lifecycle` — `2026-09-09/2026-09-11` — Capture primaire trop ancienne pour clore le delta lifecycle EKS.
- `aws-bedrock-history` — `2026-09-07/2026-09-11` — Historique capturé avec retard ; voies AWS et IA liées à Bedrock incomplètes.
- `gke-security-bulletins` — `2026-09-09/2026-09-11` — Capture sans GCP-2026-061 ; le bulletin général GCP ne clôt pas la source GKE.
