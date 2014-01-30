# vagrant-devbox

Ubuntu Server 12.04.3 LTS dev box

See `install.sh` for details

Includes:

* build-essential
* chef server 11
* git
* git-review
* libssl-dev
* libxml2-dev
* libxslt1-dev
* python-dev
* python-pip
* ruby1.9.1-dev
* vim

## Start

    git clone https://github.com/torandu/vagrant-devbox
    cd vagrant-devbox
    vagrant up

## Options

The default path for project sources is `$HOME/src`.

To set an alternative path:

    export SRC_PATH=/path/to/sources
    vagrant up
