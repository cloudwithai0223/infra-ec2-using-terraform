
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        TF_IN_AUTOMATION = 'true'
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
                bat 'terraform plan -input=false'
            }
        }
    }

    post {
        success {
            echo 'Terraform validation and plan completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check Console Output.'
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
}
