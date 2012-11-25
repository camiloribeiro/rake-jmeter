Vagrant::Config.run do |config|                                                                                                                                                  
  config.vm.define :vagrant01 do |config|
    config.vm.box =  "quantal64"
    config.vm.forward_port 3005, 3005
    config.vm.network :hostonly, "10.10.1.10"
    config.vm.host_name = "quantal64"
  end

  config.vm.define :vagrant02 do |config|
    config.vm.box = "quantal64"
    config.vm.forward_port 3306, 3306
    config.vm.network :hostonly, "10.10.1.11"
    config.vm.host_name = "quantal64"
  end
end
