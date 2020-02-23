def notifySlack(String buildStatus = 'STARTED') {
// Build status of null means success.
buildStatus = buildStatus ?: 'SUCCESS'
def color

if (buildStatus == 'STARTED') {
    color = '#D4DADF'
} else if (buildStatus == 'SUCCESS') {
    color = '#BDFFC3'
} else if (buildStatus == 'UNSTABLE') {
    color = '#FFFE89'
} else {
    color = '#FF9FA1'
}

def msg = "${buildStatus}: `${env.JOB_NAME}` #${env.BUILD_NUMBER}:\n${env.BUILD_URL}"

slackSend(color: color, message: msg)
}



node {
try {
notifySlack()

    // Existing build steps.
} catch (e) {
    currentBuild.result = 'FAILURE'
    throw e
} finally {
    notifySlack(currentBuild.result)
}
}



node {
    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "artifactory"
    // Create an Artifactory Maven instance.
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo
    
 rtMaven.tool = "maven"

    stage('Clone sources') {
        git url: 'https://github.com/dharmendrasoni12/webapp.git'
    }
	

    stage('Artifactory configuration') {
        // Tool name from Jenkins configuration
        rtMaven.tool = "maven"
        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
    }
	
          stage("build & SonarQube analysis") {
            agent any
            steps {
              withSonarQubeEnv('sonar') {
                sh 'mvn clean package sonar:sonar -Dsonar.host.url=http://35.225.184.76:9000/ -Dsonar.login=ff177383dda7da09c6364187a7d1b057c7fe64b7 -Dsonar.sources=. -Dsonar.tests=. -Dsonar.test.inclusions=**/test/java/servlet/createpage_junit.java -Dsonar.exclusions=**/test/java/servlet/createpage_junit.java'
              }
            }
          }
          stage("Quality Gate") {
            steps {
              timeout(time: 1, unit: 'HOURS') {
                waitForQualityGate abortPipeline: true
              }
            }
          }

	
	
    stage('Maven build') {
        buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install'
    }
	
	

    stage('Publish build info') {
        server.publishBuildInfo buildInfo
    }
	
	
	stage('docker build/push') {
     docker.withRegistry('', 'docker') {
       def app = docker.build("dharmendrasoni12/docker-webapp", '.').push()
     }

    }
    }
