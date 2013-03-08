require 'rspec'

describe "Rake Jmeter" do
  context "Virtual Machines" do
    it "has virtual box installed" do
      (`whereis virtualbox`).should include("/usr/bin/virtualbox\n")
    end
    it "has box virtual quantan64 added" do
      (`vagrant box list`).should include("quantal64")
    end
    it "has virtual maxhines up" do
      (`vagrant status vagrant01`).should include("vagrant01                running")
      (`vagrant status vagrant02`).should include("vagrant02                running")
    end
  end
  context "Environment setedup" do
    it "has config file configured" do
      (`cat ~/.ssh/config`).should include("ServerAliveInterval 300")
      (`cat ~/.ssh/config`).should include("Host vagrant01\nHostName 10.10.1.10\nPort 22\nUser vagrant")
      (`cat ~/.ssh/config`).should include("Host vagrant02\nHostName 10.10.1.11\nPort 22\nUser vagrant")
    end
    it "has ssh keys delivered on virtual machines" do
      @key = `cat ~/.ssh/id_rsa.pub`
      (`ssh -C -p 22 vagrant@vagrant01 'cat ~/.ssh/authorized_keys'`).should include(@key)
    end
    it "has ssh configurations delivered to master" do
      (`ssh -C -p 22 vagrant@vagrant01 'cat ~/.ssh/config'`).should include("ServerAliveInterval 300")
      (`ssh -C -p 22 vagrant@vagrant01 'cat ~/.ssh/config'`).should include("Host vagrant01\nHostName 10.10.1.10\nPort 22\nUser vagrant")
      (`ssh -C -p 22 vagrant@vagrant01 'cat ~/.ssh/config'`).should include("Host vagrant02\nHostName 10.10.1.11\nPort 22\nUser vagrant")
    end
    it "has java installed in all machines" do
      (`ssh -C -p 22 vagrant@vagrant01 'whereis java'`).should include("/usr/bin/java")
      (`ssh -C -p 22 vagrant@vagrant02 'whereis java'`).should include("/usr/bin/java")
    end
    it "has last framework deployed" do
      (`rake`).should include("Copying files to vagrant01...\nbuilding file list ... done", "Copying files to vagrant02...\nbuilding file list ... done")
    end
    it "has ruby environment running on master" do
      (`ssh -C -p 22 vagrant@vagrant01 'ruby -v'`).should include("ruby 1.9.3p194")
    end
  end
  context "Running and reporting" do
    it "has a report assertion ok" do
      system("bundle exec rake perf:sample:nominal")
    end
  end
end
