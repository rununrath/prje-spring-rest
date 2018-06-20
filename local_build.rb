@task_index=0
def next_task_index
  @task_index += 1
  sprintf("%02d", @task_index)
end

desc "local build"
task "#{next_task_index}_build" do
  sh %Q(mvn clean package)
end

desc "run"
task "#{next_task_index}_run" do
  cmd = %Q(java -jar target/spring-boot-rest-example.jar)
  sh cmd
end