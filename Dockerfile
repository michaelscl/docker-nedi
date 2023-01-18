FROM ubuntu:22.04

ENV TZ=Europe/Prague
ENV DEBIAN_FRONTEND=noninteractive

ARG NEDI=nedi-2.2C.tgz

# Installation of nesesary package/software for this containers...
RUN echo $TZ > /etc/timezone && \
    apt-get  update && \
    apt-get install -y  libdbd-mysql-perl libnet-snmp-perl libnet-telnet-perl libsocket6-perl librrds-perl libalgorithm-diff-perl libcrypt-rijndael-perl libdigest-hmac-perl libcrypt-des-perl libcrypt-hcesha-perl \
                        libio-pty-perl libwww-perl libnet-ntp-perl libnet-dns-perl perl-doc \ 
                        mariadb-client \
                        php-fpm php-mysql php-snmp php-gd php-ldap \
			# php-radius \
                        # iptables-persistent \
                        net-tools snmp rrdtool nginx openssl fping wget mc htop git cron iputils-ping && \
    apt-get clean && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Installing NeDi community edition
COPY src/${NEDI} /var/nedi/${NEDI}
RUN cd /var/nedi && \
    tar zxf ${NEDI} && \
    rm ${NEDI} && \
    mkdir -p /var/log/nedi && \
    chown -R www-data.www-data /var/log/nedi && \
    rm -rf /var/nedi/sysobj && \
    git clone https://github.com/michaelscl/nedi-sysobj.git /var/nedi/sysobj && \
    rm -rf /var/nedi/html/img && \
    git clone https://github.com/michaelscl/nedi-img.git /var/nedi/html/img && \
    sed -i -e 's/dbhost.*localhost/dbhost		db/' /var/nedi/nedi.conf && \
    mv /var/nedi/nedi.conf /var/nedi/conf/nedi.conf && \
    ln -s /var/nedi/conf/nedi.conf /var/nedi/html/nedi.conf && \
    ln -s /var/nedi/conf/nedi.conf /var/nedi/nedi.conf && \
    mv /var/nedi/seedlist /var/nedi/conf/seedlist && \
    ln -s /var/nedi/conf/seedlist /var/nedi/seedlist && \
    chown -R www-data.www-data /var/nedi && \
    if ! grep -q Time::HiRes /usr/share/perl5/Net/SNMP/Message.pm; then \
        echo "Enabling SNMP latency measurement"; \
        sed -i '23 i use Time::HiRes;' /usr/share/perl5/Net/SNMP/Message.pm; \
        sed -i '687 i \ \ \ $this->{_transport}->{_send_time} = Time::HiRes::time;' /usr/share/perl5/Net/SNMP/Message.pm; \
    fi

RUN PHPVER=`ls /etc/php` && \
    sed -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 8M/' /etc/php/$PHPVER/fpm/php.ini && \
    sed -i -e 's/display_errors = Off/display_errors = On/' /etc/php/$PHPVER/fpm/php.ini && \
    sed -i -e 's/display_startup_errors = Off/display_startup_errors = On/' /etc/php/$PHPVER/fpm/php.ini

# Nginx
RUN openssl genrsa -out /etc/ssl/private/server.key 2048 && \
    openssl req -new -key /etc/ssl/private/server.key -out /etc/ssl/server.csr -subj "/C=CH/ST=ZH/L=Zurich/O=NeDi Consulting/OU=R&D" && \
    openssl x509 -req -days 365 -in /etc/ssl/server.csr -signkey /etc/ssl/private/server.key -out /etc/ssl/server.crt
COPY src/nginx.conf /etc/nginx/sites-enabled/default

# Nedi Monitor
COPY src/nedi-monitor /etc/init.d/nedi-monitor
RUN chmod 755 /etc/init.d/nedi-monitor && \
    update-rc.d nedi-monitor defaults

# Nedi syslog
COPY src/nedi-syslog /etc/init.d/nedi-syslog
RUN chmod 755 /etc/init.d/nedi-syslog && \
    update-rc.d nedi-syslog defaults

COPY src/entrypoint.sh /entrypoint.sh
RUN  chmod 755 /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
#CMD [ "/entrypoint.sh" ]

EXPOSE 80 514