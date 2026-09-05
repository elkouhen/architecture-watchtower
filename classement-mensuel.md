# Classement mensuel des technologies — consigne

Produis une fois par mois un classement rétrospectif des technologies, services, projets, standards et patterns effectivement observés pendant le mois écoulé dans les radars, cartes et signaux locaux.

Toute consigne utilisateur modifiant le classement doit être intégrée à ce prompt avant son application à un rapport. Lire également `docs/contrats-veille.md` et utiliser le contrat version 2.

## Objectif

Ce rapport ne remplace pas le radar quotidien et ne déclenche aucun POC, laboratoire ou recommandation d’adoption. Il aide l'utilisateur à prendre du recul : quelles technologies ont réellement compté ce mois-ci, lesquelles méritent une carte ou une qualification ultérieure, lesquelles sont restées de simples signaux de découverte.

Le classement principal est ordonné par intérêt pour les nouveautés et les changements architecturaux. Un simple correctif CVE, un bulletin sans changement de produit ou une maintenance déjà connue reste dans `Sujets non classés`, sauf rupture d’architecture ou décision de plateforme nouvelle. Le rapport fait ressortir les tendances transverses observées dans plusieurs technologies ou rapports.

## Entrées et période

1. Lire `state/context.yaml`, `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml`, les radars et les cartes du mois écoulé.
2. Définir explicitement la période calendaire couverte, du premier au dernier jour du mois précédent.
3. Dédupliquer par identifiant de technologie stable et URL canonique ; regrouper versions et fonctionnalités du même produit. Une extension n’a sa propre ligne que si elle a un cycle de vie ou un déploiement autonome documenté ; justifier l’exception. Un pattern transversal est synthétisé dans les tendances et ne double pas les produits classés, sauf s’il est lui-même le sujet d’une analyse distincte.
4. Inclure les éléments étudiés dans un radar, une carte ou un signal local pendant la période.
5. Ne pas ajouter une technologie uniquement pour atteindre un nombre de lignes.
6. Distinguer `nouveau`, `mise à jour`, `incident/sécurité`, `lifecycle`, `standard/pattern` et `signal faible`.
7. Marquer les simples correctifs CVE et actions de maintenance comme `hors classement principal`, avec leur motif ; ne les remonter que si le changement modifie réellement un contrat, une architecture, une surface d’exploitation ou une capacité de plateforme.
8. Reconstituer uniquement les faits connus pendant la période à partir des rapports datés, de l’historique des signaux et, si nécessaire, de Git. Un état actuel ou `last_seen` ne prouve pas l’état à la clôture. Si cet état est introuvable, marquer `inconnu`. Isoler les corrections découvertes après clôture dans `Sources et limites`, avec leur date ; elles ne modifient pas silencieusement le rang historique. Une source consultée après clôture peut confirmer un fait de la période, mais pas y introduire un événement ultérieur.
9. Distinguer découverte pendant le mois et annonce publiée pendant le mois. Inventorier les jours réellement couverts et les lacunes par thème, notamment AWS/GCP/IA ; absence de sujet retenu ne signifie pas absence d’actualité.
10. Décompter les preuves indépendantes selon `docs/contrats-veille.md`. La répétition d’une annonce dans un radar et une carte compte une seule fois. Un mouvement d’écosystème requiert plusieurs technologies et des événements distincts, pas plusieurs articles reprenant le même communiqué.

## Méthode de classement

Conserver les dimensions séparées dans les sources de décision, mais ne pas les afficher dans le tableau principal. Le classement principal privilégie la nouveauté et l’intérêt architectural :

- `nouveaute_interet` : 30 % ;
- `impact_architectural` : 25 % ;
- `pertinence_stack` : 20 % ;
- `confiance` : 15 % ;
- `maturite_exploitation` : 10 %.

`urgence` reste dans le registre de classement de `Période et méthode`, ainsi que dans `Sujets non classés` pour les risques exclus du rang ; elle ne contribue pas au score. Un correctif CVE sans nouveauté architecturale reçoit la classe `hors classement principal`, sans être présenté comme un risque résolu.

Les notes `impact_architectural`, `pertinence_stack`, `confiance` et `urgence` proviennent de l’état historique du registre ; si elles manquent, conserver `inconnu`. Ne pas convertir `legacy_score` ou `confidence` en notes normalisées. `nouveaute_interet` et `maturite_exploitation` sont des évaluations mensuelles justifiées par les preuves de la période, selon les repères communs ; faute de preuve, conserver `inconnu`. Les stocker dans le rapport, sans modifier les signaux.

Calculer le score sur 5 uniquement lorsque les cinq notes sont connues, avec les poids ci-dessus. Aucun remplacement par zéro, moyenne ou renormalisation des poids. Si tous les éléments classés ont un score, mode `pondéré` : score décroissant, puis impact décroissant, puis identifiant alphabétique. Sinon, mode `qualitatif` pour tout le classement : classe (`priorité nouveauté`, `à qualifier`, `veille`, `signal faible`, `à écarter`), puis impact connu décroissant (inconnu en dernier), puis identifiant alphabétique. Ne pas mélanger deux modes dans une édition. Justifier chaque classe ; publier les scores calculables à titre indicatif dans le registre de méthode. Le rang est ordinal, pas une mesure d’adoption ou de performance.

Le jugement d’architecte intervient dans les évaluations et leur justification, sans déplacement arbitraire après le tri. Classes : `priorité nouveauté` pour un changement structurant étayé ; `à qualifier` lorsqu’une inconnue conditionne la décision ; `veille` pour un intérêt documenté sans rupture ; `signal faible` pour une découverte encore peu étayée ; `à écarter` pour un manque de pertinence établi. Les simples CVE/maintenances restent hors classement et les risques critiques restent visibles dans `Sujets non classés` avec leur statut connu et un lien de suivi.

Tendance : `forte` exige au moins trois événements indépendants touchant au moins deux technologies ; `émergente` au moins deux événements indépendants ; `stable` une comparaison documentée avec la période précédente sans changement substantiel ; `faible` signifie preuve insuffisante pour les catégories précédentes. Consigner les événements et dates, sans assimiler quantité de mentions et force de tendance.

La popularité GitHub, Trendshift ou Google Trends ne peut jamais constituer seule un critère de classement élevé. Les faits importants doivent être confirmés par une source primaire.

## Format obligatoire

Le rapport doit contenir :

1. `## Période et méthode` : période, nombre d’éléments, couverture réelle, corpus local, formule et mode de classement. Inclure le registre YAML `watchtower-classement` défini dans `docs/contrats-veille.md`, avec les notes, preuves, classes et motifs nécessaires pour reproduire le tri ;
2. `## Classement complet` : toutes les nouveautés retenues, dans l’ordre, avec uniquement les colonnes `Rang`, `Technologie`, `Pitch rapide — pourquoi c’est intéressant`, `Tendance`, `Classe`, `Lien vers la preuve` ;
3. `## Tendances du mois` : zéro à sept tendances transverses étayées, leur portée architecturale et les limites de l’inférence ; signaler explicitement un corpus insuffisant plutôt que remplir un quota ;
4. `## Lecture architecturale` : les cinq premières nouveautés, ou toutes si moins de cinq, en expliquant le changement architectural ou opérationnel et la raison du rang ;
5. `## Par thème` : Cloud AWS, Cloud GCP, Kubernetes, observabilité/ELK, HashiCorp/IaC, sécurité, IA/agents et OSS/platform engineering, uniquement lorsque le thème contient au moins un élément ;
6. `## Mouvements du mois` : distinguer variation de rang, changement documenté, nouvel entrant et absence d’observation. Comparer uniquement les identifiants communs avec méthode identique ; sinon écrire `rangs non comparables` et expliquer. Une baisse due à de nouveaux entrants ne prouve pas un déclin ; une absence ne signifie ni retrait du produit ni abandon. Pour le premier mois, écrire `première édition` ;
7. `## Sujets non classés` : CVE simples, maintenance, sujets sans preuve suffisante, doublons ou simples mentions, avec motif ;
8. `## Sources et limites` : rapports locaux, registres, sources primaires importantes, lacunes, exposition réelle inconnue et éventuelles sources en échec.

La section `Lecture architecturale` ne doit pas devenir un plan d’action ou un laboratoire. Utiliser `à surveiller`, `à qualifier`, `carte pertinente` ou `à écarter` comme décisions descriptives ; ne pas attribuer de POC ou d’échéance sans demande explicite de l'utilisateur.

## Règles de qualité

- Le classement doit couvrir toutes les nouveautés retenues dans les rapports du mois, pas seulement un top 5 ; les sujets hors classement principal restent explicitement listés avec leur motif.
- Une technologie ne doit apparaître qu’une seule fois dans le classement complet.
- Chaque ligne possède un lien canonique ou un lien vers le rapport primaire qui la documente.
- Les scores manquants restent `inconnus` ; ils ne sont pas remplacés silencieusement par une moyenne.
- Les tendances sont séparées du classement et respectent les seuils de preuves ci-dessus.
- Le rapport ne réécrit pas l’historique des signaux et ne crée pas de nouveau signal uniquement pour le classement.
- Mettre à jour `docs/rapports.md`, la navigation récente de `README.md` et `docs/catalogue.md` uniquement pour les éléments analysés. Ne pas modifier les cartes ni attribuer un niveau d’apprentissage à partir de cette rétrospective.
- Le rapport doit rester lisible en moins de vingt minutes.

## Sortie et publication

Écrire le fichier dans `dist/AAAA-MM-DD/classement-mensuel-AAAA-MM.md`, sans écraser un autre livrable. Avant génération, rechercher ce mois dans tous les répertoires `dist/` : une seule édition par mois est autorisée. Si elle existe, fournir son lien ; une correction explicitement demandée modifie ce même fichier, avec historique Git et note de correction, sans créer de seconde édition. Par défaut couvrir le mois précédent ; un rattrapage explicitement demandé peut couvrir un mois antérieur clos. Exécuter `ruby scripts/validate_watchtower.rb --report <livrable>` après mise à jour des index et avant le commit local.

Réponds en français.
