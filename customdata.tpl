#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt install pipx -y
sudo apt install pip -y
python3 -m pipx install pywinrm
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible -y
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install packer
sudo apt install unzip
pipx install ansible-core
pipx inject ansible-core pywinrm