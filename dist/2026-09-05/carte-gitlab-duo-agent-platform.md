# CARTE SERVICE — [GitLab Duo Agent Platform](https://docs.gitlab.com/user/duo_agent_platform/)

Date : 2026-09-05. Type : `plateforme CI/CD agentique`. Version de référence documentée : GitLab Duo Agent Platform GA depuis GitLab 18.8 ; GitLab 19.2 ajoute notamment Duo CLI GA et les custom flows GA. Version réellement utilisée dans la stack de l'utilisateur : `à qualifier`.

## 1. TYPE, LIEN ET PITCH RAPIDE

GitLab Duo Agent Platform est une plateforme d’agents intégrée au cycle de développement GitLab : issues, merge requests, code review, pipelines et outils MCP. Elle est intéressante pour une équipe qui possède déjà GitLab CI/CD car elle rapproche l’assistant agentique, l’exécution contrôlée par runner et les garde-fous de livraison, au lieu d’ajouter un agent externe à côté du pipeline.

## 2. RÉSUMÉ DÉCISIONNEL

**Fait :** la plateforme propose des flows spécialisés, des custom flows et des connexions MCP ; les flows exécutés dans CI/CD passent par un runner et le GitLab Duo CLI. **Analyse :** GitLab devient à la fois système de gestion du changement, moteur CI/CD et plan d’exécution d’agents. **Décision proposée :** `qualifier` l’édition, les droits, le runner et le modèle de données avant toute décision d’intégration. Principal compromis : cohérence native et traçabilité contre dépendance à GitLab Duo, aux crédits et à une exécution d’outils potentiellement puissante.

## 3. POSITION DANS LE SYSTÈME

```text
développeur / issue / merge request / événement pipeline
                         │
                         ▼
GitLab Duo Agent Platform ──► flow spécialisé ou custom flow
                         │
                         ▼
GitLab CI/CD runner ──► Duo CLI ──► dépôt, Git, tests, outils MCP
                         │                         │
                         └──────────────► commit / MR / commentaire / statut
```

Producteurs : développeurs, issues, merge requests, règles de projet et événements GitLab. Consommateurs : reviewers, responsables de plateforme, pipelines, registries et environnements de déploiement. Entrées : code, contexte du projet, instructions, variables autorisées et outils MCP. Sorties : modifications, commits, merge requests, commentaires, diagnostics et statuts CI.

Compléments : GitLab Runner, GitLab CI/CD, CI/CD Catalog, registry de composants, secrets manager, OIDC/identités cloud, observabilité de runners et politiques de merge. Le service peut remplacer une partie des bots de code, scripts de triage et assistants CI isolés ; il ne remplace pas automatiquement les contrôles déterministes du pipeline.

## 4. MODÈLE MENTAL

Un utilisateur ou un événement déclenche un flow. Le flow assemble un ou plusieurs agents, reçoit un contexte contrôlé et demande éventuellement l’usage d’outils. En exécution CI/CD, le runner télécharge le package `@gitlab/duo-cli`, ouvre une connexion WebSocket vers le service de workflow GitLab Duo, puis exécute les opérations demandées dans son environnement.

Chemin concret : issue ou pipeline en échec → flow de diagnostic → lecture du dépôt et des logs autorisés → proposition ou modification → tests CI déterministes → commit/MR → revue humaine et merge selon les règles du projet.

Les éléments d’état à distinguer sont le flow, sa configuration, le contexte injecté, les privilèges d’agent, les appels d’outils, les artefacts et le résultat Git. Erreurs principales : contexte incomplet, runner indisponible, outil MCP non autorisé, credentials absents, boucle d’agent, modification non testée, timeout du service ou sortie trop large.

## 5. ARCHITECTURE DE DÉPLOIEMENT

**Développement/local :** utiliser un projet GitLab de développement, un flow limité, un runner éphémère et un dépôt sans secrets de production. Les fichiers de personnalisation peuvent vivre dans `.gitlab/duo/`, avec `AGENTS.md` et une configuration de flow versionnée. L’environnement doit rester séparé des runners partagés et des réseaux sensibles.

**GitLab.com :** GitLab héberge la plateforme, mais l’équipe contrôle les projets, groupes, politiques, runners, variables, composants et connexions MCP autorisées. Vérifier le tier Premium/Ultimate, l’activation de GitLab Duo et les crédits avant d’exposer la fonctionnalité à une équipe.

**Self-Managed/Dedicated :** prévoir une version GitLab compatible, l’activation de l’Agent Platform, un AI Gateway si le mode choisi l’exige, la connectivité sortante vers la plateforme, des runners isolés et une politique explicite pour les modèles self-hosted ou cloud-connected.

Chemins de panne : service Duo indisponible → continuer les pipelines déterministes sans flow ; runner compromis → révoquer tokens, isoler l’exécuteur et analyser les artefacts ; MCP indisponible → supprimer l’outil du flow et conserver le chemin manuel ; modification agentique incorrecte → pipeline rouge, MR non fusionnable et retour au dernier commit connu.

## 6. DONNÉES ET CYCLE DE VIE

Les données utiles comprennent le code source, les instructions de projet, le contexte de l’issue/MR, les logs transmis au flow, les sorties d’outils, les commits, les artefacts et les traces d’audit. La rétention et la localisation exacte dépendent de l’offre GitLab, de GitLab Duo et des modèles utilisés ; elles sont `à qualifier` pour la stack réelle.

Versionner les configurations `.gitlab/duo/`, `AGENTS.md`, les flows et les composants CI/CD. Épingler les composants de pipeline par SHA ou version plutôt que `latest`. Prévoir une revue de compatibilité lors des upgrades GitLab, Duo CLI, runners et MCP.

## 7. EXPLOITATION

SLO à qualifier : disponibilité du pipeline déterministe, taux de réussite des flows, p95 de durée d’un flow, temps d’attente runner, taux de rollback de modifications agentiques et délai de revue humaine. Alertes : hausse des échecs par flow, appels MCP refusés, exécution sur runner non conforme, consommation de crédits, artefacts contenant des secrets et modifications générées sans test associé.

| Charge hypothétique | Ressource | Métrique | Décision |
|---|---|---|---|
| 1–10 flows simultanés | runners et concurrence GitLab | queue time, durée, saturation | augmenter la capacité ou limiter les flows coûteux |
| 10–100 jobs agentiques/jour | crédits, API et WebSocket | consommation, erreurs, p95 | fixer des quotas et une enveloppe par groupe |
| dépôt monorepo volumineux | CPU/RAM, clone et contexte | taille contexte, temps d’indexation, tokens | réduire le contexte et segmenter les flows |
| outils MCP externes | réseau et permissions | appels, refus, egress, erreurs | allowlist stricte et repli sans MCP |

Upgrade : vérifier les changements de tier, crédits, modèles, runners, API Flow et MCP ; conserver un chemin de pipeline non agentique. Rollback : désactiver le flow ou sa connexion MCP, revenir aux jobs CI déterministes et conserver les commits générés pour audit. Maintenance : propriétaires par flow, revue des instructions, rotation des tokens et revue des composants inclus.

## 8. SÉCURITÉ ET RESPONSABILITÉS

Le runner est une frontière d’exécution de code non fiable : GitLab rappelle qu’un job peut voler le code d’autres projets ou les secrets lorsqu’il utilise un runner self-managed non isolé. Préférer des runners éphémères, dédiés par niveau de confiance, non privilégiés lorsque possible, avec réseau segmenté, credentials courts et accès minimal.

Les flows headless peuvent approuver automatiquement les appels d’outils : ils ne doivent pas être considérés comme équivalents à une validation humaine. N’autoriser que les serveurs MCP de confiance, documenter chaque outil et séparer lecture, écriture et déploiement. Protéger variables, `CI_JOB_TOKEN`, artefacts, caches, logs et branches protégées.

Responsabilités GitLab : disponibilité de la plateforme, service Duo et composants hébergés selon l’offre. Responsabilités de l’équipe : configuration, prompts/instructions, flows, permissions, runners, images, secrets, MCP, règles de merge, données transmises et supervision des sorties.

## 9. CHOIX ET ALTERNATIVES

GitLab Duo Agent Platform est pertinent si GitLab CI/CD est déjà le système de référence et si l’on veut rattacher l’agent aux issues, merge requests, pipelines et permissions existants. La dépendance à GitLab Duo, au tier, aux crédits et aux modèles est le principal verrou potentiel.

Alternatives pertinentes : GitHub Actions avec Copilot/agents pour une organisation GitHub ; Jenkins avec agents et plugins pour une plateforme déjà centrée Jenkins ; runners CI classiques avec scripts déterministes et un service d’agent externe pour un contrôle plus explicite ; GitLab Duo Self-Hosted lorsque la contrainte de modèle ou de localisation l’exige. Aucune alternative n’offre exactement le même couplage natif GitLab–flow–runner–MR.

## 10. QUAND L’UTILISER / L’ÉVITER

À utiliser pour diagnostiquer des pipelines, préparer des merge requests, appliquer des transformations répétitives, assister la revue et orchestrer des tâches outillées avec une trace GitLab claire.

À éviter pour un déploiement production autonome sans approbation, un accès large aux secrets, un runner partagé entre projets de confiance différente, un flow dépendant d’un MCP non audité ou une tâche dont la sortie doit être strictement déterministe. La sortie se fait en désactivant les flows, en révoquant les outils et en conservant les pipelines CI/CD classiques.

## 11. ÉVOLUTIONS DEPUIS LA DERNIÈRE CARTE

Première carte de GitLab Duo Agent Platform dans ce dépôt ; il n’existe pas de carte précédente à comparer.

- **2026-07-16 — GitLab 19.2 :** Duo CLI et custom flows sont documentés comme disponibles, avec MCP, exécution headless et points de contrôle humains ; impact : le CI/CD devient une surface d’exécution agentique gouvernable.
- **Documentation actuelle :** Agent Platform couvre flows de développement, code review, correction de pipeline, conversion CI/CD, custom flows et clients MCP ; impact : le périmètre dépasse l’assistance au code.
- **Documentation actuelle :** l’exécution CI/CD passe par un runner et le Duo CLI ; impact : la sécurité du runner devient une condition de sécurité de l’agent.

## 12. INCERTITUDES ET SOURCES

Inconnus : édition GitLab réellement utilisée, GitLab.com ou Self-Managed, activation Duo, modèle et localisation des données, crédits, runners, flows actifs, outils MCP autorisés, politiques de merge et exposition dans la stack. L’exposition réelle est `à qualifier`.

Sources primaires consultées :

- [GitLab Duo Agent Platform](https://docs.gitlab.com/user/duo_agent_platform/)
- [Configuration de l’exécution des flows](https://docs.gitlab.com/user/duo_agent_platform/flows/execution/)
- [Utilisation du GitLab Duo CLI](https://docs.gitlab.com/user/gitlab_duo_cli/use/)
- [GitLab 19.2 release notes](https://docs.gitlab.com/releases/19/gitlab-19-2-released/)
- [Sécurité des runners self-managed](https://docs.gitlab.com/runner/security/)
- [CI/CD components et bonnes pratiques](https://docs.gitlab.com/ci/components/)
- [GitLab Runner autoscaling](https://docs.gitlab.com/runner/runner_autoscale/)

## Vue d’ensemble

GitLab Duo Agent Platform est une plateforme CI/CD agentique intégrée à GitLab, avec exécution par runners et accès outillé contrôlable.

## Sujets écartés

Aucun sujet connexe n’est écarté de cette carte ; les alternatives sont décrites uniquement lorsqu’elles influencent le choix d’architecture.

## Sources consultées

Les sources officielles GitLab listées ci-dessus couvrent le produit, les flows, le CLI, les runners, les composants CI/CD et la sécurité.

## Sources en échec

Aucune source primaire en échec. Le tier, les crédits, le modèle réellement utilisé et l’exposition de la stack restent à qualifier.
