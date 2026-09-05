# Radar architecture — 5 septembre 2026

Fenêtre de collecte : 48 h pour les nouveautés, 7 jours pour les changements récents et 90 jours pour la déduplication locale. Les environnements réels restent `exposition inconnue` tant que l’inventaire n’est pas confirmé. Ce radar sert à expliquer des sujets ; il ne planifie pas d’expérimentation.

## Vue d’ensemble

| Outil | Type | Pitch rapide | Lien vers la section |
|---|---|---|---|
| [AWS MCP Server — capacité serverless](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-mcp-server-serverless/) | Nouveau hors OSS · agents | AWS MCP Server corrèle les signaux opérationnels d’une fonction Lambda et de services connectés. | [fiche](#aws-mcp-server--capacité-serverless) |
| [Amazon EC2 compatible instance types](https://aws.amazon.com/about-aws/whats-new/2026/09/ec2-images-supported-instances/) | Nouveau hors OSS · plateforme | Une AMI peut déclarer les types d’instances compatibles et bloquer les lancements non autorisés. | [fiche](#amazon-ec2--types-dinstances-compatibles-déclarés-dans-les-ami) |
| [AWS Transfer Family SFTP credential rotation](https://aws.amazon.com/about-aws/whats-new/2026/09/transfer-family-sftp-credential-rotation/) | Nouveau hors OSS · sécurité | Les identifiants des connecteurs SFTP peuvent être renouvelés dans Secrets Manager sans interrompre les transferts. | [fiche](#aws-transfer-family--rotation-des-identifiants-sftp) |
| [Amazon SageMaker Batch Transform G6e](https://aws.amazon.com/about-aws/whats-new/2026/09/sagemaker-batch-transform-g6e-instances/) | Nouveau hors OSS · IA | Les instances G6e deviennent disponibles pour les traitements Batch Transform SageMaker. | [fiche](#sagemaker-batch-transform--instances-g6e) |
| [Kthena](https://github.com/volcano-sh/kthena) | Nouveau projet OSS · infrastructure IA | Kthena sépare contrôleur de workloads et routeur pour servir des modèles sur Kubernetes. | [fiche](#kthena--plans-de-contrôle-et-de-routage-pour-linférence) |
| [Forge](https://github.com/initializ/forge) | Nouveau projet OSS · agents | Forge propose un runtime de skills et d’agents avec exécution Kubernetes, politiques d’egress et audit. | [fiche](#forge--runtime-de-skills-et-dagents) |

## [AWS MCP Server — capacité serverless](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-mcp-server-serverless/)

- **Pitch rapide :** **Fait :** l’annonce AWS du 04/09/2026 décrit une capacité serverless d’AWS MCP Server qui analyse Lambda et des services connectés — API Gateway, EventBridge, S3, DynamoDB, SNS, SQS et Step Functions — en rapprochant une baseline de 7 jours, les erreurs récurrentes, la configuration et la chronologie des changements. La capacité est annoncée sans coût additionnel, avec exécution du serveur MCP en `us-east-1` et `eu-frankfurt`.
- **Utilité architecturale :** cela rapproche diagnostic applicatif et contexte d’infrastructure dans une interface d’agent, mais ajoute une voie d’accès outillée aux données opérationnelles. **Analyse :** la frontière IAM, le périmètre des journaux consultables et la résidence des données doivent être traités comme une surface d’administration.
- **Outils similaires :** AWS Systems Manager et CloudWatch pour l’exploitation explicite ; MCP auto-hébergé avec allowlist pour un contrôle différent du périmètre ; plateformes APM pour la corrélation métriques-traces.

## [Amazon EC2 — types d’instances compatibles déclarés dans les AMI](https://aws.amazon.com/about-aws/whats-new/2026/09/ec2-images-supported-instances/)

- **Pitch rapide :** **Fait :** AWS annonce le 04/09/2026 la possibilité pour le propriétaire d’une AMI de déclarer les types d’instances compatibles ou interdits ; EC2 bloque alors le lancement sur un type non permis. La capacité est annoncée dans toutes les régions, sans coût additionnel.
- **Utilité architecturale :** ce garde-fou déplace une partie de la compatibilité OS, drivers et architecture CPU dans le contrat de l’image. **Analyse :** il peut réduire les erreurs de capacité ou d’architecture, mais une déclaration incomplète peut bloquer un autoscaling légitime ou donner un faux sentiment de compatibilité.
- **Outils similaires :** contraintes Terraform/Autoscaling, Image Builder et politiques AWS Organizations ; ces mécanismes restent nécessaires pour traiter le cycle de vie et l’autorisation, pas seulement la compatibilité.

## [AWS Transfer Family — rotation des identifiants SFTP](https://aws.amazon.com/about-aws/whats-new/2026/09/transfer-family-sftp-credential-rotation/)

- **Pitch rapide :** **Fait :** l’annonce AWS du 04/09/2026 documente la rotation des identifiants de connecteurs SFTP via AWS Secrets Manager, avec utilisation ordonnée des versions de secret pour éviter l’interruption des transferts.
- **Utilité architecturale :** la rotation devient une propriété du flux de connexion plutôt qu’une opération manuelle de remplacement. **Analyse :** le bénéfice dépend de la discipline sur les versions de secret, les droits IAM, le calendrier de rotation et la capacité du partenaire distant à accepter l’identifiant suivant.
- **Outils similaires :** rotation native Secrets Manager, Vault avec moteur de secrets et rotation côté partenaire ; ils ne suppriment pas la nécessité de coordonner le changement distant.

## [SageMaker Batch Transform — instances G6e](https://aws.amazon.com/about-aws/whats-new/2026/09/sagemaker-batch-transform-g6e-instances/)

- **Pitch rapide :** **Fait :** AWS annonce le 04/09/2026 le support des instances Amazon EC2 G6e par SageMaker Batch Transform pour les traitements d’inférence par lots. Les caractéristiques exactes, régions et tarifs doivent être lus dans la documentation de service associée avant toute comparaison.
- **Utilité architecturale :** cette extension ajoute une option de capacité GPU aux traitements différés. **Analyse :** elle peut modifier le compromis coût–débit–durée, mais ne démontre ni disponibilité dans une région donnée ni avantage économique pour une charge réelle.
- **Outils similaires :** SageMaker Processing, jobs Kubernetes avec vLLM ou Triton, et instances GPU EC2 gérées directement ; le choix dépend du niveau de contrôle voulu sur le runtime.

## [Kthena — plans de contrôle et de routage pour l’inférence](https://github.com/volcano-sh/kthena)

- **Pitch rapide :** **Fait :** le dépôt Apache-2.0 de Volcano présente Kthena comme une plateforme Kubernetes-native pour servir des LLM, avec séparation entre workload controller et router, support de vLLM/SGLang/Triton, autoscaling, mises à jour progressives et routage Gateway API optionnel. Le dépôt et sa page de releases ont été consultés le 05/09/2026.
- **Utilité architecturale :** le découplage des plans permet de traiter séparément placement, capacité et décision de routage, notamment pour le préremplissage–décodage. **Analyse :** cela augmente aussi le nombre de contrats entre contrôleur, routeur, runtime de modèle et observabilité ; la maturité opérationnelle reste à qualifier.
- **Outils similaires :** llm-d, KServe, vLLM seul et gateways IA dédiées ; ils diffèrent par le degré de séparation entre orchestration et routage.

## [Forge — runtime de skills et d’agents](https://github.com/initializ/forge)

- **Pitch rapide :** **Fait :** le dépôt Apache-2.0 Forge se présente comme un runtime open source pour Anthropic Agent Skills, déployable sur Kubernetes ou on-premises, y compris en environnement air-gapped. Le README documente notamment egress allowlists, secrets chiffrés, audit NDJSON, MCP, fallback et intégration OpenTelemetry ; le dépôt a été consulté le 05/09/2026.
- **Utilité architecturale :** Forge propose une frontière d’exécution entre skill déclaratif, outils autorisés et environnement d’exécution. **Analyse :** les contrôles annoncés sont prometteurs pour limiter l’egress et tracer les actions, mais la confiance dépend de la chaîne de build, du modèle de menace et de la fréquence des correctifs.
- **Outils similaires :** Agent Sandbox, runtimes de skills propriétaires et exécution de jobs Kubernetes avec politiques réseau ; le niveau de garantie et la surface MCP ne sont pas équivalents.

## Sujets écartés

- Les 15 signaux arrivés à échéance le 05/09 ont été traités avant la sélection. Les projets WorkWeave/router, Hezo et AgentReady sont `discarded` avec décision `avoid` faute de justification suffisante pour maintenir une veille active ; les autres signaux sans évolution substantielle sont `deferred` et ont une nouvelle échéance. Vault CVE-2026-5006 et les pertes silencieuses possibles d’Elastic Agent restent `open` car l’exposition et la version réellement déployée sont inconnues.
- Les sources GCP globales et GKE release notes n’ont pas pu être relues complètement aujourd’hui : timeout/échec de récupération. Aucun nouveau sujet GCP n’est donc présenté comme fait sur la seule base d’une source non relue. Le bulletin GKE GCP-2026-058 du 02/09 reste connu localement et n’est pas répété.
- Les évolutions AWS et les projets OSS ci-dessus sont nouvelles dans la fenêtre locale. Le quota est respecté : deux nouveaux projets OSS sur six sujets, soit 33 %.

## Sources consultées

- **AWS —** [What's New](https://aws.amazon.com/new/), [AWS MCP Server serverless](https://aws.amazon.com/about-aws/whats-new/2026/09/aws-mcp-server-serverless/), [AMI compatible instance types](https://aws.amazon.com/about-aws/whats-new/2026/09/ec2-images-supported-instances/), [Transfer Family SFTP credential rotation](https://aws.amazon.com/about-aws/whats-new/2026/09/transfer-family-sftp-credential-rotation/), [SageMaker G6e](https://aws.amazon.com/about-aws/whats-new/2026/09/sagemaker-batch-transform-g6e-instances/) et [bulletins sécurité](https://aws.amazon.com/security/security-bulletins/), contrôlés le 05/09 ; borne de reprise : 04/09 ; **signal retenu** pour quatre nouveautés AWS. Les notes EKS/Bedrock ont été tentées mais leur relecture n’a pas abouti dans cet appel.
- **GCP —** [bulletins GKE](https://cloud.google.com/kubernetes-engine/security-bulletins) contrôlés le 05/09 ; [release notes globales](https://cloud.google.com/release-notes), [release notes GKE](https://cloud.google.com/kubernetes-engine/docs/release-notes), [dépréciations](https://cloud.google.com/terms/deprecation) et [Vertex AI](https://cloud.google.com/vertex-ai/docs/core-release-notes) tentés ; borne de reprise : dernier succès local du 04/09, reprise dès que les pages sont récupérables ; **échec** de relecture complète des voies release/lifecycle, **aucun changement retenu** sur ces voies.
- **IA —** [OpenAI changelog](https://developers.openai.com/api/docs/changelog), [OpenAI dépréciations](https://developers.openai.com/api/docs/deprecations), [Claude release notes](https://platform.claude.com/docs/en/release-notes/overview) et documentation Vertex AI contrôlés le 05/09 ; borne de reprise : 04/09 ; **aucun changement retenu** dans ces sources pour ce radar. La nouveauté AWS MCP Server est retenue comme évolution d’outillage d’agents AWS.
- **OSS —** [Kthena](https://github.com/volcano-sh/kthena) et [Forge](https://github.com/initializ/forge), dépôts et pages de releases consultés le 05/09 ; **signal retenu**. Les métriques GitHub indiquent activité et visibilité, pas maturité ou adoption.

## Sources en échec

- Les pages Google Cloud release notes, GKE release notes et politique de dépréciation ont respectivement renvoyé timeout ou échec de récupération dans la collecte du 05/09. Les entrées correspondantes sont marquées `degraded` dans `state/sources.yaml`; la couverture sécurité GKE reste confirmée par le bulletin primaire consulté.
- La documentation AWS EKS n’a pas été récupérée dans la collecte du jour ; la dernière observation locale reste celle du 04/09. Aucun changement de lifecycle EKS n’est affirmé.
