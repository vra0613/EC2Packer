pipeline {
    agent any

    environment {
        PACKER_PATH = '/usr/local/bin'
        AWS_REGION = 'eu-central-1'
        AWS_ACCESS_KEY_ID = 'AKIAWXMJD7E4NKCL7EMH'
        AWS_SECRET_ACCESS_KEY = '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'
        PACKER_TEMPLATE = '/usr/local/bin/packer.hcl'
    } 

    stages {
        stage('Checkout') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'git', url: 'https://github.com/PriyankaJ6/Masterjenkins.git']])
            }
        }
        stage('INIT PACKER') {
            steps {
                script {
                  sh 'packer init .'
                }
            }
        }
    }
} 
