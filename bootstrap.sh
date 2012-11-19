rvm install 1.9.3
rvm use 1.9.3
bundle install
vagrant box add quantal64 https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box
vagrant up
rake ssh:add_keys       
rake sync:run
rake ssh:install_java  
rake ssh:setup_master
rake ssh:internal_network_config
rake ssh:internal_network_hosts
rake perf:sample:nominal
