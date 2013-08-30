namespace :perf do

    @tests.each do |test, types|
    types.each do |type|
      desc "#{test} #{type} load test"
      task "#{test}:#{type}" => ['sync:run'] do
        Rake::Task['perf:test_run'].invoke test, type
      end
    end
  end

  task :test_run, :test, :test_type do |t, args|
    timestamp = Time.now.strftime '%Y%m%d_%H%M%S'

    properties = File.join 'schedule', "#{args.test}_#{args.test_type}.properties"
    log = File.join 'logs', "#{args.test}_#{args.test_type}_#{timestamp}.jtl"
    plan = File.join 'plans', "#{args.test}.jmx"
    FileUtils.mkdir_p File.dirname(log)

    File.exists?(properties) or raise "Properties file #{properties} not found."
    File.exists?(plan)       or raise "Test plan file #{plan} not found."

    puts "[INFO][#{Time.now.to_i}] Starting test using #{properties} for plan #{plan}. Results will be logged to #{log}..."
    Rake::Task['servers:start'].invoke properties
    puts "[INFO][#{Time.now.to_i}] Servers restarted"

    cmds = []
    jmeter = "#{@project_dir}/jmeter/2.9/bin/jmeter"

    cmds << %[ssh -C #{MASTER.name} "rm -rf #{@project_dir}/logs/* && #{jmeter} -n -p #{@project_dir}/#{properties} -t #{@project_dir}/#{plan} -l #{@project_dir}/#{log} -R #{STRESS_SERVERS_INTERNAL.map {|a| a.host}.join(',')}"]
    cmds << %[scp -C #{MASTER.name}:#{@project_dir}/#{log} ./#{log}]
    cmds.each do |cmd|
      if ENV['DRY']
        puts cmd
      else
        sh cmd
      end
    end

    Rake::Task['servers:stop'].invoke
    File.exists?(log) or raise "Log file #{log} not found."
    Rake::Task[:report].invoke log unless ENV['DRY']

  end
end
