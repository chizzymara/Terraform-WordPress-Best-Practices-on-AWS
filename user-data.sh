#!/bin/bash

#installing requirements to get data base credentials from secrets manager
touch /home/ubuntu/log.txt

sudo apt update
sudo apt-get update
sudo dpkg --configure -a
sudo apt install -y jq
sudo apt install awscli -y
echo "completed installation of jq and aws cli" >> /home/ubuntu/log.txt


#Install Nginx

sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update
sudo apt dist-upgrade -y
sudo apt install nginx -y
echo "completed installation of nginx" >> /home/ubuntu/log.txt

#install php
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt dist-upgrade -y
sudo apt install php8.0-fpm php8.0-common php8.0-mysql php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd php8.0-imagick php8.0-cli php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-redis php8.0-soap php8.0-zip -y
echo "completed installation of php" >> /home/ubuntu/log.txt

#installing mysql client
sudo apt install mysql-client -y
echo "completed installation of mysql client" >> /home/ubuntu/log.txt

#starting and enabling services
sudo systemctl start nginx
sudo systemctl enable nginx
echo "started and enabled nginx" >> /home/ubuntu/log.txt


#installing wordpress

sudo wget https://wordpress.org/latest.zip --output-file=wget_error.log -P /home/ubuntu/
echo "completed installation of wordpress" >> /home/ubuntu/log.txt
sudo apt install unzip
echo "completed installation of unzip" >> /home/ubuntu/log.txt
sudo unzip /home/ubuntu/latest.zip -d /home/ubuntu/
echo "unzip wordpress done" >> /home/ubuntu/log.txt

sudo apt-get upgrade -y
sudo apt-get -y install nfs-common
echo "install nfs common done" >> /home/ubuntu/log.txt
mkdir -p /var/www/html/
echo "mkdir -p /var/www/html/ done" >> /home/ubuntu/log.txt
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${file_system_id}.efs.${region}.amazonaws.com:/ /var/www/html
echo "mount efs done" >> /home/ubuntu/log.txt

#copy wordpress files to and change ownership and permissions
sudo cp -r /home/ubuntu/wordpress/* /var/www/html/
echo "sudo cp -r /home/ubuntu/wordpress/* /var/www/html/ done" >> /home/ubuntu/log.txt
sleep 20s
echo "waiting for 20s" >> /home/ubuntu/log.txt
sudo chown -R www-data:www-data /var/www/html/
echo "sudo chown -R www-data:www-data /var/www/html/" >> /home/ubuntu/log.txt
sleep 10s
echo "waiting for 10s" >> /home/ubuntu/log.txt
sudo chmod -R 755 /var/www/html/
echo "sudo chmod -R 755 /var/www/html/" >> /home/ubuntu/log.txt
sleep 10s
echo "waiting for 10s" >> /home/ubuntu/log.txt

sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/wordpress
echo "moving nginx site available to sites enabled done" >> /home/ubuntu/log.txt
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
echo "renaming wp-config-sapmle file done" >> /home/ubuntu/log.txt

#editing the config files

#including index.php to list
sudo sed -i "s/index/& index.php/" /etc/nginx/sites-enabled/wordpress
echo "adding index.php to sites enabled file" >> /home/ubuntu/log.txt

#include index.php?$args
sudo sed -i "s/=404/\/index.php\?\$args/" /etc/nginx/sites-enabled/wordpress
echo "adding args to sites enabled file" >> /home/ubuntu/log.txt

# changing the php-fpm version from 7.4 to 8.0
sudo sed -i "s/php7.4-fpm/php8.0-fpm/" /etc/nginx/sites-enabled/wordpress
echo "adding php8.0 sites enabled file" >> /home/ubuntu/log.txt
#uncommenting php block
sudo sed -i '/\\.php\$/s/#//g' /etc/nginx/sites-enabled/wordpress
echo "uncommented sites enabled file" >> /home/ubuntu/log.txt
sudo sed -i '/fastcgi-php.conf;/s/#//g' /etc/nginx/sites-enabled/wordpress
echo "uncommented sites enabled file" >> /home/ubuntu/log.txt
sudo sed -i '/fastcgi_pass\sunix:/s/#//g' /etc/nginx/sites-enabled/wordpress
sudo sed -i '/fastcgi_pass\s127.0.0.1:9000/{n;s/#//g}' /etc/nginx/sites-enabled/wordpress
echo "uncommented sites enabled file" >> /home/ubuntu/log.txt
#inserting database credentials to wp-config.php
sudo sed -i "s/database_name_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_NAME)/g" /var/www/html/wp-config.php
echo "adding databasename to wp config done" >> /home/ubuntu/log.txt
sudo sed -i "s/username_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_USER)/g" /var/www/html/wp-config.php
echo "adding  username to index.php file" >> /home/ubuntu/log.txt
sudo sed -i "s/password_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_PASSWORD)/g" /var/www/html/wp-config.php
echo "adding password to index.php file" >> /home/ubuntu/log.txt
sudo sed -i "s/localhost/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_HOST)/g" /var/www/html/wp-config.php
echo "adding  local host to index.php file" >> /home/ubuntu/log.txt
#sudo sed -i "/table_prefix/ a define( 'WP_HOME', '$(curl 169.254.169.254/latest/meta-data/public-ipv4)' );" /var/www/html/wp-config.php 
#sudo sed -i "/table_prefix/ a define( 'WP_SITEURL', '$(curl 169.254.169.254/latest/meta-data/public-ipv4)' );" /var/www/html/wp-config.php
#echo "define( 'WP_HOME', '$(curl 169.254.169.254/latest/meta-data/local-ipv4)' );" >> /var/www/html/wp-config.php 
#echo "define( 'WP_SITEURL', '$(curl 169.254.169.254/latest/meta-data/local-ipv4)' );" >> /var/www/html/wp-config.php 

#restart nginx to refresh settings
sudo systemctl restart nginx
echo "restarted nginx" >> /home/ubuntu/log.txt


#connecting to wordpress
#have to use secrets for this the instance must have an instance profile/role
sudo mysql -u $(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_USER) -h $(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_HOST) -p$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_PASSWORD)
echo "connected to database" >> /home/ubuntu/log.txt

#restart nginx to refresh settings
sudo systemctl restart nginx
echo "restarted nginx" >> /home/ubuntu/log.txt


#connect memcached
apt-get install telnet
echo "installed telnet" >> /home/ubuntu/log.txt
az=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone/)

if [ $az == "eu-central-1a" ]
then
telnet ${node-az1} 11211
else
telnet ${node-az2} 11211
fi
echo "connected to memcached" >> /home/ubuntu/log.txt