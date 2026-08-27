# Guide agents — veille Cloud, DevOps et architecture

## Objet du dépôt

Ce dépôt contient les consignes et les résultats de trois veilles en français pour Mehdi :

- `sentinelle-devops.md` : détection quotidienne des signaux urgents ;
- `radar-architecture.md` : radar hebdomadaire Cloud, DevOps, architecture applicative et IA ;
- `revue-architecture.md` : revue mensuelle stratégique.
- `carte-service.md` : carte quotidienne détaillée d’un service ciblé.

Les livrables sont des fichiers texte sous `dist/YYYY-MM-DD/`. Chaque cadence produit son propre fichier ; une exécution quotidienne ne doit pas fabriquer un radar hebdomadaire ou une revue mensuelle.

- `sentinelle-devops.txt` ;
- `radar-architecture.txt` ;
- `revue-architecture.txt`.
- `carte-<service>.txt` (une carte par service exécuté).

## Exécution d’une veille

1. Lire la consigne source concernée avant de lancer la recherche.
2. Dédupliquer exclusivement avec les documents locaux : `state/signals.yaml` (source d’autorité), les livrables précédents sous `dist/` et les journaux de décisions locaux. Utiliser 90 jours pour la sentinelle et le radar, et 6 mois pour la revue mensuelle.
3. Prioriser les sources primaires : bulletins de sécurité, changelogs, release notes, dépôts et documentation des fournisseurs/projets.
4. Ne présenter comme fait que les informations vérifiées. Distinguer explicitement `Fait`, `Analyse`, `Inférence` et `Décision` lorsque ces éléments sont utilisés.
5. Pour chaque recommandation, indiquer un propriétaire, une échéance ou date de réexamen, et un critère de succès lorsqu’un test est proposé.
6. Pour chaque signal, conserver au minimum : identifiant stable, URL canonique, produit/version, environnement, première et dernière observation, score, confiance, statut, décision, propriétaire, échéance et livrables associés.
7. Écrire le résultat dans le répertoire `dist/<date_du_jour>/` sans écraser un livrable d’une autre date.
8. Vérifier le fichier produit : non vide, sources primaires présentes, sections obligatoires complètes et dates cohérentes avec la cadence. Les trois fichiers ne sont requis que lorsqu’une exécution planifiée des trois cadences a effectivement eu lieu.

Pour une carte de service, appliquer `carte-service.md`, produire uniquement le ou les services demandés dans `dist/<date_du_jour>/`, et ne pas régénérer les veilles quotidiennes, hebdomadaires ou mensuelles. Une carte doit distinguer l’état documenté du produit de l’état réellement observé dans la stack ; si ce dernier est inconnu, écrire `à qualifier` ou `exposition inconnue`.

## Règles de contenu

- Éviter le marketing, les benchmarks non reproductibles et les annonces non corroborées.
- Une alerte automatisée ne prouve pas l’exposition : qualifier produit, version, environnement et correctif avant de recommander une action.
- Ne pas répéter un sujet déjà signalé, sauf changement substantiel de statut, risque, échéance ou recommandation ; l’indiquer alors comme `Mise à jour`.
- Retirer du radar les sujets sans évolution pendant deux cycles, sauf risque, échéance ou action active.
- Les fonctions Preview, beta ou en disponibilité limitée ne doivent pas porter seules un contrôle de production critique ; prévoir une solution de repli.

## Publication locale

Les rapports sont publiés exclusivement dans `dist/` et doivent être commités localement après validation. Aucun connecteur de messagerie externe ne doit être utilisé pour les rapports. La preuve de publication est le commit Git local contenant le livrable ; ne pas écrire « publié » avant que ce commit existe.
