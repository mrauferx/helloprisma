node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
    //    app = docker.build("mraufer/hellonode")
        app = docker.build("harbor.localdomain/mytest/hellonode")
    }

    stage ('Test image') {
        app.inside {
          sh 'echo "Tests passed"'
        }
    }

    // Aqua scan stages start here
    // eventually

    stage('Scan image') {
        aqua locationType: 'local', localImage: 'harbor.localdomain/mytest/hellonode:latest', hideBase: false, notCompliesCmd: '', onDisallowed: 'ignore', showNegligible: false
        }
    
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
}
