class Server < Struct.new(:name,:host,:port,:user); end

  @project_dir = "Sample"

  STRESS_SERVERS_INTERNAL = [
    Server.new('vagrant01','10.10.1.10', '22', 'vagrant'),
    Server.new('vagrant02','10.10.1.11', '22', 'vagrant')
  ]
  STRESS_SERVERS_EXTERNAL = STRESS_SERVERS_INTERNAL

  MASTER = STRESS_SERVERS_INTERNAL[0]
