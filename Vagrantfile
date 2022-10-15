# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_NO_PARALLEL'] = 'yes'

$COMMANDS = <<-'BLOCK'
apt-get update
apt-get install vim git snap dos2unix -y
chmod a+x /tmp/*.sh
find /tmp -type f |xargs dos2unix
BLOCK
        

Vagrant.configure(2) do |config|

  NodeCount = 1

  (1..NodeCount).each do |i|
    config.vm.define "kafka-cluster" do |node|
      node.vm.box = "bento/ubuntu-22.04"
      node.vm.hostname = "kafka-cluster.example.com"
      node.vm.network :forwarded_port, guest: 80,host: 80
      node.vm.network :forwarded_port, guest: 8080,host: 8080
      node.vm.network :forwarded_port, guest: 9092,host: 9092
      node.vm.provision "file", source: "main.sh", destination: "/tmp/main.sh"
      node.vm.provision "file", source: "kafka.sh", destination: "/tmp/kafka.sh"
      node.vm.provision "file", source: "zk.sh", destination: "/tmp/zk.sh"
      node.vm.provision "file", source: './configs', destination: "/tmp/configs"
      node.vm.provision "file", source: "kafka1.properties", destination: "/tmp/kafka1.properties"
      node.vm.provision "file", source: "kafka2.properties", destination: "/tmp/kafka2.properties"
      node.vm.provision "file", source: "kafka3.properties", destination: "/tmp/kafka3.properties"
      node.vm.provision "file", source: "zk1.cfg", destination: "/tmp/zk1.cfg"
      node.vm.provision "file", source: "zk2.cfg", destination: "/tmp/zk2.cfg"
      node.vm.provision "file", source: "zk3.cfg", destination: "/tmp/zk3.cfg"
      node.vm.provision "shell",privileged: true, inline: $COMMANDS
      node.vm.provision :shell, privileged: true, :inline => "bash /tmp/main.sh"
      node.vm.network "private_network", ip: "10.10.100.11#{i}"
      node.vm.provider "virtualbox" do |v|
        v.name = "kafka-cluster"
        v.memory = 6144
        v.cpus = 2
      end
    end
  end
end
