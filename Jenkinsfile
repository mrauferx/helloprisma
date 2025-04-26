node {
    def app

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
    end Twistlock */

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
    */
}
