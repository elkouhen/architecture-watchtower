# Prompt — radar d’architecture

Produis en français le radar hebdomadaire Cloud, Kubernetes, DevOps et IA de l’utilisateur. Le contrat `docs/contrats-veille.md` fixe les preuves, les notes, le manifest, la couverture et la validation ; en cas de conflit, le contrat et `AGENTS.md` priment. Les scripts collectent, pré-filtrent, sélectionnent, rendent et publient : ton travail est la qualification des deltas puis la prose des seuls sujets retenus.

## But et périmètre

Détecte les changements et tendances capables de modifier une décision d’architecture, de plateforme, d’exploitation, de sécurité, de coût ou de trajectoire technologique. Couvre en priorité :

- AWS et GCP, notamment EKS/GKE, réseau, sécurité, données, observabilité, coûts, quotas et lifecycle ;
- Kubernetes, CNCF, conteneurs, service mesh, Gateway API, GitOps et platform engineering ;
- CI/CD, IaC, supply chain, SRE, OpenTelemetry, Elastic et l’écosystème HashiCorp ;
- IA appliquée aux plateformes : agents, RAG, inference gateways, routage, observabilité et gouvernance.

Écarte marketing, listes sans preuve, benchmarks non reproductibles, clones sans différenciation et annonces sans conséquence architecturale identifiable. Une popularité n’est ni une adoption ni une recommandation. Aucun POC, laboratoire ou nouvelle carte sans demande explicite.

## Déroulement

Le radar est produit une fois par semaine, en quatre phases de `scripts/run_radar.rb` exécutées dans la session :

1. `prepare` : traite les échéances de signaux, collecte chaque source une fois dans `.cache/radar/AAAA-MM-JJ/`, écrit `digest.md` (deltas classés par voie et mots-clés de stack, avec fichier et ligne du cache), pré-remplit le manifest `state/radar-runs/AAAA-MM-JJ.yaml` (rôles des sources, douze voies, échecs et lacunes) et produit `brief-qualification.md`.
2. Qualification par le modèle : lis le brief puis le digest, chacun une seule fois, et complète `candidates` et `candidate_yield_note` du manifest. Puis `select` calcule la sélection et produit `brief-redaction.md`.
3. Rédaction par le modèle : ajoute la prose des candidats sélectionnés dans le manifest.
4. `publish` : rend le rapport et les lignes de catalogue, avance les curseurs de sources, synchronise signaux et index, valide et committe. `replace` rend à nouveau un rapport existant depuis son manifest, sans collecte ni sélection.

Ne relis ni le contrat, ni les registres, ni les livrables sur disque : le brief contient le contexte de déduplication (signaux et sujets des 90 derniers jours, catalogue, retours récents). Annonce chaque phase en une ligne et conclus-la par un bilan court, sans reproduire le contenu des sources.

## Qualification

Lis le digest en entier, une fois. Pour chaque voie AWS, GCP et IA (releases/fonctionnalités, sécurité, lifecycle/dépréciations, disponibilité/régions/quotas/coûts), examine les éléments retenus par mots-clés et parcours les titres seuls ; un titre explicite suffit à ouvrir l’élément. N’ouvre dans le cache que le fichier et les lignes désignés par le digest (`sed -n`, `rg -n`), et sur le web uniquement la page canonique d’un candidat qui franchit les deux premiers filtres, ou une seule fois une source en échec. Budget indicatif : quinze appels d’outil, dont huit lectures web au plus ; un dépassement n’est admis que pour une alerte critique et doit être signalé.

Découverte : le digest liste les dépôts de `github-trending` et `trendshift`. Retiens au plus un candidat OSS par flux et vérifie sa page canonique (licence, activité, périmètre) avant de le qualifier. Ne prétends consulter aucun autre flux.

Applique successivement trois filtres à chaque élément : un changement nouveau ou substantiel dans la fenêtre locale de 90 jours, ou une première découverte pertinente ; un impact plausible sur architecture, sécurité, exploitation, coût ou lifecycle ; une preuve primaire précise (release, changelog, bulletin, documentation ou dépôt). Arrête une piste dès qu’un filtre échoue, qu’elle est dupliquée ou invérifiable.

Renseigne le manifest (schéma 2 du contrat) : fiche compacte pour chaque candidat qui franchit les trois filtres, fiche allégée (identité, nom, URL, `novelty`, `subject`, les trois filtres, `rejection_note`) pour chaque rejet notable. Une fiche compacte porte `identity_key` stable, `nature`, `novelty` et `origin` (`AWS`, `GCP`, `OpenAI`, `Anthropic`, nom du projet…), `subject`, `product_version`, `environment` (`exposition inconnue` par défaut), les quatre notes `impact_architectural`, `urgence`, `pertinence_stack`, `confiance` justifiées dans `scoring_note`, `recency`, `coverage_lanes`, `signal_level`, un `fact` d’une phrase destiné au rapport, `decision`, `owner`, `due_date` (date du radar plus 30 jours pour `monitor`, plus 14 jours pour une action) et une preuve primaire dans `evidence`. Ne rédige ni analyse ni pitch à ce stade : la prose n’est demandée qu’après sélection.

Déduplication : une identité présente dans `recent_signals` ou `recent_report_subjects` n’est éligible qu’avec une évolution substantielle vérifiée de statut, risque, échéance ou recommandation ; elle porte alors `novelty: Mise à jour` et réutilise l’`identity_key` existante. Un simple suivi de signal actif n’est pas une évolution. Ne préclasse pas les candidats : le script applique l’éligibilité, l’ordre total, le quota OSS et la protection des candidats urgents ou de dépréciation. Décris le rendement réel dans `candidate_yield_note`. Si ta lecture contredit une entrée de couverture pré-remplie (voie lue partiellement, source en échec rouverte), corrige `complete` et `note` ; une lacune reste `Couverture incomplète`, jamais « aucun changement ».

## Rédaction

Le brief de rédaction liste les candidats sélectionnés et leurs champs qualifiés. Pour chacun, ajoute dans le manifest :

- `pitch_court` : une phrase pour la vue d’ensemble ;
- `analyse` : une ou deux phrases d’analyse ou d’inférence, nommées comme telles, complétant le `fact` ;
- `utilite` : un paragraphe concis sur l’impact, les limites, la maturité et ce qui reste `à qualifier` localement ;
- `success_criterion` : le critère de succès de la décision ;
- `reperes` (facultatif) : trois alternatives au plus ;
- `pitch_detaille` (facultatif, trois candidats au plus) : une conséquence transverse ou une seconde preuve, sans procédure de déploiement.

Le script compose la fiche (`Fait`, `Analyse`, niveau, exposition, décision, échéance), la vue d’ensemble, les sujets écartés, les sources et le bloc `watchtower-couverture`. Ne modifie aucun autre champ et n’écris pas le rapport toi-même.

## Publication

`publish` écrit `dist/AAAA-MM-JJ/radar-architecture.md`, une ligne de catalogue par sujet retenu, les curseurs de `state/sources.yaml`, un signal par candidat sélectionné (`identity_key` commune), `docs/rapports.md` et la navigation de `README.md`, puis exécute `ruby scripts/validate_watchtower.rb --report <livrable>` et committe localement. Un échec de validation laisse les fichiers en place sans commit : corrige le manifest puis relance `publish` après avoir supprimé le rapport rendu, ou `replace` si seul le rendu change. N’utilise aucun connecteur externe.
