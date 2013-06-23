bundle install
vagrant box add quantal64 https://github.com/downloads/roderik/VagrantQuantal64Box/quantal64.box
vagrant destroy vagrant01 -f
vagrant destroy vagrant02 -f
vagrant up 
rake ssh:add_keys       
rake ssh:setup_master
rake test:all
