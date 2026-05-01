#!/bin/bash
# Check if the folder of the base mysql is empty
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Install the base tables of the system to our volume
    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql
fi

#start the service
#service mysql start
mysqld_safe &

sleep 10

if [ ! -d /var/lib/mysql/${MYSQL_DATABASE} ];
then
	mysql -u ${MYSQL_ROOT_USER} -e "CREATE DATABASE $MYSQL_DATABASE;"
	mysql -u ${MYSQL_ROOT_USER} -e "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';"
	mysql -u ${MYSQL_ROOT_USER} -e "GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' WITH GRANT OPTION;"
	mysql -u ${MYSQL_ROOT_USER} -e "FLUSH PRIVILEGES;"
	mysql -u ${MYSQL_ROOT_USER} -e "ALTER USER '${MYSQL_ROOT_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
fi

mysqladmin -u ${MYSQL_ROOT_USER}  --password=${MYSQL_ROOT_PASSWORD} shutdown

exec mysqld_safe
