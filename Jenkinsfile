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
        
        stage('Get EC2 Public IP') {
            steps {
                script {
                    env.EC2_PUBLIC_IP = bat(
                        script: '@terraform output -raw ec2_public_ip',
                        returnStdout: true
                    ).trim()

                    if (!env.EC2_PUBLIC_IP) {
                        error('Terraform did not return an EC2 public IP.')
                    }

                    echo "EC2 public IP: ${env.EC2_PUBLIC_IP}"
                }
            }
        }

        stage('Wait for EC2 SSH') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    retry(30) {
                        sleep time: 10, unit: 'SECONDS'
                        bat 'ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new -o ConnectTimeout=5 %SSH_USER%@%EC2_PUBLIC_IP% "echo SSH is ready"'
                    }
                }
            }
        }

        stage('Copy Docker Files to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    bat 'ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new %SSH_USER%@%EC2_PUBLIC_IP% "rm -rf /tmp/docker-nginx /tmp/deploy-docker.sh"'

                    bat 'scp -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new -r docker-nginx %SSH_USER%@%EC2_PUBLIC_IP%:/tmp/'

                    bat 'scp -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new scripts/deploy-docker.sh %SSH_USER%@%EC2_PUBLIC_IP%:/tmp/deploy-docker.sh'
                }
            }
        }

        stage('Install Docker and Deploy Nginx') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    bat 'ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new %SSH_USER%@%EC2_PUBLIC_IP% "sudo rm -rf /opt/docker-nginx && sudo mv /tmp/docker-nginx /opt/docker-nginx && sudo bash /tmp/deploy-docker.sh"'
                }
            }
        }

        stage('Verify Nginx Website') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    bat 'ssh -i "%SSH_KEY%" -o StrictHostKeyChecking=accept-new %SSH_USER%@%EC2_PUBLIC_IP% "curl -fsS http://localhost:8080/"'

                    echo "Website URL: http://${env.EC2_PUBLIC_IP}:8080"
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
