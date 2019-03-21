FROM ubuntu:16.04
MAINTAINER PmoshBR

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN apt install -y  dialog apt-utils
RUN apt install -y curl sudo apt-transport-https software-properties-common python-software-properties
RUN apt install -y apache2
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php -y
RUN apt update

RUN apt install -y php7.2 php7.2-common
RUN apt install -y php7.2-dev php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-intl php7.2-xml php7.2-zip
RUN a2enmod php7.2

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list | sudo tee /etc/apt/sources.list.d/mssql-server-2017.list
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
RUN apt-get update

RUN ACCEPT_EULA=Y apt install -y msodbcsql17 mssql-tools
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN source ~/.bashrc
RUN apt install -y unixodbc-dev

RUN pecl install sqlsrv
RUN pecl install pdo_sqlsrv
RUN echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
RUN echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

RUN apt clean && rm -rf /var/lib/apt/lists/*

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