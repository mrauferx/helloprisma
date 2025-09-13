# helloprisma
This is a very basic Hello World application written with Node.

It includes a `Dockerfile` for building a Docker image with the application, and a `Jenkinsfile` that defines a build pipeline for it.
The pipeline will check out and scan the code using Palo Alto Prisma Cloud. 

If the scan passes muster, the pipeline will continue to build the image, then scan it for vulnerabilities and configuration conformance using Prisma Cloud.

If the image passes the scan it will be pushed to a local Harbor registry and then deployed to a local Kubernetes cluster using Helm.
The Dockerfile controls the base image to build from; change as needed to illustrate differences in vulnerability and compliance findings after scanning.

The scenario has been extended to use GitHub Actions as the pipeline to build, Palo Alto Cortex Cloud to scan, and deploy the application to Google Cloud GAR and GKE.

Access to Prisma or Cortex Cloud SaaS, a GCP project with GAR and GKE are required.
Credentials for Git, security tools, cluster, and registry must be defined in Jenkins or GitHub.

```markdown
CORTEX_API_KEY_ID	Cortex API key ID (for scanning)
CORTEX_API_KEY		Cortex API kes / secret (for scanning)
CORTEX_API_URL		Cortex API endpoint URL (for scanning)
GAR_PREFIX			Google artifact registry prefix (to do: set as variable, not as secret)
GCP_CREDENTIALS		GCP credentials - registry SA key json (for authentication; SA also has Kubernetes Engine Developer role for deployment)
GCP_PROJECT			GCP project ID (to do: set as variable, not as secret)
GKE_CLUSTER			GKE cluster name
GKE_ZONE			GKE cluster zone (to do: set as variable, not as secret)
```

Jenkins needs to run locally to the registry. Alternatively, change to push to a remote registry such as quay.io.
A RootCA.crt file is present, for now, on the Jenkins node to connect to the local registry. (to do: make this more generic)

```markdown
PC_USER             Prisma API key
PC_PASSWORD         Prisma API secret
REG_USER            local registry user
REG_PW              local registry password
```
