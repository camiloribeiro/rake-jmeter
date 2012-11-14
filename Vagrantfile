Vagrant::Config.run do |config|                                                                                                                                                  
  config.vm.define :vagrant01 do |config|
    config.vm.box =  "lucid32"
    config.vm.forward_port 80, 8080
    config.vm.network :hostonly, "192.168.1.10"
  end

  config.vm.define :vagrant02 do |config|
    config.vm.box = "lucid32"
    config.vm.forward_port 3306, 3306
    config.vm.network :hostonly, "192.168.1.11"
  end
end
