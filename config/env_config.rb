class Server < Struct.new(:name,:host,:port,:user); end

  @project_dir = "/home/root/qcon"

  STRESS_SERVERS_INTERNAL = [
    Server.new('perf01','192.241.250.165', '22', 'root'),
    Server.new('perf02','192.241.250.167', '22', 'root')
  ]
  STRESS_SERVERS_EXTERNAL = STRESS_SERVERS_INTERNAL

  MASTER = STRESS_SERVERS_INTERNAL[0]
