# Classement mensuel des technologies — consigne

Produis une fois par mois un classement rétrospectif des technologies, services, projets, standards et patterns effectivement observés pendant le mois écoulé dans les radars, cartes et signaux locaux.

## Objectif

Ce rapport ne remplace pas le radar quotidien et ne déclenche aucun POC, laboratoire ou recommandation d’adoption. Il aide Mehdi à prendre du recul : quelles technologies ont réellement compté ce mois-ci, lesquelles méritent une carte ou une qualification ultérieure, lesquelles sont restées de simples signaux de découverte.

Le classement principal est ordonné par intérêt pour les nouveautés et les changements architecturaux, pas par urgence opérationnelle. Un simple correctif CVE, un bulletin sans changement de produit ou une action de maintenance déjà connue ne doit pas remonter dans le classement principal ; il est résumé dans `Sujets non classés` ou `Sujets écartés`, sauf s’il introduit une rupture d’architecture ou une décision de plateforme nouvelle. Le rapport doit faire ressortir les tendances transverses observées dans plusieurs technologies ou rapports.

## Entrées et période

1. Lire `state/context.yaml`, `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml`, les radars et les cartes du mois écoulé.
2. Définir explicitement la période calendaire couverte, du premier au dernier jour du mois précédent.
3. Dédupliquer par URL canonique et par technologie ; regrouper les évolutions du même produit dans une seule ligne.
4. Inclure les éléments étudiés dans un radar, une carte ou un signal local pendant la période.
5. Ne pas ajouter une technologie uniquement pour atteindre un nombre de lignes.
6. Distinguer `nouveau`, `mise à jour`, `incident/sécurité`, `lifecycle`, `standard/pattern` et `signal faible`.
7. Marquer les simples correctifs CVE et actions de maintenance comme `hors classement principal`, avec leur motif ; ne les remonter que si le changement modifie réellement un contrat, une architecture, une surface d’exploitation ou une capacité de plateforme.
8. Repérer les tendances en recherchant au moins deux occurrences indépendantes ou deux technologies convergentes sur un même pattern : répétition dans les rapports, convergence de standards, évolution de plateformes, signaux de gouvernance ou mouvement d’écosystème. Une tendance ne peut pas reposer uniquement sur des étoiles ou un classement de popularité.

## Méthode de classement

Conserver les dimensions séparées et afficher leurs valeurs. Le classement principal privilégie la nouveauté et l’intérêt architectural :

- `nouveaute_interet` : 30 % ;
- `impact_architectural` : 25 % ;
- `pertinence_stack` : 20 % ;
- `confiance_evidence` : 15 % ;
- `maturite_exploitation` : 10 %.

`urgence` reste affichée comme information de contexte, mais ne contribue plus au rang principal. Un correctif CVE sans nouveauté architecturale reçoit donc la classe `hors classement principal`.

`nouveaute_interet`, `impact_architectural`, `pertinence_stack`, `confiance_evidence` et `urgence` viennent de `state/signals.yaml` lorsqu’elles existent ; si elles manquent, les laisser à `inconnu`. `maturite_exploitation` est évaluée à partir de la documentation, du chemin de déploiement, de la maintenance, de la sécurité et de la réversibilité ; si elle est inconnue, l’indiquer explicitement.

Le score pondéré sert à ordonner les nouveautés, mais ne remplace pas le jugement d’architecte. Afficher également une classe qualitative : `priorité nouveauté`, `à qualifier`, `veille`, `signal faible`, `hors classement principal` ou `à écarter`. Un sujet avec une urgence élevée mais une nouveauté faible reste hors du classement principal ; expliquer ce cas. Calculer et afficher un indicateur de tendance séparé (`forte`, `émergente`, `stable`, `faible`) avec les occurrences et les éléments convergents qui le justifient.

La popularité GitHub, Trendshift ou Google Trends ne peut jamais constituer seule un critère de classement élevé. Les faits importants doivent être confirmés par une source primaire.

## Format obligatoire

Le rapport doit contenir :

1. `## Période et méthode` : période, nombre d’éléments, sources locales utilisées et formule de classement ;
2. `## Classement complet` : toutes les nouveautés retenues, dans l’ordre, avec les colonnes `Rang`, `Technologie`, `Nature`, `Évolution du mois`, `Nouveauté`, `Impact`, `Pertinence stack`, `Confiance`, `Urgence`, `Maturité`, `Score`, `Tendance`, `Classe`, `Lien vers la preuve` ;
3. `## Tendances du mois` : trois à sept tendances transverses, leur preuve par occurrences ou technologies convergentes, leur portée architecturale et les limites de l’inférence ;
4. `## Lecture architecturale` : les cinq premières nouveautés, en expliquant le changement architectural ou opérationnel et la raison du rang ;
5. `## Par thème` : Cloud AWS, Cloud GCP, Kubernetes, observabilité/ELK, HashiCorp/IaC, sécurité, IA/agents et OSS/platform engineering, uniquement lorsque le thème contient au moins un élément ;
6. `## Mouvements du mois` : technologies montées, descendues, stabilisées ou retirées par rapport au classement mensuel précédent ; pour le premier mois, écrire `première édition` ;
7. `## Sujets non classés` : CVE simples, maintenance, sujets sans preuve suffisante, doublons ou simples mentions, avec motif ;
8. `## Sources et limites` : rapports locaux, registres, sources primaires importantes, lacunes, exposition réelle inconnue et éventuelles sources en échec.

La section `Lecture architecturale` ne doit pas devenir un plan d’action ou un laboratoire. Utiliser `à surveiller`, `à qualifier`, `carte pertinente` ou `à écarter` comme décisions descriptives ; ne pas attribuer de POC ou d’échéance sans demande explicite de Mehdi.

## Règles de qualité

- Le classement doit couvrir toutes les nouveautés retenues dans les rapports du mois, pas seulement un top 5 ; les sujets hors classement principal restent explicitement listés avec leur motif.
- Une technologie ne doit apparaître qu’une seule fois dans le classement complet.
- Chaque ligne possède un lien canonique ou un lien vers le rapport primaire qui la documente.
- Les scores manquants restent `inconnus` ; ils ne sont pas remplacés silencieusement par une moyenne.
- Les tendances sont séparées du classement : une tendance forte doit être étayée par au moins deux éléments convergents ou deux observations distinctes.
- Le rapport ne réécrit pas l’historique des signaux et ne crée pas de nouveau signal uniquement pour le classement.
- Les cartes, index et catalogue ne sont mis à jour que pour les éléments effectivement analysés dans le rapport.
- Le rapport doit rester lisible en moins de vingt minutes.

## Sortie et publication

Écrire le fichier dans `dist/AAAA-MM-DD/classement-mensuel-AAAA-MM.md`, sans écraser un autre livrable. Le rapport est exécuté une seule fois par mois, après la clôture de la période couverte. Ajouter le fichier à `docs/rapports.md`, puis exécuter le validateur local avant le commit.

Réponds en français.
