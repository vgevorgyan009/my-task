
pipeline {
  agent any
  stages {
    stage("provision server and simple webapp deploying") {
        environment {
            AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
            AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        }
        steps {
            script {
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
            }
        }
    }
   }
}
