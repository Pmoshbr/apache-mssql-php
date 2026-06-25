FROM ubuntu:20.04
MAINTAINER PmoshBR

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y dialog apt-utils
RUN apt-get install -y curl sudo apt-transport-https software-properties-common

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN add-apt-repository -y ppa:ondrej/php -y

RUN apt-get update

RUN apt-get install -y apache2
RUN apt-get install -y php7.4 php7.4-common
RUN apt-get install -y php7.4-dev php7.4-curl php7.4-gd php7.4-mbstring php7.4-intl php7.4-xml php7.4-zip php7.4-mysql php7.4-sqlite3 php7.4-soap
RUN a2enmod php7.4

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bashrc
RUN /bin/bash -c "source /root/.bashrc"
RUN apt-get install -y unixodbc-dev

RUN apt-get install -y at

RUN pecl channel-update pecl.php.net && pecl install sqlsrv-5.10.1
RUN pecl install pdo_sqlsrv-5.10.1
RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

# FOR DEVELOPMENT ONLY
RUN apt-get install -y git-core
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php
RUN php -r "unlink('composer-setup.php');"
RUN mv composer.phar /usr/local/bin/composer

# CLEAN AND FINAL STEPS
RUN apt-get autoremove -y
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
RUN mkdir /media/dados

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
VOLUME /etc/php
VOLUME /media/dados

EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
