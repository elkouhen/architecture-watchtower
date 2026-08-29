# CARTE SERVICE — AGENT SANDBOX

**Régénération :** 28 août 2026, avec pitch rapide obligatoire pour le service.

**Perspective :** carte rédigée du point de vue d’un architecte DevOps/Cloud qui doit décider où placer le service, comment l’opérer et quand ne pas le retenir.

Date : 2026-08-28. Type : `outil Kubernetes / contrôleur`. Version observée : `v0.5.6` dans la release officielle. Version réellement déployée dans la stack de Mehdi : `à qualifier`.

## 1. RÉSUMÉ DÉCISIONNEL

**Pitch rapide :** Agent Sandbox fournit une ressource Kubernetes pour exécuter un agent dans un environnement persistant et identifiable, avec un cycle de vie géré par contrôleur. Il s’adresse aux équipes plateforme qui veulent isoler les sessions d’agents ou de code généré sans recomposer manuellement Pod, Service et stockage.

Agent Sandbox est un contrôleur Kubernetes pour des workloads singleton, persistants et isolés, adaptés aux runtimes d’agents et à l’exécution de code non fiable. Le potentiel est élevé pour la plateforme IA, mais le produit reste émergent. Décision proposée : `tester` localement, sans usage critique ni secrets. Principal compromis : simplicité de cycle de vie contre nouvelle CRD, surface d’isolation et dépendance à un projet jeune.

## 2. POSITION DANS LE SYSTÈME

Producteur : orchestrateur d’agent ou plateforme interne.  
Contrôleur : Agent Sandbox dans Kubernetes.  
Entrées : ressource `Sandbox`, image de runtime, ServiceAccount, PVC et politiques réseau.  
Sorties : Pod singleton avec identité réseau stable, état persistant et événements Kubernetes.  
Compléments : registry, secrets manager, OTel Collector/Elastic APM, NetworkPolicy, admission policy et stockage objet pour artefacts.

## 3. MODÈLE MENTAL

Un `Sandbox` décrit un pod durable possédant un nom et une identité stables. Le contrôleur réconcilie cette ressource, crée ou maintient le pod et permet de gérer un cycle de vie de session. Le pattern cible les environnements de développement, notebooks, agents exécutant du code et services singleton.

Chemin : demande de session → validation admission/RBAC → création du Sandbox → Pod + stockage → appels outils contrôlés → traces/événements → hibernation ou suppression.

Erreurs principales : image absente, PVC non provisionné, permissions excessives, réseau sortant non contrôlé, contrôleur indisponible, API CRD incompatible ou nettoyage incomplet.

## 4. ARCHITECTURE DE DÉPLOIEMENT

**Local reproductible :** Kind, namespace dédié, contrôleur et CRD depuis une release figée, une image de test non privilégiée, PVC local et NetworkPolicy restrictive. Les manifests officiels sont documentés ici : https://github.com/kubernetes-sigs/agent-sandbox#installation.

**Production réaliste :** EKS ou GKE avec version Kubernetes et CRD supportées, contrôleur installé via manifests/Helm selon la documentation publiée, namespace séparé, ServiceAccount minimal, Pod Security Admission, NetworkPolicy deny-by-default, quotas, registry privée, stockage chiffré et observabilité. Terraform doit gérer le cluster et les dépendances ; les manifests de l’application doivent rester versionnés séparément.

**Chemins de panne :** si le contrôleur tombe, ne pas supposer que les sessions sont recréées correctement ; si le PVC reste attaché, bloquer le nettoyage ; si le runtime est compromis, couper l’egress et révoquer l’identité ; si la CRD change, suspendre le rollout et revenir à la release précédente validée.

## 5. DONNÉES ET CYCLE DE VIE

Le service ne définit pas le modèle métier de l’agent. L’état peut résider dans un PVC ou dans un stockage externe. Décider explicitement : taille, classe, chiffrement, rétention, snapshots et suppression avec la session. Les artefacts de sortie doivent être exportés vers un stockage contrôlé, pas conservés indéfiniment dans le Sandbox.

## 6. EXPLOITATION ET DIMENSIONNEMENT

SLO proposé pour un laboratoire : création de session réussie ≥ 99 % et nettoyage terminé ≤ 2 minutes. Pour la production, les valeurs restent `à qualifier`.

| Charge | Ressource | Métrique | Décision |
|---|---|---|---|
| 1–10 sessions simultanées | CPU contrôleur 0,1–0,5 vCPU | reconcile latency, erreurs | augmenter replicas/CPU si p95 > 1 s |
| runtime agent | 0,5–2 vCPU et 512 MiB–2 GiB par session | CPU, RSS, OOMKill | limiter par quota et tester le pire outil |
| état session | PVC 1–10 GiB par session | remplissage, IOPS, erreurs | rotation/export avant 80 % |
| appels outils | réseau egress borné | octets, DNS, refus, latence | deny par défaut, allowlist explicite |

Alertes : contrôleur non prêt, erreurs de reconciliation, Sandbox bloqués, PVC saturés, OOMKill, egress refusé anormal, durée de session excessive et ressources orphelines. Upgrade : tester CRD et manifests dans Kind, sauvegarder les définitions, appliquer avec fenêtre de retour. Rollback : restaurer la release précédente et vérifier conversion/compatibilité des CRD ; ne jamais supprimer une CRD de production sans plan de migration.

## 7. SÉCURITÉ ET RESPONSABILITÉS

L’équipe doit fournir une image minimale, un ServiceAccount sans privilèges, des secrets injectés au dernier moment ou absents, un egress allowlisté, des quotas et une politique d’admission. Le fournisseur Cloud reste responsable du control plane managé ; l’équipe reste responsable du contrôleur, des images, du runtime, des données, des règles réseau et de l’audit. L’isolation fonctionnelle du CRD ne remplace pas une défense en profondeur (Pod Security, sandbox runtime, seccomp/AppArmor/gVisor selon besoin).

## 8. CHOIX ET LIMITES

Le gain principal est une abstraction Kubernetes pour les sessions singleton persistantes. Alternatives : StatefulSet + Service + PVC pour un besoin simple ; job isolé ou microVM pour une isolation plus forte ; service managé de sandbox si la charge opérationnelle Kubernetes est trop élevée. Comparaison détaillée à reporter tant que le cas d’usage et le niveau d’isolement requis sont inconnus.

## 9. QUAND L’UTILISER / L’ÉVITER

À utiliser pour des sessions longues, identifiables et persistantes, notamment des agents qui doivent conserver un workspace. À éviter pour un simple traitement stateless, un contrôle critique de production tant que l’API est émergente, ou un code hostile nécessitant une isolation matérielle non démontrée.

## 10. ÉVOLUTIONS DEPUIS LA DERNIÈRE CARTE

Première carte du service dans ce dépôt. Fait nouveau : documentation officielle et releases actives observées ; impact : le sujet franchit le seuil minimal pour un laboratoire, mais pas pour une adoption.

## 11. LABORATOIRE GUIDÉ — 45 À 60 MINUTES

**Owner :** plateforme Kubernetes. **Prérequis :** Docker, Kind, kubectl, accès réseau et une image alpine non privilégiée.

1. Créer un cluster Kind et un namespace de test.
2. Installer une release Agent Sandbox explicitement choisie depuis les manifests officiels.
3. Créer un `Sandbox` avec un PVC temporaire, un ServiceAccount dédié et une NetworkPolicy restrictive.
4. Écrire un fichier dans le workspace, redémarrer/reconcilier la session et vérifier la persistance.
5. Tenter une résolution DNS/connexion sortante non autorisée et vérifier le refus.
6. Supprimer le Sandbox, attendre la fin du contrôleur et vérifier Pods, PVC et événements orphelins.

**Observations :** temps de création, état du CRD, identité du Pod, persistance, refus réseau et temps de nettoyage.  
**Critère de réussite :** session créée, état conservé, egress non autorisé refusé et nettoyage complet en moins de deux minutes.  
**Nettoyage :** supprimer le namespace puis le cluster Kind. Ne pas utiliser cette procédure telle quelle en production.

## 12. INCERTITUDES ET SOURCES

Inconnus : version réellement disponible/supportée, runtime d’isolation, exposition de la stack, SLO, coût, topologie Kubernetes, stockage et propriétaire opérationnel. Sources primaires :

- dépôt : https://github.com/kubernetes-sigs/agent-sandbox
- releases : https://github.com/kubernetes-sigs/agent-sandbox/releases
- documentation : https://agent-sandbox.sigs.k8s.io/docs/
- installation : https://agent-sandbox.sigs.k8s.io/docs/getting_started/install_prerequisites/
- article Kubernetes : https://kubernetes.io/blog/2026/03/20/running-agents-on-kubernetes-with-agent-sandbox/
