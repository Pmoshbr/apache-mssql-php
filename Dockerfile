FROM ubuntu:16.04
MAINTAINER PmoshBR

ADD script/install.sh /root/

ENV DEBIAN_FRONTEND noninteractive
RUN chmod +x /root/install.sh
RUN	/bin/bash /root/install.sh

ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2
RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR

VOLUME /var/www
VOLUME /etc/apache2
VOLUME /etc/php7

EXPOSE 80
EXPOSE 443
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]