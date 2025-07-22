pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = "<REPLACE_ME>"
        AWS_DEFAULT_REGION = "us-east-2"
        CLUSTER_NAME = "ahmad-ecs-cluster-terra"
        SERVICE_NAME = "ahmad-service-terra"
        TASK_DEFINITION_NAME = "ahmad-taskdef-terra"
        DESIRED_COUNT = "2"
        IMAGE_REPO_NAME = "ahmad-repo-terra"
        IMAGE_TAG = "${env.BUILD_ID}"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
        registryCredential = "aws-jenkins"
    }

    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("${IMAGE_REPO_NAME}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    docker.withRegistry("https://${REPOSITORY_URI}", "ecr:${AWS_DEFAULT_REGION}:${registryCredential}") {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                withAWS(credentials: registryCredential, region: "${AWS_DEFAULT_REGION}") {
                    sh 'chmod +x script.sh && ./script.sh'
                }
            }
        }
    }

    post {
        always {
            sh 'docker system prune -a -f'
        }
    }
}
