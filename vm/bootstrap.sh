#!/usr/bin/env bash
set -ex

#######################################
# Runs as root
#######################################
cat > /etc/default/locale <<"DOC"
LANG="en_US.UTF-8"
LANGUAGE=
LC_CTYPE="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_PAPER="en_US.UTF-8"
LC_NAME="en_US.UTF-8"
LC_ADDRESS="en_US.UTF-8"
LC_TELEPHONE="en_US.UTF-8"
LC_MEASUREMENT="en_US.UTF-8"
LC_IDENTIFICATION="en_US.UTF-8"
LC_ALL=
DOC
source /etc/default/locale

#######################################
# Prerequisites
########################################

apt-get update

# Developer tools
apt-get -y install vim
apt-get -y install expect

#
# Install postgres
#

sudo apt-get -y install postgresql

# Fix authentication method for database
sed -i.bak -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'    /" /etc/postgresql/9.1/main/postgresql.conf
sed -i.bak -f - /etc/postgresql/9.1/main/pg_hba.conf <<EOS
  /local \{1,\}all \{1,\}all/s/peer/trust/
  /host \{1,\}all \{1,\}all/s/md5/trust/
  /host \{1,\}all \{1,\}all/s/127.0.0.1\/32/0.0.0.0\/0/
EOS
service postgresql restart

# Create target database
sudo -u postgres createuser --superuser vagrant
sudo -u postgres expect -f - <<DOC
spawn psql
expect "postgres=#" { send "\\\\password vagrant\r" }
expect "Enter new password:" { send "vagrant\r" }
expect "Enter it again:" { send "vagrant\r" }
DOC
sudo -u postgres createdb vagrant

#
# Install mysql
#

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server

sed -i.bak -e "/bind-address/d" /etc/mysql/my.cnf

service mysql restart

mysql -uroot -proot <<DOC
CREATE USER 'vagrant'@'%' IDENTIFIED BY 'vagrant';
GRANT ALL PRIVILEGES ON *.* TO 'vagrant'@'%' WITH GRANT OPTION;
CREATE DATABASE vagrant;
DOC
