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

sudo -u postgres createuser --superuser vagrant
sudo -u postgres expect -f - <<DOC
spawn psql
expect "postgres=#" { send "\\\\password vagrant\r" }
expect "Enter new password:" { send "vagrant\r" }
expect "Enter it again:" { send "vagrant\r" }
DOC
sudo -u postgres createdb vagrant
