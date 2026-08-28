# RADAR DES TENDANCES — 2026-08-28

**Période :** 7 derniers jours pour les nouveautés ; 30 derniers jours pour l’émergence.  
**Lecture cible :** moins de 30 minutes. Découverte large dominante ; approfondissement d’environ 40 % sur Kubernetes, ELK/observabilité et IA appliquée.

## LES TROIS TENDANCES À RETENIR

1. **AI Gateway / inference gateway — émergente :** les APIs Kubernetes commencent à traiter le routage, la politique et l’observabilité du trafic d’inférence ; `surveiller`, puis tester sur un flux non critique.
2. **Agent Sandbox sur Kubernetes — émergente avec chemin de déploiement :** un CRD formalise des workloads agents isolés, persistants et singleton ; `tester` en environnement local avant toute exposition à des outils ou secrets.
3. **OpenTelemetry GenAI — émergente :** les conventions GenAI se structurent dans un dépôt dédié ; `surveiller` l’interopérabilité avec Elastic APM avant de standardiser les attributs.

## TENDANCES DÉTAILLÉES

### 1. AI Gateway et routage d’inférence — ÉMERGENTE

- **Pourquoi maintenant :** le Kubernetes AI Gateway Working Group, annoncé en mars 2026, travaille sur le routage de modèles, le traitement de payloads et les passerelles egress vers Bedrock, Vertex AI ou OpenAI.
- **Preuves de traction :** groupe de travail Kubernetes et propositions actives ; Gateway API v1.6 publiée en août 2026 avec plusieurs implémentations conformantes. Sources : https://kubernetes.io/blog/2026/03/09/announcing-ai-gateway-wg/ ; https://kubernetes.io/blog/2026/08/03/gateway-api-v1-6-release/.
- **Fait vérifié :** les propositions sont en développement actif ; ce n’est pas une API standardisée et stable de production pour tous les contrôleurs.
- **Analyse :** le pattern déplace le contrôle du routage, de l’authentification, du rate limiting, du failover et éventuellement du filtrage au bord du plan d’inférence.
- **Maturité :** `émergente` ; risque de divergence entre contrôleurs et de dépendance aux extensions. Ne pas placer un contrôle critique sur une fonctionnalité Preview/bêta seule.
- **Pertinence pour Mehdi :** `possible` ; forte pertinence Kubernetes, Terraform, CI/CD et observabilité, mais distribution et workloads inconnus.
- **Architecture cible :** Gateway API devant des backends de modèles internes et externes ; identité de workload pour les appels fournisseurs ; logs et traces vers OTel/ELK ; repli vers un endpoint connu si le routage échoue.
- **Test proposé :** sur Kind, router deux backends factices selon modèle et priorité ; mesurer taux d’erreur, latence p95, décision de routage et comportement de repli en 45 minutes.
- **Décision :** `surveiller` puis `tester` si l’implémentation choisie documente les capacités nécessaires.
- **Prévision :** à 1–3 mois, les contrôleurs vont diverger avant qu’un socle commun ne se stabilise ; signal attendu : nouvelles GEP/CRD et conformance tests. Si la couverture reste partielle, conserver un proxy explicite et réversible.

### 2. Agent Sandbox — ÉMERGENTE / TRACTION

- **Pourquoi maintenant :** le projet Kubernetes SIG Apps propose un CRD `Sandbox` pour des workloads singleton, persistants et isolés, adaptés aux runtimes d’agents qui exécutent du code généré ou non fiable.
- **Preuves de traction :** dépôt actif, documentation officielle, 11 releases affichées et une release v0.4.6 en mai 2026 ; la documentation décrit un déploiement par manifests et un quickstart. Sources : https://github.com/kubernetes-sigs/agent-sandbox ; https://agent-sandbox.sigs.k8s.io/docs/.
- **Fait vérifié :** le projet fournit un contrôleur, des CRD et des exemples ; son niveau de maturité API et son adéquation à une production critique restent à qualifier.
- **Analyse :** il encapsule identité stable, persistance et cycle de vie d’une session agent, au lieu de recomposer StatefulSet, Service et PVC.
- **Maturité :** `émergente` ; maintenance et chemin de déploiement sont démontrés, mais version/API, isolation réelle, coût et observabilité doivent être testés.
- **Pertinence pour Mehdi :** `confirmée` pour l’axe Kubernetes/IA, sans exposition réelle connue.
- **Architecture cible :** contrôleur dans un namespace dédié ; image agent sans secrets par défaut ; NetworkPolicy, ServiceAccount minimal, PVC borné et traces d’exécution ; EKS/GKE seulement après validation locale.
- **Test proposé :** déployer la version explicitement choisie sur Kind, créer un Sandbox, vérifier persistance et suppression, puis injecter une tentative d’accès réseau non autorisé. Critères : isolation observée, nettoyage idempotent et aucun secret accessible.
- **Décision :** `tester` en laboratoire ; pas d’adoption de production.
- **Prévision :** si API v1beta1, documentation et intégrations d’observabilité progressent sous 3 mois, produire une carte de standardisation ; sinon conserver comme pattern expérimental.

### 3. OpenTelemetry GenAI — ÉMERGENTE

- **Pourquoi maintenant :** les conventions GenAI ont été déplacées vers un dépôt dédié, signe que l’écosystème formalise les attributs et spans des appels LLM, agents et outils.
- **Preuves de traction :** documentation OTel 1.44.0 et dépôt officiel `semantic-conventions-genai`, avec des conventions de spans GenAI. Sources : https://opentelemetry.io/docs/specs/semconv/ ; https://github.com/open-telemetry/semantic-conventions-genai.
- **Fait vérifié :** OTel définit des noms communs pour les données de télémétrie ; les conventions GenAI sont encore un domaine en évolution et leur implémentation par les agents n’est pas uniforme.
- **Analyse :** un vocabulaire commun peut relier modèle, fournisseur, tokens, outils, erreurs et latence dans ELK/APM, mais la capture de prompts/réponses crée des risques de données sensibles et de coût.
- **Maturité :** `émergente` ; risque de changements de schéma et de coexistence avec des conventions propriétaires.
- **Pertinence pour Mehdi :** `confirmée` pour ELK et Elastic APM, sous réserve de vérifier le support exact de la version réellement déployée.
- **Architecture cible :** instrumentation côté application, OTel Collector avec filtrage/redaction, export métriques/traces vers Elastic APM/ELK ; conservation séparée des contenus sensibles ; corrélation avec CI/CD et identités.
- **Test proposé :** instrumenter un appel LLM fictif et un appel outil ; vérifier les attributs, la redaction, le coût de stockage et la recherche dans Kibana.
- **Décision :** `surveiller` ; tester uniquement comme expérimentation d’observabilité.
- **Prévision :** la convergence sera utile si Elastic, OTel et les frameworks d’agents consomment le même vocabulaire ; signal attendu : support documenté dans les SDK/exporters utilisés.

### 4. Kubernetes 1.37 comme cycle de plateforme — TRACTION

- **Pourquoi maintenant :** Kubernetes 1.37.0 est sorti le 26 août 2026, avec 67 améliorations.
- **Preuves de traction :** release officielle et branche maintenue parmi les trois dernières mineures. Sources : https://kubernetes.io/blog/2026/08/26/kubernetes-v1-37-release/ ; https://kubernetes.io/releases/.
- **Fait vérifié :** 16 améliorations sont stables, 23 bêta, 27 alpha et une dépréciation/suppression ; la prochaine patch release annoncée est 1.37.1.
- **Analyse :** l’intérêt n’est pas la version seule mais le cycle de validation des APIs, add-ons, providers Terraform, politiques et workloads.
- **Maturité :** `mature` pour Kubernetes, `à qualifier` pour la compatibilité de la stack de Mehdi.
- **Pertinence pour Mehdi :** `possible`, car la version réellement déployée est inconnue.
- **Architecture cible :** environnement de test paritaire, plan de rollback, validation des CRD/admission controllers et observabilité des erreurs API.
- **Test proposé :** inventaire puis upgrade d’un cluster de test ; comparer déploiements, événements, erreurs API, SLO et plans Terraform.
- **Décision :** `surveiller` jusqu’à l’inventaire, puis `tester`.
- **Prévision :** la décision dépendra plus des add-ons et providers que du control plane ; réexaminer le 15 septembre 2026.

## SIGNAUX À SURVEILLER

- **AgentOps / observabilité d’agents :** signal local du 27 août ; preuve manquante : deux implémentations actives et une source primaire décrivant les garanties opérationnelles. Réexamen : 5 septembre 2026.
- **Inference Extension Gateway API :** projet officiel et documentation Kubernetes ; preuve manquante : niveau de conformance et support du contrôleur retenu. Réexamen : 15 septembre 2026.
- **Évolutions Elastic 9.5.x :** release notes et artefacts 9.5.2 observés, mais la page de release notes consultée met en avant 9.5.1 ; preuve manquante : version supportée et notes détaillées correspondant à l’environnement réel. Réexamen : 3 septembre 2026.

## À NE PAS SUIVRE CETTE SEMAINE

- Benchmarks LLM isolés sans architecture ni protocole reproductible.
- Annonces de modèles sans changement de routage, déploiement, coût, sécurité ou exploitation.
- Releases de maintenance Elastic sans conséquence sur compatibilité, sécurité ou architecture.

## LABORATOIRE DE LA SEMAINE

Tester **Agent Sandbox sur Kind** en moins d’une heure : installation de la version figée, création d’un Sandbox, vérification d’identité/persistance, tentative réseau contrôlée, suppression et vérification du nettoyage. Critère : aucune permission hors périmètre et état nettoyé sans ressource orpheline.

## SOURCES CONSULTÉES

Sources primaires : Kubernetes releases/blog, Agent Sandbox GitHub/documentation, OpenTelemetry documentation/repository, Elastic release notes/status. Sources locales : `state/context.yaml`, `state/signals.yaml`, rapports du 27 août 2026. Les sources sociales n’ont pas été utilisées pour confirmer un fait.
