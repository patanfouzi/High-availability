pipeline {
    agent any

    environment {
        TERRAFORM_DIR = "/var/lib/jenkins/workspace/auto-scale-job"
    }

    stages {
        stage('Check Terraform Setup') {
            steps {
                script {
                    echo "🔍 Checking Terraform setup and workspace..."
                    sh "terraform -version"
                    sh "ls -l ${TERRAFORM_DIR}"
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    sh "terraform init"
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    echo "📋 Planning Terraform deployment..."
                    sh "terraform plan -out=tfplan"
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    echo "🚀 Applying Terraform deployment..."
                    sh "terraform apply -auto-approve tfplan"
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                dir("${TERRAFORM_DIR}") {
                    echo "🗑️ Destroying Terraform-managed infrastructure..."
                    sh "terraform destroy -auto-approve"
                }
            }
        }
    }

    post {
        failure {
            echo "❌ Pipeline failed. Check above logs for the exact error."
        }
        success {
            echo "✅ Pipeline completed successfully!"
        }
    }
}
