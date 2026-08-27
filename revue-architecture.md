Produis la revue mensuelle stratégique Cloud, DevOps et architecture de Mehdi.

OBJECTIF
Transformer les signaux des trente derniers jours en décisions d’architecture, de formation et d’expérimentation. La revue doit mesurer ce que Mehdi comprend réellement et définir le prochain parcours d’apprentissage ; ne fais pas une simple compilation des rapports quotidiens et hebdomadaires.

PRINCIPE
La revue mensuelle est l’instance de décision : toute recommandation doit être reliée à un besoin, une preuve primaire et une prochaine action. Distingue sans ambiguïté fait vérifié, analyse, inférence et décision. Une technologie médiatisée mais non contextualisée reste « ÉVALUER ».

ENTRÉES
- lis `state/context.yaml` et évalue les décisions par rapport aux environnements AWS/GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK et Terraform ;
- analyse les rapports et journaux locaux sous `dist/` et `state/` au cours des six derniers mois ;
- utilise les rapports du dernier mois comme registre ;
- vérifie les faits encore déterminants auprès des sources primaires actuelles ;
- identifie les tendances récurrentes, les changements de maturité et les sujets qui ne sont plus pertinents.

PÉRIMÈTRE
GCP, AWS, Kubernetes, IaC/GitOps, CI/CD, sécurité, observabilité/ELK, architecture applicative, open source, services managés, IA générative, agents, MCP, RAG, MLOps et plateforme engineering.

TECHNOLOGY RADAR
Classe chaque technologie, service ou pattern retenu dans une seule catégorie :
- ADOPTER : suffisamment mature et directement utile ;
- TESTER : mérite un PoC court ;
- ÉVALUER : prometteur mais encore incertain ;
- ATTENDRE/ÉVITER : risque, coût, verrouillage ou immaturité excessifs.

CRITÈRES DE PASSAGE
- ÉVALUER : signal crédible et impact potentiel ; une recherche ciblée ou un échange expert est requis ;
- TESTER : problème concret, hypothèse mesurable, propriétaire, environnement isolé et budget/temps bornés ;
- ADOPTER : bénéfice démontré dans un usage comparable, sécurité et exploitation maîtrisées, compétences et coût acceptés ;
- ATTENDRE/ÉVITER : justification explicite, condition de réexamen et date associée.

N’utilise pas « ADOPTER » sans preuve d’usage réel interne ou de retour d’expérience comparable. Un benchmark fournisseur seul ne constitue pas cette preuve.

Pour chaque entrée, donne :
- ce qui a changé ce mois-ci ;
- preuve et lien vers la source primaire ;
- fait vérifié, analyse, inférence et décision, dans des rubriques distinctes ;
- intérêt pour le contexte de Mehdi ;
- option open source ;
- équivalent GCP ;
- équivalent AWS ;
- maturité ;
- risque de verrouillage ;
- coût et charge d’exploitation ;
- décision et prochaine action.
- prévision à 1–3 mois, hypothèse vérifiable, signaux attendus et décision conditionnelle (« si… alors… »).

Ajoute pour chaque entrée un propriétaire, une date de réexamen et, pour TESTER, un critère de succès et une limite de durée.
Une entrée sans source primaire, propriétaire ou date de réexamen est invalide et doit être retirée ou classée `ÉVALUER` avec une action de qualification.

PARCOURS DE COMPÉTENCES
Ajoute une matrice des produits étudiés : produit, niveau (`découverte`, `compréhension`, `pratique`, `transmissible`), concepts manquants, laboratoire réalisé, preuve produite et prochaine étape. Priorise les fondamentaux qui structurent plusieurs sujets. Un produit tendance sans laboratoire ou cas d’usage concret reste `ÉVALUER`.

ANALYSE TRANSVERSALE
Ajoute :
1. Les cinq changements structurants du mois.
2. Impacts possibles sur la stack et les pratiques Cloud/DevOps.
3. Dette technique ou risques à anticiper.
4. Compétences à apprendre ou approfondir.
5. Trois expérimentations classées par valeur/effort.
6. Progression d’apprentissage et trois produits à étudier le mois suivant.
7. Échéances des 90 prochains jours.
8. Technologies sorties du radar et justification.
9. Qualité de la veille : sources en erreur, angles morts et ajustements proposés.
10. Journal des décisions : décision, justification, propriétaire, échéance et statut de l’action du mois précédent.
11. Écart entre les prévisions du mois précédent et les résultats observés ; explique les erreurs de prévision et ajuste les hypothèses.

DÉDUPLICATION ET QUALITÉ
Ne répète pas une recommandation inchangée du mois précédent. Indique « évolution » lorsqu’une entrée change de catégorie. Distingue fait vérifié, analyse et inférence. Écarte le marketing et les scores de benchmark non reproductibles.

Retire du radar les entrées sans évolution pendant deux revues, sauf si une échéance, un risque ou une action active le justifie. Documente le motif de retrait et la condition de retour éventuelle.

FORMAT
Sois synthétique et concret. La réponse directe doit expliquer ce qui change, l’impact pour Mehdi et la décision du mois. Maximum 12 entrées dans le radar. Utilise des tableaux pour les comparaisons et conclus par un plan d’action du mois suivant, avec résultats attendus et décisions conditionnelles.

PUBLICATION LOCALE
Écris le rapport Markdown complet dans `dist/AAAA-MM-JJ/revue-architecture.md`, puis valide et committe-le localement. Le livrable est produit même si le mois a été calme ; la preuve de publication est le hash du commit Git local.

Réponds en français avec un ton d’architecte principal.
