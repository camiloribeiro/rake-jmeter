namespace :ssh do
  task :check do
    config = File.expand_path '~/.ssh/config'
    File.exists?(config) or raise "Could not find #{config} file"
    File.read(config) =~ /stress0\d/ or Rake::Task['ssh:help'].invoke
  end

  desc 'Add keys'
  task :add_keys do

    File.expand_path '~/.ssh/config'
    @key = `cat ~/.ssh/id_rsa.pub`
    puts "Key stored"

    puts "add defaualt configuration to config file"
    `echo "ServerAliveInterval 300\nServerAliveCountMax 3" >> ~/.ssh/config`


    STRESS_SERVERS_EXTERNAL.each do |server|
      if server.port
        puts "Add #{server.name} alias to local machine"
        `echo "\nHost #{server.name}\nHostName #{server.host}\nPort #{server.port}\nUser #{server.user}" >> ~/.ssh/config`

        puts "Accessing #{server.host} using user #{server.user} at port #{server.port}"
        `ssh -C -p #{server.port} #{server.user}@#{server.host} 'echo "#{@key}" >> ~/.ssh/authorized_keys'` 
        puts "key included with success"
      else
        puts "Accessing #{server.host} using user #{server.user} at default port"
        `ssh -C #{server.user}@#{server.host} 'echo "#{@key}" >> ~/.ssh/authorized_keys'` 
        puts "key included with success"
      end
    end
  end
end
