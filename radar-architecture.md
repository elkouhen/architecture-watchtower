Produis le radar des tendances Cloud, DevOps, architecture applicative et IA de Mehdi.

## Objectif

Mehdi est architecte Cloud/DevOps et utilise ce radar pour maintenir et développer son expertise. Détecte tôt les projets, services, patterns et pratiques qui peuvent modifier une architecture, une plateforme, une méthode d’exploitation, une posture de sécurité, un coût, une capacité ou une trajectoire technologique.

Le radar est agressif sur la découverte : conserve les projets prometteurs mais immatures en les marquant `signal faible`. Ne transforme jamais un signal de popularité en recommandation d’adoption. Écarte les sujets purement marketing, les annonces de modèles sans impact architectural, les benchmarks isolés, les clones sans différenciation et les projets sans artefact vérifiable.

## Contexte à lire

Lis `state/context.yaml`, `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml` et les rapports précédents sous `dist/`. Les priorités sont Kubernetes, ELK/Elasticsearch, Elastic APM, Logstash, observabilité, OpenTelemetry, platform engineering, sécurité, IA appliquée aux architectures, agents, RAG, inference gateways, model routing et gouvernance.

## Sources et fenêtres

Utilise :

- les dernières 48 heures pour les signaux ASAP ;
- les sept derniers jours pour les nouveautés et accélérations ;
- les trente derniers jours pour les tendances qui démarrent lentement.

Priorise les sources primaires : documentation, dépôts officiels, releases, changelogs, advisories, lifecycle et matrices de compatibilité. Utilise GitHub Trending, Trendshift, Google Trends, CNCF Landscape, blogs d’ingénierie, Hacker News, Lobsters, forums et réseaux sociaux pour découvrir les sujets.

Trendshift mesure un momentum de dépôts. Google Trends mesure un intérêt de recherche. Aucun de ces signaux ne prouve l’adoption, la maturité, la sécurité, la performance ou la qualité technique. Pour Google Trends, désambiguïse les termes et indique la période, la zone, la catégorie et les comparaisons utilisées. Pour chaque sujet conservé, vérifie autant que possible le dépôt canonique, l’activité récente, la licence, les releases, la documentation, le chemin de déploiement et les risques de sécurité.

## Point de vue d’architecte

Explique les sujets avec des mots simples mais précis. Relie toujours le sujet à un problème concret d’architecture ou d’exploitation. Quand l’information est inconnue, écris `à qualifier` ou `exposition inconnue`; n’invente jamais la présence du produit dans la stack.

## Format obligatoire pour chaque sujet

### Nom du projet, service ou pattern

- **Pitch rapide :** en une ou deux phrases, explique ce que fait le sujet, le problème résolu et pour quel type d’équipe ou de workload il est utile.
- **Utilité :** explique sa place concrète dans une architecture, le changement qu’il peut apporter et le scénario qui justifierait de l’étudier.
- **Preuves de traction :** indique les signaux observés, leurs dates et leurs sources. Distingue explicitement `Fait`, `Analyse` et `Inférence`. Marque `signal faible` lorsqu’une seule preuve de découverte existe.

## Description précise conditionnelle

Ajoute cette partie uniquement pour les sujets les plus intéressants du radar — au maximum trois — ou lorsqu’une seconde preuve indépendante confirme un potentiel élevé. Ne la produis pas pour remplir le rapport.

### Description précise

Décris uniquement les éléments qui aideront Mehdi à décider s’il doit approfondir :

- problème d’architecture et pattern associé ;
- composants, flux, données, identité et dépendances ;
- mode de déploiement et d’intégration avec AWS, GCP, Kubernetes, Terraform, GitHub/GitLab, ELK ou CloudWatch lorsque pertinent ;
- exploitation : métriques, logs, traces, capacité, coût, upgrade, rollback et retrait ;
- sécurité, permissions, isolation, données sensibles et risques de verrouillage ;
- limites, conditions où il ne faut pas l’utiliser et alternatives utiles ;
- test ou laboratoire de moins d’une heure, avec métriques et critère de réussite ;
- **Décision proposée :** `surveiller`, `tester` ou `écarter` ;
- prochaine vérification et signaux qui confirmeraient ou invalideraient l’intérêt.

Pour l’IA, préciser le modèle ou fournisseur, les données, le middleware, la latence, le coût, l’évaluation, l’observabilité, les permissions, la validation humaine et le mécanisme de repli. Pour Kubernetes ou un middleware, préciser installation, mise à jour et retrait.

## Sélection

Remonte jusqu’à vingt candidats pendant la recherche, puis présente au maximum dix sujets dans le radar. Un seul signal crédible suffit pour faire apparaître un sujet dans le radar, mais un sujet ne peut être décrit comme `émergent` ou `traction` qu’avec une deuxième preuve indépendante et une source primaire suffisante. La maturité doit rester distincte de la popularité.

Déduplique avec les documents locaux. Ne répète pas un sujet sans évolution substantielle ; dans ce cas, indique `Mise à jour`. Retire un sujet immobile pendant deux cycles, sauf risque, échéance ou action active. Une carte de service est produite séparément uniquement si le sujet atteint le seuil prévu dans `carte-service.md`.

## Sortie

Le rapport doit rester court et lisible en moins de quinze minutes :

1. une liste de sujets classés par fraîcheur et intérêt architectural ;
2. pour chaque sujet, uniquement `Pitch rapide`, `Utilité` et `Preuves de traction` ;
3. les `Descriptions précises` conditionnelles, au maximum trois ;
4. une courte liste de sujets écartés avec leur motif ;
5. les sources consultées et les sources en échec.

Ne crée pas de sections séparées `Les trois tendances à retenir`, `Tendances détaillées`, `Signaux à surveiller`, `Laboratoire` ou `Échéances`. Leur contenu doit être intégré dans les trois champs obligatoires ou dans la `Description précise` lorsqu’elle est justifiée.

## Contrôle qualité et publication

Avant la sortie, vérifie que chaque sujet possède un pitch, une utilité, une preuve datée, une URL canonique et un niveau de preuve. Vérifie les faits importants dans une source primaire. Note les sources en échec et les corrections dans `state/feedback.yaml`. Mets à jour `state/signals.yaml` pour les nouveaux signaux avec identifiant stable, score, confiance, statut, décision, propriétaire, échéance et livrable associé.

Écris `dist/AAAA-MM-JJ/radar-architecture.md` sans écraser une autre date. Le fichier doit être non vide et contenir les sources consultées. Après validation, committe localement le livrable. Ne l’envoie par aucun connecteur externe.

Réponds en français.
