# Contrats des rapports et preuves

Référence commune à lire avec le prompt du livrable demandé. Les rapports nouvellement produits portent `<!-- watchtower:2 -->` immédiatement après le titre. Ce marqueur est une métadonnée du fichier Markdown : le générateur de site doit l’omettre du corps HTML comme des extraits et cartes d’index. Les archives sans marqueur restent au contrat historique : ne pas les régénérer pour satisfaire une nouvelle règle. Une correction substantielle demandée applique le contrat courant au fichier corrigé. Le validateur impose le marqueur aux fichiers encore absents de l’historique Git ; un rapport marqué ne peut revenir au contrat historique.

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

Pour un radar produit à partir du 8 septembre 2026, `algorithm` vaut exactement `scan-filter-verify-publish`. Les trois listes classent les sources réellement consultées par rôle ; `qualification_sources` peut être vide, `control_sources` ne peut jamais l’être. Une source utilisée dans une entrée de couverture figure dans `control_sources`. `discovery_sources` contient entre un et deux identifiants distincts : la sobriété de collecte réduit la profondeur de qualification, jamais l’étape de découverte elle-même. Un même identifiant peut avoir plusieurs rôles lorsqu’une collecte sert aussi à qualifier un candidat.

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
3. Consulter au moins un et au maximum deux flux de découverte open source. Cette étape reste obligatoire même pour économiser du budget ; leur résultat sert uniquement à proposer des candidats.
4. Traiter chaque source comme un flux à delta : reprendre à `last_success`, lire l’intervalle manquant et arrêter la lecture après le dernier élément déjà consigné. Une même URL n’est ouverte qu’une fois par exécution.
5. Si une source primaire échoue ou est hors périmètre, essayer un seul fallback. Si ce fallback échoue ou reste incomplet, conserver la précédente valeur de `last_success`, déclarer la période manquante et ne pas conclure à l’absence de changement.

### Manifest de qualification

Chaque radar produit un registre d’exécution `state/radar-runs/AAAA-MM-JJ.yaml`. Ce fichier n’est pas un second livrable : il constitue la preuve structurée utilisée pour calculer et valider le rapport. Il contient la date, les rôles des sources, les douze entrées de couverture, les échecs et tous les candidats détectés. Chaque candidat possède au minimum une `identity_key` stable, un nom, une URL canonique, une nature, une nouveauté, une origine exacte, les trois résultats de filtre, son statut OSS, sa licence le cas échéant, sa récence, ses quatre notes, leur justification et une preuve primaire lorsqu’elle est déclarée disponible. `origin` nomme le fournisseur ou projet responsable (`AWS`, `GCP`, `OpenAI`, `Anthropic`, etc.) ; pour une nouveauté managée, cette valeur remplace le libellé technique `Nouveau hors OSS` dans la vue d’ensemble du rapport.

```yaml
schema_version: 1
date: "2026-09-10"
algorithm: scan-filter-verify-publish
sources:
  control: [aws-whats-new]
  discovery: [github-trending]
  qualification: [projet-canonique]
coverage: [] # les douze entrées au format watchtower-couverture
source_failures: []
candidate_yield_note: Moins de douze éléments disponibles dans les deltas contrôlés.
candidates:
  - id: candidate-001
    identity_key: produit:sujet-stable
    name: Produit
    canonical_url: https://example.org/release
    nature: outil
    novelty: Nouveau hors OSS
    origin: GCP
    subject: Changement vérifié
    product_version: "1.0"
    environment: exposition inconnue
    substantive_change: true
    architectural_effect: true
    primary_evidence: true
    open_source: false
    new_project: false
    license: null
    impact_architectural: 4
    urgence: 3
    pertinence_stack: 4
    confiance: 5
    recency: 48h
    coverage_lanes: [GCP/releases_features]
    signal_level: normal
    scoring_note: Justification des quatre notes.
    fact: Fait précis destiné au rapport.
    analysis: Conséquence architecturale et limites.
    unknowns: Exposition locale à qualifier.
    maturity: État documenté du produit.
    decision: qualify
    owner: plateforme
    due_date: "2026-09-24"
    success_criterion: Inventaire concerné établi.
    evidence:
      - source_id: projet-canonique
        url: https://example.org/release
        primary: true
        observed_at: "2026-09-10"
        published_at: "2026-09-09"
        effective_at: inconnue
        fact: Version et périmètre vérifiés.
selection: {} # réservé au script de sélection
```

L’URL n’est pas l’identité. Une même page de notes de version peut porter plusieurs sujets, tandis qu’un même sujet peut changer d’URL. Une identité déjà observée dans les 90 jours impose le type `Mise à jour` et un changement substantiel explicite. Le script `scripts/select_radar_candidates.rb` est seul responsable des champs `selection_status`, `rank`, `selection_reason` et du bloc `selection` ; l’agent ne les décide pas.

Lors de la rédaction, chaque candidat sélectionné crée ou met à jour exactement un signal de même `identity_key`. Sa `classification` vaut respectivement `nouveau_projet_oss`, `nouveau_hors_oss` ou `mise_a_jour`. L’URL, les quatre notes, la décision, le propriétaire, l’échéance, `last_seen` et le lien vers le livrable doivent reprendre le candidat et la date du radar.

### 2. Filtrer

Appliquer successivement trois conditions à chaque élément détecté :

1. il décrit un changement nouveau ou substantiel par rapport aux 90 derniers jours ;
2. il peut modifier une décision d’architecture, de sécurité, d’exploitation ou de coût ;
3. il possède une preuve primaire précise et vérifiable.

Arrêter l’investigation dès qu’une condition échoue. Un flux de découverte ne satisfait jamais seul la troisième condition. Enregistrer seulement les exclusions qui expliquent une absence notable, une exception ou une limite de couverture.

### 3. Vérifier

Pour chaque candidat ayant passé le filtre, vérifier dans une source primaire la date, la version ou édition, le statut, le périmètre, l’impact, les inconnues et, pour un projet open source, la licence. Une preuve primaire suffit par défaut. Ouvrir une deuxième preuve indépendante uniquement pour établir une traction, étayer une tendance transverse, résoudre une contradiction ou justifier un pitch détaillé.

Noter ensuite `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. Une note d’impact ou d’urgence égale à 5 rend obligatoire tout candidat par ailleurs éligible. Un candidat exige un impact d’au moins 3. Une confiance inférieure à 3 n’est admise que si `signal_level` vaut `signal faible`. Les alertes critiques vérifiées restent prioritaires lorsque l’exposition locale est inconnue.

### 4. Publier

Le classement est déterministe et sans score agrégé. Trier les candidats éligibles par la clé suivante : obligatoire d’abord, urgence décroissante, impact architectural décroissant, pertinence stack décroissante (`inconnu` après les valeurs numériques), confiance décroissante, récence `48h`, `7d`, `30d`, `discovery`, puis `identity_key` alphabétique.

Lorsque sept candidats ou moins sont éligibles, les conserver tous. Au-delà, retenir les sept premiers, sauf si plus de sept candidats obligatoires existent : les retenir jusqu’au plafond de dix ; si plus de dix candidats obligatoires existent, le dépassement critique est admis. Calculer ensuite le quota OSS. Pour le satisfaire, remplacer seulement les derniers candidats non obligatoires et non OSS par les meilleurs nouveaux projets OSS éligibles encore exclus. Ne jamais évincer un candidat obligatoire. Si le quota reste impossible, inscrire automatiquement une exception motivée dans le manifest et la reprendre dans `Sujets écartés`.

La cible minimale est de cinq sujets. Si les nouveaux candidats éligibles sont moins de cinq après qualification complète, compléter la sélection avec des suivis de signaux `new` ou `open` : la source primaire et le statut doivent avoir été revus pendant l’exécution, l’effet architectural doit rester démontré et la fiche doit être explicitement une `Mise à jour`, sans affirmer une nouvelle annonce. Ces suivis n’entrent pas dans le quota des nouveaux projets OSS. Le bloc `selection` indique leur nombre et leurs identifiants ; `minimum_exception` n’est admis que si aucun suivi actif vérifiable ne permet d’atteindre cinq sujets. Lorsque cinq sujets ou plus sont retenus, `minimum_exception` vaut `null`.

Après sélection, le script recalcule le résultat des douze voies à partir des `coverage_lanes` des seuls candidats retenus. Une voie en échec reste en échec ; une autre voie vaut `signal retenu` seulement si au moins un sujet publié lui est relié, sinon `aucun changement retenu`.

Dans `Sources consultées`, distinguer le rôle `contrôle`, `découverte` ou `qualification` de chaque source. Ne conserver dans le contexte de rédaction que le fait, la date, l’URL canonique, l’impact, les inconnues, la décision existante et les notes nécessaires. Préférer les liens vers les preuves à leur reformulation.

Cette réduction du nombre de lectures ne diminue ni la couverture obligatoire, ni les exigences de preuve, ni le traitement des échéances actives.

### Budget de contexte orchestré

Une exécution lancée par `scripts/run_radar.rb` reçoit le prompt, le présent contrat et une vue locale préparée dès son premier message. Elle reste normalement sous douze appels d’outil, dont huit appels web, utilise des résultats web courts par défaut, filtre avant qualification, verrouille les preuves avant rédaction et n’exécute qu’une validation locale. Un dépassement n’est admis que pour préserver une alerte critique et doit être signalé dans la réponse finale.

### Protocole d’analyse isolée `watchtower:isolate-v1`

Ce protocole est activé uniquement lorsque `scripts/run_radar.rb` injecte explicitement le marqueur `watchtower:isolate-v1`. La seule présence de cette section dans le contrat ne vaut pas activation. Le changement doit être livré atomiquement avec le runner, ses schémas et ses tests ; avant cette activation, le protocole orchestré à deux tours reste la référence exécutable.

Lorsqu’il est activé, le pipeline suit cet ordre :

1. **Préparer.** Construire une fois la vue locale, le plan de collecte dédupliqué et un index minimal de déduplication. Cet index contient les `identity_key`, URL canoniques, noms, `last_seen`, statuts et liens de rapports utiles ; il n’embarque ni rapports complets, ni historique narratif sans utilité pour la source analysée.
2. **Collecter.** Télécharger chaque URL canonique une seule fois, en respectant la borne `last_success`, dans un répertoire temporaire propre à l’exécution et absent de Git. Conserver avec le document l’URL finale, l’horodatage, le type de contenu, le statut HTTP, la taille et l’éventuelle troncature. Essayer au plus un fallback. Un échec reste un échec de couverture ; il n’est jamais transformé en absence de changement.
3. **Normaliser.** Retirer scripts, styles, navigation, publicités et répétitions de gabarit. Préserver titres, dates, versions, statuts de disponibilité, tableaux, listes, avis de sécurité, blocs de code et liens canoniques nécessaires à la preuve. Toute limite de taille est déterministe et signalée ; une troncature qui empêche la vérification impose `primary_evidence: false` ou une couverture incomplète.
4. **Analyser en isolation.** Lancer un nouveau contexte Codex pour chaque document, ou pour un petit lot partageant la même URL canonique et la même fenêtre de delta. Ce contexte ne contient aucun document ni résultat d’analyse antérieur. Il reçoit seulement un prompt d’analyse borné, le document normalisé, ses métadonnées, les voies concernées et les lignes pertinentes de l’index de déduplication. Il n’a pas accès au web, ne modifie pas le dépôt et retourne exclusivement un objet structuré conforme au schéma de fragment.
5. **Agréger.** Valider chaque fragment avant usage, rejeter les champs inconnus, fusionner les résultats par `identity_key` et signaler les contradictions. L’agrégation produit les douze entrées de couverture, les échecs, le rendement et tous les candidats dans le manifest. Aucun analyseur isolé ne renseigne `selection_status`, `rank`, `selection_reason` ou `selection`.
6. **Sélectionner et rédiger.** Exécuter l’algorithme Ruby inchangé, puis fournir au tour de rédaction uniquement les candidats sélectionnés, leurs preuves, la couverture agrégée, les échecs et les seuls enregistrements locaux à mettre à jour. Ne transmettre ni documents bruts, ni fragments rejetés, ni candidats non sélectionnés hors du résumé requis pour `Sujets écartés`.
7. **Nettoyer.** Supprimer le cache temporaire après validation ou échec. Aucun contenu téléchargé ne devient un livrable ou une preuve publiée autonome ; le rapport cite toujours l’URL primaire canonique.

Un fragment d’analyse contient au minimum : identifiant et URL de source, intervalle effectivement lu, résultat par voie, erreurs ou troncatures, et zéro ou plusieurs candidats utilisant les champs du manifest de qualification. Les preuves reprennent un fait court attribuable au document ; elles ne recopient pas la page. Le schéma est versionné et validé avant agrégation.

L’isolation désigne un nouveau contexte d’exécution, pas une compaction ou une instruction demandant au modèle d’oublier. Pour éviter que le coût fixe des instructions annule le gain, regrouper seulement les entrées d’une même page ou d’un même flux ; ne jamais regrouper des URL indépendantes dans un historique croissant.

L’activation exige des tests automatisés prouvant : une seule collecte par URL, l’absence de document précédent dans chaque contexte, le refus d’un fragment invalide, la conservation des douze voies, l’identité de la sélection pour un manifest équivalent, l’absence du cache dans Git, l’addition des consommations de tous les contextes et une réduction mesurable de l’entrée hors cache sur un jeu de référence. Le seuil de publication continue de s’appliquer à la somme de l’exécution entière.

### Garde-fou de publication par dépassement de budget

`state/budget.yaml` définit une référence de consommation par exécution (`tokens_hors_cache`, cf. Transparence de consommation) et un seuil de dépassement toléré en pourcentage. Après la fin du tour Codex, `scripts/run_radar.rb` compare l’entrée hors cache réellement mesurée à `reference_value * (1 + overrun_threshold_pct/100)`. Au-delà de ce seuil, l’orchestrateur n’injecte pas de commit : il annule les modifications locales produites par le tour, affiche un avertissement explicite avec les valeurs mesurée et de référence, et le radar n’est pas publié. La consommation déjà dépensée pendant la génération n’est pas récupérable ; ce garde-fou protège uniquement la publication, pas le coût déjà engagé du tour en cours. Tant que `reference_value` reste une estimation provisoire (quota réel non communiqué), l’ajuster dès que le quota effectif est connu.

Le contexte préparé est une projection, pas un nouveau registre : les fichiers sous `state/`, `dist/` et `docs/` restent les sources de vérité. Le script de préparation sélectionne les champs nécessaires, y compris l’identité, les notes, l’environnement, la justification, l’historique et la dernière revue des signaux actifs ou observés dans les 90 jours. Il inclut les sources requises pour la couverture, les sujets récents et les entrées canoniques. Il ne modifie aucun fichier.

### Collecte automatisable

`scripts/prepare_radar_context.rb` génère aussi un plan de collecte dédupliqué : une entrée par URL avec les identifiants de source, les voies couvertes, la borne `last_success` et le fallback. Les collecteurs structurés placés dans `scripts/radar_collectors/` peuvent alimenter le manifest à partir de RSS, Atom, JSON ou API. Une source sans collecteur reste qualifiée par l’agent. Dans tous les cas, le manifest et `state/sources.yaml` doivent conserver la tentative, le succès éventuel, le dernier élément vu et la période manquante.

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

Lorsqu’un radar est lancé par `scripts/run_radar.rb`, la phase de rédaction écrit d’abord la variante `non disponible` et ne crée pas de commit. Après les tours de qualification et de rédaction, l’orchestrateur additionne leurs consommations puis remplace cette ligne par :

Une exécution `--replace` exige le rapport et son manifest sélectionné existants. Elle saute la collecte, la qualification et la sélection, puis réécrit uniquement le rapport depuis ce manifest verrouillé. Elle ne modifie ni registres, ni index, ni manifest. Cette sémantique empêche le livrable remplacé d’être considéré comme un doublon de lui-même et conserve la photographie historique ; une nouvelle observation exige un nouveau radar daté.

> **Tokens utilisés :** `<total>` total — entrée `<input>` (dont cache `<cached>`, hors cache `<billed_input>`), sortie `<output>`, raisonnement `<reasoning>` — mesure runtime Codex, durée `<HH:MM:SS>`. Le cache est facturé nettement moins cher que l’entrée hors cache ; `hors cache` et `sortie` approchent le mieux le coût réel.

Toutes les valeurs de tokens sont des entiers fournis par le runtime, sauf `<billed_input>` qui est dérivé localement (`entrée - cache`) pour isoler la part réellement coûteuse de l’entrée. `cache` est inclus dans `entrée` et `raisonnement` est inclus dans `sortie` : ne pas les additionner une seconde fois. Le total doit être égal à `entrée + sortie`. Utiliser la consommation de chaque tour (`turn_token_usage`), jamais celle de tout le thread, puis additionner les deux tours afin de ne pas attribuer au radar des échanges antérieurs. La durée est un temps mural mesuré avec une horloge monotone depuis le début de l’orchestration, après analyse des options, jusqu’à l’injection des métriques ; elle inclut les contrôles initiaux, la préparation, la qualification, la sélection et la rédaction, mais exclut la validation finale et le commit. Elle est arrondie à la seconde supérieure et affichée en `HH:MM:SS`, avec un nombre d’heures non borné. L’orchestrateur injecte les métriques, relance la validation, puis crée le commit local ; un échec d’extraction interdit le commit instrumenté.

Le total en tokens n’est pas un proxy fiable du coût : un total élevé dominé par le cache peut coûter bien moins qu’un total plus faible mais entièrement hors cache. Pour suivre le coût réel d’un radar dans le temps, comparer `hors cache` (et non `total`) d’une exécution à l’autre.

Le format `non disponible` reste autorisé uniquement lorsque le radar n’est pas lancé par cet orchestrateur ou lorsque le runtime ne fournit réellement aucun compteur exploitable. Ne jamais déduire les tokens de la taille du rapport.
