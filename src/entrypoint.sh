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
echo "Set crontab ..."
if [ -z "${CRON}" ];
then
    echo "CRON not set"
    echo "Setting default CRON: NEDI starts every hour in 15min"
    CRON="15 * * * *"
else
    echo "Setting default CRON: ${CRON}"
fi
echo "${CRON}     www-data    /var/nedi/nedi.pl -por" > /etc/cron.d/nedi
echo "Restart crontab ..."
service cron restart

#
echo "Waiting 20 sec while SQL starts ...."
sleep 20

#######
# NEDI
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


