# Guide agents — veille Cloud, DevOps et architecture

## Objet du dépôt

Ce dépôt contient désormais deux démarches actives en français pour Mehdi :

- `radar-architecture.md` : radar Cloud, DevOps, architecture applicative et IA ;
- `carte-service.md` : carte détaillée d’un service ciblé.

Les anciennes sentinelles et revues mensuelles sous `dist/` sont conservées uniquement comme historique ; elles ne doivent plus être exécutées ni régénérées.

L’objectif n’est pas seulement de surveiller l’actualité : il est de construire une compréhension d’architecte des produits connus ou en tendance, avec un chemin concret d’usage, de déploiement et d’exploitation.

Les livrables actifs sont des fichiers Markdown sous `dist/YYYY-MM-DD/`. Chaque exécution produit uniquement le livrable demandé : un radar ou une carte de service.

- `radar-architecture.md` ;
- `carte-<service>.md` (une carte par service exécuté).

Le registre pédagogique `state/learning.yaml` suit les produits étudiés, leur niveau de compréhension et le prochain laboratoire à réaliser.
L’index transversal `README.md` classe par thème les outils et patterns analysés et fournit les liens vers leurs radars ou cartes de services.

## Exécution d’une veille

**Règle de synchronisation des prompts :** lorsqu’une consigne utilisateur modifie le contenu, le format, le périmètre, les sources ou le comportement attendu d’un type de revue, mettre à jour en premier le prompt associé (`radar-architecture.md` pour un radar, `carte-service.md` pour une carte), puis appliquer cette règle au livrable. Ne jamais modifier durablement un rapport sans synchroniser son prompt source.

1. Lire la consigne source concernée avant de lancer la recherche.
2. Dédupliquer exclusivement avec les documents locaux : `state/signals.yaml` (signaux), `state/learning.yaml` (progression), les livrables précédents sous `dist/` et les journaux de décisions locaux. Utiliser 90 jours pour le radar et 30 jours pour les cartes.
3. Prioriser les sources primaires : bulletins de sécurité, changelogs, release notes, dépôts et documentation des fournisseurs/projets.
4. Ne présenter comme fait que les informations vérifiées. Distinguer explicitement `Fait`, `Analyse`, `Inférence` et `Décision` lorsque ces éléments sont utilisés.
5. Pour chaque recommandation, indiquer un propriétaire, une échéance ou date de réexamen, et un critère de succès lorsqu’un test est proposé.
6. Pour chaque signal, conserver au minimum : identifiant stable, URL canonique, produit/version, environnement, première et dernière observation, score, confiance, statut, décision, propriétaire, échéance et livrables associés.
7. Écrire le résultat dans le répertoire `dist/<date_du_jour>/` sans écraser un livrable d’une autre date, avec l’extension `.md`.
8. Vérifier le fichier produit : non vide, sources primaires présentes, sections obligatoires complètes et dates cohérentes avec la cadence. Ne produire que le radar demandé ou la carte de service demandée.
9. Mettre à jour `README.md` lorsqu’un outil ou pattern est analysé ; conserver une entrée canonique par outil et ajouter le lien vers le nouveau livrable.

Pour une carte de service, appliquer `carte-service.md`, produire uniquement le ou les services demandés dans `dist/<date_du_jour>/`, et ne pas régénérer les autres veilles. Une carte doit d’abord enseigner le produit — modèle mental, usages, déploiement et exploitation — puis distinguer l’état documenté du produit de l’état réellement observé dans la stack ; si ce dernier est inconnu, écrire `à qualifier` ou `exposition inconnue`.

## Règles de contenu

- Éviter le marketing, les benchmarks non reproductibles et les annonces non corroborées.
- Une alerte automatisée ne prouve pas l’exposition : qualifier produit, version, environnement et correctif avant de recommander une action.
- Ne pas répéter un sujet déjà signalé, sauf changement substantiel de statut, risque, échéance ou recommandation ; l’indiquer alors comme `Mise à jour`.
- Retirer du radar les sujets sans évolution pendant deux cycles, sauf risque, échéance ou action active.
- Les fonctions Preview, beta ou en disponibilité limitée ne doivent pas porter seules un contrôle de production critique ; prévoir une solution de repli.

## Publication locale

Les rapports sont publiés exclusivement dans `dist/` et doivent être commités localement après validation. Aucun connecteur de messagerie externe ne doit être utilisé pour les rapports. La preuve de publication est le commit Git local contenant le livrable ; ne pas écrire « publié » avant que ce commit existe.
