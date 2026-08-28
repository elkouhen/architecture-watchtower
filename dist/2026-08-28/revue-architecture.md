# REVUE ARCHITECTURE — 28 AOÛT 2026

**Périmètre :** revue des décisions et prévisions du rapport du 27 août, plus les évolutions vérifiées depuis. Les rapports quotidiens et hebdomadaires restent séparés de cette revue.

## RÉPONSE DIRECTE

1. **Qualifier immédiatement** les versions Kubernetes, les add-ons et l’exposition APM Serverless Elastic ; aucune exposition réelle n’est prouvée dans le dépôt.
2. **Tester Agent Sandbox sur Kind** comme pattern d’exécution isolée d’agents, sans secret ni usage critique.
3. **Surveiller puis expérimenter** AI Gateway et OpenTelemetry GenAI ; leur direction est importante, mais leurs interfaces et intégrations restent mouvantes.

## RÉSULTATS ET PRÉVISIONS DU RAPPORT PRÉCÉDENT

| Prévision/action | Résultat observé | Écart et cause probable | Ajustement |
|---|---|---|---|
| Qualifier l’inventaire Kubernetes et ELK/APM | Non réalisé dans le dépôt ; versions et exposition restent inconnues | accès à la stack réelle absent | faire de l’inventaire la première étape obligatoire avant toute recommandation |
| Tester Kubernetes 1.37 | La release 1.37.0 est confirmée le 26 août, mais aucun test n’est enregistré | laboratoire non exécuté | conserver `tester`, échéance 15 septembre |
| Évaluer l’observabilité IA avec l’existant | OTel GenAI se structure ; compatibilité Elastic non vérifiée | absence de version/exporter réel | commencer par un test de schéma et de redaction, pas par une adoption |

## DÉCISIONS DU MOIS

### D1 — QUALIFIER l’exposition et les versions

- **Fait :** Kubernetes 1.37.0 est sorti le 26 août ; Elastic a documenté un incident APM Serverless résolu le 26 août. Sources : https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/ ; https://status.elastic.co/.
- **Analyse :** sans inventaire, une release ou un incident ne permet pas de conclure à un risque de production.
- **Décision :** `évaluer` l’exposition, pas mettre à jour à l’aveugle.
- **Owner :** plateforme Kubernetes et observabilité. **Échéance :** 1er septembre 2026.
- **Succès :** tableau cluster/add-on/provider/Elastic endpoint, version, environnement, propriétaire et action suivante.
- **Risque/repli :** si l’inventaire est impossible, conserver `exposition inconnue` et ne recommander qu’une qualification.

### D2 — TESTER Agent Sandbox

- **Fait :** le projet Kubernetes SIG Apps fournit un contrôleur et une CRD pour des workloads singleton persistants, avec installation et quickstart documentés : https://github.com/kubernetes-sigs/agent-sandbox ; https://agent-sandbox.sigs.k8s.io/docs/.
- **Analyse :** le pattern peut réduire la composition manuelle StatefulSet/Service/PVC pour les runtimes d’agents, mais l’isolation et la compatibilité restent à prouver.
- **Décision :** `tester` en Kind, aucune adoption de production.
- **Owner :** plateforme Kubernetes. **Échéance :** 12 septembre 2026. **Critère :** persistance, refus réseau, permissions minimales et nettoyage complet démontrés.
- **Risque/repli :** revenir à un StatefulSet contrôlé ou un runtime plus isolé si le CRD ou le niveau de sécurité ne convient pas.

### D3 — SURVEILLER les interfaces IA de plateforme

- **Fait :** Kubernetes anime un AI Gateway Working Group et OpenTelemetry maintient un dépôt dédié aux conventions GenAI. Sources : https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/ ; https://github.com/open-telemetry/semantic-conventions-genai.
- **Analyse :** ces travaux peuvent relier routage, politiques et observabilité, mais les APIs et attributs ne sont pas encore un socle universel.
- **Décision :** `surveiller`, avec une expérimentation limitée si une implémentation compatible avec la stack est identifiée.
- **Owner :** IA/observabilité. **Échéance de réexamen :** 30 septembre 2026. **Succès :** une implémentation, une matrice de compatibilité et un scénario de repli documentés.
- **Risque/repli :** conserver un proxy et un schéma de télémétrie internes versionnés.

## PLAN D’EXÉCUTION ET EXPÉRIMENTATIONS

1. **P0 — Inventaire :** récupérer versions Kubernetes, add-ons, Terraform providers et endpoints APM ; livrable : tableau d’exposition ; owner plateforme ; 1er septembre.
2. **P1 — Agent Sandbox :** exécuter le laboratoire local ; livrable : manifeste versionné, observations et décision ; owner plateforme ; 12 septembre.
3. **P2 — OTel/AI Gateway :** vérifier support des SDK/exporters et redaction ; livrable : matrice de compatibilité ; owner IA/observabilité ; 30 septembre.

## SUJETS ARRÊTÉS OU REPORTÉS

- Adoption de Kubernetes 1.37 reportée jusqu’à l’inventaire et un test paritaire.
- Adoption d’un AI Gateway reportée : standard et intégrations encore en développement.
- Production Agent Sandbox interdite pour le moment : isolation, version supportée et SLO non démontrés.

## ÉCHÉANCES DES 90 PROCHAINS JOURS

- **1er septembre :** inventaire d’exposition Kubernetes/APM.
- **12 septembre :** sortie du laboratoire Agent Sandbox.
- **15 septembre :** réexamen Kubernetes 1.37 et prochaine patch release ciblée.
- **30 septembre :** matrice OTel GenAI / Elastic APM / gateway.
- **28 novembre :** revue de la décision d’adoption ou de maintien en expérimentation.

## SOURCES ET INCERTITUDES

Sources primaires : Kubernetes release et AI Gateway WG, Agent Sandbox dépôt/documentation, OpenTelemetry semantic conventions, Elastic status. Incertitudes : versions réellement déployées, exposition, workloads critiques, coûts, SLO/RPO/RTO et owners opérationnels.
