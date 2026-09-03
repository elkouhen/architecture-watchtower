# PRD — Architecture Watchtower

**Statut :** proposition initiale  
**Date :** 29 août 2026  
**Propriétaire :** Mehdi — architecture Cloud/DevOps

## 1. Résumé

Architecture Watchtower est un dispositif local de veille et d’apprentissage destiné à détecter les évolutions Cloud, DevOps, architecture, observabilité, sécurité, IA et écosystème HashiCorp, puis à les transformer en décisions vérifiables.

Le produit génère deux types de livrables :

- un radar quotidien `dist/YYYY-MM-DD/radar-architecture.md` ;
- une carte de service `dist/YYYY-MM-DD/carte-<service>.md` lorsqu’un sujet est suffisamment mature.

Les rapports, signaux, sources et décisions restent versionnés dans Git. Aucune publication externe n’est requise.

## 2. Problème à résoudre

La veille technique classique mélange actualité, popularité, maturité et recommandation. Elle produit soit trop de bruit, soit des synthèses difficiles à relier à une architecture réelle.

Le produit doit permettre de répondre rapidement à quatre questions :

1. Qu’est-ce qui a changé récemment ?
2. Pourquoi cela peut modifier une architecture ou son exploitation ?
3. Que sait-on réellement, et que reste-t-il à qualifier ?
4. Quelle décision ou action est justifiée maintenant ?

## 3. Objectifs

- Produire idéalement une dizaine d’informations pertinentes par jour.
- Dédupliquer uniquement avec les signaux et rapports des trois derniers mois.
- Prioriser les sources primaires et rendre chaque fait traçable.
- Séparer découverte, preuve, analyse, inférence et décision.
- Couvrir en priorité Kubernetes, ELK/Elastic APM/Logstash, OpenTelemetry, Cloud AWS/GCP, CI/CD, IA appliquée et tous les projets HashiCorp.
- Garantir à chaque radar une preuve de contrôle des domaines AWS, GCP et IA, y compris lorsqu’aucun sujet n’est retenu.
- Réserver au moins 33 % de la sélection aux nouveaux projets open source qualifiés, sans masquer les alertes ou évolutions prioritaires.
- Maintenir une compréhension exploitable : rôle dans le système, déploiement, exploitation, sécurité, limites et alternatives.
- Conserver un historique local permettant de suivre les décisions et changements de statut.

## 4. Hors périmètre

- Veille généraliste sans impact Cloud, DevOps ou architecture.
- Recommandation d’adoption fondée uniquement sur les stars, tendances ou annonces marketing.
- Exécution automatique en production.
- Envoi vers Slack, email ou autre connecteur externe.
- Régénération des anciennes sentinelles et revues qui ne disposent plus de prompt actif.

## 5. Utilisateur cible

### Mehdi, architecte Cloud/DevOps

Il utilise la veille pour maintenir son expertise, préparer des choix d’architecture et identifier des sujets à qualifier dans AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK, Terraform et l’écosystème HashiCorp.

Ses attentes :

- lecture en moins de quinze minutes ;
- faits datés et sources accessibles ;
- absence d’affirmation sur l’exposition réelle sans inventaire ;
- comparaison utile avec les alternatives ;
- prochaine action explicite et critère de réussite lorsqu’une qualification est proposée.

## 6. Fonctionnalités requises

### FR-01 — Radar quotidien

Le système doit produire un radar Markdown daté contenant idéalement 8 à 10 sujets, avec une vue d’ensemble puis une fiche par sujet.

Chaque fiche doit contenir :

- type et URL canonique ;
- pitch rapide ;
- utilité architecturale ;
- preuves datées, distinguant `Fait`, `Analyse` et `Inférence` ;
- outils ou approches similaires ;
- indicateurs de tendance optionnels et datés : étoiles/forks GitHub, activité de dépôt, dernière release, rang de découverte ou intérêt de recherche ;
- décision proposée, propriétaire et date de réexamen lorsque pertinent ;
- classification `Nouveau projet OSS`, `Nouveau hors OSS` ou `Mise à jour`.

Les indicateurs de tendance doivent rester séparés de la maturité, de la sécurité, de la qualité technique et de l’adoption. Une valeur d’étoiles ou de rang ne constitue jamais, seule, une preuve de recommandation.

Au moins 33 % des sujets retenus doivent être de nouveaux projets open source, avec arrondi à l’entier supérieur. Cette cible ne bloque jamais une vulnérabilité, un incident, une dépréciation, un changement incompatible ou une évolution AWS/GCP/IA à fort impact. Les mises à jour de produits connus ne sont pas plafonnées et une exception au quota doit être motivée.

### FR-02 — Carte de service

Le système doit pouvoir produire une carte détaillée lorsqu’un sujet combine potentiel architectural, documentation officielle, déploiement reproductible et maintenance démontrée.

La carte doit couvrir modèle mental, position dans le système, déploiement local et production, cycle de vie, exploitation, sécurité, alternatives, conditions d’usage et inconnues.

### FR-03 — Déduplication

La déduplication doit comparer le nouveau candidat uniquement à :

- `state/signals.yaml` sur les 90 derniers jours ;
- les rapports sous `dist/` des 90 derniers jours ;
- `state/learning.yaml` et les décisions locales associées.

Un sujet récent ne peut réapparaître que si une évolution substantielle est constatée : release structurante, vulnérabilité, incident, changement de licence, compatibilité, architecture, adoption documentée, échéance ou décision modifiée.

Les sujets antérieurs à cette fenêtre ne bloquent pas une nouvelle observation.

### FR-04 — Sources

Le registre `state/sources.yaml` doit distinguer :

- sources primaires de preuve ;
- sources de découverte ;
- sources d’évaluation ou de contexte.

Chaque source doit avoir un identifiant, une URL canonique, des thèmes, une cadence, un niveau de fiabilité, un fallback, `last_attempt`, `last_success`, `last_item_seen`, un statut de collecte et des règles d’usage. La collecte reprend au dernier succès fiable pour couvrir les interruptions dans la limite de trente jours.

Chaque radar doit contrôler AWS, GCP et IA sur quatre voies : releases/fonctionnalités, sécurité, lifecycle/dépréciations et disponibilité/régions/quotas/coûts. Le rapport conserve la preuve du contrôle ou signale explicitement une couverture incomplète.

### FR-05 — Registre des signaux

Chaque signal doit conserver au minimum :

`id`, `canonical_url`, `subject`, `product_version`, `environment`, `first_seen`, `last_seen`, `impact_architectural`, `urgence`, `pertinence_stack`, `confiance`, `status`, `decision`, `owner`, `due_date`, `deliverables`, `publication` et `discard_reason`.

Les statuts autorisés sont `new`, `open`, `closed`, `deferred` et `discarded`. Une alerte ne doit pas être interprétée comme une exposition réelle sans qualification.

Les quatre dimensions sont notées séparément de 1 à 5 et ne sont pas réduites à une somme opaque. Une évolution d’un signal existant conserve son identifiant et ajoute un historique. Toute échéance atteinte est réexaminée avant une nouvelle sélection ; son résultat est daté et motivé.

### FR-06 — Index transversal

`docs/catalogue.md` conserve une entrée canonique par outil, service, standard ou pattern effectivement analysé, avec type, résumé, niveau et liens vers les radars ou cartes. `docs/rapports.md` indexe les livrables par date et `README.md` reste la page de navigation.

### FR-07 — Contrôle qualité

Avant validation, le système doit vérifier :

- fichier non vide ;
- nombre de sujets conforme à la cible disponible ;
- URL canonique et type présents pour chaque sujet ;
- preuve datée et source primaire pour les faits importants ;
- dates cohérentes ;
- absence de liens vers des livrables supprimés ;
- YAML valide et identifiants uniques ;
- aucune URL canonique dupliquée sans justification explicite ;
- aucune échéance `new` ou `open` atteinte sans réexamen ;
- couverture AWS/GCP/IA complète et quota OSS conforme pour tout nouveau radar ;
- aucun ancien type de livrable généré.

Ces contrôles sont exécutés par `scripts/validate_watchtower.rb`. Un résultat non nul interdit la validation et le commit du livrable.

### FR-08 — Publication locale

La preuve de publication est un commit Git local contenant le livrable validé. Les fichiers non suivis ou changements non liés ne doivent jamais être inclus automatiquement.

## 7. Flux utilisateur cible

```text
Lire les prompts et l’état local
        ↓
Découvrir les candidats
        ↓
Vérifier les faits dans les sources primaires
        ↓
Dédupliquer sur 90 jours
        ↓
Sélectionner jusqu’à 10 sujets lisibles
        ↓
Rédiger le radar
        ↓
Mettre à jour signaux + catalogue + index des rapports + journal de sources
        ↓
Valider puis committer localement
```

## 8. Données et fichiers

| Fichier | Responsabilité |
|---|---|
| `radar-architecture.md` | Prompt du radar quotidien |
| `carte-service.md` | Prompt des cartes de service |
| `state/context.yaml` | Profil, clouds, plateformes et thèmes favoris |
| `state/sources.yaml` | Catalogue des sources et règles d’usage |
| `state/signals.yaml` | Registre canonique des signaux |
| `state/learning.yaml` | Progression et lacunes par produit |
| `state/feedback.yaml` | Corrections et retours qualité |
| `docs/catalogue.md` | Index thématique transversal |
| `docs/rapports.md` | Index chronologique des livrables |
| `README.md` | Navigation et liens récents |
| `dist/YYYY-MM-DD/` | Livrables datés |

## 9. Règles éditoriales

- Répondre en français.
- Éviter le marketing et les benchmarks non reproductibles.
- Employer `à qualifier` ou `exposition inconnue` lorsque le contexte réel manque.
- Ne pas confondre popularité, traction, maturité, sécurité et adoption.
- Les fonctions Preview, beta ou limitées ne doivent pas soutenir seules un contrôle critique de production.
- Pour HashiCorp, distinguer systématiquement Terraform, Vault, Consul, Nomad, Boundary, Packer, Vagrant, Waypoint, HCP et les modes self-managed/Enterprise.

## 10. Indicateurs de succès

- 8 à 10 sujets pertinents dans la majorité des radars lorsque la collecte le permet.
- 100 % des faits importants liés à une source primaire.
- 0 livrable historique régénéré.
- 0 référence cassée vers un fichier supprimé.
- 100 % des signaux retenus avec owner, décision et date de réexamen.
- 100 % des radars avec preuve de contrôle AWS, GCP et IA.
- Au moins 33 % de nouveaux projets open source dans les radars, sauf exception prioritaire motivée.
- Diminution progressive des signaux ouverts sans évolution.
- Au moins une décision d’architecture ou de suivi explicite pour les sujets à fort impact.

## 11. Risques et réponses

| Risque | Réponse |
|---|---|
| Trop de bruit provenant des tendances | Utiliser les tendances pour découvrir, puis confirmer dans le primaire. |
| Dette de signaux ouverts | Exiger une décision, une échéance et une clôture justifiée. |
| Fausse impression d’exposition | Conserver `environment: unknown` tant que l’inventaire n’est pas établi. |
| Dépendance à une source indisponible | Déclarer la source en échec et utiliser son fallback. |
| Dérive de format | Exécuter le validateur bloquant sur les noms de fichiers, sections, YAML, échéances et liens avant commit. |
| Surveille excessive de HashiCorp | Filtrer par impact architectural, sécurité, lifecycle, compatibilité ou exploitation. |

## 12. Critères d’acceptation du MVP

Le MVP est accepté lorsque :

1. un radar peut être généré dans `dist/YYYY-MM-DD/` sans toucher à une autre date ;
2. le radar contient idéalement dix sujets et leurs preuves ;
3. la comparaison historique est limitée aux 90 derniers jours ;
4. les signaux, le catalogue et l’index des rapports sont mis à jour sans doublons d’identifiants ;
5. les sources primaires, les échecs et les inconnues sont documentés ;
6. les contrôles qualité passent ;
7. le livrable est committé localement ;
8. aucun connecteur externe n’est utilisé.

## 13. Évolutions futures

- Ajouter une mesure de latence de détection par voie de couverture.
- Vérifier périodiquement les liens web et les versions obsolètes avec accès réseau.
- Ajouter un historique des changements de décision par signal.
- Produire des vues de portefeuille sans créer de nouveaux types de livrables permanents.
