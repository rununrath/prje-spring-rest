require "erb"
require_relative "shell"

module KubeTools
  def self.create_namespace namespace
    Shell.run %Q(kubectl create namespace #{namespace} || echo ignore exists error)
  end

  def self.create_pull_secret namespace, user, pass, secret_name
    Shell.run %Q(kubectl delete secret #{secret_name} -n #{namespace} || echo ignore non exists error)
    Shell.run %Q(kubectl create secret docker-registry #{secret_name} -n #{namespace} --docker-server=#{ENV["PRIVATE_DOCKER_REGISTRY_NAME"]}:#{ENV["PRIVATE_DOCKER_REGISTRY_PORT"]} --docker-username=#{ENV["PRIVATE_DOCKER_REGISTRY_USER"]} --docker-password=#{ENV["PRIVATE_DOCKER_REGISTRY_USER_PASSWORD"]} --docker-email=#{ENV["PRIVATE_DOCKER_REGISTRY_USER"]}@#{ENV["PRIVATE_DOCKER_REGISTRY_NAME"]})
  end


  def self.create_new_yaml yaml_template_file, yaml_file, data = {}
    erb = ERB.new(File.read(yaml_template_file))
    b = binding

    data.each_pair do |key, value|
      b.local_variable_set(key, value)
    end

    File.open yaml_file, "w" do |fh|
      fh.puts erb.result(b)
    end
  end

  def self.deploy_to_k8s yaml_file
    Shell.run %Q(kubectl apply -f #{yaml_file})
  end
end
