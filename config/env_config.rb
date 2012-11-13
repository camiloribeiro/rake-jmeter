class Server < Struct.new(:name,:host,:port,:user); end

  @project_dir = "sample"

  STRESS_SERVERS_INTERNAL = [
    Server.new('vagrant01','192.168.1.11', '8080', 'vagrant'),
    Server.new('vagrant02','192.168.1.11', '8080', 'vagrant'),
  ]
  STRESS_SERVERS_EXTERNAL = STRESS_SERVERS_INTERNAL

  MASTER = STRESS_SERVERS_INTERNAL[0]
