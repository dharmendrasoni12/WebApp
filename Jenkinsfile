
node {
    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "artifactory"
    // Create an Artifactory Maven instance.
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo
    
 rtMaven.tool = "maven"

    stage('Clone sources') {
        git url: 'https://github.com/garima-sindhwani26/WebApp.git'
    }
    
     stage('Artifactory configuration') {
        // Tool name from Jenkins configuration
        rtMaven.tool = "maven"
        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
        rtMaven.deployer releaseRepo:'repo1', snapshotRepo:'repo1', server: server
        //rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
    }

    stage('Maven build') {
        buildInfo = rtMaven.run pom: 'pom.xml', goals: 'clean -DskipTests install'
    }
    
   stage('Build') {
   jiraSendBuildInfo branch: 'master', site: 'devopsbootcamp.atlassian.net'
} 

    stage('Publish build info') {
        server.publishBuildInfo buildInfo
    }
    stage('deploy to tomcat'){
        deploy adapters: [tomcat7(credentialsId: 'tomcat-tharun', path: '', url: 'http://34.93.27.202:8080/')], contextPath: '/QAWebapp', onFailure: false, war: '**/*.war'
    
    }

}
