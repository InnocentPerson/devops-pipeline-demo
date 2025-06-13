pipeline {
    agent any

    tools {
        maven 'Maven-3.8.6'
        jdk 'jdk21'  // Confirmed correct JDK tool name
    }

    environment {
        // Use your Docker Hub username
        DOCKER_IMAGE = "striverr/petclinic:${env.BUILD_NUMBER}"
        
        // Use consistent project key across all tools
        SONAR_PROJECT_KEY = "devops-pipeline-demo"
        
        // Kubernetes config paths
        K8S_DIR = "src/k8s"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                bat 'cd src && mvn clean package'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonarqube') {
                    // Use project key from environment variable
                    bat "cd src && mvn sonar:sonar -Dsonar.projectKey=${SONAR_PROJECT_KEY}"
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
                        // Use environment variables properly in Windows
                        bat "docker login -u %DOCKER_USER% -p %DOCKER_PASS%"
                    }
                    
                    // Build from root directory where Dockerfile exists
                    bat "docker build -t ${DOCKER_IMAGE} ."
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('', 'docker-hub-creds') {
                        docker.image("${DOCKER_IMAGE}").push()
                    }
                    // Also push as 'latest'
                    docker.image("${DOCKER_IMAGE}").push('latest')
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
            // Clean up workspace
            cleanWs()
        }
        success {
            // Add success notification (Slack/Email)
            echo "Pipeline succeeded!"
        }
        failure {
            // Add failure notification
            echo "Pipeline failed!"
        }
    }
}