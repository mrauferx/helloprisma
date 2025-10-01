node {
    // not sure this is needed
    def app

    /* Prisma content
    stage('Clone repository') {
        checkout scm
    }

    // Prisma scan stages start here
    stage('Scan Code') {
        // Use credentials
        withCredentials([
            string(credentialsId: 'PC_USER', variable: 'pc_user'),
            string(credentialsId: 'PC_PASSWORD', variable: 'pc_password')
        ]) {
            // Use Docker image
            docker.image('bridgecrew/checkov:latest').inside("--entrypoint=''") {
                // Unstash source code - why?
                // unstash 'source'
                // Try block for running Checkov
                try {
                    sh '''
                        export PRISMA_API_URL=https://api.prismacloud.io
                        checkov -d . \
                            --use-enforcement-rules \
                            -o cli -o junitxml \
                            --output-file-path console,results.xml \
                            --bc-api-key ${pc_user}::${pc_password} \
                            --repo-id mrauferx/helloprisma \
                            --branch master
                    '''
                    junit skipPublishingChecks: true, testResults: 'results.xml'
                } catch (err) {
                    junit skipPublishingChecks: true, testResults: 'results.xml'
                    throw err
                }
            }
        }
    }
    // end Prisma
          
    stage('Build Image') {
        app = docker.build("harbor.localdomain/mytest/helloprisma")
    }

    stage ('Test Image') {
        app.inside {
          sh 'echo "Tests passed"'
        }
    }
 
    /* Twistlock scan stages start here
    stage ('scan') {
        twistlockScan ca: '', cert: '', compliancePolicy: 'critical', dockerAddress: 'unix:///var/run/docker.sock', gracePeriodDays: 0, ignoreImageBuildTime: false, image: 'mraufer/hellonode:latest', key: '', logLevel: 'true', policy: 'critical', requirePackageUpdate: false, timeout: 10
    }

    stage ('publish') {
        twistlockPublish ca: '', cert: '', dockerAddress: 'unix:///var/run/docker.sock', image: 'mraufer/hellonode:latest', key: '', logLevel: 'true', timeout: 10
    }
    end Twistlock 

    // Prisma scan stages start here
    // using Jenkins plug-in:
    stage ('Prisma Cloud scan') {
        prismaCloudScanImage ca: '',
                    cert: '',
                    dockerAddress: 'unix:///var/run/docker.sock',
                    image: 'harbor.localdomain/mytest/helloprisma:latest',
                    resultsFile: 'prisma-cloud-scan-results.xml',
                    project: '',
                    ignoreImageBuildTime: true,
                    key: '',
                    logLevel: 'info',
                    podmanPath: '',
                    sbom: 'cyclonedx_json',
                    // compliancePolicy: 'critical',
                    // gracePeriodDays: 0,
                    // policy: 'critical', 
                    // requirePackageUpdate: false, 
                    timeout: 10
                    // containerized: true
    }

    stage ('Prisma Cloud publish') {
        prismaCloudPublish resultsFilePattern: 'prisma-cloud-scan-results.json'
    }
    // end Prisma

    stage('Push Image') {
        docker.withRegistry('https://harbor.localdomain', 'harbor-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
        
    /* Prisma scan stages start here
    stage('Manifest Generation') {
        // sbom t.b.d.
        }
    }    
    end Prisma */

    /*
    stage('Deploy to Kubernetes') {
        withKubeConfig([credentialsId: 'default', serverUrl: 'https://192.168.30.10:6443']) {
            withCredentials([
                usernamePassword(credentialsId: 'harbor-credentials', usernameVariable: 'REG_USER', passwordVariable: 'REG_PW')
                ]) {
                sh '''
                    helm registry login --ca-file RootCA.crt -u ${REG_USER} -p ${REG_PW} harbor.localdomain
                    helm upgrade --ca-file RootCA.crt --install --create-namespace --namespace hellonode helloprisma oci://harbor.localdomain/helm-charts/helloprisma --set image.tag=$BUILD_NUMBER,imageCredentials.username=${REG_USER},imageCredentials.password=${REG_PW}
                '''
            } 
        }
    }
    
} 

node {
    */
    // Cortex XDR scan stages start here - only code scan sample available, not image scan nor sbom creation
    // using CLI binary instead of CLI Docker container
    docker.image('cimg/node:22.17.0').inside('-u root') {
        
        // Set environment variables
        withCredentials([
            string(credentialsId: 'CORTEX_API_KEY', variable: 'CORTEX_API_KEY'),
            string(credentialsId: 'CORTEX_API_KEY_ID', variable: 'CORTEX_API_KEY_ID')
        ]) {
            env.CORTEX_API_URL = 'https://api-unifiedcloudsecops.xdr.us.paloaltonetworks.com'

            stage('Clone repository') {
                checkout scm
            }

            stage('Install Dependencies') {
                sh '''
                    apt update
                    apt install -y curl jq git
                '''
            }

            stage('Download cortexcli') {
                script {
                    def response = sh(script: """
                        curl --location '${env.CORTEX_API_URL}/public_api/v1/unified-cli/releases/download-link?os=linux&architecture=amd64' \
                          --header 'Authorization: ${env.CORTEX_API_KEY}' \
                          --header 'x-xdr-auth-id: ${env.CORTEX_API_KEY_ID}' \
                          --silent
                    """, returnStdout: true).trim()

                    def downloadUrl = sh(script: """echo '${response}' | jq -r '.signed_url'""", returnStdout: true).trim()

                    sh """
                        curl -o cortexcli '${downloadUrl}'
                        chmod +x cortexcli
                        ./cortexcli --version
                    """
                }
            }

            stage('Run Code Scan') {
                script {
                    unstash 'source'

                    sh """
                        ./cortexcli \
                          --api-base-url "${env.CORTEX_API_URL}" \
                          --api-key "${env.CORTEX_API_KEY}" \
                          --api-key-id "${env.CORTEX_API_KEY_ID}" \
                          code scan \
                          --directory "\$(pwd)" \
                          --repo-id "mrauferx/helloprisma" \
                          --branch "master" \
                          --source "JENKINS" \
                          --create-repo-if-missing
                    """
                }
            }
        }
    }
}
