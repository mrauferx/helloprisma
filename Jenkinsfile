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

    //    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
    stage('Push image') {
        docker.withRegistry('https://harbor.localdomain', 'harbor-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
    
    stage('Deploy to Kubernetes') {
    //    kubernetesDeploy(configs: 'hellonode.yaml', kubeconfigId: 'mwm-k3s')
        withKubeConfig([credentialsId: 'mwm-k3s', serverUrl: 'https://192.168.30.10:6443']) {
            sh 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"'
            sh 'chmod +x ./kubectl'
            sh './kubectl create -f hellonode.yaml'
        }
    }
}
