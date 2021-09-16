#!/bin/bash

echo "-----------------------------------------------------------------------------------------------------------"

#######
# PHP
echo "Start php-fpm ..."
PHPVER=`ls /etc/php`
service php${PHPVER}-fpm start

#######
# NGINX
echo "Restart NGINX ..."
sed -i -e "s/xPHPVERx/$PHPVER/" /etc/nginx/sites-enabled/default
service nginx restart

#######
# CRON
if [ ! -z "${CRON}" ];
then
    echo "Set crontab ${CRON} ..."
    echo "${CRON}     www-data    /var/nedi/nedi.pl -por 3" > /etc/cron.d/nedi
    echo "Restart crontab ..."
    service cron restart
fi

#
echo "Waiting 20 sec while SQL starts ...."
sleep 20

#######
# NEDI
if [ ! -f /var/nedi/conf/nedi.conf ]; then
    echo "Install NEDI ..."
    /var/nedi/nedi.pl -i root dbpa55
    mv /var/nedi/nedi.conf /var/nedi/conf/nedi.conf
    ln -s /var/nedi/conf/nedi.conf /var/nedi/html/nedi.conf
    ln -s /var/nedi/conf/nedi.conf /var/nedi/nedi.conf
    mv /var/nedi/seedlist /var/nedi/conf/seedlist
    ln -s /var/nedi/conf/seedlist /var/nedi/seedlist
fi
echo "Start nedi-syslog ..."
service nedi-syslog start

echo "Start nedi-monitor ..."
service nedi-monitor start

echo "-----------------"
echo "End of entrypoint"

while [ 1 ]
do
    sleep 60
    echo -n .
done


