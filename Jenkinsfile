pipeline {
    agent any

    tools {
        maven 'maven3.9'
    }

    environment {
        deploy_DB = "true"
        DB_HOST   = "100.56.248.108"
        APP_HOST  = "32.196.116.4"

        DB_NAME   = "acada_db"
        DB_USER   = "acada_user"
        DB_PASS   = "acada_pass"
    }

    stages {

        stage("Git Checkout") {
            steps {
                git branch: 'main', url: 'https://github.com/OnomeVera/acada-webapp2.git'
            }
        }
        stage("sonar scan"){
            steps{
                withCredentials([string(
                    credentialsId: 'sonar_token', 
                    variable: 'SONAR_TOKEN'
                    )]) {
                        sh '''
                    mvn clean verify sonar:sonar \
                     -Dsonar.projectKey=acada-webapp \
                     -Dsonar.projectName='acada-webapp' \
                     -Dsonar.host.url=http://18.208.148.250:9000 \
                     -Dsonar.token=${SONAR_TOKEN}
                
                
                  '''
    
}
                
            }
        }

        stage("Maven Packaging") {
            steps {
                sh 'mvn clean package'
            }
        }

        stage("Image Build & Push") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER-PAT',
                    passwordVariable: 'DOCKERHUB_PASS',
                    usernameVariable: 'DOCKERHUB_USER'
                )]) {
                    sh '''
                        echo "$DOCKERHUB_PASS" | docker login -u "$DOCKERHUB_USER" --password-stdin
                        docker build -t onomeoviero/acada-webapp:latest .
                        docker push onomeoviero/acada-webapp:latest
                    '''
                }
            }
        }
        stage("Archive Artifact on NEXUS"){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'Nexus_cred', 
                    passwordVariable: 'NEXUS_PASSWORD', 
                    usernameVariable: 'NEXUS_USER')])
                     {
                        sh ' mvn deploy -Drepo.login=${NEXUS_USER} -Drepo.password=${NEXUS_PASSWORD} -s settings.xml'
    
                        }
            }
        }

        stage("Deploy: DATABASE") {
            steps {
                script {
                    if (env.deploy_DB == "true") {

                        withCredentials([sshUserPrivateKey(
                            credentialsId: 'DB-HOST',
                            keyFileVariable: 'DB_SSH_KEY',
                            usernameVariable: 'DB_SSH_USER'
                        )]) {

                            sh '''
                                echo "POSTGRES_USER=$DB_USER" > .env
                                echo "POSTGRES_PASSWORD=$DB_PASS" >> .env

                                scp -o StrictHostKeyChecking=no -i "$DB_SSH_KEY" .env init-db.sql $DB_SSH_USER@$DB_HOST:/home/$DB_SSH_USER/

                                ssh -o StrictHostKeyChecking=no -i "$DB_SSH_KEY" $DB_SSH_USER@$DB_HOST '
                                    mkdir -p ~/web-app-db &&
                                    mv ~/init-db.sql ~/web-app-db/ || true &&
                                    mv ~/.env ~/web-app-db/.env || true &&
                                    docker rm -f acada-postgres || true &&
                                    docker run -d \
                                      --name acada-postgres \
                                      -p 5432:5432 \
                                      -v ~/web-app-db/init-db.sql:/docker-entrypoint-initdb.d/init-db.sql \
                                      --env-file ~/web-app-db/.env \
                                      postgres:15-alpine
                                '
                            '''
                        }
                    }
                }
            }
        }

        stage("Deploy APPLICATION") {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'DOCKER-PAT',
                        passwordVariable: 'DOCKERHUB_PASS',
                        usernameVariable: 'DOCKERHUB_USER'
                    )
                ]) {

                    sh '''
                        echo DB_HOST=$DB_HOST > .env
                        echo DB_PORT=5432 >> .env
                        echo DB_NAME=$DB_NAME >> .env
                        echo DB_USERNAME=$DB_USER >> .env
                        echo DB_PASSWORD=$DB_PASS >> .env
                    '''

                    withCredentials([sshUserPrivateKey(
                        credentialsId: 'DB-HOST',
                        keyFileVariable: 'APP_SSH_KEY',
                        usernameVariable: 'APP_SSH_USER'
                    )]) {

                        sh '''
                            scp -o StrictHostKeyChecking=no -i "$APP_SSH_KEY" .env $APP_SSH_USER@$APP_HOST:~/web-app/
                        '''

                        sh '''
                            ssh -o StrictHostKeyChecking=no -i "$APP_SSH_KEY" $APP_SSH_USER@$APP_HOST '
                                set -e

                                echo "'"$DOCKERHUB_PASS"'" | docker login -u "'"$DOCKERHUB_USER"'" --password-stdin

                                docker rm -f acada-app || true

                                docker pull onomeoviero/acada-webapp:latest

                                docker run -d \
                                  --name acada-app \
                                  -p 8081:8080 \
                                  --env-file ~/web-app/.env \
                                  onomeoviero/acada-webapp:latest
                            '
                        '''
                    }
                }
            }
        }
    }
}




// pipeline{
//     agent {
//         label 'acada-node'
//     }
//     tools {
//         maven 'mvn3.9'
//     }
//     environment {
//         DEPLOY_DB = 'True'
//         DB_HOST = '3.96.167.29'
//         NEXUS_HOST = "15.222.6.124"
//         SONARQUBE_HOST = "15.222.233.235"
//         APP_HOST = "99.79.41.129"
       
//     }
//     stages {
//         stage('Git checkout'){
//             steps{
//              git branch: 'main', changelog: false, credentialsId: 'git-hub', url: 'https://github.com/udodi05/acada-webapp.git'               
//             }
//         }
//         stage('Sonar Scan') {
//             steps{
//                     withCredentials([string(credentialsId: 'sonarqube_token', variable: 'SONAR_TOKEN')]) {
//                         sh 'mvn clean verify sonar:sonar -Dsonar.projectName=Acada-webapp -Dsonar.host.url=http://${SONARQUBE_HOST}:9000 -Dsonar.token=${SONAR_TOKEN} -Dsonar.qualitygate.wait=true'
//                 }
//             }
//         }
//         stage('Image Build | Push | Deploy to Nexus Repository') {
//             parallel {
//                 stage('Image Build') {
//                     steps{
//                         withCredentials([usernamePassword(credentialsId: 'nexus-creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
//                             sh 'echo ${NEXUS_PASSWORD} | docker login ${NEXUS_HOST}:90 -u ${NEXUS_USER} --password-stdin'
//                             sh 'docker build -t ${NEXUS_HOST}:90/acada-repo/acada-webapp:v1 .'
//                             sh 'docker push ${NEXUS_HOST}:90/acada-repo/acada-webapp:v1'
//                         }
//                     }
//                 }
//                 stage('Deploy to Nexus Repo') {
//                     steps{
//                         withCredentials([usernamePassword(credentialsId: 'nexus-creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER')]) {
//                             sh 'mvn deploy -Drepo.login=${NEXUS_USER} -Drepo.pwd=${NEXUS_PASSWORD} -s settings.xml'
//                         }
//                     }
//                 }
//             }
//         }
//         stage('Deploy Database') {
//             when {
//                 environment name: 'DEPLOY_DB', value: 'True'
//             }
//             steps{
//                 withCredentials([
//                     usernamePassword(credentialsId: 'db_creds', passwordVariable: 'DB_PASSWORD', usernameVariable: 'DB_USER'),
//                     sshUserPrivateKey(credentialsId: 'ec2-creds', keyFileVariable: 'EC2_KEY', usernameVariable: 'EC2_USER')
//                     ]){
//                         sh 'echo "POSTGRES_USER=$DB_USER" > .db_env'
//                         sh 'echo "POSTGRES_PASSWORD=$DB_PASSWORD" >> .db_env'
//                         sh 'ssh -o StrictHostKeyChecking=no -i ${EC2_KEY} ${EC2_USER}@${DB_HOST} "mkdir ~/web-app-db/" || true'
//                         sh 'scp -o StrictHostKeyChecking=no -i ${EC2_KEY} init-db.sql .db_env deploy_db.sh ${EC2_USER}@${DB_HOST}:~/web-app-db/'
//                         sh 'ssh -o StrictHostKeyChecking=no -i ${EC2_KEY} ${EC2_USER}@${DB_HOST} "bash ~/web-app-db/deploy_db.sh"'
//                 }
//             }
//         }
//         stage('Deploy Application') {
//             steps{
//                     withCredentials([
//                         usernamePassword(credentialsId: 'db_creds', passwordVariable: 'DB_PASSWORD', usernameVariable: 'DB_USER'),
//                         usernamePassword(credentialsId: 'nexus-creds', passwordVariable: 'NEXUS_PASSWORD', usernameVariable: 'NEXUS_USER'),
//                         sshUserPrivateKey(credentialsId: 'ec2-creds', keyFileVariable: 'EC2_KEY', usernameVariable: 'EC2_USER'),
//                         string(credentialsId: 'smtp_creds', variable: 'SMTP_PASSWORD'),
//                     ]) {
//                         sh 'echo "DB_HOST=${DB_HOST}" > .app_env'
//                         sh 'echo "DB_PORT=5432" >> .app_env'
//                         sh 'echo "DB_NAME=acada_db" >> .app_env'
//                         sh 'echo "DB_USERNAME=$DB_USER" >> .app_env'
//                         sh 'echo "DB_PASSWORD=$DB_PASSWORD" >> .app_env'
//                         sh 'echo "NEXUS_USER=$NEXUS_USER" >> .app_env'
//                         sh 'echo "NEXUS_PASSWORD=$NEXUS_PASSWORD" >> .app_env'
//                         sh 'echo "NEXUS_HOST=$NEXUS_HOST" >> .app_env'
//                         sh 'echo "SMTP_HOST=smtp.gmail.com" >> .app_env'
//                         sh 'echo "SMTP_PORT=587" >> .app_env'
//                         sh 'echo "SMTP_USERNAME=kelechi.ifediniru@gmail.com" >> .app_env'
//                         sh 'echo "SMTP_PASSWORD=$SMTP_PASSWORD" >> .app_env'
//                         sh 'echo "SMTP_FROM_EMAIL=kelechi.ifediniru@gmail.com" >> .app_env'
//                         sh 'ssh -o StrictHostKeyChecking=no -i ${EC2_KEY} ${EC2_USER}@${APP_HOST} "mkdir ~/web-app/" || true'
//                         sh 'scp -o StrictHostKeyChecking=no -i ${EC2_KEY} .app_env deploy_app.sh haproxy.cfg ${EC2_USER}@${APP_HOST}:~/web-app/'
//                         sh 'ssh -o StrictHostKeyChecking=no -i ${EC2_KEY} ${EC2_USER}@${APP_HOST} "bash ~/web-app/deploy_app.sh"'
//                     }
//             }
//         }
//     }
// }