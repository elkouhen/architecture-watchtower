# Revue des démarches de veille et correction pédagogique

**Date :** 27 août 2026  
**Portée :** les quatre démarches documentées dans ce dépôt — sentinelle quotidienne, carte quotidienne, radar hebdomadaire et revue mensuelle — ainsi que leur articulation avec les sources, les laboratoires et les livrables.

## Conclusion

Les démarches sont complémentaires, mais l’ancien fonctionnement privilégiait la collecte et le tri au détriment de l’apprentissage. La correction est une boucle en quatre couches : détecter l’urgence, construire une carte pédagogique, pratiquer par un laboratoire, puis décider et réviser. La veille ne doit pas seulement dire ce qui change ; elle doit expliquer comment utiliser et déployer les produits.

La source de vérité est locale : `state/signals.yaml` pour les signaux, `state/learning.yaml` pour la progression, `dist/` pour les cartes et rapports, et Git pour l’historique. Les commits locaux prouvent les livraisons.

## Démarche 1 — Veille manuelle, au fil de la lecture

**Atouts.** Très bonne compréhension du contexte ; facile à démarrer ; permet de détecter les signaux faibles et les avis nuancés.

**Limites.** Couverture dépendante des personnes ; absence fréquente de trace de décision ; biais de disponibilité et difficulté à distinguer une nouveauté intéressante d’un choix mûr. Le Technology Radar de Thoughtworks rappelle explicitement qu’un radar d’expérience n’est pas une analyse exhaustive du marché.

**Corrections.** Définir des produits fondamentaux et des produits en tendance. Pour chaque produit, répondre à une question d’architecte : quel problème résout-il, comment le déployer, comment l’exploiter et quand l’éviter ? Consigner le niveau de compréhension, le laboratoire et la lacune suivante dans `state/learning.yaml`. Supprimer les sources qui n’alimentent ni une alerte, ni une carte, ni un laboratoire après deux cycles.

## Démarche 2 — Alertes, RSS et agrégation automatisés

**Atouts.** Couverture continue, répétable et rapide pour les événements objectifs : versions, CVE, dépréciations, changements de licence et publications de fournisseurs.

**Limites.** Le bruit peut dépasser la valeur ; les alertes ne constituent pas une évaluation ; toute détection est partielle. GitHub indique notamment que les alertes Dependabot ne détectent pas tous les problèmes et que les avis peuvent apparaître avec délai.

**Corrections.** Séparer les flux « action immédiate » (sécurité et dépréciations) des flux « apprentissage ». Pour les premiers, conserver triage, owner et SLA. Pour les seconds, convertir au maximum trois produits par semaine en cartes pédagogiques avec déploiement minimal, déploiement de production, laboratoire et questions de validation. Une alerte n’est pas une leçon ; une release note n’est pas une décision.

## Démarche 3 — Veille structurée et collaborative (radar / comité)

**Atouts.** Rend les choix lisibles, distribue l’expertise, et relie la veille à l’architecture et aux expérimentations. Thoughtworks structure cette démarche par domaines et par statuts : Hold, Assess, Trial, Adopt ; le passage à Trial exige de l’expérience réelle en production dans sa méthode.

**Limites.** Peut devenir trop lourd, consensuel ou déconnecté du terrain si le comité ne reçoit que des présentations. Un radar est une opinion contextualisée, non une cartographie exhaustive.

**Corrections.** Tenir un comité trimestriel de 60 à 90 minutes avec un champion par sujet, une preuve sourcée et un décisionnaire. Fixer des critères de passage : problème métier ciblé, maturité, sécurité/licence, coût d’exploitation, compétences, réversibilité et résultat d’un prototype ou usage réel. Chaque entrée doit produire une phrase de recommandation, une date de réexamen et un propriétaire. Faire expirer les sujets immobiles afin de garder le radar lisible.

## Démarche 4 — Carte de service comme dossier d’apprentissage

**Rôle.** C’est le livrable central pour l’objectif de Mehdi. Elle ne décrit pas seulement l’état d’un service : elle construit un modèle mental et un chemin de pratique.

**Structure corrigée.** Identité et pourquoi maintenant ; capacités ; position dans un système ; flux ; architecture interne ; déploiement local ; déploiement Kubernetes/Cloud/managé ; modèle de données ; sécurité ; exploitation ; coûts et alternatives ; cas d’usage et anti-patterns ; laboratoire de moins d’une heure ; questions d’architecte ; sources.

**Critère de qualité.** À la fin de la lecture, Mehdi doit pouvoir expliquer le service, lancer une instance minimale, réaliser un scénario utile, citer deux risques d’exploitation et justifier quand il ne l’utiliserait pas.

## Modèle cible et plan d’adoption (30 jours)

1. **Semaine 1 — Fondamentaux.** Choisir un produit structurant et produire sa carte globale, son déploiement local et son premier laboratoire.
2. **Semaine 2 — Mise en pratique.** Ajouter un produit complémentaire ; comparer modes de déploiement, sécurité, données et exploitation.
3. **Semaine 3 — Tendance.** Étudier un produit émergent avec hypothèse, limites, alternative et expérience bornée ; ne pas le considérer comme standard.
4. **Semaine 4 — Consolidation.** Refaire les laboratoires, répondre aux questions d’architecte, mettre à jour `state/learning.yaml` et décider : approfondir, tester, adopter, attendre ou éviter.

## Indicateurs de qualité

- Part des alertes critiques triées dans le SLA ;
- ratio signal utile / éléments collectés ;
- délai entre un signal et une décision ;
- nombre de décisions avec source primaire et propriétaire ;
- résultats des expérimentations (succès, abandon justifié, adoption).
- progression par produit : découverte → compréhension → pratique → transmissible ;
- part des cartes contenant un déploiement reproductible et un laboratoire réussi ;
- délai entre découverte d’un produit et première expérience pratique.

## Limites

Les responsables opérationnels et la stack réellement déployée ne sont pas accessibles dans ce dépôt. Les owners, seuils et SLA restent donc à confirmer ; les consignes doivent conserver une valeur par défaut explicite (`exposition inconnue`, `à qualifier`) plutôt que de présenter une hypothèse comme un fait.

## Sources

- Thoughtworks, « FAQ — Technology Radar », consulté le 27 août 2026, https://www.thoughtworks.com/radar/faq
- Thoughtworks, « How to create your enterprise technology radar », 2024, https://www.thoughtworks.com/insights/blog/technology-strategy/how-to-create-your-enterprise-technology-radar
- GitHub Docs, « Dependabot alerts », consulté le 27 août 2026, https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-alerts
- GitHub Docs, « Viewing and updating Dependabot alerts », consulté le 27 août 2026, https://docs.github.com/en/code-security/how-tos/manage-security-alerts/manage-dependabot-alerts/view-dependabot-alerts
- OWASP, « DevSecOps Guideline — Software Composition Analysis », consulté le 27 août 2026, https://owasp.org/www-project-devsecops-guideline/latest/02d-Software-Composition-Analysis
- CISA, « Reducing the Significant Risk of Known Exploited Vulnerabilities », 2021, https://www.cisa.gov/sites/default/files/publications/Reducing_the_Significant_Risk_of_Known_Exploited_Vulnerabilities_20211103.pdf
