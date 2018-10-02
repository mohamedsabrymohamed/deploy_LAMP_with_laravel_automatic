#!/bin/bash
clear
echo "Please Insert new project name you want"
read laravel_proj_name
export server_name=`awk -F= '/^NAME/{print $2}' /etc/os-release`
if [ $server_name = '"Ubuntu"' ]
then
sudo apt-get update -y
sudo apt-get install apache2 -y
sudo a2enmod rewrite
sudo service apache2 restart
sudo apt-get install mysql-server -y
apt-get install python-software-properties 
add-apt-repository ppa:ondrej/php
apt-get update
apt-get install php7.2  -y
apt-get install php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml  -y
sudo service apache2 restart
sudo apt install composer  -y
cd /var/www/html/
composer global require "laravel/installer"
composer create-project --prefer-dist laravel/laravel $laravel_proj_name
cd /var/www/html/$laravel_proj_name/
mv .env.example .env
php artisan key:generate
mv  /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/old.conf
   file="/etc/apache2/sites-available/000-default.conf"
   echo "<VirtualHost *:80>   
  
     DocumentRoot /var/www/html/$laravel_proj_name/public

     <Directory /var/www/html/$laravel_proj_name/public>
        Options Indexes FollowSymLinks MultiViews
	AllowOverride All
        Require all granted
     </Directory>

     ErrorLog ${APACHE_LOG_DIR}/error.log
     CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
 " > $file

   cat $file
   
   chmod -R 777 /var/www/html/$laravel_proj_name/storage/
   chmod -R 777 /var/www/html/$laravel_proj_name/bootstrap/
   chmod -R 777 /var/www/html/$laravel_proj_name/public/

sudo service apache2 restart
   
  
else
echo "we are comming soon for centos"
fi
