node {
    // ----- Configuration -----
    def IMAGE_NAME = "mrauferx/helloprisma"
    def IMAGE_TAG = "${env.BUILD_NUMBER}"
    def HELM_RELEASE_NAME = "helloprisma"
    def HELM_CHART_PATH = "helm"

    stage('Init') {
        withCredentials([
            string(credentialsId: 'ACR_NAME', variable: 'ACR_NAME'),
            string(credentialsId: 'ACR_LONG_NAME', variable: 'ACR_LONG_NAME'),
            string(credentialsId: 'AKS_RESOURCE_GROUP', variable: 'AKS_RESOURCE_GROUP'),
            string(credentialsId: 'AKS_CLUSTER_NAME', variable: 'AKS_CLUSTER_NAME')
        ]) {
            env.ACR_NAME = ACR_NAME
            env.ACR_LONG_NAME = ACR_LONG_NAME
            env.AKS_RESOURCE_GROUP = AKS_RESOURCE_GROUP
            env.AKS_CLUSTER_NAME = AKS_CLUSTER_NAME
        }
    }

    try {
        stage('Checkout') {
            checkout scm
        }

        // --- PLACEHOLDER: Palo Alto Cortex Scan ---
        // You can insert your scan stage here.

        stage('Azure Login') {
            withCredentials([
                azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS',
                                    subscriptionIdVariable: 'SUBS_ID',
                                    clientIdVariable: 'CLIENT_ID',
                                    clientSecretVariable: 'CLIENT_SECRET',
                                    tenantIdVariable: 'TENANT_ID')
            ]) {
                sh '''
                    az login --service-principal -u $CLIENT_ID -p $CLIENT_SECRET -t $TENANT_ID
                    #az account set --subscription $SUBS_ID
                    #az account show
                    #env
                '''
            }
        }

        stage('Build Docker Image') {
            echo "Building Docker image..."
            sh """
                docker build -t ${ACR_LONG_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} .
                docker tag ${ACR_LONG_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG} ${ACR_LONG_NAME}.azurecr.io/${IMAGE_NAME}:latest
            """
        }

        // --- PLACEHOLDER: Palo Alto Cortex Scan ---
        // You can insert your scan stage here.

        stage('Push to ACR') {
            withCredentials([
                azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS',
                                    subscriptionIdVariable: 'SUBS_ID',
                                    clientIdVariable: 'CLIENT_ID',
                                    clientSecretVariable: 'CLIENT_SECRET',
                                    tenantIdVariable: 'TENANT_ID')
            ]) {
                echo "Pushing image to Azure Container Registry..."
                sh """
                    docker login ${ACR_LONG_NAME}.azurecr.io -u ${CLIENT_ID} -p ${CLIENT_SECRET}
                    #az acr login --name ${ACR_LONG_NAME}.azurecr.io
                    docker push ${ACR_LONG_NAME}.azurecr.io/${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${ACR_LONG_NAME}.azurecr.io/${IMAGE_NAME}:latest
                """
            }
        }

        stage('Deploy to AKS') {
            echo "Deploying to AKS via Helm..."
            sh """
                az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $AKS_CLUSTER_NAME --overwrite-existing

                # may be required to get kubelogin
                az aks install-cli
                kubelogin convert-kubeconfig -l azurecli
        
                helm upgrade --install "${HELM_RELEASE_NAME}" "${HELM_CHART_PATH}" \\
                    --create-namespace \\
                    --namespace "${HELM_RELEASE_NAME}" \\
                    --set image.repository=${ACR_LONG_NAME}.azurecr.io/"${IMAGE_NAME}" \\
                    --set image.tag=${IMAGE_TAG} \\
                    --set dockerConfigJson.data="$(cat ~/.docker/config.json | base64 -w 0)"
            """
        }

    } catch (err) {
        echo "❌ Pipeline failed: ${err}"
        currentBuild.result = 'FAILURE'
        throw err
    } finally {
        stage('Cleanup') {
            echo "Cleaning up Docker images..."
            sh 'docker system prune -f || true'
        }
    }

    echo "✅ Deployment completed successfully!"
}
