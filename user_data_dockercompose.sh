#!/bin/bash

#Updating system files
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

#Adding dockers key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

#Add Docker apt repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

#Run another update
sudo apt-get update

#Install Docker
sudo apt-get install -y docker-ce

#Allow user to access docker without root
sudo usermod -aG docker $USER

#Install Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#Verify Docker installation
docker-compose --version

#Create a directory for the docker-compose to run
mkdir -p ~/first-docker-compose
cd ~/first-docker-compose || exit