namespace :sync do

  desc 'Sync all nodes'
  task :run do
  STRESS_SERVERS_EXTERNAL.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Copying files to #{machine.name}..."
      cmd = "rsync -zavuSH --delete --exclude='*.jtl' --exclude='.git' --exclude='*.swp' --exclude='*.log' --exclude='*.png' . #{machine.name}:#{@project_dir}"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end
end
