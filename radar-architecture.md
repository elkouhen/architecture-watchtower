# Prompt — radar d’architecture

Produis en français le radar Cloud, Kubernetes et DevOps de l’utilisateur. Applique intégralement `docs/contrats-veille.md`, qui définit la collecte en delta, les preuves, la notation, les registres, le format `watchtower-couverture`, le budget orchestré et la validation. En cas de conflit, le contrat et `AGENTS.md` priment.

## But et périmètre

Détecte les changements et tendances capables de modifier une décision d’architecture, de plateforme, d’exploitation, de sécurité, de coût ou de trajectoire technologique. Couvre en priorité :

- AWS et GCP, notamment EKS/GKE, réseau, sécurité, données, observabilité, coûts, quotas et lifecycle ;
- Kubernetes, CNCF, conteneurs, service mesh, Gateway API, GitOps et platform engineering ;
- CI/CD, IaC, supply chain, SRE, OpenTelemetry, Elastic et l’écosystème HashiCorp ;
- IA appliquée aux plateformes lorsque le contrat l’exige : agents, RAG, inference gateways, routage, observabilité et gouvernance.

Écarte marketing, listes sans preuve, benchmarks non reproductibles, clones sans différenciation et annonces sans conséquence architecturale identifiable. Une popularité n’est ni une adoption ni une recommandation. Aucun POC, laboratoire ou nouvelle carte sans demande explicite.

## Sources et économie de collecte

En mode orchestré, `scripts/run_radar.rb` traite d’abord les échéances de signaux par script, télécharge chaque source une seule fois dans `.cache/radar/AAAA-MM-JJ/` (flux RSS/Atom découpés en éléments de delta, pages HTML normalisées en texte), puis lance deux phases. La phase `watchtower:qualify` qualifie les éléments dans `state/radar-runs/AAAA-MM-JJ.yaml`, sans rédiger le rapport. L’orchestrateur calcule ensuite la sélection. La phase `watchtower:write` rédige uniquement les sujets dont `selection_status` vaut `selected`, sans nouvelle collecte ni modification de la sélection ; les signaux, les curseurs de sources et les index sont ensuite synchronisés par script. Le prompt, les seules sections utiles du contrat et `watchtower:prepared-context` sont déjà injectés : ne relis ni le contrat, ni les registres, ni les livrables sur disque. Utilise ce contexte pour la déduplication sur 90 jours, les sources, leurs bornes et les deltas collectés. Hors orchestration, génère le même contexte avec `ruby scripts/collect_radar_deltas.rb --update-registry` puis `ruby scripts/prepare_radar_context.rb`, et applique le même manifest.

Avec `--replace`, réécris uniquement le rapport existant à partir de son manifest déjà sélectionné. Ne relance ni collecte, ni qualification, ni sélection, et ne modifie aucun registre, index ou manifest : la déduplication ne doit jamais opposer un livrable historique à lui-même. Une nouvelle observation ou un changement de sélection exige une nouvelle exécution datée, pas `--replace`.

Le contexte préparé contient, sous `collection`, le résultat de la collecte par source : pour un flux, les éléments du delta (date, titre, URL, fichier du cache, extrait, titres internes) et un `index.md` listant tous les éléments ; pour une page, le fichier normalisé, ses titres et un extrait ; pour un échec, les tentatives et l’erreur. Lis ces fichiers locaux de façon ciblée (`rg -n`, `sed -n`) et ne rouvre jamais sur le web une URL déjà collectée. Prends les URL et identifiants dans le contexte préparé ; ne recherche pas de nouvelles listes de sources si celles-ci couvrent le besoin.

1. **Contrôle primaire obligatoire.** Parcours les deltas collectés des sources AWS, GCP et IA imposées par `coverage_requirements`. Une source `failed` dans `collection` peut être ouverte une seule fois sur le web (URL ou fallback) ; si cela échoue aussi, la voie est en `échec` avec sa période manquante. Une lacune (`gap`) de plus de trente jours reste une période manquante datée. Pour Kubernetes et DevOps, consulte les releases, advisories, calendriers ou documentations officielles seulement lorsqu’un delta ou un candidat le justifie.
2. **Découverte de tendances.** Les pages `github-trending` et `trendshift` sont dans le cache : utilise l’une ou les deux, et au plus un flux ciblé supplémentaire (CNCF Landscape/blog, Google Trends, Hacker News, Lobsters ou topics GitHub) lorsqu’un angle est sous-représenté. Consigne les flux réellement consultés ; ne prétends pas avoir parcouru les autres.
3. **Qualification.** Un flux de tendance propose seulement un candidat. N’ouvre sur le web que la page canonique des candidats qui franchissent les deux premiers filtres : dépôt, release, changelog, advisory, documentation ou page fournisseur précise. Vérifie date, version, statut, périmètre, impact, inconnues et licence OSS. Une preuve primaire suffit ; une seconde preuve seulement pour une traction, une contradiction ou un pitch détaillé.

Arrête une piste dès qu’elle est dupliquée, hors périmètre ou non vérifiable. Reste sous le budget d’appels du contrat : douze appels d’outil au plus, dont huit appels web réservés aux pages canoniques et à l’unique relance d’une source en échec. Une lacune devient `Couverture incomplète`, jamais « aucun changement ».

Pendant une exécution orchestrée, émets un message de progression concis au début de chaque phase — échéances, contrôle primaire, découverte, qualification, rédaction et validation — puis un bilan court de la phase. Le runner affiche en continu ces messages et les actions d’outil avec leur durée afin de rendre visibles les lectures coûteuses, répétitions, échecs et pistes abandonnées. N’inclus ni raisonnement interne, ni contenu intégral des sources dans ces messages.

## Sélection

Les signaux arrivés à échéance ont déjà été clos ou différés par script ; `reviewed_signals` les liste pour information et tu n’y reviens pas. Applique l’algorithme `Scanner → Filtrer → Vérifier → Publier` du contrat.

Pour chaque candidat, renseigne le manifest structuré du contrat, notamment son `origin` fournisseur ou projet (`AWS`, `GCP`, `OpenAI`, `Anthropic`, etc.), et exige successivement :

1. un changement nouveau ou substantiel dans la fenêtre locale de 90 jours, ou une première découverte locale pertinente ;
2. un impact plausible sur architecture, sécurité, exploitation, coût ou lifecycle ;
3. une preuve primaire précise.

Classe sans score agrégé avec `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. Le script applique l’éligibilité et l’ordre total du contrat ; ne préclasse pas manuellement les candidats. Une `identity_key` désigne le sujet indépendamment de son URL. Réutilise l’identité existante pour une évolution du même sujet ; une telle réapparition doit être une `Mise à jour` substantielle.

Publie normalement 5 à 7 sujets, au plus 10 sauf alerte critique. Pour atteindre cinq sujets, élargis la qualification aux deltas primaires déjà collectés et aux pistes de découverte pertinentes, sans élargir la fenêtre de 90 jours ni abaisser les trois filtres. La déduplication prévaut toujours : ne republie un sujet déjà observé dans les 90 jours que si une évolution substantielle vérifiée modifie son statut, son risque, son échéance ou sa recommandation ; son type est alors `Mise à jour` et le delta est explicite. Si moins de cinq sujets remplissent ces conditions, publie seulement les sujets éligibles et inscris `Exception minimum de sujets : <motif factuel>` dans `Sujets écartés`. Ne complète jamais le quota avec un simple suivi de signal actif. Examine tous les éléments des deltas sans cible numérique de candidats : une fiche complète pour chaque candidat qui franchit les trois filtres, une fiche allégée (identité, nom, URL, `novelty`, les trois filtres et `rejection_note`) pour chaque rejet notable, et le rendement dans `candidate_yield_note`. `due_date` est une date de réexamen : la date du radar plus 30 jours pour `monitor`, plus 14 jours pour une décision portant une action.

Au moins 33 % des sujets retenus sont de nouveaux projets OSS, arrondi au supérieur. Ne force jamais un sujet faible pour atteindre ce quota et ne masque jamais un risque, une dépréciation ou une évolution AWS/GCP/IA importante : documente alors `Exception quota OSS : <motif>`. Une réapparition dans les 90 jours exige un changement substantiel vérifié et porte le type `Mise à jour`.

## Livrable concis

Écris uniquement `dist/AAAA-MM-JJ/radar-architecture.md` et les mises à jour locales exigées par `AGENTS.md`. Le rapport commence par :

1. un titre, immédiatement suivi de `<!-- watchtower:2 -->` ;
2. la ligne de métriques du contrat (tokens et, lorsque l’orchestrateur la mesure, durée murale ; variante `non disponible` provisoire en mode `watchtower:orchestrated`) ;
3. `## Vue d’ensemble`, avec exactement `Outil | Type | Pitch rapide | Lien vers la section`.

Chaque fiche a pour titre `## [Nom](URL canonique)` et contient uniquement :

- `**Pitch rapide :**` une ou deux phrases distinguant `Fait`, `Analyse` ou `Inférence` ;
- `**Utilité :**` un paragraphe concis sur l’impact, les limites, la maturité, le niveau `signal faible` ou `traction étayée`, et l’exposition locale (`à qualifier` si inconnue) ;
- `**Repères de comparaison :**` facultatif, trois alternatives maximum.

Le type de la vue d’ensemble vaut exactement `<nature> · <origine visible>`. Pour un candidat dont `novelty` vaut `Nouveau hors OSS`, affiche son origine exacte (`AWS`, `GCP`, `OpenAI`, `Anthropic`, etc.) et n’affiche jamais le libellé interne `Nouveau hors OSS`. Conserve `Nouveau projet OSS` pour un nouveau projet open source et `Mise à jour` pour une réapparition substantielle. Ajoute `### Pitch détaillé` à trois sujets maximum, uniquement si une conséquence transverse ou une seconde preuve le justifie ; reste bref et ne donne pas de procédure de déploiement.

Termine exactement par `## Sujets écartés`, `## Sources consultées` et `## Sources en échec`. Dans `Sources consultées`, fournis les preuves primaires datées et l’unique bloc `watchtower-couverture` complet. Dans `Sources en échec`, indique période manquante et conséquence ; écris `Aucune.` si nécessaire.

En mode orchestré, la rédaction ne modifie que le rapport et `docs/catalogue.md` : une ligne par sujet retenu, insérée après la ligne indiquée par le contexte ou mise à jour sur la ligne existante signalée, sans lire le reste du fichier. Les signaux (`ruby scripts/sync_radar_signals.rb`, un signal par candidat sélectionné avec son `identity_key`), les curseurs de sources, `docs/rapports.md` et la navigation récente de `README.md` sont mis à jour par l’orchestrateur ; ne committe pas. Hors orchestration, calcule d’abord la sélection avec `ruby scripts/select_radar_candidates.rb --manifest <manifest>`, exécute ces mêmes scripts (`sync_radar_signals.rb`, `index_reports.rb`), puis `ruby scripts/validate_watchtower.rb --report <livrable>` une seule fois et committe localement après validation. Un échec interdit le commit. N’utilise aucun connecteur externe.
