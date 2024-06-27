String terraformPlanCommand = 'terraform plan -out=tfplan'

pipeline {
    agent any
    environment {
        // Add the workspace directory to PATH for the entire pipeline
        PATH = "${env.PATH}:${env.WORKSPACE}"
    }
    stages {
        stage('Clean Workspace') {
            steps {
                deleteDir()
            }
        }
        stage('Checkout from Git') {
            steps{
                checkout scmGit(branches: [[name: '*/master']], extensions: [],
                userRemoteConfigs: [[url: 'https://github.com/SiddharthLucky/Terraform-Teamplate']])
            }
        }
        stage('Install Terraform and check if it is running') {
            steps {
                script {
                    sh 'curl -LO https://releases.hashicorp.com/terraform/1.9.0/terraform_1.9.0_linux_amd64.zip'
                    sh 'unzip terraform_1.9.0_linux_amd64.zip'
                    sh 'chmod +x terraform'
                    sh 'terraform --version'
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    echo 'Performing Terraform Init'
                    sh """
                    export AWS_ACCESS_KEY_ID=${params.AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${params.AWS_SECRET_ACCESS_KEY}
                    export AWS_SESSION_TOKEN=${params.AWS_SESSION_TOKEN}
                    terraform init
                    """
                }
            }
        }
        stage('Terraform Plan') {
            steps {
                script {
                    echo 'Performing Terraform Plan'
                    sh """
                    export AWS_ACCESS_KEY_ID=${params.AWS_ACCESS_KEY_ID}
                    export AWS_SECRET_ACCESS_KEY=${params.AWS_SECRET_ACCESS_KEY}
                    export AWS_SESSION_TOKEN=${params.AWS_SESSION_TOKEN}
                    ${terraformPlanCommand}
                    """
                }
            }
        }
        stage('Terraform Apply') {
            steps {
                script {
                    echo 'Performing Terraform Apply'
                    int planExitCode = sh(returnStatus: true, script: terraformPlanCommand)
                    if (planExitCode == 0) {
                        sh """
                        export AWS_ACCESS_KEY_ID=${params.AWS_ACCESS_KEY_ID}
                        export AWS_SECRET_ACCESS_KEY=${params.AWS_SECRET_ACCESS_KEY}
                        export AWS_SESSION_TOKEN=${params.AWS_SESSION_TOKEN}
                        terraform apply -auto-approve tfplan
                        """
                    } else {
                        error 'Terraform plan failed. Aborting Terraform Apply.'
                    }
                }
            }
        }
        stage('Terraform Destroy') {
            steps {
                script {
                    echo 'Performing Terraform Destroy'
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

    // stage('Check if Docker is installed') {
    //     steps{
    //         script {
    //             sh 'docker --version'
    //         }
    //     }
    // }
    // stage('Build docker image') {
    //     steps{
    //         script {
    //             sh 'docker build -t testImage:latest .'
    //         }
    //     }
    // }
    }
}
