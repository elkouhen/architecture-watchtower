# REVUE DES PROCESSUS DE VEILLE — 2026-08-27

## OBJECTIF RECADRÉ
L’objectif principal n’est pas de collecter le plus de nouveautés possible. Il est de construire une compréhension d’architecte de produits fondamentaux ou en tendance : pourquoi ils existent, comment les utiliser, comment les déployer, comment les exploiter et dans quels cas les éviter.

## DIAGNOSTIC
1. La sentinelle est correctement spécialisée dans l’urgence, mais elle ne doit pas devenir un flux d’apprentissage. Elle doit seulement protéger le temps d’étude en isolant les vulnérabilités, breaking changes, fins de support et échéances urgentes.
2. Le radar était principalement un digest de nouveautés et de décisions. Il manquait une sélection explicite de produits à apprendre et une expérience pratique associée.
3. La carte de service décrivait correctement l’architecture globale, mais son format n’imposait pas assez clairement un déploiement reproductible, un chemin d’utilisation et une validation de compréhension.
4. La revue mensuelle synthétisait les décisions, mais ne mesurait pas la progression réelle : concepts acquis, laboratoires réalisés, lacunes et prochaine étape.

## CORRECTIONS APPLIQUÉES
- `carte-service.md` est maintenant un dossier d’apprentissage : modèle mental, positionnement, capacités, flux, architecture, déploiement local et production, exploitation, sécurité, alternatives, anti-patterns, laboratoire et questions d’architecte.
- `radar-architecture.md` doit retenir au maximum trois sujets d’apprentissage approfondi : un fondamental, un produit en évolution et un sujet émergent si pertinent.
- `revue-architecture.md` doit produire une matrice de progression avec les niveaux découverte, compréhension, pratique et transmissible.
- `sentinelle-devops.md` reste focalisée sur l’attention urgente et renvoie les sujets de découverte vers le radar ou les cartes.
- `state/learning.yaml` devient le registre local de progression pédagogique.
- La déduplication reste exclusivement locale avec `state/`, `dist/` et l’historique Git.

## PROCESSUS CIBLE
Détection urgente → sélection d’un produit → carte globale → laboratoire guidé → restitution par questions → décision et prochaine lacune → révision mensuelle.

## FORMAT D’UNE CARTE RÉUSSIE
À la fin de la carte, Mehdi doit pouvoir expliquer le produit, lancer une instance minimale, réaliser un scénario utile, décrire son architecture de production, citer deux modes de panne et justifier quand il ne l’utiliserait pas.

## CADENCE PROPOSÉE
- Quotidien : une carte d’un produit fondamental, en tendance ou faisant le lien entre deux sujets ; pas de carte pour chaque actualité.
- Hebdomadaire : sélection de trois apprentissages prioritaires et comparaison des options.
- Mensuel : consolidation des laboratoires, mesure de progression et sélection des trois produits suivants.
- À tout moment : sentinelle pour les urgences uniquement.

## INDICATEURS
- part des cartes avec un déploiement local reproductible ;
- part des laboratoires terminés avec succès ;
- progression par produit ;
- délai entre découverte et première pratique ;
- nombre de décisions fondées sur une expérience plutôt que sur une annonce.

## CONCLUSION
Le dépôt devient un carnet d’apprentissage architectural versionné : les sources alimentent la sélection, les cartes construisent la compréhension, les laboratoires apportent la preuve pratique et les commits conservent la progression.

Statut : corrections appliquées ; publication à valider par commit local.
