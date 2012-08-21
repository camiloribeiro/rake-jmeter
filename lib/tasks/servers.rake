namespace :servers do

  desc 'Start JMeter server on all nodes'
  task :start, [:properties_file] => [:stop] do |t , args|
    NODES.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Starting JMeter server on #{machine}..."
      cmd = "nohup ssh #{machine} '~/#{PROJECT_NAME}/jmeter/2.7/bin/jmeter-server -p ~/#{PROJECT_NAME}/#{args.properties_file}' 2>&1 >> /dev/null < /dev/null &"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end

  desc 'Stop JMeter server on all nodes'
  task :stop do
    NODES.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Stopping JMeter server on #{machine}"
      cmd = "ssh #{machine} 'killall -v jmeter java' ; true"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end
end
