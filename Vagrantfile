Vagrant::Config.run do |config|                                                                                                                                                  
  config.vm.define :vagrant01 do |web_config|
    web_config.vm.box =  "lucid32"
    web_config.vm.forward_port 80, 8080
    web_config.vm.network :hostonly, "192.168.1.10"
  end

  config.vm.define :vagrant02 do |db_config|
    db_config.vm.box = "lucid32"
    db_config.vm.forward_port 3306, 3306
    db_config.vm.network :hostonly, "192.168.1.11"
  end
end
