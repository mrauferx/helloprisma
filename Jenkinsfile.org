node {
    def app

    stage('Clone repository') {
        checkout scm
    }

    stage('Build image') {
        app = docker.build("invhariharan/hellonode")
    }

    stage('Test image') {
        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage ('scan') {
        twistlockScan ca: '', cert: '', compliancePolicy: 'critical', dockerAddress: 'unix:///var/run/docker.sock', gracePeriodDays: 0, ignoreImageBuildTime: false, image: 'invhariharan/hellonode', key: '', logLevel: 'true', policy: 'critical', requirePackageUpdate: false, timeout: 10
    }

    stage('Push image') {
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }
}
