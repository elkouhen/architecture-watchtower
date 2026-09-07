# Contrats des rapports et preuves

Référence commune à lire avec le prompt du livrable demandé. Les rapports nouvellement produits portent `<!-- watchtower:2 -->` immédiatement après le titre. Les archives sans marqueur restent au contrat historique : ne pas les régénérer pour satisfaire une nouvelle règle. Une correction substantielle demandée applique le contrat courant au fichier corrigé. Le validateur impose le marqueur aux fichiers encore absents de l’historique Git ; un rapport marqué ne peut revenir au contrat historique.

## Preuves et dates

Pour chaque signal, conserver dans `Sources consultées` une preuve primaire reliée au sujet : URL de la page précise, produit/version/édition, région ou périmètre, date de publication, date d’effet (ou `inconnue`), date de consultation et fait soutenu. Une date de consultation ne prouve pas la fraîcheur d’un changement. Pour une découverte sans date de release, donner une observation datée de l’artefact et la qualifier de découverte, pas de nouvelle annonce.

Deux preuves sont indépendantes si elles décrivent des événements ou observations distincts avec leur origine identifiable. Un communiqué, ses reprises et sa répétition dans plusieurs rapports ne forment qu’une preuve. Deux observations distinctes d’un même fournisseur peuvent montrer son évolution, mais ne prouvent pas à elles seules une adoption indépendante. Séparer disponibilité annoncée, compatibilité documentée et usage réellement observé. Une URL n’est pas une preuve suffisante sans lecture de son contenu.

Dans une carte, identifier les sources par `Source primaire : [titre](URL)`. Vérifier manuellement que les trois URL distinctes documentent effectivement le produit, ses usages et son exploitation ; le validateur contrôle leur présence, pas la véracité de leur contenu.

## Repères des notes

Notes entières de 1 à 5 ; 2 et 4 désignent un état intermédiaire justifié. Aucune inconnue n’est transformée en moyenne.

| Dimension | 1 | 3 | 5 |
|---|---|---|---|
| impact_architectural | changement local sans contrat modifié | intégration ou exploitation sensiblement modifiée | rupture de contrat, sécurité ou architecture de plateforme |
| urgence | aucune échéance rapprochée documentée | échéance ou risque documenté à examiner sous 30 jours | incident actif, exploitation avérée ou échéance incompatible imminente |
| pertinence_stack | périphérique aux intérêts déclarés | composant ou pattern adjacent | priorité explicitement déclarée ou environnement confirmé concerné |
| confiance | artefact vérifiable mais affirmation peu étayée | source primaire précise, limites identifiées | documentation corroborée par observations ou preuves techniques distinctes |
| nouveaute_interet | capacité déjà connue, intérêt incrémental | nouvelle intégration ou approche utile | nouveau contrat ou capacité de plateforme structurante |
| maturite_exploitation | prototype avec limites majeures | intégration documentée, maintenance active | exploitation étayée, lifecycle, sécurité et réversibilité documentés |

Le radar exige les quatre premières dimensions. `pertinence_stack: inconnu` est admis uniquement avec `scoring_note` expliquant le contexte manquant ; une stack non inventoriée n’empêche pas une note fondée sur des intérêts explicitement déclarés. Toute note possède une justification dans `scoring_note` pour les nouveaux signaux. Pour les archives, conserver les valeurs existantes. Les notes mensuelles ne sont pas réinjectées dans le registre de signaux.

## Couverture du radar

Dans `Sources consultées`, inclure un bloc YAML `watchtower-couverture`. Il archive les douze couples domaine/voie, indépendamment de l’état ultérieur du journal de collecte. Une entrée comporte :

```yaml
# Gabarit d’une entrée ; répéter pour les 12 couples.
coverage:
  - domain: AWS
    lane: releases_features
    sources: [aws-whats-new]
    scope: "Annonces de services AWS ; disponibilité fournisseur, pas exposition locale."
    checked_at: "2026-09-05T10:00:00+02:00"
    from: "2026-09-04"
    through: "2026-09-05"
    result: aucun changement retenu
    complete: true
    note: "Intervalle entièrement parcouru."
```

Domaines : `AWS`, `GCP`, `IA`. Voies : `releases_features`, `security`, `lifecycle_deprecations`, `availability_quotas_costs`. `sources` référence les identifiants effectivement consultés dans `state/sources.yaml` et `scope` explicite le produit ou le périmètre couvert ; une source hors périmètre ne couvre pas une voie. Résultats : `signal retenu`, `aucun changement retenu`, `échec`. Une annonce upstream ne démontre ni la disponibilité dans un service managé ni dans une région : documenter cette distinction dans `scope` ou dans la preuve du sujet. Si une voie reste partiellement ou totalement inaccessible, `complete: false`, motif et période manquante obligatoires ; le rapport porte `Couverture incomplète` et peut être publié avec cette limite explicite. Aucune absence de changement ne peut être déduite d’un échec. Dans le registre, `last_attempt` avance à chaque tentative ; `last_success` uniquement après collecte complète. Une interruption de plus de trente jours laisse une lacune explicitement datée.

## Registre du classement mensuel

Dans `Période et méthode`, inclure un bloc YAML nommé `watchtower-classement` (le nom suit les trois accents graves). Il fait partie du seul fichier Markdown produit ; aucun second livrable n’est nécessaire.

```yaml
period: "2026-08"
mode: qualitatif
items:
  - id: exemple-produit
    rank: 1
    canonical_url: https://example.org/product
    classification: à qualifier
    trend: faible
    trend_evidence: [preuve-1]
    nouveaute_interet: 3
    impact_architectural: inconnu
    pertinence_stack: inconnu
    confiance: inconnu
    maturite_exploitation: 3
    urgence: inconnu
    score: inconnu
    reason: "Données historiques insuffisantes ; intégration documentée."
    evidence: [preuve-1]
events:
  - id: preuve-1
    date: "2026-08-20"
    technology: exemple-produit
    origin: "release officielle"
    url: https://example.org/product/releases/1
trends: []
```

Exemple de tendance : `id: tendance-1`, `level: émergente`, `evidence: [preuve-1, preuve-2]`, `reason: convergence documentée`. Chaque item porte aussi `trend` et `trend_evidence`, avec les mêmes seuils que les tendances transverses. Pour `stable`, ajouter `previous_report` avec un lien local existant vers l’édition précédente et justifier la comparaison. La liste `events` décrit des observations distinctes, pas les rapports qui les reprennent. `date` est la date d’observation locale pendant la période ; préciser séparément `published_at` et `effective_at` lorsqu’elles sont connues. Une découverte du mois peut donc concerner une annonce plus ancienne. Les corrections postérieures restent hors de ce registre historique. Les faits sans observation historique vérifiable figurent dans les limites ou les sujets non classés.

Le tableau principal et `items` ont exactement le même ordre, les mêmes URL canoniques et les mêmes classes. Chaque ligne contient aussi un lien de preuve. Deux identifiants ne peuvent partager une URL canonique, sauf `identity_note` sur chaque entrée expliquant l’autonomie des technologies. Les scores calculables sont arrondis à deux décimales, mais le tri utilise la somme exacte des poids entiers (30, 25, 20, 15, 10). Une note inconnue impose `score: inconnu`. Les valeurs non numériques ne sont jamais utilisées dans une moyenne.

## Portée du contrôle

Le validateur distingue radar, carte et classement : sections et contenu non vide, URL déclarées, dates, registres structurés, calcul et ordre mensuels, unicité des éditions. Les liens locaux sans fragment sont vérifiés ; la validité des ancres et la qualité des sources restent à relire. La pertinence, l’exhaustivité du corpus, l’indépendance réelle des preuves, les faits techniques et les justifications exigent une revue éditoriale ; un contrôle automatique réussi ne les certifie pas.

## Exécution économe

L’objectif est de préserver les preuves et les contrôles utiles tout en évitant de relire ou de rechercher ce qui n’a pas changé. Appliquer ces règles à tout nouveau livrable.

1. Commencer par les données locales structurées : signaux actifs ou arrivés à échéance, dernières dates de succès des sources, livrables du périmètre temporel et entrées canoniques du catalogue. Utiliser une recherche ciblée par identifiant, URL canonique, statut et date avant d’ouvrir un document complet. Ne relire intégralement un ancien rapport que si un candidat porte la même URL canonique ou une évolution substantielle.
2. Traiter une source comme un flux à delta : reprendre à `last_success`, lire l’intervalle manquant et s’arrêter après l’élément le plus récent déjà consigné. Ne pas refaire une recherche générale ni consulter les sources secondaires lorsqu’aucun changement primaire n’est détecté. Une source en échec reste toutefois consignée et ne permet jamais de conclure à l’absence de changement.
3. Pour chaque voie de couverture obligatoire, consulter d’abord une unique source primaire canonique adaptée. N’ouvrir une source de secours que si la première échoue, est hors périmètre ou signale un changement à qualifier. La couverture reste obligatoire ; seule l’exploration redondante est supprimée.
4. Qualifier un candidat avec une preuve primaire précise et datée. Une seconde preuve indépendante n’est requise que pour conclure à une traction étayée, étayer une tendance transversale ou produire un pitch détaillé. Les sources de découverte ne déclenchent pas à elles seules une recherche approfondie.
5. Ne conserver dans le contexte de rédaction que le fait, la date, l’URL canonique, l’impact, les inconnues, la décision existante et les notes nécessaires. Préférer les liens vers les preuves à leur reformulation. Ne pas recopier les notes de version, les descriptions produit ou l’historique inchangé.
6. Arrêter l’investigation d’un sujet dès qu’il est clairement hors périmètre, dupliqué, non vérifiable ou sans changement substantiel. Enregistrer alors un motif court dans le lieu prévu par le livrable, sans poursuivre la collecte par curiosité.

Ces économies ne réduisent ni les exigences de preuve, ni les échéances actives, ni les sections et registres imposés par le présent contrat.

### Registres tabulaires compacts

`state/signals.yaml` et `state/sources.yaml` peuvent utiliser `schema_version: 3` et `format: tabular-v1`. Dans ce format, `signal_fields` ou `source_fields` donne l’ordre des colonnes et chaque ligne de `signals` ou `sources` fournit exactement les valeurs correspondantes. Les données et les champs requis restent identiques ; seule leur représentation élimine la répétition des clés. Lire d’abord l’en-tête, puis sélectionner les colonnes et lignes utiles. Le validateur et la génération du site normalisent ce format avant contrôle.

## Transparence de consommation

Chaque nouveau rapport au contrat version 2 affiche, juste après `<!-- watchtower:2 -->`, cette ligne visible :

> **Tokens utilisés :** `<entier>` — mesure runtime.

L’entier est le total réellement fourni par le runtime pour la production du livrable, collecte incluse lorsqu’il est exposé. Ne jamais l’estimer ni le reconstituer à partir de la taille des fichiers. Si cette métrique n’est pas exposée, écrire :

> **Tokens utilisés :** `non disponible` — compteur runtime non exposé.

Cette absence est une limite de mesure, non une valeur nulle.

### Instrumentation des radars

Lorsqu’un radar est lancé par `scripts/run_radar.rb`, l’agent écrit d’abord la variante `non disponible` et ne crée pas de commit. Après la fin du tour Codex, l’orchestrateur récupère la consommation cumulative du tour, remplace cette ligne par :

> **Tokens utilisés :** `<total>` total — entrée `<input>`, cache `<cached>`, sortie `<output>`, raisonnement `<reasoning>` — mesure runtime Codex.

Toutes les valeurs sont des entiers fournis par le runtime. `cache` est inclus dans `entrée` et `raisonnement` est inclus dans `sortie` : ne pas les additionner une seconde fois. Le total doit être égal à `entrée + sortie`. Utiliser la consommation du tour (`turn_token_usage`), jamais celle de tout le thread, afin de ne pas attribuer au radar des échanges antérieurs. L’orchestrateur injecte les métriques, relance la validation, puis crée le commit local ; un échec d’extraction interdit le commit instrumenté.

Le format `non disponible` reste autorisé uniquement lorsque le radar n’est pas lancé par cet orchestrateur ou lorsque le runtime ne fournit réellement aucun compteur exploitable. Ne jamais déduire les tokens de la taille du rapport.
