# SENTINELLE DEVOPS — 2026-08-27

Fenêtre : changements vérifiés depuis la dernière exécution. Exposition de la stack : partiellement inconnue.

## RÉSULTAT

### Aucun signal prioritaire de production confirmé

La sortie de Kubernetes `1.37.0` est une évolution à qualifier, pas une urgence de production. L’incident Elastic Cloud du 26 août concernant des endpoints APM Serverless est résolu ; l’exposition de la stack de Mehdi à Serverless est inconnue.

## À QUALIFIER

**Elastic Cloud / APM Serverless — endpoint APM indisponible pendant environ neuf heures le 26 août**

- Verdict : `à qualifier` ;
- Fait : Elastic indique qu’une modification des Managed Inputs a supprimé des endpoints `.apm` pour certains projets Serverless ; le service a été restauré ;
- Impact possible : perte d’ingestion APM ou de visibilité applicative si un projet Serverless est utilisé ;
- Action sous 48 h : vérifier si un endpoint APM Serverless est utilisé et si des traces ont manqué ;
- Owner : observabilité, à désigner ;
- Statut : `à faire` ;
- Clôture : confirmer `non utilisé`, ou produire la preuve qu’aucune perte de télémétrie n’a affecté un service critique ;
- Confiance : élevée sur l’incident, inconnue sur l’exposition.

Source primaire : https://status.elastic.co/

## SUJETS ÉCARTÉS

- Kubernetes `1.37.0` : sortie confirmée, mais aucune action immédiate sans connaître les versions des clusters et le support EKS/GKE ;
- Terraform `1.16.0` : version disponible, mais pas de breaking change confirmé dans la fenêtre et exposition inconnue ;
- signaux IA et dépôts GitHub tendances : signaux de découverte, sans preuve d’exposition ni d’urgence.

## SOURCES CONSULTÉES

- Kubernetes release : https://kubernetes.io/releases/1.37/ ;
- Elastic status : https://status.elastic.co/ ;
- Elastic release notes : https://www.elastic.co/docs/release-notes ;
- HashiCorp releases : https://releases.hashicorp.com/terraform/.

## Publication

Livrable local généré le 27 août 2026. Le hash du commit de publication sera la preuve locale.
