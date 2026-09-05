# CARTE SERVICE — [Model Context Protocol (MCP)](https://modelcontextprotocol.io/specification/2026-07-28)

Date : 2026-08-29. Type : `standard / protocole`. Version de référence : `2026-07-28`. Version réellement utilisée dans la stack de l'utilisateur : `à qualifier`.

## 1. RÉSUMÉ DÉCISIONNEL

**Pitch rapide :** MCP définit un contrat entre des clients agents et des serveurs qui exposent des outils, ressources et prompts. Il standardise la découverte et l’appel de capacités sans imposer le modèle, le fournisseur ou le backend d’observabilité.

**Fait :** la révision stable `2026-07-28` est publiée le 28/07/2026. **Analyse :** elle transforme surtout le transport et le cycle de vie, plus que la forme des outils. **Décision proposée :** qualifier la compatibilité des clients/serveurs existants avant adoption ; conserver `2025-11-25` comme repli pendant la migration.

## 2. FONCTIONNALITÉS À RETENIR

| Fonctionnalité | Rôle architectural | État dans `2026-07-28` |
|---|---|---|
| Outils, ressources, prompts | Exposer des actions, données et modèles d’instructions | cœur du protocole |
| Streamable HTTP | Transport distant pour clients et serveurs | recommandé ; HTTP+SSE déprécié |
| Cœur stateless | Chaque requête porte son contexte ; pas de session protocolaire obligatoire | nouveau |
| `server/discover` | Découvrir versions et capacités avant usage | nouveau, optionnel |
| `Mcp-Method` / `Mcp-Name` | Router et autoriser au niveau gateway | nouveau |
| MRTR | Remplacer les flux bidirectionnels persistants pour sampling/elicitation | nouveau |
| Résultats de listes cacheables | Stabiliser `tools/list`, `resources/list`, `prompts/list` | nouveau |
| Extensions | Ajouter une capacité sans modifier immédiatement le cœur | formalisé |
| Tasks | Suivre des opérations longues via `tasks/get` / `tasks/update` | extension officielle |
| MCP Apps | Rendre une UI depuis un serveur MCP | extension |
| OAuth, CIMD, EMA | Identité client, autorisation et gestion entreprise | durci / extensions |
| JSON Schema 2020-12 | Décrire les entrées et sorties d’outils | élargi |

## 3. NOUVEAUTÉS DEPUIS `2025-11-25`

- **Stateless :** suppression de `initialize`/`notifications/initialized` et de `Mcp-Session-Id`. Un serveur distant peut passer derrière un load balancer round-robin sans session partagée ; l’état applicatif doit être explicite, par exemple via un handle géré par le serveur.
- **HTTP routable :** `MCP-Protocol-Version`, `Mcp-Method` et `Mcp-Name` rendent le protocole exploitable par un gateway L7 pour le routage, l’autorisation et l’observabilité.
- **MRTR :** les demandes serveur-client, dont sampling et elicitation, sont restructurées en multi round-trip requests ; il n’est plus nécessaire de maintenir un flux bidirectionnel ouvert pour chaque interaction.
- **Cache et ordre déterministe :** les réponses des listes peuvent fournir des indications de cache et un ordre stable, ce qui réduit la charge de découverte et les variations de catalogues.
- **Extensions de première classe :** Tasks sort du cœur expérimental ; MCP Apps et Enterprise-Managed Authorization s’inscrivent dans le modèle d’extensions.
- **Autorisation :** les credentials client sont liés à l’émetteur ; Client ID Metadata Documents (CIMD) devient la voie privilégiée, tandis que Dynamic Client Registration (DCR) est déprécié mais conservé pour compatibilité.
- **Dépréciations :** Roots, Sampling, Logging et le transport HTTP+SSE restent utilisables pendant une période de transition annoncée d’au moins douze mois ; ne pas les choisir pour une nouvelle implémentation.

Sources : [annonce de la release](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/blog/content/posts/2026-07-28-spec-ga/index.md), [changelog officiel](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/changelog.mdx), [détail de la spécification](https://blog.modelcontextprotocol.io/posts/2026-07-28/).

## 4. POSITION DANS LE SYSTÈME

```text
Utilisateur / agent / IDE / service métier
                 │ client MCP
                 ▼
      Gateway HTTP · auth · policy · audit
                 │ Streamable HTTP
                 ▼
     Serveur MCP ──► outils / ressources / prompts
          │                    │
          ├── APIs métier, GitHub, AWS, Kubernetes
          ├── base, fichiers, recherche, modèles
          └── OTel / logs / SIEM / métriques
```

Producteurs : serveurs MCP et systèmes qu’ils encapsulent. Consommateurs : clients agents, applications, IDE et gateways. Entrées : requêtes JSON-RPC et métadonnées HTTP. Sorties : résultats structurés, erreurs, notifications ou tâches. MCP ne remplace ni l’IAM métier, ni un proxy egress, ni un registre de secrets.

## 5. MODÈLE MENTAL

1. Le client choisit un serveur et négocie/annonce la version supportée.
2. Il découvre éventuellement les capacités avec `server/discover`, puis liste outils, ressources et prompts.
3. Il appelle un outil avec des arguments validés par le schéma ; le serveur exécute l’action selon son identité et sa politique.
4. Une opération longue utilise l’extension Tasks ; une interaction utilisateur ou modèle suit le mécanisme approprié, avec validation et timeout.
5. Le client corrèle `request_id`, serveur, outil, identité, coût, résultat et erreur dans l’observabilité.

États à gérer côté application : catalogue découvert, autorisation, appel en cours, tâche en attente, succès, erreur, expiration et révocation. Une erreur MCP n’est pas une preuve d’échec métier : conserver le code JSON-RPC, le statut HTTP, le timeout et la trace d’exécution.

## 6. ARCHITECTURE DE DÉPLOIEMENT

**Local reproductible :** lancer un serveur MCP de démonstration sur stdio ou Streamable HTTP, l’exposer uniquement sur `localhost`, utiliser un client compatible `2026-07-28`, appeler un outil inoffensif et inspecter la négociation, le catalogue et les erreurs. Figer la version du SDK et les exemples officiels ; ne fournir aucun secret réel.

**Production réaliste :** déployer le serveur comme workload HTTP stateless sur EKS/GKE ou une plateforme VM, derrière un gateway. Utiliser un load balancer sans affinité, TLS, authentification OAuth, CIMD lorsque supporté, allowlist de méthodes/outils, quotas, timeouts, egress contrôlé et journalisation structurée. Terraform peut gérer l’infrastructure ; GitHub Actions ou GitLab CI/CD valide schémas, compatibilité et tests de sécurité.

**Chemins de panne :** serveur indisponible → retry borné et circuit breaker ; outil lent → timeout et passage en Task ; catalogue obsolète → TTL/cache et nouvelle découverte ; instance supprimée → aucune dépendance à une session protocolaire ; serveur compromis → révocation, blocage egress et rotation des credentials.

## 7. DONNÉES, COMPATIBILITÉ ET CYCLE DE VIE

MCP transporte des enveloppes et résultats ; les données métier restent dans les systèmes appelés. Définir taille maximale, durée de rétention des logs, cache des listes et durée de vie des handles/Tasks. Valider les schémas JSON et les limites de profondeur/temps de validation.

La migration `2025-11-25` → `2026-07-28` doit tester : suppression de l’initialisation et de `Mcp-Session-Id`, version portée par requête, routage par headers, remplacement éventuel de server-initiated requests par MRTR, DCR/CIMD, Tasks et dépréciations. Prévoir un client ou serveur compatible ancienne version comme repli pendant la fenêtre de migration.

## 8. EXPLOITATION

SLO à qualifier : disponibilité du gateway et des serveurs, p95 de découverte/appel, taux d’erreur par outil, taux de timeout, durée des Tasks, fraîcheur des catalogues et coût par appel. Alertes : hausse `4xx/5xx`, erreurs d’autorisation, outils nouvellement exposés, catalogue changé, egress inattendu, backlog Tasks et absence de traces corrélées.

| Charge hypothétique | Ressource | Métrique | Décision |
|---|---|---|---|
| 10–100 appels/s | CPU gateway + serveur | p95, saturation, 5xx | ajouter instances si p95 dépasse le SLO |
| 100–1 000 outils listés | RAM/cache | taille catalogue, TTL, hit rate | réduire payload ou augmenter cache |
| 1–10 Tasks simultanées/client | stockage d’état applicatif | âge, backlog, expiration | purger/limiter et basculer vers async métier |
| gros résultats | réseau + stockage | octets, latence, taille réponse | préférer référence paginée et limite stricte |

Upgrade : tester chaque couple client/serveur/SDK sur un environnement éphémère, vérifier les headers et les outils critiques, puis canary. Rollback : revenir au couple précédent et au transport compatible ; ne pas supprimer les anciens chemins avant confirmation des clients actifs.

## 9. SÉCURITÉ ET RESPONSABILITÉS

Le serveur MCP est une frontière de confiance : least privilege par outil, validation d’arguments, séparation lecture/écriture, confirmation humaine pour actions sensibles, secrets hors prompts et journal d’audit immuable. Le gateway contrôle identité, TLS, rate limiting, egress et politiques ; l’équipe propriétaire du serveur contrôle le code, les dépendances, les scopes et les données retournées.

Ne pas confondre la présence d’un outil dans `tools/list` avec son autorisation réelle. Tester confused deputy, SSRF, injection de prompt dans les résultats, exfiltration via outils, replay de credentials, déni de service par réponses volumineuses et escalade entre serveur et client. Les comptes de service AWS/GCP/Kubernetes doivent être dédiés et bornés.

## 10. CHOIX ET LIMITES

MCP est pertinent si plusieurs clients doivent consommer un même catalogue d’outils ou si l’on veut découpler agents et intégrations. Une API REST/gRPC directe reste préférable pour un contrat métier stable, fortement typé et non agentique ; un bus de messages convient mieux aux workflows durables et volumineux. MCP ajoute une surface de gouvernance, de sécurité et de compatibilité : il ne doit pas devenir un passe-partout donnant accès à toute l’entreprise.

## 11. QUAND L’UTILISER / L’ÉVITER

À utiliser pour des outils agentiques réutilisables, des serveurs distants gouvernés et des intégrations où découverte et consentement comptent. À éviter pour une transaction critique synchrone sans besoin agentique, des payloads massifs, une automatisation nécessitant une garantie exactement une fois, ou un serveur dont les permissions ne sont pas isolables.

## 12. ÉVOLUTIONS DEPUIS LA DERNIÈRE CARTE

Première carte MCP dans ce dépôt ; l’évolution de référence est donc la comparaison officielle `2026-07-28` / `2025-11-25`.

- 28/07 : cœur stateless et suppression des sessions protocolaire ; impact : déploiement horizontal simplifié, migration obligatoire des clients dépendant de `Mcp-Session-Id`.
- 28/07 : MRTR, routage par headers et listes cacheables ; impact : gateway plus observable et moins dépendant de connexions longues.
- 28/07 : Tasks, MCP Apps et EMA dans le cadre d’extensions ; impact : fonctionnalités évolutives, mais compatibilité à vérifier par extension.
- 28/07 : CIMD privilégié et DCR déprécié ; impact : revoir l’enregistrement et la gestion des identités clients.
- 28/07 : Roots, Sampling, Logging et HTTP+SSE dépréciés ; décision : ne pas les introduire dans un nouveau composant.

## 13. LABORATOIRE GUIDÉ — 45 À 60 MINUTES

**Owner :** plateforme/IA. **Prérequis :** Node.js ou Python, Docker facultatif, un client MCP de test, aucune donnée sensible.

1. Figer un serveur MCP de démonstration et son SDK ; lancer une instance stdio puis une instance Streamable HTTP locale.
2. Capturer une requête de découverte/liste, vérifier version, capacités, cache hints et ordre des résultats.
3. Appeler un outil sans effet de bord puis provoquer un argument invalide et un timeout ; conserver codes, latences et traces.
4. Mettre deux instances HTTP derrière un proxy local round-robin et vérifier qu’aucune session protocolaire partagée n’est nécessaire.
5. Tester l’autorisation d’un outil, une limite de taille et l’expiration d’un cache ; documenter les écarts SDK.

**Mesures :** p95 appel, taux d’erreur, taille catalogue, hit rate cache, comportement lors du changement d’instance et temps de révocation. **Critère de réussite :** deux instances répondent en round-robin, un outil autorisé réussit, un outil interdit échoue, une entrée invalide est rejetée et aucun secret réel n’est transmis. **Nettoyage :** arrêter le serveur/proxy et supprimer les caches temporaires.

## 14. INCERTITUDES ET SOURCES

Inconnus : clients et SDK réellement utilisés, version négociée, serveurs MCP exposés, mécanisme d’IAM, gateway, SLO, volumétrie, données sensibles et propriétaire opérationnel. L’exposition réelle est `à qualifier`.

Sources primaires consultées :

- [Spécification MCP 2026-07-28](https://modelcontextprotocol.io/specification/2026-07-28)
- [Changelog 2026-07-28](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/docs/specification/2026-07-28/changelog.mdx)
- [Annonce de la release stable](https://github.com/modelcontextprotocol/modelcontextprotocol/blob/main/blog/content/posts/2026-07-28-spec-ga/index.md)
- [Détail des changements](https://blog.modelcontextprotocol.io/posts/2026-07-28/)
- [Feuille de route MCP du 22/08/2026](https://blog.modelcontextprotocol.io/posts/mcp-roadmap/)
- [Releases du dépôt de spécification](https://github.com/modelcontextprotocol/modelcontextprotocol/releases)

Sources en échec : aucune. Les détails d’implémentation des SDK et clients ne sont pas déduits de la spécification ; ils restent à vérifier dans les versions utilisées.
