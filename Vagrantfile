# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  config.vm.hostname = 'nagios'
  config.vm.network "public_network"

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  # - - - - - - - - - - - - - - - - - - -
  # Initial Setup
  config.vm.provision "file", source: "./config-files", destination: "/tmp"
  config.vm.provision "file", source: "./NagiosInstaller.sh", destination: "/tmp/NagiosInstaller.sh"
  config.vm.provision "file", source: "./NagiosGraphInstaller.sh", destination: "/tmp/NagiosGraphInstaller.sh"

  config.vm.provision "shell" do |s|
    s.inline = <<-SHELL

      echo "<==== YUM UPDATE ====>"
      yum update -y

      echo "<==== NAGIOS ====>"
      cd /tmp && sh /tmp/NagiosInstaller.sh

      echo "<==== NAGIOSGRAPH ====>"
      cd /tmp && sh /tmp/NagiosGraphInstaller.sh

      echo "<==== Installation Done ====>"
      echo "IP ADDRESS: $(ip addr)"
    SHELL
  end
end
