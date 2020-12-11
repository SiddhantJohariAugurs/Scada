pipeline {
	agent {
		kubernetes {
			label 'jenkins-slave'
		}
	}
	options {
		buildDiscarder(logRotator(numToKeepStr: '5'))
	}
	triggers {
		pollSCM 'H/5 * * * *'
	}

  stages {
    stage('Build Ant Project') {
      steps {
        container('ant') {
          sh "./vroc-build.sh"
        }
      }

    }

    stage('Build and Deploy Docker Image for Development / Staging') {
      when {
        anyOf { branch 'release/*'; branch 'hotfix/*'; branch 'PR*'; branch 'develop'}
      }
      steps {
        container('buildkit') {
          setEnvironmentalVariables()

          sh "buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --opt build-arg:VERSION=${VERSION} --output type=image,name=${DOCKERREGISTRY}/vroc/${IMAGENAME}:${VERSION},push=true"
        }
      }
      post {
        always {
          jiraSendBuildInfo site: "${JIRA_SITE_NAME}"
        }
      }
    }

    stage('Build and Deploy Docker Image for Production') {
      when {
        anyOf { branch 'master' }
      }
      steps {
        container('buildkit') {
          setEnvironmentalVariables()

          sh "buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --opt build-arg:PRODUCTION=true --opt build-arg:VERSION=${VERSION} --output type=image,name=${DOCKERREGISTRY}/vroc/${IMAGENAME}:${VERSION},push=true"
        }
      }
      post {
        always {
          jiraSendBuildInfo site: "${JIRA_SITE_NAME}"
        }
      }
    }

    stage('Deploy to K8S') {
      when {
        anyOf { branch 'master'; branch 'release/*'; branch 'develop'}
      }
      steps {
        container('buildkit') {
          setEnvironmentalVariables()

          kubernetesDeploy(kubeconfigId: 'kubernetes-jenkins-worker-user-kubeconfig',
                     configs: 'vroc-webscada.yaml',
                     enableConfigSubstitution: true,
                     secretNamespace: "vroc-webscada-${env.DEPLOYMENTTYPE}",
                     dockerCredentials: [
                         [credentialsId: 'docker-k8s-vroc-ai-credentials-id', url: 'https://docker.k8s.vroc.ai/vroc/'],
                     ]
					)
				}
			}
      post {
        always {
          jiraSendDeploymentInfo site: "${JIRA_SITE_NAME}", environmentId: 'vroc-perth', environmentName: 'VROC Perth', environmentType: "${DEPLOYMENTTYPE}"
        }
      }
    }
  }
}



def setEnvironmentalVariables() {
	env.GITCOMMITTERNAME = getGitCommitterName()
	env.DEPLOYMENTTYPE = getDeploymentType()
	env.IMAGENAME = getImageName()
	env.VERSION = getVersion()
	env.DOCKERREGISTRY = "docker.k8s.vroc.ai"
}

def getDeploymentType() {
	if (env.BRANCH_NAME.contains("master")) {
		return "production"
	}
	if (env.BRANCH_NAME.contains("release")) {
		return "staging"
	}
	if (env.BRANCH_NAME.contains("develop")) {
		return "development"
	}
	if ( (env.BRANCH_NAME.contains("feature")) || (env.BRANCH_NAME.contains("hotfix")) ) {
		return "development"
	}
}

def getImageName() {
	return "scada-app"
}

def getVersion() {
	if (env.BRANCH_NAME.contains("feature")) {
		return "${GITCOMMITTERNAME}-SNAPSHOT"
	} else {
		version="${sh(script: 'sed -n -r -e \'s/.*\\"version\\" value=\\"(.*)\\".*/\\1/p\' build.xml | head -1', returnStdout: true).trim()}"
	
	  return "${version}"
	}
}

def getGitCommitterName() {
	return "${sh(script:"git --no-pager show -s --format=%ae | sed s/[@].*//  | sed 's/\\./-/'", returnStdout: true).trim()}"
}
