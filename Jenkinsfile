pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 60, unit: 'MINUTES')
    }

    environment {
        APP_NAME    = 'devsecops-demo'
        DOCKER_USER = 'vasanthreddylingala'
        IMAGE_REPO  = 'devsecops-k8s-pipeline'
        IMAGE       = "${DOCKER_USER}/${IMAGE_REPO}:${BUILD_NUMBER}"
        SONAR_URL   = 'http://localhost:9000'
        APP_URL     = 'http://172.31.7.166:30080'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Unit Test') {
            steps {
                sh 'mvn -B clean verify'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Gate 1 - SonarQube') {
            steps {
                withCredentials([
                    string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')
                ]) {
                    sh '''
                        mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:sonar \
                          -Dsonar.projectKey=devsecops-demo \
                          -Dsonar.host.url=$SONAR_URL \
                          -Dsonar.token=$SONAR_TOKEN \
                          -Dsonar.qualitygate.wait=true
                    '''
                }
            }
        }

        stage('Gate 2 - Dependency-Check') {
            steps {
                withCredentials([
                    string(credentialsId: 'nvd-api-key', variable: 'NVD_API_KEY')
                ]) {
                    sh '''
                        mvn -B org.owasp:dependency-check-maven:check \
                          -DnvdApiKey=$NVD_API_KEY \
                          -DfailBuildOnCVSS=9 \
                          -DossindexAnalyzerEnabled=false \
                          -DdataDirectory=/var/lib/jenkins/dependency-check-data \
                          -Dformat=HTML
                    '''
                }
            }
            post {
                always {
                    archiveArtifacts artifacts: 'target/dependency-check-report.html',
                                     allowEmptyArchive: true
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Gate 3 - Trivy Image Scan') {
            steps {
                sh '''
                    trivy image --no-progress --severity HIGH,CRITICAL \
                      --ignore-unfixed --exit-code 0 $IMAGE
                    trivy image --no-progress --severity CRITICAL \
                      --ignore-unfixed --exit-code 1 $IMAGE
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh '''
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin
                        docker push $IMAGE
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                        kubectl apply -f k8s/namespace.yaml
                        sed "s|IMAGE_PLACEHOLDER|$IMAGE|g" k8s/deployment.yaml | kubectl apply -f -
                        kubectl apply -f k8s/service.yaml
                        kubectl -n devsecops rollout status deployment/devsecops-demo --timeout=240s
                    '''
                }
            }
        }

        stage('Smoke Test') {
            steps {
                retry(5) {
                    sleep time: 10, unit: 'SECONDS'
                    sh 'curl -sf $APP_URL/actuator/health'
                }
            }
        }
    }

    post {
        always {
            sh 'docker rmi $IMAGE || true'
        }
        success {
            echo "SUCCESS - app is live at ${APP_URL}/api/hello"
        }
        failure {
            echo 'FAILED - open the red stage and read its console output.'
        }
    }
}
