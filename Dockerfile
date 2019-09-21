FROM ubuntu:16.04
MAINTAINER PmoshBR

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get install -y  dialog apt-utils
RUN apt-get install -y curl sudo apt-transport-https software-properties-common python-software-properties

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list | sudo tee /etc/apt/sources.list.d/mssql-server-2017.list
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php -y

RUN apt-get update

RUN apt-get install -y apache2
RUN apt-get install -y php7.2 php7.2-common
RUN apt-get install -y php7.2-dev php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-intl php7.2-xml php7.2-zip php7.2-mysql php7.2-sqlite3
RUN a2enmod php7.2

RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /root/.bashrc
RUN /bin/bash -c "source /root/.bashrc"
RUN apt-get install -y unixodbc-dev

RUN apt-get install -y at

RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
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
VOLUME /etc/php7
VOLUME /media/dados

EXPOSE 80
CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]
