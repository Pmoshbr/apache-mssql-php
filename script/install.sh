#!/bin/bash

# exit script if return code != 0
set -e

# build scripts
####

apt update
apt install -y  dialog apt-utils
apt install -y curl sudo apt-transport-https software-properties-common python-software-properties
apt install -y apache2
LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php -y
apt update

apt install -y php7.2 php7.2-common
apt install -y php7.2-dev php7.2-curl php7.2-gd php7.2-json php7.2-mbstring php7.2-intl php7.2-xml php7.2-zip
a2enmod php7.2

curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/mssql-server-2017.list | sudo tee /etc/apt/sources.list.d/mssql-server-2017.list
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
apt-get update

cd ~/
ACCEPT_EULA=Y apt install -y msodbcsql17 mssql-tools
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
apt install -y unixodbc-dev

pecl install sqlsrv
pecl install pdo_sqlsrv
echo extension=pdo_sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/30-pdo_sqlsrv.ini
echo extension=sqlsrv.so >> `php --ini | grep "Scan for additional .ini files" | sed -e "s|.*:\s*||"`/20-sqlsrv.ini

apt clean
rm -rf /var/lib/apt/lists/*