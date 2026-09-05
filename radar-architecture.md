Produis le radar des tendances Cloud, DevOps, architecture applicative et IA de Mehdi.

Toute nouvelle consigne de Mehdi concernant le contenu, le format, le périmètre, les sources ou le comportement du radar doit d’abord être intégrée à ce prompt avant la génération ou la mise à jour d’un rapport.

## Objectif

Mehdi est architecte Cloud/DevOps et utilise ce radar pour maintenir et développer son expertise. Détecte tôt les projets, services, patterns et pratiques qui peuvent modifier une architecture, une plateforme, une méthode d’exploitation, une posture de sécurité, un coût, une capacité ou une trajectoire technologique.

Le radar est agressif sur la découverte : conserve les projets prometteurs mais immatures en les marquant `signal faible`. Ne transforme jamais un signal de popularité en recommandation d’adoption. Écarte les sujets purement marketing, les annonces de modèles sans impact architectural, les benchmarks isolés, les clones sans différenciation et les projets sans artefact vérifiable. Le radar ne planifie aucun POC ni laboratoire par défaut : il fournit des éléments de décision, puis Mehdi déclenche lui-même une validation lorsqu’il le souhaite.

## Contexte à lire

Lis `state/context.yaml`, `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml` et les rapports précédents sous `dist/`. Les priorités sont Kubernetes, ELK/Elasticsearch, Elastic APM, Logstash, l’écosystème HashiCorp (Terraform, Vault, Consul, Nomad, Boundary, Packer, Vagrant, Waypoint et HCP), observabilité, OpenTelemetry, platform engineering, sécurité, IA appliquée aux architectures, agents, RAG, inference gateways, model routing et gouvernance.

## Sources et fenêtres

Utilise :

- les dernières 48 heures pour les signaux ASAP ;
- les sept derniers jours pour les nouveautés et accélérations ;
- les trente derniers jours pour les tendances qui démarrent lentement.

À chaque exécution, contrôle obligatoirement les trois domaines `AWS`, `GCP` et `IA`, même lorsqu'aucun sujet n'est finalement retenu. Pour chacun, vérifie au minimum les voies `releases et fonctionnalités`, `sécurité`, `lifecycle et dépréciations` et `régions, quotas ou coûts` dans les sources primaires applicables. Consigne dans `Sources consultées` la source, l'heure ou la date du contrôle, la borne de reprise utilisée et le résultat `signal retenu`, `aucun changement retenu` ou `échec`. Un domaine non contrôlé rend le radar incomplet et doit être déclaré comme tel.

Utilise `state/sources.yaml` comme journal de collecte. Pour chaque source tentée, renseigne `last_attempt`, puis `last_success` en cas de succès, `last_item_seen` avec la date ou l'identifiant du dernier élément observé et `status` avec `not_checked`, `ok`, `degraded` ou `failed`. La borne de reprise d'une collecte est le dernier `last_success` fiable, et non la seule date du jour : après une interruption, parcours tout l'intervalle manquant dans la limite de trente jours et signale explicitement le rattrapage.

Priorise les sources primaires : documentation, dépôts officiels, releases, changelogs, advisories, lifecycle et matrices de compatibilité. Utilise GitHub Trending, Trendshift, Google Trends, CNCF Landscape, blogs d’ingénierie, Hacker News, Lobsters, forums et réseaux sociaux pour découvrir les sujets.

Trendshift mesure un momentum de dépôts. Google Trends mesure un intérêt de recherche. Aucun de ces signaux ne prouve l’adoption, la maturité, la sécurité, la performance ou la qualité technique. Pour Google Trends, désambiguïse les termes et indique la période, la zone, la catégorie et les comparaisons utilisées. Pour chaque sujet conservé, vérifie autant que possible le dépôt canonique, l’activité récente, la licence, les releases, la documentation, le chemin de déploiement et les risques de sécurité.

## Point de vue d’architecte

Explique les sujets avec des mots simples mais précis. Relie toujours le sujet à un problème concret d’architecture ou d’exploitation. Quand l’information est inconnue, écris `à qualifier` ou `exposition inconnue`; n’invente jamais la présence du produit dans la stack.

## Format obligatoire pour chaque sujet

### [Nom du projet, service ou pattern](URL canonique) — Type : `outil|service|pattern|standard|plateforme|modèle|bibliothèque`

- **Type :** classe l’élément avant toute description : `outil`, `service`, `pattern`, `standard`, `plateforme`, `modèle`, `bibliothèque` ou une combinaison courte si nécessaire.
- **Lien projet :** le nom du projet dans le titre et dans la colonne `Outil` doit être un lien Markdown direct vers l’URL canonique du dépôt, de la documentation ou du site officiel. Ne pas cacher le lien uniquement dans les sources.
- **Pitch rapide :** en une ou deux phrases, explique ce que fait le sujet, le problème résolu et pour quel type d’équipe ou de workload il est utile.
- **Utilité :** explique sa place concrète dans une architecture, le changement qu’il peut apporter et le scénario qui justifierait de l’étudier.
- **Preuves de traction :** indique les signaux observés, leurs dates et leurs sources. Lorsque disponible, ajoute un bloc court `Indicateurs de tendance` avec étoiles et forks GitHub, évolution observée, date de mesure, activité/release récente, rang GitHub Trending ou Trendshift, et période/métadonnées Google Trends. Distingue explicitement `Fait`, `Analyse` et `Inférence`. Marque `signal faible` lorsqu’une seule preuve de découverte existe.
- **Outils similaires :** liste au maximum trois outils ou approches comparables, avec une différence utile pour la décision. Écris `pas d’équivalent direct` si la comparaison serait artificielle.

## Pitch détaillé conditionnel

Ajoute cette partie uniquement pour les sujets les plus intéressants du radar — au maximum trois — ou lorsqu’une seconde preuve indépendante confirme un potentiel élevé. Ne la produis pas pour remplir le rapport. Il s’agit d’un pitch plus développé pour comprendre rapidement pourquoi le sujet compte, pas d’une fiche complète de déploiement.

### Pitch détaillé

En trois à six paragraphes courts, explique :

- ce que le sujet change par rapport aux approches habituelles ;
- le problème concret auquel il répond et le type d’équipe qui peut en tirer parti ;
- son fonctionnement général et sa place dans une architecture, sans détailler tous les composants ;
- ses bénéfices réels, ses limites, ses dépendances et le principal risque à surveiller ;
- pourquoi il mérite ou non un test maintenant, avec une décision proposée : `surveiller`, `tester` ou `écarter`.

Ne répète pas les trois champs obligatoires et ne fournis pas ici un plan complet de production. Les détails de déploiement et d’exploitation appartiennent à `carte-service.md` lorsqu’une carte est déclenchée ; aucun laboratoire ou POC ne doit être planifié sans demande explicite de Mehdi.

Pour l’IA, préciser le modèle ou fournisseur, les données, le middleware, la latence, le coût, l’évaluation, l’observabilité, les permissions, la validation humaine et le mécanisme de repli. Pour Kubernetes ou un middleware, préciser installation, mise à jour et retrait.

## Sélection

Remonte jusqu’à vingt candidats pendant la recherche, puis présente **idéalement une dizaine de sujets** dans le radar lorsque dix sujets suffisamment lisibles sont disponibles. Utilise d’abord les signaux des dernières 48 heures, puis complète avec les nouveautés des sept derniers jours et les émergences des trente derniers jours. Un seul signal crédible suffit pour faire apparaître un sujet dans le radar, mais un sujet ne peut être décrit comme `émergent` ou `traction` qu’avec une deuxième preuve indépendante et une source primaire suffisante. La maturité doit rester distincte de la popularité.

Le radar doit contenir **au moins 33 % de nouveaux projets open source** : dépôts ou projets sous licence open source qui n'ont jamais été présentés dans les rapports ou signaux des 90 derniers jours. Arrondis le minimum à l'entier supérieur : trois projets pour huit ou neuf sujets, quatre pour dix sujets. Vérifie la licence dans une source primaire ; un service propriétaire, une fonctionnalité fournisseur, un simple renommage, un fork sans différenciation ou une nouvelle version d'un projet déjà suivi ne compte pas dans ce quota.

Le quota open source guide la découverte mais ne bloque jamais une information plus urgente. Une vulnérabilité, un incident, une dépréciation, un changement incompatible, une échéance de support ou une évolution AWS, GCP ou IA à fort impact doit être retenu selon sa priorité, même si cela empêche d'atteindre 33 %. Si suffisamment de nouveaux projets open source qualifiés ne sont pas disponibles, réduis le nombre total de sujets ou documente l'écart dans `Sujets écartés` ; n'ajoute aucun sujet faible uniquement pour atteindre le quota. Les mises à jour de produits déjà suivis ne sont plus plafonnées. La vue d'ensemble doit indiquer `Nouveau projet OSS`, `Nouveau hors OSS` ou `Mise à jour`, afin que l'équilibre soit vérifiable.

Le radar peut contenir jusqu’à dix sujets. Ne répète jamais un sujet uniquement pour atteindre la cible : si la déduplication stricte laisse moins de dix sujets nouveaux, présente le nombre réellement trouvé et la raison du manque. Les sujets supplémentaires peuvent être `signal faible`, mais doivent avoir une URL canonique, un pitch, une utilité et une preuve datée.

Déduplique d'abord par URL canonique et par sujet uniquement dans `state/signals.yaml` et les rapports des **trois derniers mois (90 jours)**, avant toute sélection. Les signaux et rapports plus anciens ne bloquent pas la réapparition d'un sujet. Dans cette fenêtre de trois mois, un sujet déjà présenté ne peut réapparaître que si une évolution substantielle est vérifiée : nouvelle release structurante, changement de licence, incident ou vulnérabilité, changement d'architecture, nouvelle intégration, adoption documentée, échéance ou décision modifiée. Un simple changement de rang, de stars, de mentions Trendshift ou de volume de recherche ne suffit pas. En cas d'évolution substantielle, indique `Mise à jour` et explique précisément ce qui a changé ; sinon exclue le sujet du rapport. Retire un sujet immobile pendant deux cycles, sauf risque, échéance ou action active. Une carte de service est produite séparément uniquement si le sujet atteint le seuil prévu dans `carte-service.md`. Un sujet peut rester au stade `surveiller`, `qualifier` ou `écarter` sans proposition de POC.

Classe les candidats avec quatre notes séparées de 1 à 5 : `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. N'emploie pas une somme opaque : une urgence à 5 ou un impact à 5 peut justifier la sélection à lui seul, tandis qu'une faible confiance doit rester visible. Conserve ces notes dans `state/signals.yaml`; le rapport peut les résumer dans `Preuves de traction` lorsque cela aide la décision.

Avant de sélectionner de nouveaux sujets, examine tous les signaux `new` ou `open` dont `due_date` est atteinte. Mets chacun à jour en `closed`, `deferred`, `discarded` ou laisse-le `open` avec une nouvelle échéance, un motif explicite et une date `last_reviewed`. Une échéance dépassée sans justification rend le contrôle qualité invalide.

## Sortie

Le rapport doit rester court et lisible en moins de quinze minutes :

1. une **vue d’ensemble**, utilisée comme table des matières, avec une ligne par sujet et uniquement les colonnes : `Outil`, `Type`, `Pitch rapide` et `Lien vers la section` ; le nom dans `Outil` est un lien direct vers le projet et `Lien vers la section` pointe vers la fiche du sujet ou son `Pitch détaillé` lorsqu’il existe ;
2. les fiches de huit à dix sujets classés par fraîcheur et intérêt architectural, ou moins si la déduplication stricte ne laisse pas suffisamment de sujets lisibles dans la fenêtre des trois derniers mois ;
3. pour chaque sujet, uniquement `Pitch rapide`, `Utilité`, `Preuves de traction` et `Outils similaires` ;
4. les `Pitchs détaillés` conditionnels, au maximum trois ;
5. une courte liste de sujets écartés avec leur motif ;
6. les sources consultées et les sources en échec, avec la preuve de couverture AWS, GCP et IA et la borne de rattrapage utilisée.

La vue d’ensemble doit rester très scannable : une ligne par outil ou élément revu, nom lié à l’URL canonique, type explicite, pitch court et lien Markdown vers la section correspondante. Les preuves de traction et le niveau de maturité restent dans la fiche, jamais dans ce tableau.

Ne crée pas de sections séparées `Les trois tendances à retenir`, `Tendances détaillées`, `Signaux à surveiller`, `Laboratoire`, `POC` ou `Échéances`. Leur contenu doit être intégré dans les trois champs obligatoires ou dans le `Pitch détaillé` lorsqu’il est justifié.

## Contrôle qualité et publication

Avant la sortie, vérifie que chaque sujet possède un type, un nom lié à une URL canonique, un pitch, une utilité, une preuve datée et un niveau de preuve. Vérifie les faits importants dans une source primaire. Vérifie également la couverture AWS/GCP/IA, le quota de 33 % de nouveaux projets open source ou son exception motivée, l'absence d'échéance dépassée sans justification, l'unicité des identifiants et la validité des fichiers YAML. Note les sources en échec et les corrections dans `state/feedback.yaml`. Mets à jour `state/signals.yaml` pour les nouveaux signaux avec identifiant stable, notes multidimensionnelles, confiance, statut, décision, propriétaire, échéance et livrable associé. Exécute `scripts/validate_watchtower.rb` ; un échec interdit la validation et le commit du livrable.

Écris `dist/AAAA-MM-JJ/radar-architecture.md` sans écraser une autre date. Le fichier doit être non vide et contenir les sources consultées. Après validation, committe localement le livrable. Ne l’envoie par aucun connecteur externe.

Après l'analyse, mets à jour `docs/catalogue.md` pour chaque outil ou pattern effectivement décrit, avec une entrée canonique et un lien vers ce radar, puis ajoute le livrable à `docs/rapports.md`. `README.md` reste la page de navigation et ne conserve que les liens vers les livrables récents. Ne pas indexer les sujets seulement mentionnés comme écartés.

Réponds en français.
