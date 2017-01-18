#!/usr/bin/env bash
cd ~

# Create a move into directory.
mkdir terraform_0_6_16
mkdir packer_0_10_1

cd ~/terraform_0_6_16

# Download Terraform. URI: https://www.terraform.io/downloads.html
curl -O https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_darwin_amd64.zip
# Unzip and install
unzip terraform_0.6.16_darwin_amd64.zip

cd ~/packer_0_10_1

# Download Packer. URI: https://www.packer.io/downloads.html
curl -O https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_darwin_amd64.zip
# Unzip and install
unzip packer_0.10.1_darwin_amd64.zip

echo '
# Terraform & Packer Paths.
export PATH=~/terraform_0_6_14:~/packer_0_10_0/:$PATH
' >>~/.bash_profile

source ~/.bash_profile

# verify we're all set to terraform and packer.
terraform --version
packer --version
