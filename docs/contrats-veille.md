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
algorithm: scan-filter-verify-publish
control_sources: [aws-whats-new, aws-security-bulletins]
discovery_sources: [github-trending]
qualification_sources: [projet-canonique]
coverage:
  # Gabarit d’une entrée ; répéter pour les 12 couples.
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

Pour un radar produit à partir du 8 septembre 2026, `algorithm` vaut exactement `scan-filter-verify-publish`. Les trois listes classent les sources réellement consultées par rôle ; elles peuvent être vides sauf `control_sources`. Une source utilisée dans une entrée de couverture figure dans `control_sources`. `discovery_sources` contient au plus deux identifiants distincts. Un même identifiant peut avoir plusieurs rôles lorsqu’une collecte sert aussi à qualifier un candidat.

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

## Algorithme Scanner → Filtrer → Vérifier → Publier

Cet algorithme s’applique à chaque nouveau radar. Les cartes et classements mensuels conservent leurs propres méthodes.

### 1. Scanner

1. Commencer par les données locales structurées : signaux actifs ou arrivés à échéance, dernières dates de succès des sources, livrables des 90 derniers jours et entrées canoniques du catalogue. Traiter les échéances avant toute nouvelle sélection. En exécution orchestrée, `scripts/prepare_radar_context.rb` fournit cette vue compacte dans `watchtower:prepared-context` ; ne pas relire les fichiers qu’elle synthétise sauf incohérence précise.
2. Construire un petit ensemble de sources primaires couvrant les douze couples AWS/GCP/IA et fonctionnalités/sécurité/lifecycle/disponibilité. Réutiliser une même collecte pour plusieurs couples lorsque son périmètre les couvre réellement. Viser six à huit sources de contrôle sans sacrifier la couverture obligatoire.
3. Consulter au maximum deux flux de découverte open source. Leur résultat sert uniquement à proposer des candidats.
4. Traiter chaque source comme un flux à delta : reprendre à `last_success`, lire l’intervalle manquant et arrêter la lecture après le dernier élément déjà consigné. Une même URL n’est ouverte qu’une fois par exécution.
5. Si une source primaire échoue ou est hors périmètre, essayer un seul fallback. Si ce fallback échoue ou reste incomplet, conserver la précédente valeur de `last_success`, déclarer la période manquante et ne pas conclure à l’absence de changement.

### 2. Filtrer

Appliquer successivement trois conditions à chaque élément détecté :

1. il décrit un changement nouveau ou substantiel par rapport aux 90 derniers jours ;
2. il peut modifier une décision d’architecture, de sécurité, d’exploitation ou de coût ;
3. il possède une preuve primaire précise et vérifiable.

Arrêter l’investigation dès qu’une condition échoue. Un flux de découverte ne satisfait jamais seul la troisième condition. Enregistrer seulement les exclusions qui expliquent une absence notable, une exception ou une limite de couverture.

### 3. Vérifier

Pour chaque candidat ayant passé le filtre, vérifier dans une source primaire la date, la version ou édition, le statut, le périmètre, l’impact, les inconnues et, pour un projet open source, la licence. Une preuve primaire suffit par défaut. Ouvrir une deuxième preuve indépendante uniquement pour établir une traction, étayer une tendance transverse, résoudre une contradiction ou justifier un pitch détaillé.

Noter ensuite `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. Une note d’impact ou d’urgence égale à 5 impose un examen prioritaire. Un candidat normal exige un impact d’au moins 3 et une confiance d’au moins 3. Un candidat avec un impact d’au moins 3 mais une confiance inférieure à 3 ne peut être conservé que comme `signal faible`. Les alertes critiques vérifiées restent prioritaires lorsque l’exposition locale est inconnue.

### 4. Publier

Conserver dans cet ordre : toutes les alertes critiques, les changements architecturaux les plus forts, puis les découvertes open source utiles au quota. Produire normalement cinq à sept sujets lorsqu’ils passent le filtre, mais accepter un cycle calme de zéro à quatre sujets. Appliquer le plafond, les exceptions critiques et le quota open source définis dans le prompt du radar.

Dans `Sources consultées`, distinguer le rôle `contrôle`, `découverte` ou `qualification` de chaque source. Ne conserver dans le contexte de rédaction que le fait, la date, l’URL canonique, l’impact, les inconnues, la décision existante et les notes nécessaires. Préférer les liens vers les preuves à leur reformulation.

Cette réduction du nombre de lectures ne diminue ni la couverture obligatoire, ni les exigences de preuve, ni le traitement des échéances actives.

### Budget de contexte orchestré

Une exécution lancée par `scripts/run_radar.rb` reçoit le prompt, le présent contrat et une vue locale préparée dès son premier message. Elle reste normalement sous douze appels d’outil, dont huit appels web, utilise des résultats web courts par défaut, filtre avant qualification, verrouille les preuves avant rédaction et n’exécute qu’une validation locale. Un dépassement n’est admis que pour préserver une alerte critique et doit être signalé dans la réponse finale.

### Garde-fou de publication par dépassement de budget

`state/budget.yaml` définit une référence de consommation par exécution (`tokens_hors_cache`, cf. Transparence de consommation) et un seuil de dépassement toléré en pourcentage. Après la fin du tour Codex, `scripts/run_radar.rb` compare l’entrée hors cache réellement mesurée à `reference_value * (1 + overrun_threshold_pct/100)`. Au-delà de ce seuil, l’orchestrateur n’injecte pas de commit : il annule les modifications locales produites par le tour, affiche un avertissement explicite avec les valeurs mesurée et de référence, et le radar n’est pas publié. La consommation déjà dépensée pendant la génération n’est pas récupérable ; ce garde-fou protège uniquement la publication, pas le coût déjà engagé du tour en cours. Tant que `reference_value` reste une estimation provisoire (quota réel non communiqué), l’ajuster dès que le quota effectif est connu.

Le contexte préparé est une projection, pas un nouveau registre : les fichiers sous `state/`, `dist/` et `docs/` restent les sources de vérité. Le script de préparation sélectionne les champs nécessaires, les signaux actifs ou observés dans les 90 jours, les sources requises pour la couverture, les sujets récents et les entrées canoniques. Il ne modifie aucun fichier.

## Exécution économe

Pour une carte ou un classement mensuel, commencer par les données locales structurées, ouvrir uniquement les passages liés au service ou à la période, traiter les sources comme des flux à delta et arrêter une investigation dès qu’elle est hors périmètre, dupliquée ou non vérifiable. Une source secondaire n’est ouverte que pour combler une lacune décisionnelle précise. Cette règle ne remplace pas l’algorithme du radar ci-dessus.

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

> **Tokens utilisés :** `<total>` total — entrée `<input>` (dont cache `<cached>`, hors cache `<billed_input>`), sortie `<output>`, raisonnement `<reasoning>` — mesure runtime Codex. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Toutes les valeurs sont des entiers fournis par le runtime, sauf `<billed_input>` qui est dérivé localement (`entrée - cache`) pour isoler la part réellement coûteuse de l’entrée. `cache` est inclus dans `entrée` et `raisonnement` est inclus dans `sortie` : ne pas les additionner une seconde fois. Le total doit être égal à `entrée + sortie`. Utiliser la consommation du tour (`turn_token_usage`), jamais celle de tout le thread, afin de ne pas attribuer au radar des échanges antérieurs. L’orchestrateur injecte les métriques, relance la validation, puis crée le commit local ; un échec d’extraction interdit le commit instrumenté.

Le total en tokens n’est pas un proxy fiable du coût : un total élevé dominé par le cache peut coûter bien moins qu’un total plus faible mais entièrement hors cache. Pour suivre le coût réel d’un radar dans le temps, comparer `hors cache` (et non `total`) d’une exécution à l’autre.

Le format `non disponible` reste autorisé uniquement lorsque le radar n’est pas lancé par cet orchestrateur ou lorsque le runtime ne fournit réellement aucun compteur exploitable. Ne jamais déduire les tokens de la taille du rapport.
