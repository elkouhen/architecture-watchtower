Produis le radar des tendances Cloud, DevOps, architecture applicative et IA de l'utilisateur.

Toute nouvelle consigne de l'utilisateur concernant le contenu, le format, le périmètre, les sources ou le comportement du radar doit d’abord être intégrée à ce prompt avant la génération ou la mise à jour d’un rapport.

## Objectif

l'utilisateur exerce comme architecte Cloud/DevOps et utilise ce radar pour maintenir et développer son expertise. Détecte tôt les projets, services, patterns et pratiques qui peuvent modifier une architecture, une plateforme, une méthode d’exploitation, une posture de sécurité, un coût, une capacité ou une trajectoire technologique.

Le radar est agressif sur la découverte : conserve les projets prometteurs mais immatures en les marquant `signal faible`. Ne transforme jamais un signal de popularité en recommandation d’adoption. Écarte les sujets purement marketing, les annonces de modèles sans impact architectural, les benchmarks isolés, les clones sans différenciation et les projets sans artefact vérifiable. Le radar ne planifie aucun POC ni laboratoire par défaut : il fournit des éléments de décision, puis l'utilisateur déclenche lui-même une validation lorsqu’il le souhaite.

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

Dans le rapport, utiliser un titre de niveau 2 : `## [Nom du projet, service ou pattern](URL canonique)`.

- La colonne **Type** utilise exactement `<nature> · <nouveauté>`, par exemple `outil · Nouveau projet OSS`. Nature : `outil`, `service`, `pattern`, `standard`, `plateforme`, `modèle` ou `bibliothèque`. Nouveauté : `Nouveau projet OSS`, `Nouveau hors OSS` ou `Mise à jour`. Ne pas ajouter un quatrième champ à la fiche.
- **Lien projet :** le nom du projet dans le titre et dans la colonne `Outil` doit être un lien Markdown direct vers l’URL canonique du dépôt, de la documentation ou du site officiel. Ne pas cacher le lien uniquement dans les sources.
- **Pitch rapide :** en une ou deux phrases, explique ce que fait le sujet, le problème résolu et pour quel type d’équipe ou de workload il est utile.
- **Utilité :** explique sa place concrète dans une architecture, le changement qu’il peut apporter et le scénario qui justifierait de l’étudier.
- Dans **Pitch rapide**, distinguer le `Fait` documenté de l’`Analyse` et de l’`Inférence`. Dans **Utilité**, intégrer la maturité (`à qualifier`, `expérimental`, `documenté`, `exploitation démontrée`), le niveau de découverte (`signal faible` ou `traction étayée`), l’exposition et, si utile, une `Décision` descriptive. Les références de preuve pointent vers `Sources consultées` ; aucune section supplémentaire de preuves n’est nécessaire.
- **Outils similaires :** liste au maximum trois outils ou approches comparables, avec une différence utile pour la décision. Écris `pas d’équivalent direct` si la comparaison serait artificielle.

## Pitch détaillé conditionnel

Ajoute cette partie uniquement pour les sujets les plus intéressants du radar — au maximum trois — ou lorsqu’une seconde preuve indépendante confirme un potentiel élevé. Ne la produis pas pour remplir le rapport. Il s’agit d’un pitch plus développé pour comprendre rapidement pourquoi le sujet compte, pas d’une fiche complète de déploiement.

### Pitch détaillé

En trois à six paragraphes courts, explique :

- ce que le sujet change par rapport aux approches habituelles ;
- le problème concret auquel il répond et le type d’équipe qui peut en tirer parti ;
- son fonctionnement général et sa place dans une architecture, sans détailler tous les composants ;
- ses bénéfices réels, ses limites, ses dépendances et le principal risque à surveiller ;
- pourquoi il mérite ou non une attention maintenant, sans appel à décision ni plan d'expérimentation.

Ne répète pas les trois champs obligatoires et ne fournis pas ici un plan complet de production. Les détails de déploiement et d’exploitation appartiennent à `carte-service.md` lorsqu’une carte est déclenchée ; aucun laboratoire ou POC ne doit être planifié sans demande explicite de l'utilisateur.

Pour l’IA, résumer les contraintes décisives de données, fournisseur, middleware, latence, coût, évaluation, observabilité, permissions, validation humaine et repli ; marquer les inconnues sans inventer de valeurs. Pour Kubernetes ou un middleware, résumer les implications d’installation, de mise à jour et de retrait. Les procédures détaillées appartiennent à la carte.

## Sélection

Explore normalement jusqu’à vingt candidats et présente idéalement une dizaine de sujets suffisamment qualifiés. Applique l’ordre de priorité ci-dessous ; à priorité comparable, privilégie les dernières 48 heures, puis sept jours et trente jours. Un seul signal crédible suffit pour une découverte ; `traction étayée` exige une deuxième preuve indépendante et une source primaire suffisante. La maturité reste distincte de la popularité.

Le radar doit contenir **au moins 33 % de nouveaux projets open source** : dépôts ou projets sous licence open source qui n'ont jamais été présentés dans les rapports ou signaux des 90 derniers jours. Arrondis le minimum à l'entier supérieur : trois projets pour huit ou neuf sujets, quatre pour dix sujets. Vérifie la licence dans une source primaire ; un service propriétaire, une fonctionnalité fournisseur, un simple renommage, un fork sans différenciation ou une nouvelle version d'un projet déjà suivi ne compte pas dans ce quota.

Le quota open source guide la découverte mais ne bloque jamais une information plus urgente. Une vulnérabilité, un incident, une dépréciation, un changement incompatible, une échéance de support ou une évolution AWS, GCP ou IA à fort impact doit être retenu selon sa priorité, même si cela empêche d'atteindre 33 %. Si suffisamment de nouveaux projets open source qualifiés ne sont pas disponibles, réduis le nombre total de sujets ou documente l'écart dans `Sujets écartés` ; n'ajoute aucun sujet faible uniquement pour atteindre le quota. Les mises à jour de produits déjà suivis ne sont plus plafonnées. La vue d'ensemble doit indiquer `Nouveau projet OSS`, `Nouveau hors OSS` ou `Mise à jour`, afin que l'équilibre soit vérifiable.

La cible est au plus dix sujets, sauf dépassement critique motivé. Ne répète jamais un sujet pour atteindre cette cible : si le corpus qualifié est insuffisant, présente le nombre réellement trouvé et la raison du manque. Tout `signal faible` possède une URL canonique, un pitch, une utilité et une preuve datée.

Déduplique par URL canonique et sujet dans les signaux, la progression, les décisions et les rapports locaux des 90 derniers jours. Les observations plus anciennes ne bloquent pas une réapparition. Dans cette fenêtre, un sujet ne réapparaît que pour une évolution substantielle vérifiée : release structurante, licence, sécurité, architecture, intégration, adoption documentée, échéance ou décision modifiée. Un changement de rang ou de popularité ne suffit pas. Indiquer `Mise à jour` et le changement précis ; sinon exclure. Retirer un sujet immobile pendant deux cycles, sauf risque, échéance ou action active. Une carte est produite séparément sur demande explicite selon `carte-service.md`. Un sujet peut rester `surveiller`, `qualifier` ou `écarter` sans POC.

Classe les candidats avec quatre notes séparées de 1 à 5 : `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. Utilise les repères de `docs/contrats-veille.md`. La pertinence mesure le rapport aux intérêts déclarés, pas une exposition supposée ; si les intérêts ne permettent pas de noter, utiliser `inconnu` avec justification. N’utilise pas de somme pondérée pour le radar. Conserve notes et justification dans `state/signals.yaml` ; les éléments utiles au lecteur restent dans `Utilité`.

Ordre de sélection et de présentation : risques et échéances critiques, changements architecturaux structurants, puis découverte. La fraîcheur départage des sujets de priorité comparable. Une note d’urgence ou d’impact à 5 justifie un examen prioritaire, pas une affirmation non vérifiée. Les limites de vingt candidats et dix sujets ne doivent jamais masquer une alerte critique : si nécessaire, les dépasser et écrire `Dépassement critique : <nombre et motif>` dans `Sujets écartés`. Pour une dérogation OSS, écrire `Exception quota OSS : <motif>` dans cette même section.

Avant de sélectionner de nouveaux sujets, examine tous les signaux `new` ou `open` dont `due_date` est atteinte. Mets chacun à jour en `closed`, `deferred`, `discarded` ou laisse-le `open` avec une nouvelle échéance, un motif explicite et une date `last_reviewed`. Une échéance dépassée sans justification rend le contrôle qualité invalide.

## Sortie

Le rapport doit rester court et lisible en moins de quinze minutes :

1. une **vue d’ensemble**, utilisée comme table des matières, avec une ligne par sujet et uniquement les colonnes : `Outil`, `Type`, `Pitch rapide` et `Lien vers la section` ; le nom dans `Outil` est un lien direct vers le projet et `Lien vers la section` pointe vers la fiche du sujet ou son `Pitch détaillé` lorsqu’il existe ;
2. les fiches classées selon l’ordre de priorité défini ci-dessus, idéalement huit à dix, moins si le corpus qualifié est insuffisant, davantage uniquement pour préserver les alertes critiques ;
3. pour chaque sujet, uniquement `Pitch rapide`, `Utilité` et `Outils similaires` ;
4. les `Pitchs détaillés` conditionnels, au maximum trois ;
5. une courte liste de sujets non retenus avec leur motif ;
6. les sources consultées et les sources en échec, avec la preuve de couverture AWS, GCP et IA et la borne de rattrapage utilisée.

La vue d’ensemble doit rester très scannable : une ligne par outil ou élément revu, nom lié à l’URL canonique, type explicite, pitch court et lien Markdown vers la section correspondante. Les preuves de traction et le niveau de maturité restent dans la fiche, jamais dans ce tableau.

Ne crée pas de sections séparées `Les trois tendances à retenir`, `Tendances détaillées`, `Signaux à surveiller`, `Laboratoire`, `POC` ou `Échéances`. Leur contenu doit être intégré dans les trois champs obligatoires ou dans le `Pitch détaillé` lorsqu’il est justifié.

## Contrôle qualité et publication

Appliquer également `docs/contrats-veille.md` : contrat de rapport version 2, preuves datées, indépendance des observations et journal de couverture archivé dans le rapport. Si le rattrapage dépasse trente jours, indiquer précisément la période non couverte ; une tentative ou une page partiellement lue ne vaut pas couverture complète. Ne pas avancer `last_success` au-delà de l’intervalle entièrement parcouru.

Les sections finales sont exactement `## Sujets écartés`, `## Sources consultées` et `## Sources en échec`. La première section est `## Vue d’ensemble`. Exécuter `ruby scripts/validate_watchtower.rb --report <livrable>` après mise à jour des index et avant le commit.

Avant la sortie, vérifie que chaque sujet possède un type, un nom lié à une URL canonique, un pitch et une utilité. Vérifie les faits importants dans une source primaire. Vérifie également la couverture AWS/GCP/IA, le quota de 33 % de nouveaux projets open source ou son exception motivée, l'absence d'échéance dépassée sans justification, l'unicité des identifiants et la validité des fichiers YAML. Note les sources en échec et les corrections dans `state/feedback.yaml`. Mets à jour `state/signals.yaml` pour les nouveaux signaux avec identifiant stable, notes multidimensionnelles, confiance, statut, décision, propriétaire, échéance et livrable associé. Exécute `scripts/validate_watchtower.rb` ; un échec interdit la validation et le commit du livrable.

Écris `dist/AAAA-MM-JJ/radar-architecture.md` sans écraser une autre date. Le fichier doit être non vide et contenir les sources consultées. Après validation, committe localement le livrable. Ne l’envoie par aucun connecteur externe.

Après l'analyse, mets à jour `docs/catalogue.md` pour chaque outil ou pattern effectivement décrit, avec une entrée canonique et un lien vers ce radar, puis ajoute le livrable à `docs/rapports.md`. `README.md` reste la page de navigation et ne conserve que les liens vers les livrables récents. Ne pas indexer les sujets seulement mentionnés comme écartés.

Réponds en français.
