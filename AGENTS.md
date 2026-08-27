# Guide agents — veille Cloud, DevOps et architecture

## Objet du dépôt

Ce dépôt contient les consignes et les résultats de trois veilles en français pour Mehdi :

- `sentinelle-devops.md` : détection quotidienne des signaux urgents ;
- `radar-architecture.md` : radar hebdomadaire Cloud, DevOps, architecture applicative et IA ;
- `revue-architecture.md` : revue mensuelle stratégique.

Les livrables sont des fichiers texte sous `dist/YYYY-MM-DD/` :

- `sentinelle-devops.txt` ;
- `radar-architecture.txt` ;
- `revue-architecture.txt`.

## Exécution d’une veille

1. Lire la consigne source concernée avant de lancer la recherche.
2. Dédupliquer avec les emails envoyés à `mehdi.elkouhen@gmail.com` :
   - 90 jours pour la sentinelle et le radar ;
   - 6 mois pour la revue mensuelle.
3. Prioriser les sources primaires : bulletins de sécurité, changelogs, release notes, dépôts et documentation des fournisseurs/projets.
4. Ne présenter comme fait que les informations vérifiées. Distinguer explicitement `Fait`, `Analyse`, `Inférence` et `Décision` lorsque ces éléments sont utilisés.
5. Pour chaque recommandation, indiquer un propriétaire, une échéance ou date de réexamen, et un critère de succès lorsqu’un test est proposé.
6. Écrire le résultat dans le répertoire `dist/<date_du_jour>/` sans écraser un livrable d’une autre date.
7. Vérifier que les trois fichiers existent, sont non vides et comportent des sources pour les faits matériels.

## Règles de contenu

- Éviter le marketing, les benchmarks non reproductibles et les annonces non corroborées.
- Une alerte automatisée ne prouve pas l’exposition : qualifier produit, version, environnement et correctif avant de recommander une action.
- Ne pas répéter un sujet déjà signalé, sauf changement substantiel de statut, risque, échéance ou recommandation ; l’indiquer alors comme `Mise à jour`.
- Retirer du radar les sujets sans évolution pendant deux cycles, sauf risque, échéance ou action active.
- Les fonctions Preview, beta ou en disponibilité limitée ne doivent pas porter seules un contrôle de production critique ; prévoir une solution de repli.

## Envoi d’emails

Les emails sont une action externe. Ne les envoyer que si l’utilisateur le demande explicitement dans la conversation en cours ou si une tâche planifiée le demande explicitement.

Objets attendus :

- `Alerte DevOps — AAAA-MM-JJ` ;
- `Radar Architecture — AAAA-MM-JJ` ;
- `Revue Architecture — AAAA-MM`.

Avant l’envoi, vérifier que le contenu transmis correspond exactement au livrable de `dist` et ne contient pas d’affirmation non sourcée.
