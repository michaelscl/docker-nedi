#!/bin/bash

echo "-----------------------------------------------------------------------------------------------------------"

echo "Start php-fpm ..."
service php${PHPVER}-fpm start

echo "Restart NGINX ..."
PHPVER=`ls /etc/php`
sed -i -e "s/xPHPVERx/$PHPVER/" /etc/nginx/sites-enabled/default
service nginx restart

echo "Waiting 20 sec while SQL starts ...."
sleep 20

if [ ! -f /nediInstalled ]; then
    echo "Install NEDI ..."
    /var/nedi/nedi.pl -i root dbpa55
    touch /nediInstalled
fi
echo "Start nedi-syslog ..."
service nedi-syslog start

echo "Start nedi-monitor ..."
service nedi-monitor start

echo "End of entrypoint"

while [ 1 ]
do
    sleep 60
    echo -n .
done


