# Radar architecture — 8 septembre 2026
<!-- watchtower:2 -->
> **Tokens utilisés :** `5440297` total — entrée `5419055` (dont cache `5201024`, hors cache `218031`), sortie `21242`, raisonnement `3565` — mesure runtime Codex. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

L’exposition réelle des produits et versions dans la stack reste `inconnue` faute d’inventaire confirmé.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [GKE 2026-R37](https://cloud.google.com/kubernetes-engine/docs/release-notes) | service · Mise à jour | GKE ouvre Kubernetes 1.37 au canal Rapid et déplace plusieurs cibles d’auto-upgrade. | [fiche](#gke-2026-r37) |
| [Cloud SQL for PostgreSQL](https://docs.cloud.google.com/sql/docs/postgres/upgrade-in-place) | service · Mise à jour | Les changements d’édition, machine, stockage et version deviennent réalisables en place. | [fiche](#cloud-sql-for-postgresql) |
| [Gemini Code Assist](https://docs.cloud.google.com/gemini/docs/codeassist/release-notes) | service · Mise à jour | Le canal d’achat par console se ferme aux nouveaux comptes de facturation sans abonnement actif. | [fiche](#gemini-code-assist) |
| [Firestore Security Rules simulator](https://docs.cloud.google.com/firestore/native/docs/security/get-started) | outil · Nouveau hors OSS | La console peut évaluer des règles brouillon et des jetons d’authentification avant déploiement. | [fiche](#firestore-security-rules-simulator) |
| [DeerFlow](https://github.com/bytedance/deer-flow) | plateforme · Nouveau projet OSS | Un harness MIT compose sous-agents, mémoire, outils, skills et sandboxes pour les tâches longues. | [fiche](#deerflow) |
| [Lightpanda](https://github.com/lightpanda-io/browser) | outil · Nouveau projet OSS | Un navigateur headless en Zig expose CDP et WebDriver BiDi pour l’automatisation et les agents. | [fiche](#lightpanda) |

## [GKE 2026-R37](https://cloud.google.com/kubernetes-engine/docs/release-notes)

- **Pitch rapide :** **Fait :** les notes GKE du 02/09 rendent Kubernetes `1.37.0-gke.2155000` et `1.37.0-gke.2941000` disponibles dans le canal Rapid, retirent trois builds Preview 1.37 et déplacent des cibles d’auto-upgrade selon les canaux. **Analyse :** la décision ne porte plus seulement sur les fonctions upstream 1.37, mais sur le moment où les canaux managés feront progresser control planes et nœuds.
- **Utilité :** Inventorier canal, version, exclusions de maintenance, APIs dépréciées et compatibilité des add-ons avant de laisser les nouvelles cibles agir ; la disponibilité reste progressive selon les zones. Maturité : déploiement fournisseur documenté ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** qualification avant le 15/09 par `plateforme Kubernetes`, succès = matrice clusters/canaux/cibles et fenêtres de maintenance documentée, sans déclencher de POC.

## [Cloud SQL for PostgreSQL](https://docs.cloud.google.com/sql/docs/postgres/upgrade-in-place)

- **Pitch rapide :** **Fait :** Google documente depuis le 04/09 les upgrades et downgrades en place de l’édition, du type de machine, du stockage et de la version pour Cloud SQL for PostgreSQL 12 ou ultérieur. **Analyse :** cela réduit les migrations par remplacement d’instance, mais concentre davantage de changements structurants dans une même opération managée.
- **Utilité :** Ce chemin peut simplifier une évolution PostgreSQL, sous réserve de qualifier combinaisons autorisées, indisponibilité, réversibilité, réplication, stockage Hyperdisk et localisation des journaux PITR ; aucune instance locale n’est confirmée. Maturité : GA fournisseur documentée ; niveau de découverte : signal faible. **Décision :** surveiller par `plateforme données`, réexamen le 22/09 après clarification des limites propres à l’édition.
- **Repères de comparaison :** réplication vers une nouvelle instance, Database Migration Service, restauration d’une sauvegarde vers une cible neuve.

## [Gemini Code Assist](https://docs.cloud.google.com/gemini/docs/codeassist/release-notes)

- **Pitch rapide :** **Fait :** au 04/09, les comptes de facturation sans abonnement Gemini Code Assist actif ne peuvent plus acheter une nouvelle souscription dans la console et doivent passer par le canal commercial ; les comptes déjà actifs ne changent pas. **Analyse :** l’architecture technique reste stable, mais l’accès, le délai d’approvisionnement et la stratégie d’outil développeur peuvent changer.
- **Utilité :** À intégrer aux décisions de standardisation IDE/CI et aux plans de repli, en distinguant Code Assist, Antigravity et les offres Gemini Enterprise ; prix, disponibilité contractuelle et résidence restent à qualifier. Maturité : changement commercial documenté ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** qualification avant le 22/09 par `plateforme engineering/achats`, succès = canal d’achat et continuité des abonnements existants confirmés.

## [Firestore Security Rules simulator](https://docs.cloud.google.com/firestore/native/docs/security/get-started)

- **Pitch rapide :** **Fait :** la console Firestore permet désormais de tester des règles de sécurité brouillon contre des requêtes simulées et d’évaluer les jetons d’authentification avant déploiement. **Analyse :** ce contrôle rapproche la validation des règles du cycle de changement, sans prouver leur exhaustivité ni remplacer des tests automatisés.
- **Utilité :** Utile pour réduire les erreurs de permissions sur Firestore Standard et Enterprise, à condition de conserver revue, tests négatifs, séparation des rôles et déploiement contrôlé. Maturité : GA documentée ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** surveiller par `sécurité applicative`, réexamen le 29/09 si Firestore entre dans l’inventaire.

## [DeerFlow](https://github.com/bytedance/deer-flow)

- **Pitch rapide :** **Fait :** DeerFlow 2.0 est un harness MIT qui orchestre sous-agents, mémoire, skills, outils, gateway de messagerie et sandboxes, avec configuration multi-fournisseurs et démarrage Docker Compose. **Analyse :** il matérialise un plan d’exécution agentique complet, mais sa largeur fonctionnelle accroît les surfaces de permissions, secrets et données à gouverner.
- **Utilité :** À lire comme référence d’architecture pour tâches longues : fournisseur de modèle, recherche web, accès shell/fichiers, persistance, réseau des sandboxes, limites de sous-agents, coût, évaluations, traces, validation humaine et repli doivent être bornés. Maturité : intégration documentée, exploitation indépendante à qualifier ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** surveiller jusqu’au 29/09 par `plateforme IA`, sans planifier de POC.
- **Repères de comparaison :** LangGraph, OpenHands, Agents SDK avec sandbox séparée.

## [Lightpanda](https://github.com/lightpanda-io/browser)

- **Pitch rapide :** **Fait :** Lightpanda est un navigateur headless AGPL-3.0 écrit en Zig, distribuable en binaire nightly ou image Docker `amd64`/`arm64`, et pilotable par CDP, Puppeteer ou WebDriver BiDi. **Analyse :** il peut réduire le poids du navigateur dans des workers d’automatisation, mais une compatibilité de protocole ne garantit ni parité Web ni isolation du code parcouru.
- **Utilité :** Pertinent pour des pools de navigation d’agents où démarrage, densité et sortie HTML/Markdown comptent ; compatibilité de sites, politiques robots, sandbox OS, réseau sortant, secrets, observabilité et licence réseau AGPL restent à qualifier. Maturité : nightlies et déploiement documentés, exploitation à qualifier ; niveau de découverte : signal faible ; exposition inconnue. **Décision :** surveiller jusqu’au 29/09 par `plateforme IA/sécurité`, sans reprendre les benchmarks du dépôt comme preuve de performance locale.
- **Repères de comparaison :** Chromium/Playwright, Firefox/WebDriver BiDi, Browserless.

## Sujets écartés

- AWS What’s New, bulletins de sécurité et historique Bedrock : les pages et leurs fallbacks n’ont pas livré un delta vérifiable du 07 au 08/09 ; aucune absence de changement AWS n’est donc affirmée.
- Context Mode : le dépôt est visible dans GitHub Trending et documente une approche MCP/SQLite de réduction de contexte, mais l’exécution de code arbitraire et la licence n’ont pas été suffisamment qualifiées pour passer le filtre de publication.
- HyperFrames : dépôt Apache-2.0 et chaîne HTML/FFmpeg vérifiables, mais l’usage vidéo reste périphérique aux priorités d’architecture Cloud/DevOps de ce cycle.

## Sources consultées

- **Contrôle — `gcp-release-notes` :** [notes Google Cloud](https://cloud.google.com/release-notes), contrôlées le 08/09 avec reprise au 07/09 et relecture des entrées du 02 au 06/09 ; `signal retenu` pour Cloud SQL, Gemini Code Assist, Firestore et GKE, aucune entrée datée du 07 ou 08/09.
- **Contrôle — `gke-release-notes` :** [notes GKE](https://cloud.google.com/kubernetes-engine/docs/release-notes), publiées le 02/09, effet progressif selon les zones, consultées le 08/09 ; `signal retenu` pour les canaux, cibles d’auto-upgrade, builds 1.37 et images COS de R37.
- **Contrôle — `gcp-security-bulletins` :** [bulletins GCP](https://cloud.google.com/support/bulletins), contrôlés le 08/09 depuis le 07/09 ; dernier bulletin observé `GCP-2026-060` du 04/09, déjà traité, `aucun changement retenu`.
- **Contrôle — `gcp-deprecation-policy` et `vertex-ai-release-notes` :** [politique de dépréciation](https://cloud.google.com/terms/deprecation) et [notes Vertex AI](https://docs.cloud.google.com/vertex-ai/docs/release-notes), contrôlées le 08/09 depuis le 07/09 ; Preview exclue de la politique générale et aucun nouveau delta lifecycle, région, quota ou coût retenu.
- **Contrôle — `openai-api-changelog` et `openai-api-deprecations` :** [changelog OpenAI](https://developers.openai.com/api/docs/changelog) et [dépréciations](https://developers.openai.com/api/docs/deprecations), contrôlés le 08/09 depuis le 07/09 ; dernier changement structurant déjà observé le 03/09 et dernière dépréciation le 26/08, `aucun changement retenu`.
- **Contrôle — `aws-eks-lifecycle` :** [cycle de vie EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html), contrôlé le 08/09 depuis le 07/09 ; `aucun changement retenu` dans ce périmètre ciblé.
- **Découverte — `github-trending` :** [GitHub Trending](https://github.com/trending), observé le 08/09 sans borne historique fiable ; DeerFlow et Lightpanda découverts, la popularité n’est utilisée ni comme preuve de maturité ni comme recommandation.
- **Qualification — `deer-flow-repository` :** [dépôt DeerFlow](https://github.com/bytedance/deer-flow), artefacts observés le 08/09, date d’annonce courante inconnue ; licence MIT, réécriture 2.0, composants, configuration, Docker Compose et limites à gouverner vérifiés.
- **Qualification — `lightpanda-browser-repository` :** [dépôt Lightpanda](https://github.com/lightpanda-io/browser), artefacts observés le 08/09, date de release stable inconnue ; licence AGPL-3.0, nightlies, image Docker, CDP et WebDriver BiDi vérifiés.

```watchtower-couverture
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins, aws-eks-lifecycle, aws-bedrock-history, gcp-release-notes, gcp-security-bulletins, gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes, openai-api-changelog, openai-api-deprecations]
discovery_sources: [github-trending]
qualification_sources: [deer-flow-repository, lightpanda-browser-repository]
coverage:
  - {domain: AWS, lane: releases_features, sources: [aws-whats-new], scope: 'Annonces AWS générales; disponibilité fournisseur, sans inférer une exposition locale.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-06', through: '2026-09-08', result: 'échec', complete: false, note: 'Page générale non exploitable et fallback documentaire inaccessible; période manquante 07–08/09.'}
  - {domain: AWS, lane: security, sources: [aws-security-bulletins], scope: 'Bulletins AWS; produit, version et exposition locale non inférés.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'échec', complete: false, note: 'Index rendu sans liste récente et fallback trop général; période manquante 07–08/09.'}
  - {domain: AWS, lane: lifecycle_deprecations, sources: [aws-eks-lifecycle, aws-bedrock-history], scope: 'Calendrier EKS et historique Bedrock; périmètre ciblé seulement.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'échec', complete: false, note: 'EKS accessible sans delta retenu; historique Bedrock et fallback insuffisants pour clore toute la voie.'}
  - {domain: AWS, lane: availability_quotas_costs, sources: [aws-whats-new, aws-bedrock-history], scope: 'Disponibilité, régions, quotas et coûts publiés par AWS; comptes locaux inconnus.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'échec', complete: false, note: 'Sources générales et Bedrock incomplètes; aucune absence de changement affirmée.'}
  - {domain: GCP, lane: releases_features, sources: [gcp-release-notes, gke-release-notes], scope: 'Notes Google Cloud et GKE; disponibilité locale non inférée.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Flux courant parcouru; sujets retenus dans la fenêtre de sept jours.'}
  - {domain: GCP, lane: security, sources: [gcp-security-bulletins, gcp-release-notes], scope: 'Bulletins et entrées Security Google Cloud; exposition locale inconnue.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Aucun nouveau bulletin; simulateur Firestore retenu comme contrôle pré-déploiement, pas comme correctif.'}
  - {domain: GCP, lane: lifecycle_deprecations, sources: [gcp-deprecation-policy, gke-release-notes, vertex-ai-release-notes], scope: 'Politique générale et avis produit GKE/Vertex AI; Preview hors garantie générale.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Retraits de builds GKE R37 retenus; aucun autre delta.'}
  - {domain: GCP, lane: availability_quotas_costs, sources: [gcp-release-notes, vertex-ai-release-notes], scope: 'Régions, quotas, disponibilité et accès commercial GCP/IA.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Changement de canal d’achat Gemini Code Assist retenu.'}
  - {domain: IA, lane: releases_features, sources: [gcp-release-notes, vertex-ai-release-notes, openai-api-changelog], scope: 'Fonctionnalités IA GCP et API OpenAI; disponibilité fournisseur, pas adoption.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Gemini Code Assist et deux architectures OSS retenus; aucun delta OpenAI distinct.'}
  - {domain: IA, lane: security, sources: [gcp-security-bulletins, openai-api-changelog], scope: 'Bulletins GCP et contrôles API OpenAI applicables aux workloads IA.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'aucun changement retenu', complete: true, note: 'Aucune nouvelle alerte IA vérifiée dans l’intervalle.'}
  - {domain: IA, lane: lifecycle_deprecations, sources: [vertex-ai-release-notes, openai-api-deprecations], scope: 'Dépréciations Vertex AI et OpenAI API.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'aucun changement retenu', complete: true, note: 'Dernière dépréciation OpenAI observée le 26/08; aucun delta Vertex.'}
  - {domain: IA, lane: availability_quotas_costs, sources: [gcp-release-notes, vertex-ai-release-notes, openai-api-changelog], scope: 'Disponibilité, accès, quotas et coûts publiés pour Gemini, Vertex AI et OpenAI.', checked_at: '2026-09-08T08:18:00+02:00', from: '2026-09-07', through: '2026-09-08', result: 'signal retenu', complete: true, note: 'Canal d’achat Gemini Code Assist retenu; aucun delta OpenAI distinct.'}
```

Couverture incomplète : les quatre voies AWS ne sont pas closes pour la période du 07 au 08/09 ; les contrôles GCP et IA restent complets dans les périmètres explicités.

## Sources en échec

- `aws-whats-new` — page générale partiellement rendue et fallback `docs.aws.amazon.com/whats-new/` inaccessible ; période manquante `2026-09-07` à `2026-09-08` ; conséquence : voies AWS fonctionnalités et disponibilité incomplètes.
- `aws-security-bulletins` — index sans liste récente exploitable et fallback AWS Security non spécifique ; période manquante `2026-09-07` à `2026-09-08` ; conséquence : voie AWS sécurité incomplète.
- `aws-bedrock-history` — historique rendu sans delta 2026 exploitable et fallback Bedrock inaccessible ; période manquante `2026-09-07` à `2026-09-08` ; conséquence : voies AWS lifecycle et disponibilité partiellement couvertes seulement par EKS.
