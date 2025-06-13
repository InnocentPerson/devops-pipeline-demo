pipeline {
    agent any
    tools {
        maven 'Maven-3.8.6'
        jdk 'jdk21'  // Changed from JDK-17 to jdk21 (as configured)
    }
    environment {
        DOCKER_IMAGE = "your-dockerhub-username/petclinic:${env.BUILD_NUMBER}"
        KUBE_CONFIG = "--kubeconfig=${env.HOME}/.kube/config"
    }
    stages {
        stage('Build & Test') {
            steps {
                bat 'cd src && mvn clean package'  // Changed sh to bat for Windows
            }
        }
        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    bat 'cd src && mvn sonar:sonar -Dsonar.projectKey=petclinic'  // Added projectKey
                }
            }
        }
        // ▼▼▼ NEW QUALITY GATE STAGE ▼▼▼
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        // ▲▲▲ END OF NEW STAGE ▲▲▲
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Deploy to AKS') {
            steps {
                bat """  // Changed to bat
                cd src\\k8s
                kubectl apply -f petclinic.yml
                """
            }
        }
    }
}