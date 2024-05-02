pipeline {
    agent any

    environment {
        PACKER_PATH = '/usr/local/bin'
        AWS_REGION = 'eu-central-1'
        AWS_ACCESS_KEY_ID = ''
        AWS_SECRET_ACCESS_KEY = ''
        PACKER_TEMPLATE = '/usr/local/bin/packer.pkr.hcl'
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
        stage('VALIDATE PACKER') {
            steps {
                script {
                  sh 'packer validate .'
                }
            }
        }
        stage('BUILD PACKER') {
            steps {
                script {
                  sh 'packer build ${PACKER_TEMPLATE}'
                }
            }
        }
    }
}    

