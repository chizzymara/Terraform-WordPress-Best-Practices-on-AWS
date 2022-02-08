#!/bin/bash
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get -y install nfs-common
mkdir -p /var/www/html
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${file_system_id}.efs.${region}.amazonaws.com:/ /var/www/html