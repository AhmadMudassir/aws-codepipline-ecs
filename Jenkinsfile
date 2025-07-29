pipeline {
  agent { label 'node1' }

  stages {
    stage('Install Dependencies') {
      steps {
        sh '''
          ls -a
          npm i express
        '''
      }
    }
    stage('Test App') {
      steps {
        sh '''
          echo "Checking syntax of index.js..."
          node -c index.js
          echo "Syntax OK"
        '''
      }
    }
    stage('PM2') {
      steps {
        sh '''
            pm2 start index.js --name node-app
            pm2 save
        '''
      }
    }
  }
}
