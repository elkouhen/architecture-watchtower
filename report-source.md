# Revue des démarches de veille du dépôt

**Date :** 27 août 2026  
**Portée :** les trois démarches documentées dans ce dépôt — sentinelle quotidienne, radar hebdomadaire et revue mensuelle — ainsi que leur articulation avec les sources et les livrables. La lecture manuelle, l’agrégation automatisée et le radar collaboratif sont évalués comme capacités transverses, pas comme processus séparés du dépôt.

## Conclusion

Les trois démarches sont complémentaires, mais leur articulation doit être rendue vérifiable. La correction prioritaire est une boucle en trois couches : collecte ciblée, revue humaine courte, puis décision fondée sur des critères et une preuve d’usage. Le registre d’état, les livrables sous `dist/` et le journal de décisions deviennent la source de vérité ; les commits Git locaux servent de preuve de livraison.

## Démarche 1 — Veille manuelle, au fil de la lecture

**Atouts.** Très bonne compréhension du contexte ; facile à démarrer ; permet de détecter les signaux faibles et les avis nuancés.

**Limites.** Couverture dépendante des personnes ; absence fréquente de trace de décision ; biais de disponibilité et difficulté à distinguer une nouveauté intéressante d’un choix mûr. Le Technology Radar de Thoughtworks rappelle explicitement qu’un radar d’expérience n’est pas une analyse exhaustive du marché.

**Corrections.** Définir 5 à 10 thèmes stables et, pour chaque source, la question à laquelle elle répond. Consigner chaque signal dans une fiche courte : fait observé, source primaire, impact potentiel, niveau de confiance, propriétaire et prochaine revue. Réserver une session de 30 minutes hebdomadaire, puis supprimer les sources qui n’ont produit aucun signal utile après deux cycles.

## Démarche 2 — Alertes, RSS et agrégation automatisés

**Atouts.** Couverture continue, répétable et rapide pour les événements objectifs : versions, CVE, dépréciations, changements de licence et publications de fournisseurs.

**Limites.** Le bruit peut dépasser la valeur ; les alertes ne constituent pas une évaluation ; toute détection est partielle. GitHub indique notamment que les alertes Dependabot ne détectent pas tous les problèmes et que les avis peuvent apparaître avec délai.

**Corrections.** Séparer les flux « action immédiate » (sécurité et dépréciations) des flux « découverte ». Pour les premiers, définir une astreinte ou un responsable, un SLA et une règle d’escalade. Pour les seconds, remettre les éléments dans une revue hebdomadaire plutôt qu’en notification instantanée. Conserver une justification lorsqu’une alerte est fermée ou ignorée : GitHub permet un motif et un commentaire de rejet, utile pour l’audit. Mesurer le taux d’alertes traitées et la part écartée pour réduire le bruit.

## Démarche 3 — Veille structurée et collaborative (radar / comité)

**Atouts.** Rend les choix lisibles, distribue l’expertise, et relie la veille à l’architecture et aux expérimentations. Thoughtworks structure cette démarche par domaines et par statuts : Hold, Assess, Trial, Adopt ; le passage à Trial exige de l’expérience réelle en production dans sa méthode.

**Limites.** Peut devenir trop lourd, consensuel ou déconnecté du terrain si le comité ne reçoit que des présentations. Un radar est une opinion contextualisée, non une cartographie exhaustive.

**Corrections.** Tenir un comité trimestriel de 60 à 90 minutes avec un champion par sujet, une preuve sourcée et un décisionnaire. Fixer des critères de passage : problème métier ciblé, maturité, sécurité/licence, coût d’exploitation, compétences, réversibilité et résultat d’un prototype ou usage réel. Chaque entrée doit produire une phrase de recommandation, une date de réexamen et un propriétaire. Faire expirer les sujets immobiles afin de garder le radar lisible.

## Modèle cible et plan d’adoption (30 jours)

1. **Semaine 1 — Cadrer.** Choisir les thèmes, les sources primaires, les responsables et la taxonomie : sécurité, plateformes, langages/frameworks, pratiques, données/IA.
2. **Semaine 2 — Automatiser le factuel.** Activer les flux d’avis adaptés au portefeuille, notamment les alertes de dépendances ; définir triage, SLA et archivage.
3. **Semaine 3 — Curater.** Publier un digest hebdomadaire : 3 à 5 signaux, ce qui change, l’impact possible et l’action proposée.
4. **Semaine 4 — Décider.** Première revue de radar : conserver, explorer, expérimenter, adopter ou éviter. Inscrire les décisions dans le journal d’architecture ou un registre équivalent.

## Indicateurs de qualité

- Part des alertes critiques triées dans le SLA ;
- ratio signal utile / éléments collectés ;
- délai entre un signal et une décision ;
- nombre de décisions avec source primaire et propriétaire ;
- résultats des expérimentations (succès, abandon justifié, adoption).

## Limites

Les responsables opérationnels et la stack réellement déployée ne sont pas accessibles dans ce dépôt. Les owners, seuils et SLA restent donc à confirmer ; les consignes doivent conserver une valeur par défaut explicite (`exposition inconnue`, `à qualifier`) plutôt que de présenter une hypothèse comme un fait.

## Sources

- Thoughtworks, « FAQ — Technology Radar », consulté le 27 août 2026, https://www.thoughtworks.com/radar/faq
- Thoughtworks, « How to create your enterprise technology radar », 2024, https://www.thoughtworks.com/insights/blog/technology-strategy/how-to-create-your-enterprise-technology-radar
- GitHub Docs, « Dependabot alerts », consulté le 27 août 2026, https://docs.github.com/en/code-security/concepts/supply-chain-security/dependabot-alerts
- GitHub Docs, « Viewing and updating Dependabot alerts », consulté le 27 août 2026, https://docs.github.com/en/code-security/how-tos/manage-security-alerts/manage-dependabot-alerts/view-dependabot-alerts
- OWASP, « DevSecOps Guideline — Software Composition Analysis », consulté le 27 août 2026, https://owasp.org/www-project-devsecops-guideline/latest/02d-Software-Composition-Analysis
- CISA, « Reducing the Significant Risk of Known Exploited Vulnerabilities », 2021, https://www.cisa.gov/sites/default/files/publications/Reducing_the_Significant_Risk_of_Known_Exploited_Vulnerabilities_20211103.pdf
