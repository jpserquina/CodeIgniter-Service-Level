#!/usr/bin/env bash

apt-get update

# install php 7.1
	add-apt-repository  -y ppa:ondrej/php
	apt-get update
	apt-get -y install php7.1
	apt-get -y install php7.1-xdebug
	apt-get -y install php7.1-curl
	apt-get -y install php7.1-mbstring
	apt-get -y install php7.1-xml
	apt-get -y install php7.1-gd
	apt-get -y install php7.1-mysql

# Install optional components
	apt-get -y install zip
	apt-get -y install git
	apt-get -y install build-essential

# Install Apache 2.4 and enabled mods
	apt-get -y install apache2
	apt-get -y install libapache2-mod-php7.1
	a2enmod php7.1
	a2enmod rewrite

# Install Composer
  curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Add composer bin path to globals
  echo '' >> /home/vagrant/.bashrc
  echo 'export PATH="$HOME/.config/composer/vendor/bin:$PATH"' >> /home/vagrant/.bashrc
  echo 'cd /var/www/app' >> /home/vagrant/.bashrc

# Symlink /app with /var/www dir
	ln -fs /app /var/www/app

# Disable default Apache site
	a2dissite 000-default
	a2dissite default-ssl.conf

# Install mysql

# install mysql and give password to installer
  # Use single quotes instead of double quotes to make it work with special-character passwords
  PASSWORD='root'
  DBHOST=localhost
  DBNAME=app
  DBUSER=user
  DBPASSWD=user
  debconf-set-selections <<< "mysql-server mysql-server/root_password password $PASSWORD"
  debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $PASSWORD"
  apt-get -y install mysql-server
  apt-get -y install php7.1-mysql
  mysql -uroot -p$PASSWORD -e "CREATE DATABASE $DBNAME"
  mysql -uroot -p$PASSWORD -e "grant usage on *.* to $DBUSER identified by '$DBPASSWD'"
  mysql -uroot -p$PASSWORD -e "grant all privileges on $DBNAME.* to $DBUSER"

	service mysql restart

# Fix FQDN error
# https://help.ubuntu.com/community/ApacheMySQLPHP#Troubleshooting_Apache
	if [ -d /etc/apache2/conf-available ]; then
		echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
		a2enconf fqdn
	else
		echo "ServerName localhost" | tee /etc/apache2/conf.d/fqdn
	fi

# Create log file
	touch /var/log/app.log
	chmod 666 /var/log/app.log

# Copy apache vhosts and enable sites
	cp /vagrant/vhosts/* /etc/apache2/sites-available/

	for filename in /etc/apache2/sites-available/*
	do
		filenamenopath=$(basename "$filename")
		sitename="${filenamenopath%.*}"

		if ! [[ $sitename =~ "default" ]]
		then
			a2ensite $sitename
		fi

	done

# Add timezone to the php.ini file
	PHP_INI='/etc/php/7.1/apache2/php.ini'
	sed -i.bak 's|;date.timezone =|date.timezone = America/New_York|g' $PHP_INI

# Backup + edit php.ini for display_errors on, html_errors on
	sed -i 's/display_errors = Off/display_errors = On/g' $PHP_INI
	sed -i 's/html_errors = Off/html_errors = On/g' $PHP_INI
	sed -i 's/short_open_tag = Off/short_open_tag = On/g' $PHP_INI
	sed -i 's/;opcache.enable=0/opcache.enable=1/g' $PHP_INI
	sed -i 's/;opcache.enable_cli=0/opcache.enable_cli=1/g' $PHP_INI

# Increase max upload size
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1G/g' $PHP_INI
	sed -i 's/post_max_size = 8M/post_max_size = 1G/g' $PHP_INI

# Enable xdebug options for longer var dump output
	echo '' >> $PHP_INI
	echo ';xdebug.var_display_max_depth = 6' >> $PHP_INI
	echo ';xdebug.var_display_max_children = 512' >> $PHP_INI
	echo ';xdebug.var_display_max_data = 4096' >> $PHP_INI

# Enable xdebug options for remote debugging (initially commented out - uncomment for these to be enabled)
	echo '' >> $PHP_INI
	echo 'xdebug.default_enable = 1' >> $PHP_INI
	echo 'xdebug.idekey = "vagrant"' >> $PHP_INI
	echo 'xdebug.remote_enable = 1' >> $PHP_INI
	echo 'xdebug.remote_autostart = 1' >> $PHP_INI
	echo 'xdebug.remote_port = 9000' >> $PHP_INI
	echo 'xdebug.remote_handler=dbgp' >> $PHP_INI
	echo 'xdebug.remote_connect_back=1' >> $PHP_INI

# Install PHP Unit
  wget https://phar.phpunit.de/phpunit.phar
  chmod +x phpunit.phar
  mv phpunit.phar /usr/local/bin/phpunit

# Add the Drupal environemt vars for all users
  echo "SITE_ENVIRONMENT='local'" >> /etc/environment
  echo "DB_NAME='$DBNAME'" >> /etc/environment
  echo "DB_USER='$DBUSER'" >> /etc/environment
	echo "DB_PASS='$DBPASSWD'" >> /etc/environment
	echo "DB_HOST='localhost'" >> /etc/environment
	echo "DB_PORT='3306'" >> /etc/environment
	echo "export SITE_ENVIRONMENT=local" >> /etc/apache2/envvars
	echo "export DB_NAME=$DBNAME" >> /etc/apache2/envvars
	echo "export DB_USER=$DBUSER" >> /etc/apache2/envvars
	echo "export DB_PASS=$DBPASSWD" >> /etc/apache2/envvars
	echo "export DB_HOST=localhost" >> /etc/apache2/envvars
	echo "export DB_PORT=3306" >> /etc/apache2/envvars

# Set ipv4 to have priority - to fix possible composer install errors
  sh -c "echo 'precedence ::ffff:0:0/96 100' >> /etc/gai.conf"

# Restart apache for changes to take effect
	service apache2 restart

# Install dependencies
  cd /var/www/app
  composer install
  composer require nltbinh/codeigniter-service-layer
  php vendor/nltbinh/codeigniter-service-layer/install.php

echo "*******************************************************"
echo "MYSQL Info:"
echo "Username: $DBUSER"
echo "Password: $DBPASSWD"
echo "DB Name:  $DBNAME"
echo ""
echo "CLI Command: mysql -u$DBUSER -p$DBPASSWD $DBNAME"
echo "*******************************************************"
echo ""