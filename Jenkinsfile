node {
    try {
        notifyBuild('STARTED')

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
		stage("Build & SonarQube analysis") {
		  
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
		
	   	stage ('BlazeMeter test'){
		    blazeMeterTest credentialsId: 'blazemeter',
		    serverUrl:'https://a.blazemeter.com',
		    testId:'7745246',
		    notes:'',
		    sessionProperties:'',
		    jtlPath:'',
		    junitPath:'',
		    getJtl:false,
		    getJunit:false
		}		
		
		//Step pushing the image to docker hub
		stage('Docker build/push') {
		 docker.withRegistry('', 'docker') {
		   def app = docker.build("dharmendrasoni12/docker-webapp", '.').push()
			slackSend message: "Docker image dharmendrasoni12/docker-webapp build and pushed to Docker Hub Repository.";
		 }

		}
	} catch (e) {
		// If there was an exception thrown, the build failed
		currentBuild.result = "FAILED"
		throw e
	} finally {
		// Success or failure, always send notifications
		notifyBuild(currentBuild.result)
	}
}

//Method to notify the slack about Jenkins build status
def notifyBuild(String buildStatus = 'STARTED') {
  // build status of null means successful
  buildStatus =  buildStatus ?: 'SUCCESSFUL'

  // Default values
  def colorName = 'RED'
  def colorCode = '#FF0000'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} \n ${env.BUILD_URL}"
  def details = """<p>STARTED: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
    <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>"""

  // Override default values based on build status
  if (buildStatus == 'STARTED') {
    color = 'YELLOW'
    colorCode = '#FFFF00'
  } else if (buildStatus == 'SUCCESSFUL') {
    color = 'GREEN'
    colorCode = '#00FF00'
  } else {
    color = 'RED'
    colorCode = '#FF0000'
  }

  // Send notifications
  slackSend (color: colorCode, message: summary)
}
