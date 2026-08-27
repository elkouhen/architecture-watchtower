# RADAR ARCHITECTURE — 2026-08-27

Période : 21–27 août 2026. Contexte : AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform. Versions et exposition réelles à qualifier.

## SYNTHÈSE

1. **Kubernetes `1.37.0` est disponible** : préparer un test de compatibilité, mais ne pas planifier une mise en production avant validation EKS/GKE, CNI/CSI, operators et workloads.
2. **Elastic Stack `9.5.2` et Logstash `9.5.2` sont les versions de référence actuelles** : inventorier les versions et tester l’upgrade groupé Elasticsearch/Kibana/Logstash/APM.
3. **L’observabilité des agents IA devient un sujet d’outillage** : GitHub montre une activité sur ce thème, mais cela reste un signal de tendance ; tester d’abord traces, coûts, actions et erreurs dans un environnement contrôlé.

## 1. Kubernetes 1.37 — TESTER

**Changement :** Kubernetes `1.37.0` est sorti le 26 août 2026. La branche est activement supportée ; le prochain patch `1.37.1` est ciblé au 15 septembre. La release comprend 16 promotions en Stable et une dépréciation/removal. Source : https://kubernetes.io/releases/1.37/ et https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/

**Pourquoi cela compte :** une mise à niveau modifie la compatibilité du control plane, des kubelets, des APIs, des operators et des add-ons. La release déprécie notamment l’usage de cgroup v1, ce qui doit être vérifié côté nœuds.

**Pertinence :** possible ; versions des clusters AWS/GCP inconnues.

**Plan concret :** créer un environnement de test, appliquer les manifests Terraform/Kubernetes existants, tester CNI/CSI, ingress, HPA, operators, workloads stateful, observabilité et rollback.

**Test :** deux semaines ; succès si aucun manifest/API critique ne casse, les workloads passent leurs tests, les métriques CloudWatch/ELK restent disponibles et le temps de rollback est mesuré.

**Prévision :** dans les 1–3 mois, les distributions managées et les operators détermineront la faisabilité réelle. Si EKS/GKE et les add-ons critiques supportent `1.37`, préparer une migration canary ; sinon rester sur la version supportée actuelle.

**Owner :** plateforme Kubernetes, à désigner. Échéance de qualification : 15 septembre 2026.

## 2. Elastic Stack / Logstash 9.5.2 — ÉVALUER

**Changement :** Elastic documente la version `9.5.2` comme release actuelle. Les notes Logstash `9.5.2` incluent notamment des corrections de plugins et de dépendances.

**Pertinence :** confirmée comme sujet de stack, exposition et versions déployées inconnues.

**Plan concret :** inventorier Elasticsearch, Kibana, Logstash, APM Server et agents ; reproduire le pipeline d’ingestion sur données non sensibles ; tester parsing, mapping, enrichissement, indexation, dashboards, alertes, traces APM et retour arrière.

**Exploitation :** surveiller débit d’ingestion, rejets, latence, heap, files d’attente Logstash, shards non alloués, p95 de recherche et retard APM.

**Test :** un environnement isolé ; succès si aucune perte d’événement, aucune régression de requête critique, restore vérifié et rollback documenté.

**Prévision :** la prochaine décision dépendra moins des nouvelles fonctions que de la compatibilité de la chaîne complète ELK/APM. Si les plugins et mappings passent le test, planifier un upgrade par environnement ; sinon geler la version et ouvrir une qualification.

**Sources :** https://www.elastic.co/docs/release-notes et https://www.elastic.co/docs/release-notes/logstash

## 3. Observabilité des agents IA — ÉVALUER

**Signal :** le topic GitHub `agent-observability` regroupe des projets récents de traces, métriques, coûts et débogage d’agents. Source de découverte : https://github.com/topics/agent-observability

**Analyse :** le besoin opérationnel est réel, mais le classement GitHub ne prouve ni adoption ni maturité. Pour ta stack, le sujet doit être comparé à OpenTelemetry, CloudWatch, ELK et Elastic APM avant d’ajouter un middleware.

**Test :** instrumenter un agent non critique avec traces des appels modèle, outils, latence, tokens/coût, erreurs et décisions ; durée : une semaine.

**Succès :** une exécution est corrélable de bout en bout, les secrets et données sensibles sont filtrés, le coût est calculable et une erreur d’outil est visible dans CloudWatch ou ELK.

**Prévision :** les architectures qui survivront seront celles qui s’intègrent aux standards de télémétrie et aux contrôles IAM ; si un outil exige un format fermé ou un agent propriétaire, le conserver en expérimentation.

## LABORATOIRE PRIORITAIRE — KUBERNETES 1.37

Créer un cluster local avec `kind` ou `minikube`, déployer un Deployment, un StatefulSet et une métrique, puis vérifier APIs, probes, rollout, ressources et logs. Produire un tableau des incompatibilités et une décision `tester`, `attendre` ou `migrer`.

## ÉCHÉANCES

- 15 septembre 2026 : cible du patch Kubernetes `1.37.1` ;
- à qualifier : versions et support EKS/GKE réellement disponibles ;
- à qualifier : statut de support des composants Elastic 9.5.2 dans la stack.

## SOURCES

Sources primaires consultées : Kubernetes release et blog, Elastic release notes, Logstash release notes, Elastic status. Sources de tendance : GitHub Topics. Aucune source consultée en échec.
