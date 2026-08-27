Produis le radar hebdomadaire Cloud, DevOps, architecture applicative et architecture IA de Mehdi. Le radar transforme l’actualité en parcours d’apprentissage et en décisions ; il ne doit pas être une liste de liens.

PÉRIODE
Analyse les nouveautés des sept derniers jours. Vérifie aussi si une information pertinente a été manquée par la sentinelle quotidienne.

CONTEXTE D’ARCHITECTURE
Lis `state/context.yaml` avant la recherche. Priorise les sujets `ELK`, `Elastic APM`, `Logstash` et `Kubernetes`. Relie chaque sujet à AWS, GCP, Kubernetes, GitHub Actions, GitLab CI/CD, CloudWatch, ELK ou Terraform lorsqu’il existe un lien vérifiable. Si la version, l’environnement ou l’exposition sont inconnus, écris-le explicitement et propose l’étape de qualification.

PRINCIPE
Le radar hebdomadaire sélectionne un petit nombre de produits connus ou en tendance et explique pourquoi ils méritent d’être appris. Pour chaque sujet, relie la nouveauté à un modèle mental, un cas d’usage, un mode de déploiement et une expérience pratique. Ne transforme pas une annonce ou un benchmark en standard d’architecture. Sépare systématiquement collecte, fait vérifié, analyse, inférence et décision proposée.

PÉRIMÈTRE
- GCP, AWS, Kubernetes/GKE/EKS, Terraform/OpenTofu, GitOps, Argo CD et plateforme engineering ;
- Elastic/ELK, OpenTelemetry, Prometheus, Grafana, observabilité et SRE ;
- GitHub Actions, GitLab CI/CD, sécurité de la supply chain ;
- architecture applicative : monolithe modulaire, microservices, DDD, event-driven, saga, outbox, CDC, API gateway, service mesh, serverless, résilience et multi-région ;
- IA générative : RAG, GraphRAG, agents, multi-agents, MCP, mémoire, évaluation, guardrails, observabilité LLM et serving ;
- projets open source pertinents et services managés équivalents GCP/AWS.

SOURCES
Priorise les architectures de référence, blogs d’architecture, changelogs, release notes et dépôts officiels. Consulte notamment Google Cloud Architecture Center, AWS Architecture Blog et Prescriptive Guidance, CNCF, Martin Fowler, Microservices.io, Thoughtworks Technology Radar et les dépôts des projets suivis. Recoupe tout fait important avec une source primaire.

DÉDUPLICATION
Recherche dans `state/signals.yaml` et dans les rapports locaux `dist/` des 90 derniers jours les sujets déjà signalés. Ne répète un élément que si une évolution substantielle justifie une mise à jour.

TRIAGE ET GOUVERNANCE
- conserve pour chaque sujet un identifiant, une source primaire, un niveau de confiance, un propriétaire et une date de réexamen ;
- distingue « information à suivre » de « décision à prendre » ; une information sans action ou impact plausible ne doit pas entrer au radar ;
- avant de proposer « adopter », exige une preuve d’usage comparable ou un retour d’expérience interne ; à défaut, propose « évaluer » ou un test limité ;
- si un élément est écarté, documente brièvement le motif : hors périmètre, non exposé, immaturité, coût disproportionné ou doublon.
- conserve dans le registre le statut du cycle précédent afin de distinguer une nouveauté d’une simple répétition.
- pour chaque sujet prospectif, formule une prévision à 1–3 mois, une hypothèse vérifiable et les signaux attendus ;

SCORING SUR 10
- pertinence : 0–3 ;
- impact : 0–3 ;
- urgence : 0–2 ;
- source : 0–1 ;
- nouveauté : 0–1.

Inclue en priorité les scores 4 à 7. Ajoute un score 8–10 seulement s’il n’a pas déjà été traité par la sentinelle quotidienne. Écarte les scores inférieurs à 4. Maximum 8 sujets.

PARCOURS D’APPRENTISSAGE
Le rapport doit retenir au maximum trois sujets d’apprentissage approfondi : un fondamental, un produit en évolution et, si pertinent, un sujet émergent. Pour chacun, donne le niveau préalable, les concepts à maîtriser, le déploiement minimal, le déploiement de production, un laboratoire de moins d’une heure et le résultat attendu. Une simple nouveauté sans expérience proposée va dans « à surveiller », pas dans le parcours.

FORMAT
1. Synthèse exécutive : trois enseignements.
2. Nouveautés par thème.
3. Pour chaque sujet :
   - Pourquoi l’apprendre maintenant ;
   - Modèle mental et capacités essentielles ;
   - Déploiement minimal et déploiement de production ;
   - Fait vérifié et lien primaire ;
   - Analyse d’architecture ;
   - Recommandation, propriétaire et date de réexamen ;
   - Pattern concerné ;
   - Option open source ;
   - service managé GCP ;
   - service managé AWS ;
   - maturité, coût opérationnel et verrouillage ;
   - quand l’utiliser et quand l’éviter.
   - Prévision à 1–3 mois, hypothèse vérifiable, signaux attendus et décision conditionnelle (« si… alors… »).
4. Échéances et dépréciations.
5. Un test de lab réalisable en moins d’une heure par sujet d’apprentissage.
6. Sources consultées et sources en échec.

La synthèse exécutive doit répondre en langage concret à : « qu’est-ce qui a changé ? », « est-ce pertinent pour Mehdi ? » et « que faut-il faire maintenant ? ». Évite les formulations abstraites ou les regroupements de technologies sans impact explicite.

Ajoute un court « Journal des décisions » : sujet, action (surveiller/évaluer/expérimenter/adopter/éviter), justification, propriétaire et échéance. Les sujets immobiles pendant deux cycles sont retirés du radar, sauf risque ou échéance active.

Présente clairement les comparaisons connues sous forme de tableau. Identifie comme « inférence » tout rapprochement qui n’est pas directement affirmé par la source.

PUBLICATION LOCALE
Chaque vendredi, écris le rapport Markdown complet dans `dist/AAAA-MM-JJ/radar-architecture.md`, valide-le puis committe-le localement. Même sans nouveauté, le livrable doit contenir un heartbeat. Consigne le hash du commit dans le journal local si un journal de publication est utilisé.

Réponds en français, de manière synthétique et décisionnelle.
