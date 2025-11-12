# helloprisma
This is a very basic Hello World application written with Node.

## inputs
It includes a `Dockerfile` for building a Docker image with the application, a `Jenkinsfile` and `GitHub Actions` that define build pipelines for it, and a `Helm chart` that defines a Kubernetes deployment.

## outcomes
The pipeline will check out and scan the code using Palo Alto Cortex Cloud.

If the scan passes muster with a Cortex Cloud application security policy, the pipeline will continue to build the image, then scan it for vulnerabilities and configuration conformance using Cortex Cloud. The Dockerfile controls the build and base images; change as needed to illustrate differences in vulnerability and compliance findings after scanning.

If the image passes the scan threshold as defined in a Cortex Cloud vulnerability prevention policy, the pipeline creates an SBOM for the image and saves it as artifact.

The pipeline proceeds to push the image to a registry and deploy it to a Kubernetes cluster using Helm. The following choices are available:
1. Using GitHub Actions:
    - Google GAR and GKE
    - Azure ACR and AKS
    - AWS ECR and EKS
2. Using Jenkins:
    - Local Harbor and K3S (w.i.p.)
    - all of the above (w.i.p.)

## requirements
Access to Cortex Cloud SaaS, and either a GCP project with GAR and GKE, an Azure subscription with ACS and AKS, or an AWS account with ECS and EKR are required.

Credentials for GitHub, security tools, registries, and clusters must be defined in GitHub Action or Jenkins.

```markdown
CORTEX_API_KEY_ID	        Cortex API key ID (for scanning)
CORTEX_API_KEY		        Cortex API key / secret (for scanning)
CORTEX_API_URL		        Cortex API endpoint URL (for scanning)

GAR_PREFIX			        Google artifact registry prefix (to do: set as variable, not as secret)
GCP_CREDENTIALS		        GCP credentials - registry SA key json (for authentication; SA also has Kubernetes Engine Developer role for deployment)
GCP_PROJECT			        GCP project ID (to do: set as variable, not as secret)
GKE_CLUSTER			        GKE cluster name
GKE_ZONE			        GKE cluster zone (to do: set as variable, not as secret)

ACR_NAME                    Azure ACR registry name
AZURE_AKS_CLUSTER_NAME      AKS cluster name
AZURE_AKS_RESOURCE_GROUP    Azure resource group name
AZURE_CLIENT_ID             Client ID of Entra app (service account)
AZURE_CLIENT_SECRET         Client secret of Entra app
AZURE_CREDENTIALS           Json object combining client secret, subscription ID, and tenant ID and client ID
AZURE_SUBSCRIPTION_ID       Azure subscription ID
AZURE_TENANT_ID             Azure tenant ID

AWS_ACCESS_KEY_ID           AWS IAM user (service account) access key ID
AWS_EKS_CLUSTER_NAME        EKS cluster name
AWS_REGION                  AWS region
AWS_SECRET_ACCESS_KEY       IAM user secret access key

REG_USER                    local registry user
REG_PW                      local registry password
```

Cortex Cloud CLI is used for scanning in the pipelines. It requires the following:
- Java v11 or higher for image and API scans       pre-installed in a GitHub Action runner, activated via environment
- NodeJS v22 for code scans                        pre-installed in a GitHub Action runner
- Google Cloud CLI, Azure CLI, and AWS CLI         pre-installed in a GitHub Action runner
- all aove to be included with Jenkins node (w.i.p.)

For on-premises / self-hosted scenarios, Jenkins needs to run locally to the Harbor registry. A RootCA.crt file needs to be present on the Jenkins node to connect to the local registry. (to do: make this more generic). A Cortex Cloud Broker VM is also required to scan the local registry.
