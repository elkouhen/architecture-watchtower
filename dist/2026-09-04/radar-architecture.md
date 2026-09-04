# Radar architecture — 4 septembre 2026

Fenêtre de collecte : 48 h (ASAP), 7 jours (nouveautés) et 30 jours (tendances lentes). Déduplication locale appliquée sur 90 jours. Les environnements réels restent `exposition inconnue` tant que l’inventaire n’est pas confirmé.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [API Gateway model routing hostname](https://cloud.google.com/release-notes) | Nouveau hors OSS · service | Les nouvelles passerelles de routage GCP peuvent recevoir un hostname `gateway.dev` différent. | [fiche](#api-gateway--hostname-des-passerelles-de-routage) |
| [AWS Config](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-config-new-resource-types/) | Nouveau hors OSS · service | 60 types de ressources supplémentaires élargissent l’inventaire et les contrôles de conformité. | [fiche](#aws-config--couverture-de-60-nouveaux-types) |
| [Amazon Bedrock Web Search](https://aws.amazon.com/about-aws/whats-new/2026/09/amazon-bedrock-web-aws-govcloud/) | Nouveau hors OSS · service IA | La recherche web côté Bedrock devient disponible en GovCloud US-West. | [fiche](#bedrock-web-search--ancrage-en-govcloud) |
| [Amazon S3 PrivateLink FIPS](https://aws.amazon.com/about-aws/whats-new/2026/09/amazon-s3-privatelink-fips-endpoints/) | Nouveau hors OSS · sécurité | S3 peut être joint par PrivateLink avec des endpoints validés FIPS 140-3. | [fiche](#s3--privatelink-pour-endpoints-fips) |
| [CICD-for-SageMakerUnifiedStudio](https://github.com/aws/CICD-for-SageMakerUnifiedStudio) | Nouveau projet OSS · outil CI/CD | Un CLI open source promeut notebooks, manifests et workloads data/IA entre environnements. | [fiche](#sagemaker-unified-studio--promotion-ci-cd) |

## [API Gateway — hostname des passerelles de routage](https://cloud.google.com/release-notes)

- **Pitch rapide :** La note Google Cloud du 03/09 indique qu’une nouvelle passerelle utilisant le model routing peut recevoir un hostname par défaut `GATEWAY_ID-PROJECT_NUMBER.REGION.gateway.dev` au lieu de `run.app`. Le hostname effectif doit être lu depuis `defaultHostname` ; l’exposition est inconnue.
- **Utilité :** Vérifier les allowlists DNS, certificats, tests synthétiques, règles WAF et URLs codées en dur dans Terraform ou les clients. Le critère de succès est zéro dépendance applicative au hostname implicite après lecture de la propriété publiée.
- **Preuves de traction :** **Fait :** changement documenté dans les release notes primaires le 03/09/2026. **Analyse :** un changement d’URL par défaut peut casser l’intégration même sans changement d’API. **Décision :** qualifier avant toute nouvelle création de gateway. Notes : impact 4/5, urgence 4/5, pertinence stack 4/5, confiance 5/5.
- **Outils similaires :** Cloud Run `run.app` (service distinct), API Gateway sans model routing (hostname historique), DNS géré avec domaine personnalisé (découple le client du défaut fournisseur).

## [AWS Config — couverture de 60 nouveaux types](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-config-new-resource-types/)

- **Pitch rapide :** AWS annonce le 02/09 l’ajout de 60 types de ressources, dont des ressources Bedrock, EC2 et Organizations, utilisables pour l’enregistrement, les règles et les agrégateurs Config.
- **Utilité :** Étendre l’inventaire de conformité Cloud et détecter des ressources IA ou réseau jusque-là absentes des contrôles. Vérifier le coût d’enregistrement et le périmètre régional avant activation ; succès = couverture mesurée des types prioritaires et absence de dérive de coût non expliquée.
- **Preuves de traction :** **Fait :** annonce primaire AWS datée du 02/09/2026. **Analyse :** l’extension améliore la gouvernance mais ne prouve pas qu’un compte enregistre automatiquement chaque type ni que les règles existantes les couvrent. **Décision :** qualifier sur un compte de test. Notes : impact 4/5, urgence 3/5, pertinence stack 4/5, confiance 5/5.
- **Outils similaires :** AWS Security Hub (agrégation de contrôles), CloudFormation resource drift (périmètre différent), OPA/Conftest (contrôles de code et manifests).

## [Bedrock Web Search — ancrage en GovCloud](https://aws.amazon.com/about-aws/whats-new/2026/09/amazon-bedrock-web-aws-govcloud/)

- **Pitch rapide :** AWS documente le 02/09 la disponibilité de Web Search dans AWS GovCloud (US-West), avec contrôle IAM et données de requête conservées dans la frontière AWS par défaut.
- **Utilité :** Étudier un RAG web pour des workloads soumis à des contraintes de résidence ou de conformité, sans déduire que la solution convient aux données sensibles. Mesurer citations correctes, latence, coût et fuite de données sur un corpus synthétique ; prévoir un mode sans recherche si l’outil est indisponible.
- **Preuves de traction :** **Fait :** disponibilité annoncée pour GovCloud US-West et modèles supportés dans la note primaire AWS. **Analyse :** la région réduit une contrainte de déploiement, mais la recherche web introduit une dépendance externe et une nouvelle surface de filtrage. **Décision :** qualifier avec sécurité et conformité. Notes : impact 4/5, urgence 3/5, pertinence stack 3/5, confiance 5/5.
- **Outils similaires :** recherche interne/RAG sur S3 (maîtrise des données), Vertex AI grounding (gouvernance GCP), outil web auto-hébergé (contrôle supérieur, charge d’exploitation accrue).

## [S3 — PrivateLink pour endpoints FIPS](https://aws.amazon.com/about-aws/whats-new/2026/09/amazon-s3-privatelink-fips-endpoints/)

- **Pitch rapide :** Depuis le 03/09, S3 supporte des endpoints PrivateLink validés FIPS 140-3 dans plusieurs régions commerciales et GovCloud, sans coût additionnel annoncé pour cette capacité.
- **Utilité :** Simplifier une architecture où des workloads réglementés doivent atteindre S3 sans sortie réseau publique et avec des modules cryptographiques validés. Vérifier les régions réellement utilisées, le routage DNS privé, les politiques endpoint et la compatibilité des clients ; succès = flux S3 conformes et tests de restauration réussis.
- **Preuves de traction :** **Fait :** annonce primaire AWS du 03/09/2026 listant les régions initiales. **Analyse :** ce changement peut supprimer une exception réseau, mais FIPS ne remplace pas le chiffrement, IAM ou la journalisation. **Décision :** qualifier pour les workloads concernés, exposition inconnue.
- **Outils similaires :** S3 Gateway Endpoint (coût et chemin réseau différents), AWS PrivateLink standard (non-FIPS), stockage objet on-premises avec liaison privée (contrôle supérieur, exploitation différente).

## [SageMaker Unified Studio — promotion CI/CD](https://github.com/aws/CICD-for-SageMakerUnifiedStudio)

- **Pitch rapide :** Le dépôt open source AWS documente un CLI qui sépare le contenu défini par les équipes data du workflow CI/CD, avec promotion de notebooks, bundles, workflows et applications GenAI entre projets.
- **Utilité :** Piste pour standardiser les promotions data/ML/Bedrock sans multiplier les appels AWS dans chaque pipeline. Tester en dev puis test avec dry-run, IAM minimal, artefacts versionnés et rollback ; succès = promotion reproductible d’un notebook et d’un workflow sans identifiants codés en dur.
- **Preuves de traction :** **Fait :** annonce AWS du 02/09 et dépôt officiel public consulté le 04/09 ; le dépôt indique une licence open source et des commandes `bundle`, `deploy`, `test` et `destroy`. **Analyse :** l’abstraction réduit le couplage CI/CD mais ajoute une couche à suivre avec les API SageMaker/Glue/Airflow. **Décision :** tester hors production. Notes : impact 4/5, urgence 2/5, pertinence stack 4/5, confiance 5/5.
- **Outils similaires :** GitHub Actions natives AWS (plus explicites), Terraform (infrastructure plutôt que promotion de contenu), MLflow/Kubeflow (cycle ML et plateforme différents).

## Pitch détaillé

Le changement de hostname des passerelles GCP est le sujet le plus immédiatement opérationnel : il touche la résolution d’adresse, les certificats et les contrôles réseau au moment de la création. Il ne faut pas remplacer une URL existante en production sur la seule base de cette note ; il faut d’abord lire `defaultHostname` et tester les clients.

AWS Config et S3 PrivateLink FIPS renforcent deux capacités de plateforme complémentaires : savoir ce qui existe et contrôler comment les workloads atteignent les données. Leur intérêt dépend fortement des régions, comptes et exigences de conformité de Mehdi, encore à qualifier.

Bedrock Web Search GovCloud élargit le périmètre des agents ancrés par recherche web. Le test doit intégrer provenance, filtrage, coût, latence, permissions et repli déterministe ; la disponibilité régionale ne suffit pas à établir l’acceptabilité des données.

Le CLI SageMaker Unified Studio mérite un laboratoire parce qu’il propose une frontière claire entre manifeste applicatif et politique de promotion. Sa maturité réelle, sa surface IAM et sa compatibilité avec la stack GitHub/GitLab restent à mesurer.

## Sujets écartés

- Aucun second projet OSS nouveau n’a été retenu avec une preuve primaire indépendante et une utilité architecturale suffisante dans la fenêtre. **Exception quota OSS :** un seul projet OSS sur cinq sujets ; les quatre changements AWS/GCP sont des évolutions fournisseurs datées et directement actionnables, et aucun dépôt faible n’a été ajouté pour atteindre artificiellement le quota.
- Les nouveautés Cloud Run Agent Identity et Claude Fable 5.1 ont été contrôlées mais non répétées : aucun changement substantiel confirmé depuis le radar du 03/09.
- Les signaux OSS à échéance du 05/09 restent suivis dans `state/signals.yaml` et seront traités à leur date ; aucune échéance active n’était atteinte au 04/09.

## Sources consultées

- **AWS —** [What's New](https://aws.amazon.com/new/), [bulletins sécurité](https://aws.amazon.com/security/security-bulletins/), [cycle de vie EKS](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html), [historique Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html), contrôle du 04/09 ; borne de reprise : dernier succès local du 03/09, rattrapage du 03/09 au 04/09 dans la limite de 30 jours ; **signal retenu** pour Config, Bedrock Web Search et S3 PrivateLink FIPS.
- **GCP —** [release notes globales](https://cloud.google.com/release-notes), [Cloud Run](https://cloud.google.com/run/docs/release-notes), [GKE release notes](https://cloud.google.com/kubernetes-engine/docs/release-notes), [bulletins GKE](https://cloud.google.com/kubernetes-engine/security-bulletins), [dépréciations](https://cloud.google.com/terms/deprecation) et [Vertex AI](https://cloud.google.com/vertex-ai/docs/core-release-notes), contrôle du 04/09 ; borne de reprise : dernier succès local du 03/09, rattrapage 03/09–04/09 ; **signal retenu** pour le hostname model routing, **aucun changement retenu** pour sécurité, lifecycle et quotas hors éléments signalés.
- **IA —** [historique Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-ug-doc-history.html), [Vertex AI](https://cloud.google.com/vertex-ai/docs/core-release-notes), [OpenAI changelog](https://developers.openai.com/api/docs/changelog), [OpenAI dépréciations](https://developers.openai.com/api/docs/deprecations) et [Claude release notes](https://platform.claude.com/docs/en/release-notes/overview), contrôle du 04/09 ; borne de reprise : dernier succès local du 03/09, rattrapage 03/09–04/09 ; **signal retenu** pour Bedrock Web Search, **aucun changement retenu** pour OpenAI, Vertex AI et Anthropic.
- **OSS —** [CICD-for-SageMakerUnifiedStudio](https://github.com/aws/CICD-for-SageMakerUnifiedStudio), dépôt officiel consulté le 04/09 ; **signal retenu**. GitHub Trending/Trendshift n’ont pas fourni de second projet qualifié.

## Sources en échec

- Aucune source primaire bloquante. Les métriques de disponibilité régionale et l’exposition de la stack restent à qualifier dans les comptes et clusters réels.
