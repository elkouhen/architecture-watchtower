# Radar architecture — 7 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.

L’exposition réelle des produits et versions dans la stack reste `inconnue` faute d’inventaire confirmé.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-get-started.html) | service · Nouveau hors OSS | Le namespace Preview `bedrock-agentcore` s’arrête le 17/09. | [fiche](#aws-agent-registry) |
| [Gemini Enterprise Workflow Builder](https://docs.cloud.google.com/gemini/enterprise/docs/projects) | service · Nouveau hors OSS | Workflows, import A2A/ADK et mesures agents passent en GA. | [fiche](#gemini-enterprise-workflow-builder) |
| [Google SecOps case playbooks](https://docs.cloud.google.com/chronicle/docs/soar/respond/working-with-playbooks/case-playbooks) | service · Nouveau hors OSS | Les playbooks de dossier et triggers sont disponibles en Preview. | [fiche](#google-secops-case-playbooks) |
| [Setec](https://github.com/zeroroot-ai/setec) | outil · Nouveau projet OSS | Opérateur Kubernetes Apache-2.0 de sandbox micro-VM Kata/Firecracker. | [fiche](#setec) |
| [OpenHands software-agent-sdk](https://github.com/openhands/software-agent-sdk) | bibliothèque · Nouveau projet OSS | SDK MIT modulaire pour agents, outils et espace de travail OpenHands. | [fiche](#openhands-software-agent-sdk) |

## [AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-get-started.html)

- **Pitch rapide :** **Fait :** AWS annonce l’arrêt du namespace `bedrock-agentcore` le 17/09/2026 au profit de `agent-registry`; le registre catalogue agents, outils, skills et serveurs MCP avec IAM et approbation. **Analyse :** c’est un changement de contrat d’intégration, pas seulement un renommage.
- **Utilité :** Inventorier endpoints, SDK et politiques IAM qui portent l’ancien namespace. Maturité : service documenté. Exposition : inconnue. **Décision :** qualifier avant le 12/09, propriétaire `plateforme IA`, succès = aucun appel `bedrock-agentcore` avant l’échéance.

## [Gemini Enterprise Workflow Builder](https://docs.cloud.google.com/gemini/enterprise/docs/projects)

- **Pitch rapide :** **Fait :** Workflow Builder, l’import A2A/ADK et les vues de latence TTFT/TTFA/TTLT et d’erreurs pour agents sont GA. **Analyse :** orchestration, catalogue et exploitation d’agents convergent dans un même plan de gestion.
- **Utilité :** Base de comparaison avec une composition Kubernetes/MCP; les métriques cadrent des SLO sans prouver l’adoption locale. Maturité : GA fournisseur. Exposition : inconnue. **Décision :** surveiller, puis vérifier régions, IAM et modèle de données.
- **Repères de comparaison :** AWS AgentCore, GitLab Duo Agent Platform, OpenTelemetry GenAI.

## [Google SecOps case playbooks](https://docs.cloud.google.com/chronicle/docs/soar/respond/working-with-playbooks/case-playbooks)

- **Pitch rapide :** **Fait :** Google SecOps ajoute en Preview des playbooks de dossier et des triggers post-ingestion sur les changements d’alerte ou de cas. **Analyse :** l’automatisation porte désormais sur le cycle de vie de l’incident.
- **Utilité :** À comparer aux automatisations maison; les actions sensibles doivent garder approbation humaine, droits minimaux et audit. Maturité : Preview. Exposition : inconnue. **Décision :** ne pas en faire un contrôle critique; prévoir un repli procédural.

## [Setec](https://github.com/zeroroot-ai/setec)

- **Pitch rapide :** **Fait :** Setec est un opérateur Kubernetes public Apache-2.0, avec CRD Sandbox, qui orchestre des micro-VM Firecracker via Kata Containers. **Inférence :** il formalise une frontière d’exécution pour outils ou agents non fiables.
- **Utilité :** Pertinent pour isoler du code d’agent hors du processus hôte. Maturité : signal faible; compatibilité de distribution, HA et support restent à qualifier. Exposition : inconnue. **Décision :** référence d’architecture, pas recommandation de production.
- **Repères de comparaison :** Kata Containers, Agent Sandbox, gVisor.

## [OpenHands software-agent-sdk](https://github.com/openhands/software-agent-sdk)

- **Pitch rapide :** **Fait :** le dépôt public MIT contient SDK, serveur, outils, clients TypeScript, exemples et espace de travail pour OpenHands V1. **Analyse :** ces briques séparées peuvent s’intégrer dans une plateforme existante, sans constituer une frontière de sécurité.
- **Utilité :** À étudier pour intégrer un agent de développement sans adopter un monolithe. Maturité : signal faible; coût, modèles, opérations et sécurité d’exécution restent à qualifier. Exposition : inconnue. **Décision :** surveiller sans conclure à une aptitude de production.
- **Repères de comparaison :** Claude Agent SDK, LangGraph, Kiro/GitLab Duo.

## Sujets écartés

- Kiro Web prolonge une évolution d’outillage de développement, sans changement de contrat additionnel établi dans la fenêtre.
- Les pages dynamiques GCP lifecycle/Vertex et OpenAI sont déclarées en couverture incomplète, jamais assimilées à une absence de changement.

## Sources consultées

- [AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-get-started.html) et [notes AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/release-notes.html) — consultées le 07/09; migration, GA et PrivateLink.
- [Notes de version Google Cloud](https://cloud.google.com/release-notes) — consultées le 07/09; Gemini Enterprise et SecOps.
- [Zero Root AI](https://github.com/zeroroot-ai) — observée le 07/09; Setec, Apache-2.0 et CRD Sandbox.
- [OpenHands software-agent-sdk](https://github.com/openhands/software-agent-sdk) — observé le 07/09; dépôt public MIT et composants.

```watchtower-couverture
coverage:
  - {domain: AWS, lane: releases_features, sources: [aws-bedrock-history], scope: 'Bedrock et AgentCore; disponibilité locale non inférée.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Agent Registry qualifié.'}
  - {domain: AWS, lane: security, sources: [aws-security-bulletins], scope: 'Bulletins AWS.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun delta.'}
  - {domain: AWS, lane: lifecycle_deprecations, sources: [aws-eks-lifecycle], scope: 'Lifecycle EKS et support étendu.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Calendrier vérifié.'}
  - {domain: AWS, lane: availability_quotas_costs, sources: [aws-bedrock-history], scope: 'Disponibilité Bedrock publiée.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun delta distinct.'}
  - {domain: GCP, lane: releases_features, sources: [gcp-release-notes], scope: 'Notes GCP, Gemini Enterprise et SecOps.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Fonctionnalités qualifiées.'}
  - {domain: GCP, lane: security, sources: [gcp-security-bulletins], scope: 'Bulletins GCP.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun bulletin additionnel.'}
  - {domain: GCP, lane: lifecycle_deprecations, sources: [gcp-deprecation-policy], scope: 'Politique de dépréciation GCP.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'échec', complete: false, note: 'Lecture complète indisponible.'}
  - {domain: GCP, lane: availability_quotas_costs, sources: [vertex-ai-release-notes], scope: 'Limites Vertex AI.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'échec', complete: false, note: 'Delta non exploitable.'}
  - {domain: IA, lane: releases_features, sources: [openai-api-changelog], scope: 'Changelog API OpenAI.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'échec', complete: false, note: 'Rendu non exploitable.'}
  - {domain: IA, lane: security, sources: [gcp-security-bulletins], scope: 'Bulletins GCP applicables IA.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun delta distinct.'}
  - {domain: IA, lane: lifecycle_deprecations, sources: [openai-api-deprecations], scope: 'Dépréciations OpenAI.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'échec', complete: false, note: 'Lecture complète indisponible.'}
  - {domain: IA, lane: availability_quotas_costs, sources: [openai-api-changelog], scope: 'Limites API OpenAI.', checked_at: '2026-09-07T09:08:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'échec', complete: false, note: 'Rendu non exploitable.'}
```

Couverture incomplète : les voies GCP lifecycle/Vertex et IA OpenAI ne permettent aucune conclusion d’absence de changement.

## Sources en échec

- GCP deprecation policy, Vertex AI release notes et pages OpenAI : lecture complète indisponible pour 06–07/09; aucune absence de changement n’est affirmée.
