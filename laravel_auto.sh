#!/bin/bash
clear
echo +++++++++++++++++++++++++++++++++++++++++++++
echo + Choose PHP Version +
echo +++++++++++++++++++++++++++++++++++++++++++++
echo "1- PHP 7.1"
echo "2- PHP 7.2"
echo "3- PHP 7.3"
echo "4- PHP 7.4"
echo "5- Exit"

############################# read php version choice ##############################
read character
case $character in
1) echo "Selected PHP version is: php7.1" ;;
2) echo "Selected PHP version is: php7.2" ;;
3) echo "Selected PHP version is: php7.3" ;;
4) echo "Selected PHP version is: php7.4" ;;
5) echo "exit" ;;

esac

if [ ! -z "$character" ]; then
   ############################# read create laravel project choices ##############################
   read -p "Do you want to create a laravel project? " -n 1 -r
   echo
   if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Please Insert new project name you want"
      read laravel_proj_name
   fi
   ##################################### check OS type #########################################
   export os_type = $(echo $OSTYPE)
   ################################### if operating system is linux #############################
   if [[ "$OSTYPE" == "linux-gnu"* ]];
   then
   export server_name=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
   ################################# if OS is Ubuntu ############################################
   if [ $server_name = '"Ubuntu"' ]; then
      ################## install apache ##############
      sudo apt-get update -y
      sudo apt-get install apache2 -y
      sudo a2enmod rewrite
      sudo service apache2 restart
      ################## install mysql server ##############
      sudo apt-get install mysql-server -y
      ################## install php ##############
      apt-get install python-software-properties
      add-apt-repository ppa:ondrej/php
      apt-get update
      if [[ $character == 1 ]]; then
         apt-get install php7.1 -y
         apt-get install php-pear php7.1-curl php7.1-dev php7.1-gd php7.1-mbstring php7.1-zip php7.1-mysql php7.1-xml -y
      elif [[ $character == 2 ]]; then
         apt-get install php7.2 -y
         apt-get install php-pear php7.2-curl php7.2-dev php7.2-gd php7.2-mbstring php7.2-zip php7.2-mysql php7.2-xml -y
      elif [[ $character == 3 ]]; then
         apt-get install php7.3 -y
         apt-get install php-pear php7.3-curl php7.3-dev php7.3-gd php7.3-mbstring php7.3-zip php7.3-mysql php7.3-xml -y
      elif [[ $character == 4 ]]; then
         apt-get install php7.4 -y
         apt-get install php-pear php7.4-curl php7.4-dev php7.4-gd php7.4-mbstring php7.4-zip php7.4-mysql php7.4-xml -y
      else
         echo "No Version Selected" exit
      fi
      sudo service apache2 restart
      ################## install composer and laravel ##############
      sudo apt install composer -y
      if [ ! -z "$laravel_proj_name" ]; then
         cd /var/www/html/
         composer global require "laravel/installer"
         composer create-project --prefer-dist laravel/laravel $laravel_proj_name
         cd /var/www/html/$laravel_proj_name/
         mv .env.example .env
         php artisan key:generate
         mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/old.conf
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
         " >$file

         cat $file

         chmod -R 777 /var/www/html/$laravel_proj_name/storage/
         chmod -R 777 /var/www/html/$laravel_proj_name/bootstrap/
         chmod -R 777 /var/www/html/$laravel_proj_name/public/

         sudo service apache2 restart
      fi

   else
   ################################# if OS is CentOS ############################################
      if [ $server_name = '"CentOS Linux"' ]; then
         ########################## check centOS release ###########################
         export centos_ver=$(awk -F= '/^VERSION_ID/{print $2}' /etc/os-release)
         ######################## CentOS release 7 ###############################
         if [ $server_name = '"7"' ]; then
            ########### install apache ###############
            sudo yum -y update
            sudo yum -y install epel-release
            sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
            sudo yum -y update
            sudo yum -y install httpd
            sudo systemctl start httpd
            sudo systemctl enable httpd
            sudo systemctl status httpd
            sudo yum -y install yum-utils
            ########### install php ###############
            if [[ $character == 1 ]]; then
               sudo yum-config-manager --enable remi-php71 && yum install php
            elif [[ $character == 2 ]]; then
               sudo yum-config-manager --enable remi-php72 && yum install php
            elif [[ $character == 3 ]]; then
               sudo yum-config-manager --enable remi-php73 && yum install php
            elif [[ $character == 4 ]]; then
               sudo yum-config-manager --enable remi-php74 && yum install php
            else
               echo "No Version Selected" exit
            fi
            yum --enablerepo=remi -y install php-mysqlnd php-pgsql php-curl php-pecl-mongo php-zip php-mysql php-pdo php-pecl-memcache php-pecl-memcached php-gd php-xml php-mbstring php-mcrypt php-pecl-apcu php-cli php-pear

            sudo service httpd restart
            ########### install mariaDB ###############
            mariafile="/etc/yum.repos.d/mariadb.repo"
            echo "[mariadb]
                name = MariaDB
                baseurl = http://yum.mariadb.org/10.1/centos7-amd64
                gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
                gpgcheck=1" >$mariafile

            sudo yum --enablerepo=remi -y install httpd MariaDB-client MariaDB-server
            sudo systemctl enable mariadb
            ########### install composer and laravel #################
            sudo yum -y install composer
            if [ ! -z "$laravel_proj_name" ]; then
               cd /var/www/html/
               composer global require "laravel/installer"
               composer create-project --prefer-dist laravel/laravel $laravel_proj_name
               cd /var/www/html/$laravel_proj_name/
               mv .env.example .env
               php artisan key:generate
               mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/old.conf
               file="/etc/httpd/conf/httpd.conf"
               echo "<VirtualHost *:80>
                 DocumentRoot /var/www/html/$laravel_proj_name/public
                 <Directory /var/www/html/$laravel_proj_name/public>
                    Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                    Require all granted
                 </Directory>
                 ErrorLog /etc/httpd/logs/error.log
                 CustomLog /etc/httpd/logs/access_log combined
            </VirtualHost>
             " >$file

               cat $file

               chmod -R 777 /var/www/html/$laravel_proj_name/storage/
               chmod -R 777 /var/www/html/$laravel_proj_name/bootstrap/
               chmod -R 777 /var/www/html/$laravel_proj_name/public/

               sudo service httpd restart
            fi

         fi

      fi

   fi

   ################################### if operating system is macOS #############################
   elif [[ "$OSTYPE" == "darwin"* ]];
   then
   echo "MAC OS is not supported yet"
   else
   echo "Your system is not supported"
   fi



fi
