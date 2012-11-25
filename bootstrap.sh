rvm install 1.9.3
rvm use 1.9.3
bundle install
vagrant box add quantal64 https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box
vagrant destroy vagrant01 -f
vagrant destroy vagrant02 -f
vagrant up vagrant01
vagrant up vagrant02
rake ssh:add_keys       
rake ssh:install_java
rake ssh:setup_master
rake perf:sample:nominal
rake test:all
