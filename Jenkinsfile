pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        TF_IN_AUTOMATION = 'true'
        AWS_DEFAULT_REGION = 'ap-south-1'
    }

    stages {
        stage('Check Terraform') {
            steps {
                bat 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                bat 'terraform init -input=false'
            }
        }

        stage('Verify AWS Connection') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    bat 'aws sts get-caller-identity'
                }
            }
        }

        stage('Format Check') {
            steps {
                bat 'terraform fmt -check -recursive'
            }
        }

        stage('Validate') {
            steps {
                bat 'terraform validate'
            }
        }

        stage('Plan Only') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    bat 'terraform plan -input=false -out=tfplan'
                    bat 'terraform show -no-color tfplan'
                }
            }
        }

        stage('Manager Approval') {
            steps {
                input(
                    message: 'Review the Terraform plan. Approve to deploy changes to AWS.',
                    ok: 'Approve and Apply'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-terraform-creds'
                ]]) {
                    bat 'terraform apply -input=false tfplan'
                }
            }
        }
    }

    post {
        success {
            echo 'Terraform pipeline completed successfully, including apply.'
        }

        failure {
            echo 'Pipeline failed. Check Console Output.'
        }

        aborted {
            echo 'Pipeline was aborted or approval was rejected.'
        }
    }
}
