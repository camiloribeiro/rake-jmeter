namespace :servers do

  desc 'Start JMeter server on all nodes'
  task :start, [:properties_file] => [:stop] do |t , args|
  STRESS_SERVERS_EXTERNAL.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Starting JMeter server on #{machine.name}..."
      cmd = "nohup ssh #{machine.name} '#{@project_dir}/jmeter/2.9/bin/jmeter-server -p #{@project_dir}/#{args.properties_file}' 2>&1 >> /dev/null < /dev/null &"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end

  desc 'Stop JMeter server on all nodes'
  task :stop do
  STRESS_SERVERS_EXTERNAL.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Stopping JMeter server on #{machine.name}"
      cmd = "ssh #{machine.name} 'killall -9 -v jmeter java' ; true"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end
end
