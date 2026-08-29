# Carte quotidienne d’un service — consigne

## Objectif

Produis une carte d’apprentissage et de décision pour construire, déployer et exploiter un service Cloud, DevOps, observabilité, sécurité ou IA. Lis `state/context.yaml` pour relier le service à AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform lorsque c’est pertinent.

La carte contribue au maintien de l’expertise de Mehdi, architecte Cloud/DevOps. Elle doit donc rendre explicite ce que le service change dans une architecture moderne, dans quels scénarios il devient pertinent et quel niveau de compétence opérationnelle il permet d’acquérir. Privilégie les explications qui aident à décider et à agir plutôt qu’une description encyclopédique.

POINT DE VUE D’ARCHITECTE DEVOPS/CLOUD
Enseigne le service comme un architecte qui doit décider de l’introduire dans un système réel : à quoi sert-il, où se place-t-il, quels flux et dépendances il crée, comment le déployer, l’exploiter, le mettre à jour et le retirer, et quand il vaut mieux choisir une autre solution. Sépare toujours le modèle documenté du produit de ce qui est effectivement observé dans la stack.

La carte est produite en priorité pour un sujet retenu par le radar qui combine un potentiel futur élevé et une maturité démontrée : documentation officielle, déploiement reproductible et maintenance active. Elle n’est pas générée automatiquement pour chaque signal émergent ; les sujets qui n’atteignent pas ce seuil restent dans `Signaux à surveiller`.

La carte n’est ni une brochure marketing ni une recommandation automatique. Distingue `Fait`, `Analyse`, `Inférence` et `Décision proposée`. Si le contexte réel est inconnu, écris `à qualifier` ou `exposition inconnue`.

CONTRÔLE QUALITÉ
Avant la sortie, vérifie que le pitch explique clairement le service, que le déploiement local et le déploiement de production sont distingués, et que l’exploitation, la sécurité, les limites et le laboratoire sont cohérents avec les sources primaires. Note les lacunes ou corrections dans `state/feedback.yaml`.

## Entrées et déduplication

1. Lire cette consigne et `state/context.yaml`.
2. Consulter `state/signals.yaml`.
3. Rechercher les cartes et rapports locaux des 30 derniers jours.
4. Ne signaler une évolution que si la version, le statut, la sécurité, le coût, la compatibilité, le support ou la recommandation a changé ; sinon produire un heartbeat sans inventer de nouveauté.
5. Prioriser documentation, release notes, avis de sécurité, lifecycle, dépôts et matrices de compatibilité officielles.

## Format obligatoire

1. **Pitch rapide** : en une ou deux phrases, explique ce que fait le service, quel problème il résout, pour quel type d’équipe ou de workload il est utile, et pourquoi il mérite d’être étudié. Utilise des mots simples et évite le marketing.
2. **Résumé décisionnel** : rôle du service dans une architecture, problème résolu, cas d’usage, conditions de mise en œuvre, décision actuelle et principal compromis, en cinq lignes maximum.
3. **Position dans le système** : producteurs, consommateurs, entrées, traitements, sorties, flux et services complémentaires ou remplacés.
4. **Modèle mental** : chemin d’utilisation concret, composants indispensables, état, interfaces et erreurs principales.
5. **Architecture de déploiement** : un déploiement local reproductible et un déploiement de production réaliste. Pour un service distribué, expliquer rôles, communications, partitionnement, réplication, placement multi-zone, sauvegarde et chemins de panne.
6. **Données et cycle de vie** : modèle, schéma, indexation, rétention, migration, sauvegarde/restauration et compatibilité, uniquement si applicable.
7. **Exploitation** : SLO, métriques, alertes, upgrade, rollback, maintenance, capacité et pannes. Pour un service dimensionnable, fournir un tableau `charge → ressource → métrique → décision` couvrant CPU, RAM/heap, stockage/IOPS et réseau ; donner des hypothèses chiffrées et une méthode de validation.
8. **Sécurité et responsabilités** : identité, rôles, secrets, chiffrement, réseau, audit, vulnérabilités et partage fournisseur/équipe.
9. **Choix et alternatives** : coût, charge opérationnelle, verrouillage, réversibilité et alternatives uniquement si elles sont réellement pertinentes. Écrire `pas d’équivalent direct` lorsque nécessaire.
10. **Quand l’utiliser / l’éviter** : critères de fit, anti-patterns et condition de sortie.
11. **Évolutions depuis la dernière carte** : maximum cinq, datées, sourcées et reliées à un impact ou à une action.
12. **Laboratoire guidé** : durée maximale de 60 minutes, prérequis, étapes/commandes, scénario, observation, nettoyage et critère de réussite mesurable.
13. **Incertitudes et sources** : inventaire manquant, hypothèses, conséquences, URL primaires consultées et sources en échec.

## Règles de conditionnalité

- N’exige les rôles de nœuds, shards, quorum, tiers hot/warm/cold/frozen, multi-zone et sizing détaillé que si le service est distribué ou stateful.
- N’exige les comparaisons AWS/GCP/open source que si plusieurs options sont réellement envisageables.
- Pour une Preview, beta ou disponibilité limitée, proposer un repli et interdire son usage comme contrôle critique de production.
- Tout test doit avoir un owner, une durée, des métriques et un critère de sortie.
- Pour l’IA, préciser le cas d’usage, le modèle ou fournisseur, les données, le middleware, l’évaluation, l’observabilité, la sécurité, le coût et le mécanisme de repli.
- Pour Elasticsearch ou un moteur comparable, traiter les shards, replicas, tiers, ILM/rollover et sizing uniquement si ces notions s’appliquent.
- Ne produis aucune section qui n’influence ni une décision, ni une action, ni un test, ni la qualification d’un risque.

## Sortie et publication

Écrire `dist/<date_du_jour>/carte-<service>.md`, sans écraser une autre date. Le fichier doit être non vide, contenir au moins trois sources primaires et distinguer clairement laboratoire et production. Après validation, committe localement le fichier. Ne pas envoyer la carte par email.

Après la production de la carte, mettre à jour `index.md` avec une entrée canonique pour le service, son thème principal, son niveau d’étude et un lien vers la carte. Si le service existe déjà dans l’index, compléter la ligne au lieu de créer un doublon.

Réponds en français, de manière concrète et lisible en moins de trente minutes hors laboratoire.
