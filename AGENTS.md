# Guide agents — veille Cloud, DevOps et architecture

## Objet du dépôt

Ce dépôt contient trois démarches actives en français pour l'utilisateur :

- `radar-architecture.md` : radar Cloud, DevOps, architecture applicative et IA ;
- `carte-service.md` : carte détaillée d’un service ciblé ;
- `classement-mensuel.md` : revue rétrospective et classement mensuel des technologies observées dans les radars, cartes et signaux locaux.

Les anciennes sentinelles et les anciennes revues remplacées sont conservées uniquement comme historique ; elles ne doivent plus être exécutées ni régénérées. Cette restriction ne concerne pas le classement mensuel défini par `classement-mensuel.md`.

L’objectif n’est pas seulement de surveiller l’actualité : il est de construire une compréhension d’architecte des produits connus ou en tendance, avec un chemin concret d’usage, de déploiement et d’exploitation.

Les livrables actifs sont des fichiers Markdown sous `dist/YYYY-MM-DD/`. Chaque exécution produit uniquement le type de livrable demandé : radar, carte de service ou classement mensuel.

- `radar-architecture.md` ;
- `carte-<service>.md` (une carte par service exécuté) ;
- `classement-mensuel-AAAA-MM.md` (mois couvert, distinct de la date de production).

Le registre pédagogique `state/learning.yaml` suit les produits étudiés, leur niveau de compréhension et les prochaines étapes d’apprentissage. Aucun POC ou laboratoire n’est planifié sans demande explicite de l'utilisateur.
L’index transversal `docs/catalogue.md` classe par thème les outils et patterns analysés et fournit les liens vers leurs radars, cartes de services ou classements mensuels. `docs/rapports.md` indexe les livrables par date et `README.md` sert de page de navigation.

## Clarté des demandes

Ne pas démarrer une tâche lorsque la demande, son périmètre ou le résultat attendu ne semble pas suffisamment clair. Dans ce cas, s’arrêter avant toute modification ou recherche et poser à l'utilisateur les questions nécessaires pour préciser l’objectif, les fichiers concernés, les contraintes et le niveau de résultat attendu. Ne reprendre l’exécution qu’après clarification.

## Exécution d’une veille

**Règle de synchronisation des prompts :** lorsqu’une consigne utilisateur modifie le contenu, le format, le périmètre, les sources ou le comportement attendu d’un type de revue, mettre à jour en premier le prompt associé (`radar-architecture.md` pour un radar, `carte-service.md` pour une carte, `classement-mensuel.md` pour le classement mensuel), puis appliquer cette règle au livrable. Ne jamais modifier durablement un rapport sans synchroniser son prompt source.

1. Lire la consigne source concernée et `docs/contrats-veille.md` avant de lancer la recherche. Utiliser le contrat version 2 pour tout nouveau rapport ; conserver le contrat historique des archives non corrigées.
2. Dédupliquer exclusivement avec les documents locaux : `state/signals.yaml` (signaux), `state/learning.yaml` (progression), les livrables précédents sous `dist/` et les journaux de décisions locaux. Utiliser 90 jours pour le radar et 30 jours pour les cartes. Pour le classement mensuel, regrouper par technologie les observations du mois calendaire précédent ; leur présence dans un radar ou une carte est un critère d’inclusion, pas d’exclusion.
3. Pour un radar, contrôler obligatoirement AWS, GCP et IA sur les voies releases/fonctionnalités, sécurité, lifecycle/dépréciations et disponibilité/régions/quotas/coûts. Prioriser les sources primaires : bulletins de sécurité, changelogs, release notes, dépôts et documentation des fournisseurs/projets.
4. Ne présenter comme fait que les informations vérifiées. Distinguer explicitement `Fait`, `Analyse`, `Inférence` et `Décision` lorsque ces éléments sont utilisés.
5. Pour chaque recommandation opérationnelle, indiquer un propriétaire, une échéance ou date de réexamen, et un critère de succès lorsqu’un test est demandé. Les classes descriptives du classement mensuel ne déclenchent ni POC, ni laboratoire, ni nouvelle échéance sans demande explicite de l'utilisateur.
6. Pour chaque signal créé à partir du 3 septembre 2026, conserver au minimum : identifiant stable, URL canonique, produit/version, environnement, première et dernière observation, notes `impact_architectural`, `urgence`, `pertinence_stack` et `confiance` de 1 à 5, statut, décision, propriétaire, échéance et livrables associés. Pour les nouveaux signaux, justifier les notes dans `scoring_note` ; seule la pertinence peut rester `inconnu` avec motif selon le contrat commun. Une évolution du même sujet met à jour l’entrée existante et son historique.
7. Écrire le résultat dans le répertoire `dist/<date_du_jour>/` sans écraser un livrable d’une autre date, avec l’extension `.md`.
8. Avant toute nouvelle sélection de veille, traiter les signaux `new` ou `open` dont l’échéance est atteinte. Les fermer, les différer, les écarter ou maintenir leur ouverture avec un motif, `last_reviewed` et une nouvelle échéance. Le classement mensuel est une synthèse rétrospective : il ne réécrit pas l’historique des signaux et ne crée pas de signal uniquement pour le classement.
9. Vérifier le fichier produit : non vide, sources primaires présentes, sections obligatoires du prompt concerné complètes et dates cohérentes. Pour le radar uniquement, vérifier les douze voies AWS/GCP/IA (ou la déclaration précise de couverture incomplète) et le quota de 33 % de nouveaux projets open source ou son exception motivée. Pour le classement mensuel, vérifier la période, l’exhaustivité du corpus retenu, l’unicité des technologies, les preuves des tendances et les motifs des sujets non classés. Exécuter `ruby scripts/validate_watchtower.rb --report <livrable>` ; un échec interdit le commit. La validation structurelle ne remplace pas la vérification éditoriale des preuves. Ne produire que le livrable demandé.
10. Mettre à jour `docs/catalogue.md` lorsqu’un outil ou pattern est analysé, ajouter le livrable à `docs/rapports.md` et conserver `README.md` comme navigation vers les livrables récents.

Pour une carte de service, appliquer `carte-service.md`, produire uniquement le ou les services demandés dans `dist/<date_du_jour>/`, et ne pas régénérer les autres veilles. Une carte doit d’abord enseigner le produit — modèle mental, usages, déploiement et exploitation — puis distinguer l’état documenté du produit de l’état réellement observé dans la stack ; si ce dernier est inconnu, écrire `à qualifier` ou `exposition inconnue`.

Pour le classement mensuel, appliquer `classement-mensuel.md` une seule fois par mois après clôture du mois précédent. Produire uniquement `dist/<date_du_jour>/classement-mensuel-AAAA-MM.md`. Le classement principal privilégie la nouveauté et l’intérêt architectural ; les simples correctifs CVE et actions de maintenance restent dans les sujets non classés, sauf rupture architecturale. Présenter les tendances transverses et les mouvements par rapport au classement précédent, en conservant les scores manquants comme `inconnus`. Ne pas régénérer de radar ou de carte à cette occasion.

## Règles de contenu

- Éviter le marketing, les benchmarks non reproductibles et les annonces non corroborées.
- Une alerte automatisée ne prouve pas l’exposition : qualifier produit, version, environnement et correctif avant de recommander une action.
- Dans le radar et les évolutions des cartes, ne pas répéter un sujet déjà signalé, sauf changement substantiel de statut, risque, échéance ou recommandation ; l’indiquer alors comme `Mise à jour`. Le classement mensuel récapitule les observations de sa période sans les présenter comme de nouvelles annonces.
- Retirer du radar les sujets sans évolution pendant deux cycles, sauf risque, échéance ou action active.
- Les fonctions Preview, beta ou en disponibilité limitée ne doivent pas porter seules un contrôle de production critique ; prévoir une solution de repli.
- Le radar vise au moins 33 % de nouveaux projets open source, arrondis à l’entier supérieur. Ce quota ne doit jamais masquer une vulnérabilité, un incident, une dépréciation, un changement incompatible ou une évolution AWS/GCP/IA à fort impact ; les mises à jour de produits connus ne sont pas plafonnées.

## Publication locale

Les rapports sont publiés exclusivement dans `dist/` et doivent être commités localement après validation. Aucun connecteur de messagerie externe ne doit être utilisé pour les rapports. La preuve de publication est le commit Git local contenant le livrable ; ne pas écrire « publié » avant que ce commit existe.
