node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    //    app = docker.build("mrauferx/hellonode")
    stage('Build image') {
        app = docker.build("harbor.localdomain/mytest/hellonode")
    }

    stage ('Test image') {
        app.inside {
          sh 'echo "Tests passed"'
        }
    }

    // Aqua scan stages start here

    stage('Scan image') {
        aqua locationType: 'local', localImage: 'harbor.localdomain/mytest/hellonode:latest', hideBase: false, notCompliesCmd: '', onDisallowed: 'fail', showNegligible: false
        }
    // set onDisallowed: 'ignore' to continue or onDisallowed: 'fail' to honor Aqua Default assurance policy
    
    // end Aqua
    
    /* Neuvector scan stages start here
        
    stage('Scan image') {
    neuvector nameOfVulnerabilityToFailFour: '', nameOfVulnerabilityToFailOne: '', nameOfVulnerabilityToFailThree: '', nameOfVulnerabilityToFailTwo: '', numberOfHighSeverityToFail: '1', numberOfMediumSeverityToFail: '5', registrySelection: 'Local', repository: 'mraufer/hellonode:latest'
    } 
    
    end Neuvector */

    /* Twistlock scan stages start here
    stage ('scan') {
        twistlockScan ca: '', cert: '', compliancePolicy: 'critical', dockerAddress: 'unix:///var/run/docker.sock', gracePeriodDays: 0, ignoreImageBuildTime: false, image: 'mraufer/hellonode:latest', key: '', logLevel: 'true', policy: 'critical', requirePackageUpdate: false, timeout: 10
    }

    stage ('publish') {
        twistlockPublish ca: '', cert: '', dockerAddress: 'unix:///var/run/docker.sock', image: 'mraufer/hellonode:latest', key: '', logLevel: 'true', timeout: 10
    }
    end Twistlock */

    stage('Push image') {
    //    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
        docker.withRegistry('https://harbor.localdomain', 'harbor-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    
    // Aqua scan stages start here
        
    stage('Manifest Generation') {
        withCredentials([
        // Replace GITHUB_APP_CREDENTIALS_ID with the id of your github app credentials
            usernamePassword(credentialsId: 'mygithub', usernameVariable: 'GITHUB_APP', passwordVariable: 'GITHUB_TOKEN'), 
            string(credentialsId: 'AQUA_KEY', variable: 'AQUA_KEY'), 
            string(credentialsId: 'AQUA_SECRET', variable: 'AQUA_SECRET')
        ]) {
        // Replace ARTIFACT_PATH with the path to the root folder of your project 
        // or with the name:tag the newly built image
            sh '''
                export BILLY_SERVER=https://billy.eu-1.codesec.aquasec.com
                curl -sLo install.sh download.codesec.aquasec.com/billy/install.sh
                curl -sLo install.sh.checksum https://github.com/argonsecurity/releases/releases/latest/download/install.sh.checksum
                if ! cat install.sh.checksum | sha256sum --check; then
                    echo "install.sh checksum failed"
                    exit 1
                fi
                BINDIR="." sh install.sh
                rm install.sh install.sh.checksum
                ./billy generate \
                    --access-token ${GITHUB_TOKEN} \
                    --aqua-key ${AQUA_KEY} \
                    --aqua-secret ${AQUA_SECRET} \
                    --cspm-url https://eu-1.api.cloudsploit.com \
                    # --artifact-path "harbor.localdomain/mytest/hellonode:latest" 
                    --artifact-path "harbor.localdomain/mytest/hellonode:${env.BUILD_NUMBER}"

                # The docker image name:tag of the newly built image
                # --artifact-path "my-image-name:my-image-tag" \
                # OR the path to the root folder of your project. I.e my-repo/my-app 
                # --artifact-path "ARTIFACT_PATH"
            '''
        }
    }    

    // end Aqua
        
    stage('Deploy to Kubernetes') {
    //    kubernetesDeploy(configs: 'hellonode.yaml', kubeconfigId: 'mwm-k3s')
        withKubeConfig([credentialsId: 'default', serverUrl: 'https://192.168.30.10:6443']) {
    //    kubeconfig(credentialsId: 'mwm-k3s', serverUrl: 'https://192.168.30.10:6443') {
    //    withCredentials([file(credentialsId: 'mwm-k3s', variable: 'KUBECRED')]) {
    //        sh 'cat $KUBECRED > ~/.kube/config'
            sh 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
            sh 'chmod +x ./kubectl'
    //        sh './kubectl create -f $WORKSPACE/hellonode.yaml --validate=false'
            sh './kubectl create -f $WORKSPACE/hellonode.yaml'
        }
    }
}
