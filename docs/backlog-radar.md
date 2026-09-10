# Backlog — fiabilisation du radar

Objectif : rendre la sélection du radar déterministe et vérifiable. Le modèle qualifie les changements ; les scripts filtrent, classent et valident les sujets avant publication.

Statut : implémenté le 10 septembre 2026. Les collecteurs structurés couvrent RSS et Atom ; les autres formats restent pris en charge par la phase de qualification jusqu’à l’ajout d’un adaptateur dédié.

## P0 — Définir le contrat

### RADAR-01 — Formaliser les règles de sélection

- Décrire l’identité d’un signal, les critères d’éligibilité et l’ordre de priorité.
- Définir précisément les cas `Nouveau projet OSS`, `Nouveau hors OSS` et `Mise à jour`.
- Mettre à jour d’abord `radar-architecture.md` et `docs/contrats-veille.md`.
- **Terminé quand :** chaque candidat peut être accepté, rejeté et ordonné sans règle implicite.

## P1 — Structurer et calculer

### RADAR-02 — Ajouter une identité stable aux signaux

- Ajouter `identity_key` au registre des signaux.
- Dédupliquer par identité et non uniquement par URL canonique.
- Prévoir une migration compatible avec les signaux existants.
- **Terminé quand :** un même sujet conserve son identifiant malgré un changement d’URL, et une page de release notes peut porter plusieurs sujets distincts.

### RADAR-03 — Compléter le contexte préparé

- Inclure les notes, l’environnement, `scoring_note`, l’historique et la dernière revue des signaux récents.
- Inclure les bornes de collecte et les sources de découverte utilisables.
- **Terminé quand :** l’exécution orchestrée n’a plus besoin de relire les registres pour qualifier un candidat.

### RADAR-04 — Créer un manifest de candidats

- Définir un format YAML ou JSON pour les éléments détectés et leur qualification.
- Exiger changement substantiel, impact, preuve primaire, quatre notes, récence et statut OSS.
- **Terminé quand :** tout candidat retenu ou rejeté possède une fiche structurée et un motif vérifiable.

### RADAR-05 — Implémenter le filtre et le classement

- Créer un script qui applique les seuils d’éligibilité.
- Trier dans l’ordre : obligatoire, urgence, impact, pertinence, confiance, récence, identité.
- Appliquer le plafond et le quota OSS sans évincer une alerte critique.
- **Terminé quand :** les mêmes candidats produisent toujours la même sélection dans le même ordre.

## P2 — Automatiser la collecte

### RADAR-06 — Générer le plan des sources

- Transformer les douze voies AWS/GCP/IA en une liste de sources et de périodes à contrôler.
- Mutualiser une source lorsqu’elle couvre réellement plusieurs voies.
- Empêcher l’ouverture répétée d’une même URL pendant une exécution.
- **Terminé quand :** chaque voie possède une source, une borne de reprise et un résultat explicites.

### RADAR-07 — Automatiser les sources structurées

- Ajouter progressivement des collecteurs RSS, Atom ou API pour AWS, GCP, GitHub et les sources compatibles.
- Gérer `last_attempt`, `last_success`, `last_item_seen`, le fallback unique et les périodes manquantes.
- **Terminé quand :** un delta peut être extrait sans intervention du modèle pour les sources prises en charge.

## P3 — Verrouiller la publication

### RADAR-08 — Séparer qualification et rédaction

- Faire produire le manifest au modèle.
- Faire calculer la sélection par le script.
- Autoriser la rédaction uniquement à partir de la sélection verrouillée.
- **Terminé quand :** le modèle ne peut pas ajouter ou retirer silencieusement un sujet pendant la rédaction.

### RADAR-09 — Renforcer le validateur

- Comparer manifest, registre des signaux, journal des sources et rapport.
- Contrôler les seuils, l’ordre, les échéances, les mises à jour substantielles, les licences OSS et le quota.
- Vérifier que les identifiants de sources déclarés existent réellement.
- **Terminé quand :** toute divergence entre collecte, sélection et rapport bloque le commit.

### RADAR-10 — Ajouter les tests de non-régression

- Tester doublon, mise à jour substantielle, alerte critique, confiance faible, cycle calme, quota OSS et source en échec.
- Rejouer plusieurs anciens radars sous forme de fixtures.
- **Terminé quand :** le classement et les rejets attendus sont reproductibles automatiquement.

## Ordre conseillé

`RADAR-01` → `RADAR-02` et `RADAR-03` → `RADAR-04` → `RADAR-05` → `RADAR-06` et `RADAR-07` → `RADAR-08` → `RADAR-09` → `RADAR-10`

Le premier jalon utile est atteint après `RADAR-05` : la collecte peut encore être assistée par le modèle, mais la sélection devient déjà déterministe.
