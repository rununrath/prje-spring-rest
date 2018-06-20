//A Jenkinsfile for start
podTemplate(label: 'my-pod',
  containers:[
    containerTemplate(name: 'compiler', image:'maven:3.5-jdk-8',ttyEnabled: true, command: 'cat', envVars:[
        containerEnvVar(key: 'BUILD_NUMBER', value: env.BUILD_NUMBER),
        containerEnvVar(key: 'BUILD_ID', value: env.BUILD_ID),
        containerEnvVar(key: 'BUILD_URL', value: env.BUILD_URL),
        containerEnvVar(key: 'BUILD_TAG', value: env.BUILD_TAG),
        containerEnvVar(key: 'JOB_NAME', value: env.JOB_NAME)
      ],
    ),
    containerTemplate(name: 'citools', image:'zhiminwen/citools',ttyEnabled: true, command: 'cat', envVars:[
        // these env is only available in container template? podEnvVar deosn't work?!
        containerEnvVar(key: 'BUILD_NUMBER', value: env.BUILD_NUMBER),
        containerEnvVar(key: 'BUILD_ID', value: env.BUILD_ID),
        containerEnvVar(key: 'BUILD_URL', value: env.BUILD_URL),
        containerEnvVar(key: 'BUILD_TAG', value: env.BUILD_TAG),
        containerEnvVar(key: 'JOB_NAME', value: env.JOB_NAME)
      ],
    )
  ],
  volumes: [
    //for docker to work
    hostPathVolume(hostPath: '/var/run/docker.sock', mountPath: '/var/run/docker.sock'),
    persistentVolumeClaim(mountPath: '/root/.m2/repository', claimName: 'mvn-jenkins-slave-pvc', readOnly: false)
  ]
){
  node('my-pod') {
    stage('check out') {
      checkout scm
    }

    stage('compile'){
      container('compiler'){
        sh "echo compile"
        sh "mvn clean package"
      }
    }

    stage('Docker Build'){
      container('citools'){
        // sleep 3600
        sh "echo build docker image"
        sh "rake -f build.rb docker:01_build_image docker:02_push_to_ICp_registry"
      }
    }

    stage('Deploy to ICP'){
      container('citools'){
        // sleep 3600
        echo "deploy to icp..."
        sh "rake -f build.rb k8s:01_deploy_to_k8s"
      }
    }

    //stage('Deployment'){
    //  parallel 'deploy to icp': {
    //    container('citools'){
    //      echo "deploy to icp..."
    //      // sh "rake -f build.rb k8s:01_deploy_to_k8s"

    //    }
    //  },

    //  'deploy to others': {
    //    container('citools'){
    //      echo "deploy to others..."
    //    }
    //  }
    //}
  }
}
