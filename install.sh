#!/bin/bash

set -e

ssh_pubkey="$1"
ssh_known_hosts="$2"
chef_repo_url="$3"
chef_repo_branch="$4"

base_packages="
    build-essential
    git
    libssl-dev
    libxml2-dev
    libxslt1-dev
    python-dev
    python-pip
    python-software-properties
    ruby1.9.1-dev
    vim
"
apt-get update
apt-get -y install $base_packages

update-alternatives --set ruby /usr/bin/ruby1.9.1
update-alternatives --set gem /usr/bin/gem1.9.1
update-alternatives --set editor /usr/bin/vim.basic

ruby_gems="
    awesome_print
    bundler
    pry
"
gem install --no-ri --no-rdoc $ruby_gems

python_packages="
    git-review
    ipython
    virtualenvwrapper
"
pip install $python_packages

cache_d=/vagrant/.cache/pkgs
mkdir -p $cache_d
chef_pkgs="
    chef-server_11.0.10-1.ubuntu.12.04_amd64.deb
    chef_11.10.0-1.ubuntu.12.04_amd64.deb
"

for pkg in $chef_pkgs; do
    if [ ! -f $cache_d/$pkg ]; then
        wget -P $cache \
            https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/$pkg
    fi
    dpkg -i $cache_d/$pkg
done

chef-server-ctl reconfigure

echo "root:password" | sudo chpasswd # Enable root
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
echo $ssh_pubkey >> /root/.ssh/authorized_keys
echo $ssh_known_hosts >> /root/.ssh/known_hosts

cat <<EOF > /root/.ssh/config
Host *
ServerAliveInterval 300
ServerAliveCountMax 12
ForwardAgent yes
StrictHostKeyChecking no
EOF
chmod 0600 /root/.ssh/config

cat <<EOF > /root/.bash_aliases
# .bash_aliases
export EDITOR=vim
export PAGER=less
export LESS=-FRXi
EOF

mkdir -p /root/.chef
cat <<EOF > /root/.chef/knife.rb
log_level                :info
log_location             STDOUT
node_name                'admin'
client_key               '/etc/chef-server/admin.pem'
validation_client_name   'chef-validator'
validation_key           '/etc/chef-server/chef-validator.pem'
chef_server_url          'https://127.0.0.1:443'
syntax_check_cache_path  '/home/vagrant/.chef/syntax_check_cache'
cookbook_path            [ './cookbooks' ]
EOF

mkdir -p /root/.berkshelf
cat <<EOF > /root/.berkshelf/config.json
{ "ssl": { "verify": false } }
EOF

if [ -n "$chef_repo_url" ]; then
    git clone -b $chef_repo_branch $chef_repo_url /opt/chef-repo
    cd /opt/chef-repo
    bundle install

    # Ridley::SandboxResource crashed!
    set +e
    exit_status=1
    tries=1
    while [[ $exit_status != 0 ]] && [[ $tries -le 3 ]] ; do
        bundle exec berks upload
        exit_status=$?
        [[ $exit_status == 0 ]] && break
        tries=$((tries += 1))
        sleep 2
    done
    set -e
    [[ $exit_status == 0 ]]

    knife cookbook list > /root/knife-cookbook-list.devbox
fi
