# vagrant-devbox

Ubuntu Server 12.04.3 LTS dev box

See `install.sh` for details.

## Prerequisites

Required:

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)

Optional:

* [vagrant-cachier](https://github.com/fgrehm/vagrant-cachier)

## Setup

Create/ edit devbox.yml file:

    cp devbox-example.yml devbox.yml
    vim devbox.yml

Update options as required. Be sure to set a valid ssh\_pubkey.

The following two steps are optional, but will facilitate:

1. SSH login as root
2. Access to the Chef Server WebUI from the host system

Update SSH config:

    cat <<EOF >> ~/.ssh/config
        Host devbox.local
            Hostname 192.168.33.10
            User root
            StrictHostKeyChecking no
            UserKnownHostsFile=/dev/null
    EOF

Update /etc/hosts:

    echo '192.168.33.10 devbox.local' | sudo tee -a /etc/hosts

## Start VM

    vagrant up

## Connect

As root user:

    ssh devbox.local

As vagrant user:

    vagrant ssh

## Chef Server WebUI

[https://devbox.local/](https://devbox.local/)

## Notes

Chef repo directory: /opt/chef-repo

Cookbook inventory file: /root/knife-cookbook-upload.devbox

Version: 1.0.0
