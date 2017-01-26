#! /bin/bash

# node
apt-get update
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
apt-get install -y nodejs

# docker
apt-get install -y curl \
    linux-image-extra-$(uname -r) \
    linux-image-extra-virtual
apt-get install -y apt-transport-https \
                       ca-certificates
curl -fsSL https://yum.dockerproject.org/gpg | sudo apt-key add -
add-apt-repository \
       "deb https://apt.dockerproject.org/repo/ \
       ubuntu-$(lsb_release -cs) \
       main"
apt-get update
apt-get -y install docker-engine=1.12.0-0~trusty