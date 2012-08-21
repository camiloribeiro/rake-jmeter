namespace :sync do

  desc 'Sync all nodes'
  task :run do
    NODES.each do |machine|
      puts "[INFO][#{Time.now.to_i}] Copying files to #{machine}..."
      cmd = "rsync -zavuSH --delete --exclude='*.jtl' --exclude='.git' --exclude='*.swp' --exclude='*.log' --exclude='*.png' . #{machine}:#{PROJECT_NAME}"
      ENV['DRY'] ? puts(cmd) : sh(cmd)
    end
  end
end
