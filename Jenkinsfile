pipeline {
    agent any

    stages {
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                  ls -la
                  node --version
                  npm --version
                  npm ci
                  npm run build
                  ls -la
                '''
            }
        }

        stage('Parallel Tests') {
            parallel {
                stage('Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E Tests') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build & 
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright HTML Report', reportTitles: '', useWrapperFileDirectly: true])
                        }
                    }
                }
            }
        }

        stage('Deploy') {
            
            steps {
                  script {
              // Set up temporary directory to store the built files
                    def tmpDir = '/tmp/my-node-app'

                    // Ensure any previous build is cleaned up
                    sh "rm -rf ${tmpDir}"

                    // Ensure 'build' directory exists before copying
                    sh 'ls -la build'  // Verify 'build' directory exists
                    sh "mkdir -p ${tmpDir}"
                    sh "cp -r build/* ${tmpDir}/"  // Copy build files to tmp directory

                    // Build the Docker image
                    sh 'docker build -t my-node-app-image .'

                    // Run the Docker container (map the port to host machine port 3000)
                    sh 'docker run -d -p 3000:3000 --name my-node-app-container my-node-app-image'
                    sh 'docker ps'

                    // Optionally: Wait for the container to be up (can be reduced or removed based on your app)
                    sleep 5
                  }
            }
        }
    }
}
