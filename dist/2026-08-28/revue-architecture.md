# REVUE ARCHITECTURE — 28 AOÛT 2026

**Périmètre :** revue des décisions et prévisions du rapport du 27 août, plus les évolutions vérifiées depuis. Les rapports quotidiens et hebdomadaires restent séparés de cette revue.

**Mise à jour du 28 août, après exécution du radar agressif :** les nouveaux projets ont été détectés et enregistrés, mais aucune qualification de stack, aucun laboratoire et aucune décision d’adoption n’est documenté depuis la dernière revue. Les décisions ci-dessous restent donc inchangées ; leur statut opérationnel est `à faire`.

## RÉPONSE DIRECTE

1. **Qualifier immédiatement** les versions Kubernetes, les add-ons et l’exposition APM Serverless Elastic ; aucune exposition réelle n’est prouvée dans le dépôt.
2. **Tester Agent Sandbox v0.5.6 sur Kind** comme pattern d’exécution isolée d’agents, sans secret ni usage critique.
3. **Surveiller l’écosystème runtime et agents-as-code** — Hermes, Stately Agent, OpenAgentPack — ainsi que AI Gateway et OpenTelemetry GenAI ; les signaux accélèrent mais les garanties restent inégales.

## RÉSULTATS ET PRÉVISIONS DU RAPPORT PRÉCÉDENT

| Prévision/action | Résultat observé | Écart et cause probable | Ajustement |
|---|---|---|---|
| Qualifier l’inventaire Kubernetes et ELK/APM | Non réalisé dans le dépôt ; versions et exposition restent inconnues | accès à la stack réelle absent | faire de l’inventaire la première étape obligatoire avant toute recommandation |
| Tester Kubernetes 1.37 | La release 1.37.0 est confirmée le 26 août, mais aucun test n’est enregistré | laboratoire non exécuté | conserver `tester`, échéance 15 septembre |
| Évaluer l’observabilité IA avec l’existant | OTel GenAI se structure ; compatibilité Elastic non vérifiée | absence de version/exporter réel | commencer par un test de schéma et de redaction, pas par une adoption |
| Suivre les nouveaux runtimes et control planes agents | Hermes v0.20.6, Stately Agent alpha.21 et OpenAgentPack sont documentés dans le radar ; aucune comparaison n’est encore réalisée | maturité, sécurité et usage terrain inconnus | conserver en veille active et exiger une seconde preuve avant une carte ou un test |

## DÉCISIONS DU MOIS

### D1 — QUALIFIER l’exposition et les versions

- **Fait :** Kubernetes 1.37.0 est sorti le 26 août ; Elastic a documenté un incident APM Serverless résolu le 26 août. Sources : https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/ ; https://status.elastic.co/.
- **Analyse :** sans inventaire, une release ou un incident ne permet pas de conclure à un risque de production.
- **Décision :** `évaluer` l’exposition, pas mettre à jour à l’aveugle.
- **Owner :** plateforme Kubernetes et observabilité. **Échéance :** 1er septembre 2026.
- **Succès :** tableau cluster/add-on/provider/Elastic endpoint, version, environnement, propriétaire et action suivante.
- **Risque/repli :** si l’inventaire est impossible, conserver `exposition inconnue` et ne recommander qu’une qualification.

### D2 — TESTER Agent Sandbox v0.5.6

- **Fait :** la release v0.5.6 ajoute notamment le miroir des conditions de scheduling, des métriques suspend/resume, des outils filesystem MCP bornés et des ressources Prometheus opt-in : https://github.com/kubernetes-sigs/agent-sandbox/releases/tag/v0.5.6.
- **Analyse :** le pattern peut réduire la composition manuelle StatefulSet/Service/PVC pour les runtimes d’agents et devient plus opérable, mais l’isolation et la compatibilité restent à prouver.
- **Décision :** `tester` en Kind, aucune adoption de production.
- **Owner :** plateforme Kubernetes. **Échéance :** 12 septembre 2026. **Critère :** persistance, refus réseau, permissions minimales et nettoyage complet démontrés.
- **Risque/repli :** revenir à un StatefulSet contrôlé ou un runtime plus isolé si le CRD ou le niveau de sécurité ne convient pas.

### D3 — SURVEILLER les interfaces et runtimes IA de plateforme

- **Fait :** Kubernetes anime un AI Gateway Working Group ; OpenTelemetry maintient un dépôt dédié aux conventions GenAI ; Hermes v0.20.6 et Stately Agent alpha.21 ont publié des évolutions de runtime le 27 août ; OpenAgentPack documente un control plane beta agents-as-code. Sources : https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/ ; https://github.com/open-telemetry/semantic-conventions-genai ; https://github.com/NousResearch/hermes-agent/releases/tag/v2026.8.27 ; https://github.com/statelyai/agent/releases ; https://github.com/modelstudioai/OpenAgentPack.
- **Analyse :** routage, observation, durabilité et gouvernance déclarative convergent vers une couche de plateforme agents, mais les APIs et garanties ne sont pas encore un socle universel.
- **Décision :** `surveiller`, avec une expérimentation limitée si une implémentation compatible avec la stack est identifiée.
- **Owner :** IA/observabilité. **Échéance de réexamen :** 30 septembre 2026. **Succès :** une implémentation, une matrice de compatibilité et un scénario de repli documentés.
- **Risque/repli :** conserver un proxy et un schéma de télémétrie internes versionnés.

## PLAN D’EXÉCUTION ET EXPÉRIMENTATIONS

**État au 28 août :** P0, P1 et P2 sont `à faire`. Le radar a produit les pistes et les sources ; il ne constitue pas l’exécution des tests.

1. **P0 — Inventaire :** récupérer versions Kubernetes, add-ons, Terraform providers et endpoints APM ; livrable : tableau d’exposition ; owner plateforme ; 1er septembre.
2. **P1 — Agent Sandbox :** exécuter le laboratoire local en v0.5.6 ; livrable : manifeste versionné, observations et décision ; owner plateforme ; 12 septembre.
3. **P2 — Runtime agents :** comparer Hermes, Stately Agent et OpenAgentPack sur exécution, état, outils, secrets, rollback et observabilité ; livrable : matrice de compatibilité ; owner IA/observabilité ; 12 septembre.

## SUJETS ARRÊTÉS OU REPORTÉS

- Adoption de Kubernetes 1.37 reportée jusqu’à l’inventaire et un test paritaire.
- Adoption d’un AI Gateway ou d’un runtime agent reportée : standards, APIs et intégrations encore en développement.
- Production Agent Sandbox interdite pour le moment : isolation, version supportée et SLO non démontrés.

## ÉCHÉANCES DES 90 PROCHAINS JOURS

- **1er septembre :** inventaire d’exposition Kubernetes/APM.
- **12 septembre :** sortie du laboratoire Agent Sandbox.
- **15 septembre :** réexamen Kubernetes 1.37 et prochaine patch release ciblée.
- **12 septembre :** comparaison Hermes / Stately Agent / OpenAgentPack.
- **30 septembre :** matrice OTel GenAI / Elastic APM / gateway.
- **28 novembre :** revue de la décision d’adoption ou de maintien en expérimentation.

## SOURCES ET INCERTITUDES

Sources primaires : Kubernetes release et AI Gateway WG, Agent Sandbox v0.5.6, OpenTelemetry semantic conventions, Hermes Agent v0.20.6, Stately Agent alpha.21, OpenAgentPack et Elastic status. Incertitudes : versions réellement déployées, exposition, workloads critiques, coûts, SLO/RPO/RTO et owners opérationnels. Les releases AgentField et Go UTCP restent des signaux de découverte à confirmer par leurs dépôts primaires.
