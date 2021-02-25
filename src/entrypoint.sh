#!/bin/bash


PHPVER=`ls /etc/php`

echo "Start php-fpm ...."
service php${PHPVER}-fpm start

echo "Start NGINX ....."
sed -i -e "s/xPHPVERx/$PHPVER/" /etc/nginx/sites-enabled/default
cat /etc/nginx/sites-enabled/default
service nginx restart

# service nedi-syslog start
# service nedi-monitor start


echo "Waiting 20 sec...."
sleep 20
echo "First install NEDI ...."
/var/nedi/nedi.pl -i root dbpa55

while [ 1 ]
do
    sleep 5
    echo .
done


