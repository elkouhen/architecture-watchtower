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

En mode orchestré, le travail est séparé en deux phases. La phase `watchtower:qualify` collecte et qualifie les éléments dans `state/radar-runs/AAAA-MM-JJ.yaml`, sans rédiger le rapport. L’orchestrateur calcule ensuite la sélection. La phase `watchtower:write` rédige uniquement les sujets dont `selection_status` vaut `selected`, sans nouvelle collecte ni modification de la sélection. Le prompt, le contrat et `watchtower:prepared-context` sont déjà injectés : ne les relis pas sur disque. Utilise ce contexte pour les échéances, la déduplication sur 90 jours, les sources et leurs bornes. Hors orchestration, lis les fichiers locaux exigés par `AGENTS.md` de façon ciblée et applique le même manifest.

Prends les URL et identifiants dans `state/sources.yaml` ou dans le contexte préparé. Ne recherche pas de nouvelles listes de sources si celles-ci couvrent le besoin.

1. **Contrôle primaire obligatoire.** Parcours en delta les sources officielles AWS, GCP et IA imposées par `coverage_requirements`, dont AWS What’s New, AWS Security Bulletins, lifecycle EKS, Google Cloud/GKE release notes et bulletins de sécurité. Pour Kubernetes et DevOps, consulte les releases, advisories, calendriers ou documentations officielles seulement lorsqu’un delta ou un candidat le justifie.
2. **Découverte de tendances.** Consulte un ou deux flux maximum par exécution : un flux de momentum transversal (`github-trending` ou `trendshift`) et, si utile, un flux ciblé parmi CNCF Landscape/blog, Google Trends, Hacker News, Lobsters ou les topics GitHub Cloud/DevOps/Kubernetes. Alterne le flux ciblé selon les angles sous-représentés récemment. Consigne les flux réellement consultés ; ne prétends pas avoir parcouru les autres.
3. **Qualification.** Un flux de tendance propose seulement un candidat. Avant publication, ouvre sa source canonique : dépôt, release, changelog, advisory, documentation ou page fournisseur précise. Vérifie date, version, statut, périmètre, impact, inconnues et licence OSS. Une preuve primaire suffit ; une seconde preuve seulement pour une traction, une contradiction ou un pitch détaillé.

Réutilise une page pour plusieurs voies lorsqu’elle les couvre réellement, n’ouvre aucune URL deux fois et arrête une piste dès qu’elle est dupliquée, hors périmètre ou non vérifiable. Pour un flux RSS ou Atom enregistré, utilise si possible `ruby scripts/collect_radar_source.rb --source <id> --date <date> --update-registry` afin d’extraire le delta et de mettre à jour ses curseurs. Préfère un flux officiel à une page équivalente lourde. Reste normalement sous le budget d’appels défini par le contrat ; une lacune devient `Couverture incomplète`, jamais « aucun changement ».

Pendant une exécution orchestrée, émets un message de progression concis au début de chaque phase — échéances, contrôle primaire, découverte, qualification, rédaction et validation — puis un bilan court de la phase. Le runner affiche en continu ces messages et les actions d’outil avec leur durée afin de rendre visibles les lectures coûteuses, répétitions, échecs et pistes abandonnées. N’inclus ni raisonnement interne, ni contenu intégral des sources dans ces messages.

## Sélection

Traite d’abord tous les signaux `new` ou `open` arrivés à échéance, puis applique l’algorithme `Scanner → Filtrer → Vérifier → Publier` du contrat.

Pour chaque candidat, renseigne le manifest structuré du contrat et exige successivement :

1. un changement nouveau ou substantiel dans la fenêtre locale de 90 jours, ou une première découverte locale pertinente ;
2. un impact plausible sur architecture, sécurité, exploitation, coût ou lifecycle ;
3. une preuve primaire précise.

Classe sans score agrégé avec `impact_architectural`, `urgence`, `pertinence_stack` et `confiance`. Le script applique l’éligibilité et l’ordre total du contrat ; ne préclasse pas manuellement les candidats. Une `identity_key` désigne le sujet indépendamment de son URL. Réutilise l’identité existante pour une évolution du même sujet ; une telle réapparition doit être une `Mise à jour` substantielle.

Publie normalement 5 à 7 sujets, au plus 10 sauf alerte critique. Un cycle calme peut en publier 0 à 4 si la couverture et la découverte ont réellement été faites. Vise 12 à 20 candidats ; si les flux en fournissent moins, examine-les tous et indique le rendement et sa cause dans `Sujets écartés`.

Au moins 33 % des sujets retenus sont de nouveaux projets OSS, arrondi au supérieur. Ne force jamais un sujet faible pour atteindre ce quota et ne masque jamais un risque, une dépréciation ou une évolution AWS/GCP/IA importante : documente alors `Exception quota OSS : <motif>`. Une réapparition dans les 90 jours exige un changement substantiel vérifié et porte le type `Mise à jour`.

## Livrable concis

Écris uniquement `dist/AAAA-MM-JJ/radar-architecture.md` et les mises à jour locales exigées par `AGENTS.md`. Le rapport commence par :

1. un titre, immédiatement suivi de `<!-- watchtower:2 -->` ;
2. la ligne de tokens du contrat (`non disponible` provisoirement en mode `watchtower:orchestrated`) ;
3. `## Vue d’ensemble`, avec exactement `Outil | Type | Pitch rapide | Lien vers la section`.

Chaque fiche a pour titre `## [Nom](URL canonique)` et contient uniquement :

- `**Pitch rapide :**` une ou deux phrases distinguant `Fait`, `Analyse` ou `Inférence` ;
- `**Utilité :**` un paragraphe concis sur l’impact, les limites, la maturité, le niveau `signal faible` ou `traction étayée`, et l’exposition locale (`à qualifier` si inconnue) ;
- `**Repères de comparaison :**` facultatif, trois alternatives maximum.

Le type de la vue d’ensemble vaut exactement `<nature> · <nouveauté>`, avec les valeurs autorisées par le contrat. Ajoute `### Pitch détaillé` à trois sujets maximum, uniquement si une conséquence transverse ou une seconde preuve le justifie ; reste bref et ne donne pas de procédure de déploiement.

Termine exactement par `## Sujets écartés`, `## Sources consultées` et `## Sources en échec`. Dans `Sources consultées`, fournis les preuves primaires datées et l’unique bloc `watchtower-couverture` complet. Dans `Sources en échec`, indique période manquante et conséquence ; écris `Aucune.` si nécessaire.

Mets à jour `state/sources.yaml`, `state/signals.yaml`, `state/feedback.yaml` et le manifest `state/radar-runs/AAAA-MM-JJ.yaml` seulement selon les faits de l’exécution, puis `docs/catalogue.md`, `docs/rapports.md` et la navigation récente de `README.md`. Chaque nouveau signal reprend l’`identity_key` du candidat correspondant. Exécute une seule fois `ruby scripts/validate_watchtower.rb --report <livrable>`. Un échec interdit le commit. En mode orchestré, ne committe pas ; sinon, calcule d’abord la sélection avec `ruby scripts/select_radar_candidates.rb --manifest <manifest>` puis committe localement après validation. N’utilise aucun connecteur externe.
