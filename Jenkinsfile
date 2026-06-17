@Library("Shared") _
pipeline{
    
    agent { label "worker" }
    
    stages{
        
        stage("Code"){
            steps{
                script{
                    clone("https://github.com/syedmehfooz47/3-tier-django-notes-app.git", "main")
                }
            }
        }
        
         stage('Building'){
             steps{
                 echo "This is building the code"
             }
         }
         stage('Test'){
             steps{
                 echo "This is testing the code"
             }
         }
         
         stage('Deploy'){
             steps{
                 echo 'This is deploying the code'
                 sh "docker compose up -d"
             }
         }
         
         
        }
    
}
