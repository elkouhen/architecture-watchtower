# Radar architecture — 6 septembre 2026
<!-- watchtower:2 -->

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [GKE / Kubernetes 1.37 rootless](https://kubernetes.io/blog/2026/09/04/kubernetes-v1-37-rootless-beta/) | plateforme · Mise à jour | Le kubelet et les composants de nœud peuvent fonctionner dans un espace de noms utilisateur non-root. | [fiche](#gke--kubernetes-137-rootless) |
| [GCP-2026-060](https://cloud.google.com/support/bulletins) | service · Nouveau hors OSS | Bulletin High sur `sbcast` de Slurm pour Cluster Director. | [fiche](#gcp-2026-060--slurm-cluster-director) |
| [Vault 2.1](https://developer.hashicorp.com/vault/docs/updates/release-notes) | service · Mise à jour | Le support natif des workflows agentiques sort de beta en GA. | [fiche](#vault-21--support-natif-des-workflows-agents) |
| [Kata Containers 4.0](https://katacontainers.io/blog/kata-sandbox-demo-on-kubecon-jp-2026/) | plateforme · Nouveau projet OSS | runtime-rs et Dragonball forment un runtime de sandbox à processus unique. | [fiche](#kata-containers-40--runtime-rs-et-dragonball) |
| [Xolis](https://github.com/gnawux/xolis) | outil · Nouveau projet OSS | Démonstrateur de sandbox d’agents Kubernetes sur Kata 4.0 et PVM. | [fiche](#xolis--sandbox-dagents-kubernetes-kata-et-pvm) |

## [GKE / Kubernetes 1.37 rootless](https://kubernetes.io/blog/2026/09/04/kubernetes-v1-37-rootless-beta/)

- **Pitch rapide :** **Fait :** Kubernetes 1.37 fait passer `KubeletInUserNamespace` en beta ; les composants de nœud peuvent tourner sous un utilisateur non-root, sans convertir automatiquement les clusters existants. **Analyse :** c’est une nouvelle couche de réduction de privilèges pour les nœuds, distincte des user namespaces de pods.
- **Utilité :** La compatibilité CNI, CSI, sysctls et runtimes doit être qualifiée avant toute activation. Maturité : expérimental/beta ; traction étayée par la release Kubernetes et le guide de fonctionnement. Exposition : inconnue. **Décision :** surveiller comme mise à jour de la stratégie de durcissement, sans remplacer seccomp, les mises à jour de noyau ou les contrôles d’admission.
- **Outils similaires :** user namespaces de pods (isole le pod, pas le nœud), Kata Containers (isolation VM), gVisor (runtime applicatif).

## [GCP-2026-060 — Slurm Cluster Director](https://cloud.google.com/support/bulletins)

- **Pitch rapide :** **Fait :** le bulletin GCP-2026-060, publié le 04/09, décrit une vulnérabilité High dans `sbcast` de Slurm pouvant contourner des contrôles sur des bibliothèques partagées et faire tomber des nœuds Cluster Director. **Analyse :** le risque est spécifique aux environnements HPC qui emploient ce plan de contrôle, pas à GCP dans son ensemble.
- **Utilité :** Vérifier l’usage de Cluster Director, Slurm et des images concernées ; l’exposition réelle est inconnue. Maturité : correctif fournisseur documenté. **Décision :** qualifier l’inventaire avant toute action ; ne pas déduire une exposition depuis le seul bulletin.
- **Outils similaires :** Slurm auto-administré (responsabilité de patch distincte), GKE batch (plan de contrôle différent), AWS Parallel Computing Service (service distinct).

## [Vault 2.1 — support natif des workflows agents](https://developer.hashicorp.com/vault/docs/updates/release-notes)

- **Pitch rapide :** **Fait :** Vault 2.1, publié le 01/09, fait sortir de beta le support Enterprise de sécurisation des workflows agentiques. **Analyse :** le sujet est la gestion des identités, secrets et droits des outils d’agents, non le choix d’un modèle.
- **Utilité :** À qualifier face à l’édition Vault et aux flux d’identité réellement utilisés. Maturité : GA fournisseur, mais intégration stack inconnue. **Décision :** suivre comme mise à jour HashiCorp ; toute adoption doit conserver des permissions minimales, audit et révocation.
- **Outils similaires :** SPIFFE/SPIRE (identité workload), cloud IAM (identité fournisseur), Boundary (accès humain ou applicatif distinct).

## [Kata Containers 4.0 — runtime-rs et Dragonball](https://katacontainers.io/blog/kata-sandbox-demo-on-kubecon-jp-2026/)

- **Pitch rapide :** **Fait :** Kata 4.0 a publié le 21/07 l’intégration stable de runtime-rs et du VMM Dragonball ; le démonstrateur Xolis l’emploie avec Agent Sandbox. **Analyse :** la réduction des processus de runtime peut simplifier l’opération des micro-VM, sans supprimer les exigences de réseau, stockage et haute disponibilité.
- **Utilité :** Maturité : composant OSS documenté avec déploiements producteurs mentionnés, mais compatibilité Kubernetes/runtimes à qualifier par distribution. Exposition : inconnue. **Décision :** référence d’isolation à comparer à gVisor et Firecracker pour les workloads sensibles.
- **Outils similaires :** gVisor (isolation par sandbox), Firecracker (micro-VM), QEMU/Kata historique (architecture de runtime différente).

## [Xolis — sandbox d’agents Kubernetes, Kata et PVM](https://github.com/gnawux/xolis)

- **Pitch rapide :** **Fait :** Xolis est un démonstrateur OSS utilisant l’Agent Sandbox CRD, Kata runtime-rs et PVM sur EKS ; son auteur le décrit comme une référence à rendre plus production-ready. **Inférence :** il rend visible une composition possible pour isoler l’exécution d’agents sans dépendre d’un service propriétaire.
- **Utilité :** Utile pour étudier les frontières runtime, image pull et réseau d’un sandbox agentique. Maturité : signal faible ; le projet ne documente pas encore base de données, haute disponibilité, multi-AZ ou réseau complet. Exposition : inconnue. **Décision :** conserver comme référence d’architecture, sans recommandation de production.
- **Outils similaires :** Agent Sandbox (API Kubernetes), Kata Containers (runtime), Firecracker (micro-VM, intégration différente).

## Sujets écartés

- AWS : les voies release, sécurité, lifecycle et régions/quotas ont été contrôlées ; aucun changement additionnel suffisamment distinct des signaux des 90 derniers jours n’est retenu.
- La disponibilité AWS de Claude Fable 5.1 prolonge un sujet déjà présent sans évolution indépendante suffisante pour une nouvelle fiche.
- Les autres projets OSS découverts ne disposaient pas simultanément d’une licence, d’une preuve de maintenance et d’un chemin d’exploitation suffisamment qualifié.

## Sources consultées

- [Kubernetes rootless beta](https://kubernetes.io/blog/2026/09/04/kubernetes-v1-37-rootless-beta/) — publié le 04/09, consulté le 06/09 ; Kubernetes 1.37, compatibilité et limites de sécurité.
- [Bulletins GCP](https://cloud.google.com/support/bulletins) — publié le 04/09, consulté le 06/09 ; GCP-2026-060 et périmètre Cluster Director/Slurm.
- [Kata Containers : Xolis](https://katacontainers.io/blog/kata-sandbox-demo-on-kubecon-jp-2026/) et [dépôt Xolis](https://github.com/gnawux/xolis) — observés le 06/09 ; démonstrateur OSS et limites de production déclarées.
- [Vault 2.1](https://developer.hashicorp.com/vault/docs/updates/release-notes) — publié le 01/09, consulté le 06/09 ; GA des workflows agentiques.

```watchtower-couverture
coverage:
  - {domain: AWS, lane: releases_features, source: 'https://aws.amazon.com/new/', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Rattrapage complet.'}
  - {domain: AWS, lane: security, source: 'https://aws.amazon.com/security/security-bulletins/', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Bulletins contrôlés.'}
  - {domain: AWS, lane: lifecycle_deprecations, source: 'https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Lifecycle EKS contrôlé.'}
  - {domain: AWS, lane: availability_quotas_costs, source: 'https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Historique Bedrock contrôlé.'}
  - {domain: GCP, lane: releases_features, source: 'https://cloud.google.com/release-notes', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'signal retenu', complete: true, note: 'GKE rootless retenu.'}
  - {domain: GCP, lane: security, source: 'https://cloud.google.com/support/bulletins', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'signal retenu', complete: true, note: 'GCP-2026-060 retenu.'}
  - {domain: GCP, lane: lifecycle_deprecations, source: 'https://cloud.google.com/terms/deprecation', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Politique et notes vérifiées.'}
  - {domain: GCP, lane: availability_quotas_costs, source: 'https://cloud.google.com/vertex-ai/docs/core-release-notes', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Régions et capacités Vertex vérifiées.'}
  - {domain: IA, lane: releases_features, source: 'https://developers.openai.com/api/docs/changelog', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Changelogs OpenAI, Anthropic, Bedrock et Vertex contrôlés.'}
  - {domain: IA, lane: security, source: 'https://cloud.google.com/support/bulletins', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'signal retenu', complete: true, note: 'Bulletin GCP contrôlé ; exposition IA inconnue.'}
  - {domain: IA, lane: lifecycle_deprecations, source: 'https://developers.openai.com/api/docs/deprecations', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Dépréciations fournisseurs contrôlées.'}
  - {domain: IA, lane: availability_quotas_costs, source: 'https://platform.claude.com/docs/en/release-notes/overview', checked_at: '2026-09-06T10:00:00+02:00', from: '2026-09-05', through: '2026-09-06', result: 'aucun changement retenu', complete: true, note: 'Disponibilité et limites documentées contrôlées.'}
```

## Sources en échec

- Aucune source primaire bloquante. La disponibilité réelle dans les comptes AWS/GCP, les versions Kubernetes et l’exposition Slurm restent à qualifier.
