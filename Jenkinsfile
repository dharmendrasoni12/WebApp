node {
	//Sending notification to slack for build status
	try {
		notifySlack()
		} 
	catch (e) {
		currentBuild.result = 'FAILURE'
		throw e
	} 
	finally {
		notifySlack(currentBuild.result)
	}
	
    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "artifactory"
    // Create an Artifactory Maven instance.
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo
    
	rtMaven.tool = "maven"

	//Step git clone from master
    stage('Clone sources') {
        git url: 'https://github.com/dharmendrasoni12/webapp.git'
    }
	
	//Step Artifactory configuration
    stage('Artifactory configuration') {
        // Tool name from Jenkins configuration
        rtMaven.tool = "maven"
        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
    }
	
	//Step Sonar analysis
	stage("build & SonarQube analysis") {
	  
		'$SONAR_MAVEN_GOAL -Dsonar.host.url=$SONAR_HOST_URL sonar.sources=. sonar.tests=. sonar.inclusions=/test/java/servlet/createpage_junit.java sonar.test.exclusions=/test/java/servlet/createpage_junit.java -Dsonar.login=daa3f86869fe853d6321d54d2ad9b8931a91dacd -Dsonar.sources=. -Dsonar.tests=. -Dsonar.test.inclusions=*/test/java/servlet/createpage_junit.java -Dsonar.exclusions=*/test/java/servlet/createpage_junit.java'
	}

	//Step Maven build
    stage('Maven build') {
        buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean install'
    }
	
	//Step publish the build
    stage('Publish build info') {
        server.publishBuildInfo buildInfo
    }
	
	//Step pushing the image to docker hub
	stage('docker build/push') {
     docker.withRegistry('', 'docker') {
       def app = docker.build("dharmendrasoni12/docker-webapp", '.').push()
        slackSend message: "Docker image dharmendrasoni12/docker-webapp build and pushed to Docker Hub Repository.";
     }

    }
}

//Method to notify the slack about Jenkins build status
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
