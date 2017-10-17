/*
   This Jenkinsfile builds and tests containers, and pushes tagged versions to a container registry.
 */
def github_org         = "samsung-cnct"
def publish_branch     = "master"
def registry           = "quay.io"
def registry_user      = "samsung_cnct"
def robot_secret       = "quay-robot-drunkensmee-container-rw"
def image_name         = "drunkensmee-container"

podTemplate(label: "${image_name}", containers: [
    containerTemplate(name: 'jnlp',
                      image: "${registry}/${registry_user}/custom-jnlp:0.1",
                      args: '${computer.jnlpmac} ${computer.name}'),
    containerTemplate(name: 'docker',
                      image: 'docker:17.09.0-ce-git',
                      command: 'cat',
                      ttyEnabled: true),
    ], volumes: [
        hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
        hostPathVolume(hostPath: '/var/lib/docker/scratch', mountPath: '/mnt/scratch'),
    ], envVars: [
        secretEnvVar(key: 'USERNAME', secretName: robot_secret, secretKey: 'username'),
        secretEnvVar(key: 'PASSWORD', secretName: robot_secret, secretKey: 'password')])
    {
    node("${image_name}") {
      customContainer('docker') {
        // add a docker rmi/docker purge/etc.
        stage('Checkout') {
          checkout scm
          
          // retrieve the URI used for checking out the source
          // this assumes one branch with one uri
          git_uri = scm.getRepositories()[0].getURIs()[0].toString()
          git_branch = scm.getBranches()[0].toString()
        }
        // build new version of kraken-tools image on 'docker' container
        stage('Build') {
          kubesh "docker build -t ${image_name}:${env.JOB_BASE_NAME}.${env.BUILD_ID} ."
        }

        stage('Test') {
          kubesh "echo The test stage is empty"
        }

        // only push from master.   check that we are on samsung-cnct fork
        stage('Publish') {
          if (git_branch.contains(publish_branch) && git_uri.contains(github_org)) {
            kubesh "docker login ${registry} -u ${USERNAME} -p ${PASSWORD}"
            kubesh "docker tag ${image_name}:${env.JOB_BASE_NAME}.${env.BUILD_ID} ${registry}/${registry_user}/${image_name}:\$(git rev-parse --short HEAD)"
            kubesh "docker push ${registry}/${registry_user}/${image_name}:\$(git rev-parse --short HEAD)"
          } else {
            echo "Not pushing to docker repo:\n    BRANCH_NAME='${env.BRANCH_NAME}'\n    GIT_BRANCH='${git_branch}'\n    git_uri='${git_uri}'"
          }
        }
      }
    }
  }

def kubesh(command) {
  if (env.CONTAINER_NAME) {
    if ((command instanceof String) || (command instanceof GString)) {
      command = kubectl(command)
    }

    if (command instanceof LinkedHashMap) {
      command["script"] = kubectl(command["script"])
    }
  }
  sh(command)
}

def kubectl(command) {
  "kubectl exec -i ${env.HOSTNAME} -c ${env.CONTAINER_NAME} -- /bin/sh -c 'cd ${env.WORKSPACE} && ${command}'"
}

def customContainer(String name, Closure body) {
  withEnv(["CONTAINER_NAME=$name"]) {
    body()
  }
}

// vi: ft=groovy
