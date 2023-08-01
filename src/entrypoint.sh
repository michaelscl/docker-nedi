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
#echo "Waiting 20 sec while SQL starts ...."
#sleep 20

#######
# NEDI
if [ ! -f /var/nedi/conf/INSTALLED ]; then
    echo "Install NEDI ..."
    /var/nedi/nedi.pl -i root dbpa55
    touch /var/nedi/conf/INSTALLED
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


