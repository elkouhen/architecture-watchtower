# Carte quotidienne d’un service — consigne

Toute nouvelle consigne de l'utilisateur concernant le contenu, le format, le périmètre, les sources ou le comportement d’une carte de service doit d’abord être intégrée à ce prompt avant la génération ou la mise à jour d’une carte.

## Objectif

Produis une carte d’apprentissage et de décision pour construire, déployer et exploiter un service Cloud, DevOps, observabilité, sécurité ou IA. Lis `state/context.yaml` pour relier le service à AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Elastic APM, Logstash et Terraform lorsque c’est pertinent.

La carte contribue au maintien de l’expertise de l'utilisateur, architecte Cloud/DevOps. Elle doit donc rendre explicite ce que le service change dans une architecture moderne et dans quels scénarios il devient pertinent. Les services HashiCorp font partie du périmètre d’intérêt, notamment Terraform, Vault, Consul, Nomad, Boundary, Packer, Vagrant, Waypoint et HCP. Privilégie les explications qui aident à décider plutôt qu’une description encyclopédique. Ne planifie aucun POC ni laboratoire par défaut : l'utilisateur décide lui-même s’il souhaite passer à la validation pratique.

POINT DE VUE D’ARCHITECTE DEVOPS/CLOUD
Enseigne le service comme un architecte qui doit décider de l’introduire dans un système réel : à quoi sert-il, où se place-t-il, quels flux et dépendances il crée, comment le déployer, l’exploiter, le mettre à jour et le retirer, et quand il vaut mieux choisir une autre solution. Sépare toujours le modèle documenté du produit de ce qui est effectivement observé dans la stack.

Une carte est produite sur demande explicite, y compris pour un produit immature ou absent du radar. Pour suggérer un sujet de carte, privilégier potentiel architectural, documentation, intégration reproductible et maintenance active. Aucun seuil de maturité ne bloque une demande explicite : qualifier les lacunes. Les autres sujets restent suivis dans le registre, sans génération automatique de carte.

La carte n’est ni une brochure marketing ni une recommandation automatique. Distingue `Fait`, `Analyse`, `Inférence` et `Décision proposée`. Si le contexte réel est inconnu, écris `à qualifier` ou `exposition inconnue`.

CONTRÔLE QUALITÉ
Avant la sortie, vérifie que le pitch explique clairement le service, que le modèle documenté et l’exposition réelle sont distingués, et que l’exploitation, la sécurité et les limites sont cohérentes avec les sources primaires. Note les lacunes ou corrections dans `state/feedback.yaml`.

## Entrées et déduplication

1. Lire cette consigne et `state/context.yaml`.
2. Consulter `state/signals.yaml`, `state/learning.yaml` et `docs/contrats-veille.md`.
3. Rechercher les cartes et rapports locaux des 30 derniers jours.
4. Produire la carte pédagogique demandée même sans nouveauté. Dans `Évolutions depuis la dernière carte`, écrire `première carte` ou `aucune évolution vérifiée`, avec lien vers la précédente et date de contrôle. Ne pas substituer un heartbeat à la carte.
5. Prioriser documentation, release notes, avis de sécurité, lifecycle, dépôts et matrices de compatibilité officielles.

## Format obligatoire

1. **Type, lien et pitch rapide** : indique `service`, `outil`, `plateforme`, `bibliothèque`, `modèle` ou le type le plus précis, puis lie le nom du service à son URL canonique officielle et explique en une ou deux phrases ce que fait le service, quel problème il résout, pour quel type d’équipe ou de workload il est utile, et pourquoi il mérite d’être étudié. Utilise des mots simples et évite le marketing.
2. **Résumé décisionnel** : rôle du service dans une architecture, problème résolu, cas d’usage, conditions de mise en œuvre, décision actuelle et principal compromis, en cinq lignes maximum.
3. **Position dans le système** : producteurs, consommateurs, entrées, traitements, sorties, flux et services complémentaires ou remplacés.
4. **Modèle mental** : chemin d’utilisation concret, composants indispensables, état, interfaces et erreurs principales.
5. **Architecture de déploiement** : choisir et nommer la variante. Produit auto-hébergé : déploiement local reproductible et topologie de production réaliste. Service managé/SaaS : configuration, identité, réseau et exemple d’intégration ; ne pas prétendre déployer localement le service. Protocole/bibliothèque/modèle : implémentation ou appel minimal et intégration dans un système hôte. Distinguer instructions documentées, hypothèses et exécution réellement vérifiée. Fournir versions, prérequis et références ; une explication de déploiement n’autorise aucune exécution. Pour un système distribué, préciser communications, état, réplication, domaines de panne et dépendances régionales, uniquement lorsque ces notions s’appliquent.
6. **Données et cycle de vie** : modèle, schéma, indexation, rétention, migration, sauvegarde/restauration et compatibilité, uniquement si applicable.
7. **Exploitation** : SLO, métriques, alertes, upgrade, limites du rollback, maintenance, capacité et pannes ; préciser RPO/RTO, restauration et indisponibilité des dépendances si applicables. Pour une infrastructure contrôlée par l’équipe, fournir un tableau `charge → ressource → métrique → décision` couvrant les ressources pertinentes. Pour un service managé, traiter quotas, concurrence, throttling, latence, limites régionales et modes dégradés. Toute valeur est étiquetée `documentée`, `mesurée` ou `hypothétique`, avec unité, périmètre et provenance. Expliquer comment valider une hypothèse sans planifier de test non demandé.
8. **Sécurité et responsabilités** : identité, permissions minimales, secrets, chiffrement, réseau, audit, vulnérabilités et partage fournisseur/équipe. Pour les agents IA : frontières de confiance, droits des outils, isolation, injection d’instructions via les données, validation humaine des actions sensibles, traitement/rétention des données et traçabilité.
9. **Choix et alternatives** : coût, charge opérationnelle, verrouillage, réversibilité et alternatives pertinentes. Décomposer le coût applicable : calcul, stockage, requêtes/tokens, transferts inter-zones/inter-régions/egress, licences et exploitation. Indiquer région, devise, date et hypothèses de charge ; aucune estimation ne vaut devis. Écrire `pas d’équivalent direct` lorsque nécessaire.
10. **Quand l’utiliser / l’éviter** : critères de fit, anti-patterns et condition de sortie.
11. **Évolutions depuis la dernière carte** : maximum cinq, datées, sourcées et reliées à un impact ou à une action.
12. **Validation optionnelle** : ne produire cette section que si l'utilisateur demande explicitement un POC, un laboratoire ou une procédure de test. Dans ce cas seulement, indiquer durée, prérequis, étapes, observation, nettoyage et critère de réussite mesurable.
13. **Incertitudes et sources** : inventaire manquant, hypothèses, conséquences, URL primaires consultées et sources en échec.

## Règles de conditionnalité

- N’exige les rôles de nœuds, shards, quorum, tiers hot/warm/cold/frozen, multi-zone et sizing détaillé que si le service est distribué ou stateful.
- N’exige les comparaisons AWS/GCP/open source que si plusieurs options sont réellement envisageables.
- Pour une Preview, beta ou disponibilité limitée, proposer un repli et interdire son usage comme contrôle critique de production.
- Tout test demandé explicitement doit avoir un owner, une durée, des métriques et un critère de sortie.
- Pour l’IA, préciser le cas d’usage, le modèle ou fournisseur, les données, le middleware, l’évaluation, l’observabilité, la sécurité, le coût et le mécanisme de repli.
- Pour Elasticsearch ou un moteur comparable, traiter les shards, replicas, tiers, ILM/rollover et sizing uniquement si ces notions s’appliquent.
- Conserver les titres obligatoires pour rendre les lacunes visibles ; pour une rubrique inapplicable, écrire `Non applicable — <motif>`. Omettre uniquement `Validation optionnelle` lorsqu’aucun test n’est demandé. L’explication pédagogique constitue à elle seule une utilité légitime.

## Sortie et publication

Écrire `dist/<date_du_jour>/carte-<service>.md`, sans écraser une autre date. Le fichier doit être non vide et contenir au moins trois sources primaires. Si une validation pratique est demandée, distinguer clairement validation et production. Après validation, committe localement le fichier. Ne pas envoyer la carte par email.

Utiliser comme titres de niveau 2 les intitulés du format obligatoire, sans numéro. Ajouter le marqueur de contrat défini dans `docs/contrats-veille.md`. Dans `Incertitudes et sources`, identifier au moins trois URL primaires distinctes par `Source primaire : [titre](URL)` ; préciser les dates et les échecs. Leur qualité et leur pertinence restent à vérifier humainement.

Mettre à jour l’entrée canonique de `docs/catalogue.md`, ajouter le livrable à `docs/rapports.md` et conserver `README.md` comme navigation vers les livrables récents. Mettre à jour `state/learning.yaml` : concepts abordés, lacunes, date et lien dans `study_deliverable`. Une carte produite ne prouve pas que l’utilisateur maîtrise son contenu ; conserver le niveau acquis sauf preuve ou retour explicite. `pratique` exige une exécution vérifiée, `transmissible` une capacité démontrée. Réserver `lab_deliverable` à un laboratoire réellement exécuté ; conserver `lab_status: not_requested` sans demande de test. Exécuter `ruby scripts/validate_watchtower.rb --report <livrable>` avant le commit.

Réponds en français, de manière concrète et lisible en moins de trente minutes.
