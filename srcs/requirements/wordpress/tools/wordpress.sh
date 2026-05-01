#!/bin/bash

#Wait for mariadb start.
sleep 10

if [ -f ./wp-config.php ]
then
    echo "Wordpress already Exists!!"
else
    echo "Downloading Wordpress"
    wp core download --allow-root
    echo "Creating Wordpress Config File"
    wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$MYSQL_HOSTNAME --allow-root
    echo "Installing the Wordpress Base"
    wp core install --url=$DOMAIN_NAME --title="$WP_TITLE" --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root
    echo "Creating the normal User Wordpress"
    wp user create $WP_USER $WP_USER_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root
    echo "Installing a Wordpress Theme"
    wp theme install twentysixteen --activate --allow-root
fi

exec /usr/sbin/php-fpm7.4 -F;
