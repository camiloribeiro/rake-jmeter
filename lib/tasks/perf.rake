namespace :perf do

  {
    # Define your tests and test types here!
    #
    # This will look for a plans/sample.jmx file and config/sample_{nominal,peak}.properties files.
    #
    # Output will be generated in logs/sample_{nominal,peak}_YYYYMMDD_HHMMSS.jtl and
    # reports/sample_{nominal,peak}_YYYYMMDD_HHMMSS.
    #
    'sample' => [:nominal, :peak],
  }.each do |test, types|
    types.each do |type|
      desc "#{test} #{type} load test"
      task "#{test}:#{type}" => ['sync:run'] do
        Rake::Task['perf:test_run'].invoke test, type
      end
    end
  end

  # These are your stress servers' internal IP addresses. These IPs will be passed to JMeter.
  STRESS_SERVERS_INTERNAL = ['123.6.1.84', '123.6.1.85', '123.6.1.86', '123.6.1.87'].join(',')

  task :test_run, :test, :test_type do |t, args|
    timestamp = Time.now.strftime '%Y%m%d_%H%M%S'

    properties = File.join 'config', "#{args.test}_#{args.test_type}.properties"
    log = File.join 'logs', "#{args.test}_#{args.test_type}_#{timestamp}.jtl"
    plan = File.join 'plans', "#{args.test}.jmx"
    FileUtils.mkdir_p File.dirname(log)

    File.exists?(properties) or raise "Properties file #{properties} not found."
    File.exists?(plan)       or raise "Test plan file #{plan} not found."

    puts "[INFO][#{Time.now.to_i}] Starting test using #{properties} for plan #{plan}. Results will be logged to #{log}..."
    Rake::Task['servers:start'].invoke properties
    puts "[INFO][#{Time.now.to_i}] Servers restarted"

    cmds = []
    jmeter = "~/#{PROJECT_NAME}/jmeter/2.7/bin/jmeter"
    cmds << %[ssh -C #{MASTER} 'rm -rf ~/#{PROJECT_NAME}/logs/* && #{jmeter} -n -p ~/#{PROJECT_NAME}/#{properties} -t ~/#{PROJECT_NAME}/#{plan} -l ~/#{PROJECT_NAME}/#{log} -R #{STRESS_SERVERS_INTERNAL}']
    cmds << %[scp -C #{MASTER}:~/#{PROJECT_NAME}/#{log} ./#{log}]
    cmds.each do |cmd|
      if ENV['DRY']
        puts cmd
      else
        sh cmd
      end
    end

    File.exists?(log) or raise "Log file #{log} not found."

    Rake::Task[:report].invoke log unless ENV['DRY']
  end

end
