#!/bin/bash

set -e

packages=" ack-grep build-essential git htop libssl-dev libxml2-dev
libxslt1-dev python-dev python-pip rsync ruby1.9.1-dev tree vim "

apt-get update
apt-get -y install $packages

update-alternatives --set editor /usr/bin/vim.basic
update-alternatives --set ruby /usr/bin/ruby1.9.1
update-alternatives --set gem /usr/bin/gem1.9.1

gem install --no-ri --no-rdoc bundler

pip install git-review
pip install ipython
pip install virtualenvwrapper

debfile=chef-server_11.0.10-1.ubuntu.12.04_amd64.deb
pkgs=/vagrant/pkgs
mkdir -p $pkgs
if [ ! -f $pkgs/$debfile ]; then
    wget -P $pkgs \
        https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$debfile
fi
dpkg -i $pkgs/$debfile

chef-server-ctl reconfigure
chef-server-ctl test

mkdir -p /home/vagrant/.chef
cp /etc/chef-server/admin.pem /home/vagrant/.chef
cp /etc/chef-server/chef-validator.pem /home/vagrant/.chef

cat <<EOF > /home/vagrant/.chef/knife.rb
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/home/vagrant/.chef/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/home/vagrant/chef-validator.pem'
chef_server_url          'https://devbox:443'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
cookbook_path            [ './cookbooks' ]
EOF

mkdir -p /home/vagrant/.berkshelf
cat <<EOF > /home/vagrant/.berkshelf/config.json
{ "ssl": { "verify": false } }
EOF

curl -L https://www.opscode.com/chef/install.sh | bash

cat <<EOF > /etc/sudoers
Defaults    env_reset
Defaults    secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
root        ALL=(ALL:ALL) ALL
vagrant     ALL=(ALL:ALL) NOPASSWD:ALL
%admin      ALL=(ALL) NOPASSWD:ALL
%sudo       ALL=(ALL:ALL) ALL
EOF

cat <<EOF > /home/vagrant/.ssh/config
Host *
ServerAliveInterval 300
ServerAliveCountMax 12
ForwardAgent yes
StrictHostKeyChecking no
EOF

chmod 600 /home/vagrant/.ssh/config

cat <<EOF > /home/vagrant/.bash_aliases
# .bash_aliases
export EDITOR=vim
export PAGER=less
export LESS=-FRXi
EOF

chown -R vagrant:vagrant /home/vagrant
