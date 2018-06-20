require 'dotenv'
Dotenv.load ".env.build"
require_relative "build_libs/helpers"

image_name = ENV["IMAGE_NAME"]
tag=ENV["BUILD_NUMBER"]||"B1"

namespace "docker" do
  reset_task_index

  desc "build docker image"
  task "#{next_task_index}_build_image" do
    sh %Q(docker build -t #{image_name}:#{tag} .)
  end

  desc "push to ICp registry"
  task "#{next_task_index}_push_to_ICp_registry" do
    DockerTools.add_etc_hosts
    KubeTools.create_namespace ENV["K8S_NAMESPACE"]
    DockerTools.push_to_registry image_name, tag
  end
end

namespace "k8s" do
  reset_task_index

  desc "deploy into k8s"
  task "#{next_task_index}_deploy_to_k8s" do
    KubeTools.create_pull_secret ENV["K8S_NAMESPACE"], ENV["PRIVATE_DOCKER_REGISTRY_USER"], ENV["PRIVATE_DOCKER_REGISTRY_USER_PASSWORD"], ENV["PRIVATE_DOCKER_REGISTRY_PULL_SECRET"]

    yaml_template_file = "#{image_name}.k8.template.yaml"
    yaml_file = "#{image_name}.yaml"

    private_registry = sprintf("%s:%s", ENV["PRIVATE_DOCKER_REGISTRY_NAME"], ENV["PRIVATE_DOCKER_REGISTRY_PORT"])
    namespace = ENV["PRIVATE_DOCKER_REGISTRY_NAMESPACE"]

    full_new_image_name = "#{private_registry}/#{namespace}/#{image_name}:#{tag}"
    data = {
      new_image: full_new_image_name
    }

    KubeTools.create_new_yaml yaml_template_file, yaml_file, data

    KubeTools.deploy_to_k8s yaml_file
  end
end
