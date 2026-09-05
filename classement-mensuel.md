# Classement mensuel des technologies — consigne

Produis une fois par mois un classement rétrospectif des technologies, services, projets, standards et patterns effectivement observés pendant le mois écoulé dans les radars, cartes et signaux locaux.

## Objectif

Ce rapport ne remplace pas le radar quotidien et ne déclenche aucun POC, laboratoire ou recommandation d’adoption. Il aide Mehdi à prendre du recul : quelles technologies ont réellement compté ce mois-ci, lesquelles méritent une carte ou une qualification ultérieure, lesquelles sont restées de simples signaux de découverte.

Le classement porte sur les éléments observés dans le mois, pas uniquement sur les nouveautés publiées dans le mois. Une mise à jour urgente, une vulnérabilité ou une dépréciation peut donc être mieux classée qu’un projet OSS populaire.

## Entrées et période

1. Lire `state/context.yaml`, `state/signals.yaml`, `state/learning.yaml`, `state/sources.yaml`, les radars et les cartes du mois écoulé.
2. Définir explicitement la période calendaire couverte, du premier au dernier jour du mois précédent.
3. Dédupliquer par URL canonique et par technologie ; regrouper les évolutions du même produit dans une seule ligne.
4. Inclure les éléments étudiés dans un radar, une carte ou un signal local pendant la période.
5. Ne pas ajouter une technologie uniquement pour atteindre un nombre de lignes.
6. Distinguer `nouveau`, `mise à jour`, `incident/sécurité`, `lifecycle`, `standard/pattern` et `signal faible`.

## Méthode de classement

Conserver les dimensions séparées et afficher leurs valeurs :

- `impact_architectural` : 30 % ;
- `pertinence_stack` : 25 % ;
- `confiance_evidence` : 20 % ;
- `urgence` : 15 % ;
- `maturite_exploitation` : 10 %.

Les quatre premières dimensions viennent de `state/signals.yaml` lorsqu’elles existent. `maturite_exploitation` est évaluée à partir de la documentation, du chemin de déploiement, de la maintenance, de la sécurité et de la réversibilité ; si elle est inconnue, l’indiquer explicitement.

Le score pondéré sert à ordonner les lignes, mais ne remplace pas le jugement d’architecte. Afficher également une classe qualitative : `priorité architecture`, `à qualifier`, `veille`, `signal faible` ou `à écarter`. Un sujet avec une urgence ou un impact de 5 peut remonter devant un score moyen ; expliquer ce cas.

La popularité GitHub, Trendshift ou Google Trends ne peut jamais constituer seule un critère de classement élevé. Les faits importants doivent être confirmés par une source primaire.

## Format obligatoire

Le rapport doit contenir :

1. `## Période et méthode` : période, nombre d’éléments, sources locales utilisées et formule de classement ;
2. `## Classement complet` : toutes les technologies retenues, dans l’ordre, avec les colonnes `Rang`, `Technologie`, `Nature`, `Évolution du mois`, `Impact`, `Pertinence stack`, `Confiance`, `Urgence`, `Maturité`, `Score`, `Classe`, `Lien vers la preuve` ;
3. `## Lecture architecturale` : les cinq premiers éléments, en expliquant le changement architectural ou opérationnel et la raison du rang ;
4. `## Par thème` : Cloud AWS, Cloud GCP, Kubernetes, observabilité/ELK, HashiCorp/IaC, sécurité, IA/agents et OSS/platform engineering, uniquement lorsque le thème contient au moins un élément ;
5. `## Mouvements du mois` : technologies montées, descendues, stabilisées ou retirées par rapport au classement mensuel précédent ; pour le premier mois, écrire `première édition` ;
6. `## Sujets non classés` : sujets sans preuve suffisante, doublons ou simples mentions, avec motif ;
7. `## Sources et limites` : rapports locaux, registres, sources primaires importantes, lacunes, exposition réelle inconnue et éventuelles sources en échec.

La section `Lecture architecturale` ne doit pas devenir un plan d’action ou un laboratoire. Utiliser `à surveiller`, `à qualifier`, `carte pertinente` ou `à écarter` comme décisions descriptives ; ne pas attribuer de POC ou d’échéance sans demande explicite de Mehdi.

## Règles de qualité

- Le classement doit couvrir toutes les technologies retenues dans les rapports du mois, pas seulement un top 5.
- Une technologie ne doit apparaître qu’une seule fois dans le classement complet.
- Chaque ligne possède un lien canonique ou un lien vers le rapport primaire qui la documente.
- Les scores manquants restent `inconnus` ; ils ne sont pas remplacés silencieusement par une moyenne.
- Le rapport ne réécrit pas l’historique des signaux et ne crée pas de nouveau signal uniquement pour le classement.
- Les cartes, index et catalogue ne sont mis à jour que pour les éléments effectivement analysés dans le rapport.
- Le rapport doit rester lisible en moins de vingt minutes.

## Sortie et publication

Écrire le fichier dans `dist/AAAA-MM-DD/classement-mensuel-AAAA-MM.md`, sans écraser un autre livrable. Le rapport est exécuté une seule fois par mois, après la clôture de la période couverte. Ajouter le fichier à `docs/rapports.md`, puis exécuter le validateur local avant le commit.

Réponds en français.
