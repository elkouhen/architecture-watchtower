# Radar architecture — 7 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.

L’exposition réelle des produits et versions dans la stack reste `inconnue` faute d’inventaire confirmé.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [Amazon EFS CSI Driver](https://aws.amazon.com/security/security-bulletins/2026-099-aws/) | outil · Mise à jour | La version 3.4.1 corrige une suppression inter-filesystem conditionnelle. | [fiche](#amazon-efs-csi-driver) |
| [awslabs postgres-mcp-server](https://aws.amazon.com/security/security-bulletins/2026-101-aws/) | outil · Mise à jour | La version 1.1.7 rétablit la frontière de lecture seule, sous réserve des droits PostgreSQL. | [fiche](#awslabs-postgres-mcp-server) |
| [AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-faq.html) | service · AWS | Le namespace Preview `bedrock-agentcore` s’arrête le 17 septembre. | [fiche](#aws-agent-registry) |
| [Gemini Enterprise Workflow Builder](https://docs.cloud.google.com/gemini/enterprise/docs/release-notes) | service · GCP | Workflows, import A2A/ADK et observabilité des agents sont désormais GA. | [fiche](#gemini-enterprise-workflow-builder) |
| [Setec](https://github.com/zeroroot-ai/setec) | outil · Nouveau projet OSS | Une CRD Kubernetes pilote plusieurs frontières d’isolation, dont Kata/Firecracker. | [fiche](#setec) |
| [OpenHands Software Agent SDK](https://github.com/openhands/software-agent-sdk) | bibliothèque · Nouveau projet OSS | SDK Python/TypeScript/REST pour agents de développement et workspaces éphémères. | [fiche](#openhands-software-agent-sdk) |

## [Amazon EFS CSI Driver](https://aws.amazon.com/security/security-bulletins/2026-099-aws/)

- **Pitch rapide :** **Fait :** le bulletin AWS 2026-099 indique que les versions `<= 3.4.0`, avec l’option non standard `--delete-access-point-root-dir=true`, ne vérifient pas l’appartenance de l’access point au filesystem avant suppression ; la version `3.4.1` corrige le défaut. **Analyse :** la combinaison d’un volume handle forgé et du droit de créer des PersistentVolumes peut transformer une opération Kubernetes en suppression récursive hors du périmètre attendu.
- **Utilité :** Qualifier versions, option du contrôleur, RBAC de création des PV, rôle IAM et politiques EFS ; le défaut n’affecte pas EFS lui-même. Maturité : correctif documenté ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** qualification avant le 11/09 par `plateforme Kubernetes/sécurité`, succès = absence de version vulnérable avec l’option active, ou passage à `3.4.1` et bornage RBAC/IAM documenté.

## [awslabs postgres-mcp-server](https://aws.amazon.com/security/security-bulletins/2026-101-aws/)

- **Pitch rapide :** **Fait :** AWS documente qu’avant `1.1.7`, le validateur SQL peut laisser un acteur non authentifié injecter du contenu conduisant à une modification de données lorsqu’un utilisateur authentifié interagit avec le serveur MCP. **Analyse :** une promesse applicative de lecture seule ne constitue donc pas une frontière de sécurité suffisante.
- **Utilité :** Rechercher le paquet PyPI, ses forks et rôles de connexion PostgreSQL ; la base doit imposer elle-même `CONNECT`, `USAGE`, `SELECT` et les transactions en lecture seule. Maturité : correctif documenté ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** qualification avant le 11/09 par `plateforme IA/sécurité données`, succès = aucune version `< 1.1.7` et aucun rôle superuser, `rds_superuser` ou propriétaire de cluster utilisé par ce serveur.

## [AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-faq.html)

- **Pitch rapide :** **Fait :** AWS arrête le 17/09/2026 l’accès au namespace Preview `bedrock-agentcore` du Registry et impose `agent-registry`; endpoints, actions IAM, principaux de service, ARN, clients SDK, commandes CLI, quotas et événements changent, ainsi qu’une partie du schéma. **Analyse :** il s’agit d’une migration incompatible du contrat d’intégration, pas d’un renommage cosmétique.
- **Utilité :** Inventorier registres, enregistrements, IaC, politiques IAM/SCP, règles EventBridge, requêtes CloudTrail, dashboards CloudWatch et quotas qui référencent l’ancien namespace ; les autres services AgentCore gardent `bedrock-agentcore`. Maturité : GA documentée ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** qualification avant le 11/09 par `plateforme IA`, succès = aucune dépendance Registry à l’ancien endpoint, ARN ou schéma avant le 17/09.

## [Gemini Enterprise Workflow Builder](https://docs.cloud.google.com/gemini/enterprise/docs/release-notes)

- **Pitch rapide :** **Fait :** le 03/09, Google a rendu GA Workflow Builder avec exécution planifiée, manuelle ou par mention, import d’agents A2A/ADK, connecteurs et contrôles administratifs ; des vues GA distinctes exposent p50/p95 de TTFT, TTFA, TTLT et les taux d’erreur. **Analyse :** composition, catalogue et exploitation d’agents convergent dans le même plan de gestion.
- **Utilité :** Sert de référence face à une composition Kubernetes/MCP, mais impose de qualifier régions, IAM, résidence, données envoyées aux agents et connecteurs, coût, validation humaine et repli hors plateforme. Maturité : GA fournisseur ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** surveiller par `plateforme IA`, réexamen le 21/09 après qualification des régions, permissions et limites opérationnelles.
- **Repères de comparaison :** AWS Agent Registry/AgentCore, GitLab Duo Agent Platform, plateforme Kubernetes avec MCP et OpenTelemetry.

## [Setec](https://github.com/zeroroot-ai/setec)

- **Pitch rapide :** **Fait :** Setec est un opérateur Kubernetes Apache-2.0 dont la CRD `Sandbox` `v1alpha1` sélectionne Kata/Firecracker, Kata/QEMU, gVisor ou `runc`, avec chart Helm, pool de préchauffage et télémétrie Prometheus/OpenTelemetry. **Inférence :** cette API peut uniformiser la frontière d’exécution de code non fiable sans masquer les différences d’isolation entre backends.
- **Utilité :** Le chemin documenté exige Kubernetes `1.30+`, des nœuds `amd64` et KVM pour les micro-VM ; le dépôt se déclare pré-release/alpha et ses objectifs de latence ne sont pas une preuve indépendante. Maturité : expérimental ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** conserver comme référence d’architecture, réexamen le 28/09 par `plateforme Kubernetes` si une release, un test indépendant ou un retour d’exploitation apparaît.
- **Repères de comparaison :** Agent Sandbox, Kata Containers, gVisor.

## [OpenHands Software Agent SDK](https://github.com/openhands/software-agent-sdk)

- **Pitch rapide :** **Fait :** ce dépôt MIT fournit des API Python, TypeScript et REST, un Agent Server, des outils, conversations et workspaces locaux ou éphémères Docker/Kubernetes pour des agents travaillant sur du code. **Analyse :** la séparation SDK/serveur/client facilite l’intégration dans une plateforme existante, mais ne constitue pas à elle seule une isolation de sécurité.
- **Utilité :** À considérer pour composer un agent de développement sans adopter toute l’interface OpenHands ; fournisseur de modèle, permissions d’outils, secrets, coût, évaluations, observabilité, validation humaine et repli restent à qualifier. Maturité : intégration documentée, exploitation non étayée ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** surveiller jusqu’au 28/09 par `plateforme IA`, sans conclure à une aptitude de production.
- **Repères de comparaison :** Claude Agent SDK, LangGraph, Agents SDK avec sandbox séparée.

## Sujets écartés

- Google SecOps case playbooks et reaction triggers : Preview utile mais moins urgente que les deux bulletins AWS retenus ; ne pas en faire seul un contrôle de production critique.
- OpenAI Responses API pour GPT-6 Astra : les contrôles de tâches longues du 03/09 sont documentés, mais la sélection privilégie ici les ruptures de sécurité et de namespace ; aucune exposition locale ni traction indépendante n’est établie.
- Bulletin `awslabs.dynamodb-mcp-server` 2026-097 : correctif `2.1.6` vérifié, mais exposition inconnue et valeur décisionnelle moindre que la rupture de lecture seule PostgreSQL ; ne pas déduire une absence de risque si le paquet ou un fork est inventorié.
- AWS What’s New général : couverture incomplète du 07/09 ; les contrôles AgentCore, sécurité, EKS et Bedrock ciblés ne prouvent pas l’absence de changement dans les autres services AWS.

## Sources consultées

- [Bulletin AWS 2026-099](https://aws.amazon.com/security/security-bulletins/2026-099-aws/) — Amazon EFS CSI Driver `<= 3.4.0`, publié et effectif le 04/09/2026, consulté le 07/09 ; condition d’exposition, correctif `3.4.1` et mesures RBAC/IAM.
- [Bulletin AWS 2026-101](https://aws.amazon.com/security/security-bulletins/2026-101-aws/) — `awslabs postgres-mcp-server < 1.1.7`, publié et effectif le 04/09/2026, consulté le 07/09 ; contournement de la lecture seule, correctif et moindre privilège PostgreSQL.
- [Guide de migration AWS Agent Registry](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/registry-faq.html) et [notes AgentCore](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/release-notes.html) — namespace lancé le 06/08, échéance effective le 17/09, pages consultées le 07/09 ; surfaces incompatibles et périmètre AgentCore inchangé.
- [Notes Gemini Enterprise](https://docs.cloud.google.com/gemini/enterprise/docs/release-notes) et [métriques agents](https://docs.cloud.google.com/gemini/enterprise/docs/access-metrics) — nouveautés publiées le 03/09, effet GA le même jour, consultées le 07/09 ; Workflow Builder, import A2A/ADK, TTFT/TTFA/TTLT et erreurs.
- [Setec](https://github.com/zeroroot-ai/setec) — dépôt et artefacts observés le 07/09, date de release inconnue ; licence Apache-2.0, statut alpha, CRD, backends, prérequis et Helm vérifiés.
- [OpenHands Software Agent SDK](https://github.com/openhands/software-agent-sdk) — dépôt observé le 07/09, date de release inconnue ; licence MIT, frontières des composants et workspaces Docker/Kubernetes vérifiés.
- [AWS Security Bulletins](https://aws.amazon.com/security/security-bulletins/) — contrôlés le 07/09 avec reprise corrective au 04/09 ; derniers bulletins observés `2026-101-AWS` à `2026-097-AWS`, deux signaux retenus.
- [Cycle de vie Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html) et [historique Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html) — contrôlés le 07/09 depuis la borne du 06/09 ; aucun changement additionnel retenu.
- [Notes Google Cloud](https://docs.cloud.google.com/release-notes), [bulletins GCP](https://docs.cloud.google.com/support/bulletins), [politique de dépréciation](https://cloud.google.com/terms/deprecation) et [notes Vertex AI](https://docs.cloud.google.com/vertex-ai/docs/release-notes) — contrôlés le 07/09 depuis le 06/09 ; signaux Gemini/SecOps qualifiés, aucun autre changement sécurité, lifecycle, région, quota ou coût retenu.
- [Changelog OpenAI API](https://developers.openai.com/api/docs/changelog), [dépréciations](https://developers.openai.com/api/docs/deprecations) et [catalogue des modèles](https://developers.openai.com/api/docs/models) — documentation OpenAI officielle contrôlée le 07/09, relecture corrective du 01/09 au 07/09 ; contrôles Responses du 03/09 qualifiés, aucune nouvelle dépréciation ou variation distincte de disponibilité/coût retenue.

```watchtower-couverture
coverage:
  - {domain: AWS, lane: releases_features, sources: [aws-whats-new, aws-agentcore-release-notes], scope: 'Annonces AWS générales; fallback AgentCore parcouru, sans inférer une disponibilité locale.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'signal retenu', complete: false, note: 'Flux général et fallback AWS What’s New non parcourus intégralement; AgentCore qualifié seulement.'}
  - {domain: AWS, lane: security, sources: [aws-security-bulletins], scope: 'Bulletins AWS, dont logiciels Kubernetes et MCP; exposition locale non inférée.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-04', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Relecture corrective complète depuis les bulletins du 04/09.'}
  - {domain: AWS, lane: lifecycle_deprecations, sources: [aws-eks-lifecycle, aws-agent-registry-docs], scope: 'Calendrier EKS et migration du namespace AWS Agent Registry.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-08-08', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Fenêtre de trente jours du nouveau flux Registry et calendrier EKS parcourus.'}
  - {domain: AWS, lane: availability_quotas_costs, sources: [aws-agentcore-release-notes, aws-bedrock-history], scope: 'Régions, PrivateLink, quotas et disponibilité publiés pour AgentCore et Bedrock; comptes locaux inconnus.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun delta additionnel dans ce périmètre ciblé.'}
  - {domain: GCP, lane: releases_features, sources: [gcp-release-notes, gemini-enterprise-release-notes], scope: 'Notes Google Cloud et Gemini Enterprise; disponibilité locale non inférée.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-07', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Relecture de l’édition du jour; Workflow Builder et SecOps qualifiés.'}
  - {domain: GCP, lane: security, sources: [gcp-security-bulletins], scope: 'Bulletins GCP publiés; produits et exposition locale inconnus.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-07', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Dernier bulletin observé: GCP-2026-060 du 04/09, déjà traité le 06/09.'}
  - {domain: GCP, lane: lifecycle_deprecations, sources: [gcp-deprecation-policy, vertex-ai-release-notes], scope: 'Politique générale et avis lifecycle Vertex AI; Preview exclue de la garantie générale.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Pages entièrement lisibles lors de la correction.'}
  - {domain: GCP, lane: availability_quotas_costs, sources: [gcp-release-notes, vertex-ai-release-notes], scope: 'Régions, quotas, coûts et disponibilité publiés dans Google Cloud et Vertex AI.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Aucun delta distinct dans l’intervalle.'}
  - {domain: IA, lane: releases_features, sources: [aws-agentcore-release-notes, gemini-enterprise-release-notes, openai-api-changelog], scope: 'Plans agents AWS/GCP et API OpenAI; fonctionnalités fournisseur, pas adoption.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-01', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Relecture corrective de sept jours; Registry, Gemini et Responses qualifiés.'}
  - {domain: IA, lane: security, sources: [aws-security-bulletins, gcp-security-bulletins], scope: 'Bulletins applicables aux serveurs MCP, SDK/outils IA et services GCP.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-04', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'PostgreSQL MCP retenu; autres expositions non supposées.'}
  - {domain: IA, lane: lifecycle_deprecations, sources: [openai-api-deprecations, vertex-ai-release-notes, aws-agent-registry-docs], scope: 'Arrêts OpenAI, Vertex AI et namespace AWS Agent Registry.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'signal retenu', complete: true, note: 'Échéance Registry retenue; aucune nouvelle dépréciation OpenAI ou Vertex.'}
  - {domain: IA, lane: availability_quotas_costs, sources: [openai-api-changelog, vertex-ai-release-notes, aws-bedrock-history], scope: 'Disponibilité, limites et coûts publiés pour API OpenAI, Vertex AI et Bedrock.', checked_at: '2026-09-07T21:15:00+02:00', from: '2026-09-06', through: '2026-09-07', result: 'aucun changement retenu', complete: true, note: 'Catalogues et notes accessibles; aucun delta distinct retenu.'}
```

Couverture incomplète : la voie AWS `releases_features` générale du 07/09 n’a pas pu être parcourue intégralement ; aucune absence de changement n’est affirmée hors des périmètres AWS ciblés ci-dessus.

## Sources en échec

- AWS What’s New général — page partiellement rendue et flux RSS non exploitable pour le 07/09 ; période manquante `2026-09-07`; conséquence : couverture AWS `releases_features` générale incomplète malgré le contrôle ciblé AgentCore.
