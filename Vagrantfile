# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
OPTS = YAML.load_file ('devbox.yml')

Vagrant.configure('2') do |config|
  config.vm.box = 'precise-server-cloudimg-amd64'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/vagrant/precise/current/precise-server-cloudimg-amd64-vagrant-disk1.box'
  config.vm.hostname = 'devbox.local'
  if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.auto_detect = true
  end
  config.vm.network :private_network, ip: "192.168.33.10"
  config.ssh.forward_agent = true
  config.vm.synced_folder OPTS[:synced_folder][:host_path], OPTS[:synced_folder][:guest_path]
  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--memory', '4096']
  end
  config.vm.provision 'shell', path: 'install.sh', \
    args: [ OPTS[:ssh_pubkey], OPTS[:ssh_known_hosts], OPTS[:install_chef].to_s,
            OPTS[:chef_repo][:url], OPTS[:chef_repo][:branch] ]
end
