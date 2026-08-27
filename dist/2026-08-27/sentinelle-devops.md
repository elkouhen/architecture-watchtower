# ALERTE DEVOPS — 2026-08-27
Fenêtre : depuis l’alerte du 26 août 2026, 22:13 CEST.
Déduplication : `state/signals.yaml` et rapports locaux `dist/` sur 90 jours.

## RÉSULTAT : AUCUN SIGNAL PRIORITAIRE SUPPLÉMENTAIRE

Aucun changement confirmé depuis le dernier cycle n’atteint 6/10 après déduplication. La publication Grafana du 27 août est une build nightly explicitement destinée au développement ; elle ne justifie aucune action de production.
Source : https://grafana.com/grafana/download/13.3.0-33030554180?edition=oss&platform=linux

## SUIVI DES ACTIONS TOUJOURS OUVERTES (non comptées comme nouveautés)

## 1. GitLab self-managed : mettre à jour vers 19.3.1, 19.2.5 ou 19.1.7 selon la branche. Owner : plateforme/sécurité. Échéance : immédiate.
Source : https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-3-1-released/

## 2. GitHub Actions : inventorier et renouveler les runners auto-hébergés ; l’enforcement Enterprise Cloud est annoncé le 25 septembre 2026. Owner : CI/CD. Échéance : 48 h pour l’inventaire.
Source : https://github.blog/changelog/2026-06-12-github-actions-minimum-version-enforcement-timeline-for-self-hosted-runners/

## 3. Cloud Service Mesh in-cluster : vérifier version et patcher les versions touchées par GCP-2026-057. Owner : plateforme Kubernetes. Échéance : immédiate.
Source : https://docs.cloud.google.com/service-mesh/docs/security-bulletins

## 4. Grafana multi-tenant : appliquer les versions corrigées de CVE-2026-19197 et inventorier les snapshots publics. Owner : observabilité. Échéance : immédiate.
Source : https://grafana.com/security/security-advisories/cve-2026-19197/

## LIMITES
Les pages dynamiques non corroborées de GCP/AWS ne sont pas retenues comme faits. Publication : commit Git local.
