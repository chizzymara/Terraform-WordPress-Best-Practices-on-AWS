#!/bin/bash

#installing requirements to get data base credentials from secrets manager

sudo apt update
sudo apt-get update
sudo dpkg --configure -a
sudo apt install -y jq

sudo apt install awscli -y


#Install Nginx

sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update
sudo apt dist-upgrade -y
sudo apt install nginx -y

#install php
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update
sudo apt dist-upgrade -y
sudo apt install php8.0-fpm php8.0-common php8.0-mysql php8.0-xml php8.0-xmlrpc php8.0-curl php8.0-gd php8.0-imagick php8.0-cli php8.0-dev php8.0-imap php8.0-mbstring php8.0-opcache php8.0-redis php8.0-soap php8.0-zip -y

#installing mysql client
sudo apt install mysql-client -y

#starting and enabling services
sudo systemctl start nginx
sudo systemctl enable nginx

#installing wordpress
cd $HOME
sudo wget https://wordpress.org/latest.zip --output-file=wget_error.log -P /home/ubuntu/
sudo apt install unzip
sudo unzip /home/ubuntu/latest.zip -d /home/ubuntu/


#copy wordpress files to and change ownership and permissions
sudo cp -r /home/ubuntu/wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/

sudo mv /etc/nginx/sites-enabled/default /etc/nginx/sites-enabled/wordpress
cd $HOME
sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

#editing the config files

#including index.php to list
sudo sed -i "s/index/& index.php/" /etc/nginx/sites-enabled/wordpress

#include index.php?$args
sudo sed -i "s/=404/\/index.php\?\$args/" /etc/nginx/sites-enabled/wordpress

# changing the php-fpm version from 7.4 to 8.0
sudo sed -i "s/php7.4-fpm/php8.0-fpm/" /etc/nginx/sites-enabled/wordpress

#uncommenting php block
sudo sed -i '/\\.php\$/s/#//g' /etc/nginx/sites-enabled/wordpress
sudo sed -i '/fastcgi-php.conf;/s/#//g' /etc/nginx/sites-enabled/wordpress

sudo sed -i '/fastcgi_pass\sunix:/s/#//g' /etc/nginx/sites-enabled/wordpress
sudo sed -i '/fastcgi_pass\s127.0.0.1:9000/{n;s/#//g}' /etc/nginx/sites-enabled/wordpress

#inserting database credentials to wp-config.php
sudo sed -i "s/database_name_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_NAME)/g" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_USER)/g" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_PASSWORD)/g" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_HOST)/g" /var/www/html/wp-config.php

#sudo sed -i "/table_prefix/ a define( 'WP_HOME', '$(curl 169.254.169.254/latest/meta-data/public-ipv4)' );" /var/www/html/wp-config.php 
#sudo sed -i "/table_prefix/ a define( 'WP_SITEURL', '$(curl 169.254.169.254/latest/meta-data/public-ipv4)' );" /var/www/html/wp-config.php
#echo "define( 'WP_HOME', '$(curl 169.254.169.254/latest/meta-data/local-ipv4)' );" >> /var/www/html/wp-config.php 
#echo "define( 'WP_SITEURL', '$(curl 169.254.169.254/latest/meta-data/local-ipv4)' );" >> /var/www/html/wp-config.php 

#restart nginx to refresh settings
sudo systemctl restart nginx

sudo apt-get install expect -y

#connecting to wordpress
#have to use secrets for this the instance must have an instance profile/role
sudo mysql -u $(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_USER) -h $(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_HOST) 

expect "Enter passwordr"
send "$(aws secretsmanager get-secret-value --region eu-central-1 --secret-id database-cred --query SecretString --output text | jq -r .DB_PASSWORD)\n"

#restart nginx to refresh settings
sudo systemctl restart nginx
