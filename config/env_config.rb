class Server < Struct.new(:name,:host,:port,:user); end

  @project_dir = "sample"

  STRESS_SERVERS_INTERNAL = [
    Server.new('stress01','123.123.123.111', '8080', 'team'),
    Server.new('stress02','123.123.123.112', '8080', 'team'),
    Server.new('stress03','123.123.123.113', '8080', 'team'),
    Server.new('stress04','123.123.123.114', '8080', 'team')
  ]

  if ENV['MODE'] == 'INTERNAL'
    STRESS_SERVERS_EXTERNAL = STRESS_SERVERS_INTERNAL
  else
    STRESS_SERVERS_EXTERNAL = [
      Server.new('stress01','200.123.123.111', '8080', 'team'),
      Server.new('stress02','200.123.123.112', '8080', 'team'),
      Server.new('stress03','200.123.123.113', '8080', 'team'),
      Server.new('stress04','200.123.123.114', '8080', 'team')
    ]
  end

  MASTER = STRESS_SERVERS_INTERNAL[0]
