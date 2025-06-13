pipeline {
    agent any

    tools {
        gradle 'Gradle-8.5'      // ✅ Make sure this tool is configured in Jenkins
        jdk 'jdk21'              // ✅ Confirmed in Jenkins tools
    }

    environment {
        DOCKER_IMAGE = "striverr/devops-pipeline-demo:${env.BUILD_NUMBER}"
        SONAR_PROJECT_KEY = "devops-pipeline-demo"
        K8S_DIR = "src/k8s"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test with Gradle') {
            steps {
                bat 'cd src && gradlew.bat build'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    bat "cd src && gradlew.bat sonarqube -Dsonar.projectKey=${SONAR_PROJECT_KEY}"
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'docker-hub-creds',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
                        bat "docker build -t ${DOCKER_IMAGE} src"
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-creds') {
                        docker.image("${DOCKER_IMAGE}").push()
                        docker.image("${DOCKER_IMAGE}").push('latest')
                    }
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                withCredentials([azureServicePrincipal('AZURE_CREDS')]) {
                    bat '''
                    az login --service-principal -u %AZURE_CLIENT_ID% -p %AZURE_CLIENT_SECRET% --tenant %AZURE_TENANT_ID%
                    az aks get-credentials --resource-group devops-rg --name devops-cluster --admin
                    kubectl apply -f %K8S_DIR%/petclinic.yml
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "✅ Pipeline succeeded!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
