pipeline {
    agent any
    tools {
        maven 'Maven-Build'
    }
    parameters {
        string(name: 'SDLC_ENV', defaultValue: '', description: 'Enter SDLC Environment')
    }
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL}"
                dir("${env.WORKSPACE}"){
                    sh "pwd"
                    sh 'mvn clean install -f pom.xml'
                }
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                echo "${params.SDLC_ENV} is value retrieved!"
            }
        }
        stage('DeployToDev') {
            when {
                environment name: 'SDLC_ENV', value: 'dev'
            }
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat_creds', path: '', url: 'http://172.31.41.46:8080/')], contextPath: 'dev-java-tomcat-pipeline-sample', war: '**/*.war'
            }
        }
        stage('DeployToQa') {
            when {
                environment name: 'SDLC_ENV', value: 'qa'
            }
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat_creds', path: '', url: 'http://172.31.41.46:8080/')], contextPath: 'qa-java-tomcat-pipeline-sample', war: '**/*.war'
            }
        }
        stage('DeployToProd') {
            when {
                environment name: 'SDLC_ENV', value: 'prod'
            }
            steps {
                deploy adapters: [tomcat9(credentialsId: 'tomcat_creds', path: '', url: 'http://172.31.41.46:8080/')], contextPath: 'prod-java-tomcat-pipeline-sample', war: '**/*.war'
            }
        }
    }
    post {
        always {
            archiveArtifacts artifacts: 'new-project-jenkins-docker/target/*.war', fingerprint: true
        }
    }
}
