#!/bin/bash
# Nagios Setup Script
# Tested on Centos 7
# 11/9/2017 - by jb


# Set Variables
NAGIOS_WEB_USER=nagiosadmin
NAGIOS_WEB_PASS=password
NAGIOS_PKG_VERSION=nagios-4.3.4
NAGIOS_PLUGIN_VERSION=nagios-plugins-2.2.1
NAGIOS_ADMIN_EMAIL=email@website.com

# Yum Update & Install Dependences
yum update -y

yum install -y epel-release \
               wget \
               gcc \
               glibc \
               glibc-common \
               gd \
               gd-devel \
               make \
               net-snmp \
               openssl \
               openssl-devel xinetd \
               unzip \
               git \
               httpd \
               php \
               php-cli \
               mailx \
               postfix mod_ssl

echo "+++> Setup Users"
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
usermod -a -G nagcmd apache
usermod -a -G nagios nagios


echo "+++> Install NAGIOS"
wget –quiet https://assets.nagios.com/downloads/nagioscore/releases/$NAGIOS_PKG_VERSION.tar.gz -P /tmp
cd /tmp && tar xzf $NAGIOS_PKG_VERSION.tar.gz
cd /tmp/$NAGIOS_PKG_VERSION && ./configure --with-command-group=nagcmd && \
                                            make all            && \
                                            make install        && \
                                            make install-init   && \
                                            make install-config && \
                                            make install-commandmode && \
                                            make install-webconf

echo "+++> Set Web PASS"
htpasswd -b -c /usr/local/nagios/etc/htpasswd.users $NAGIOS_WEB_USER $NAGIOS_WEB_PASS

echo "+++> PLUGINS"
wget –quiet http://nagios-plugins.org/download/$NAGIOS_PLUGIN_VERSION.tar.gz -P /tmp
cd /tmp && tar xzf $NAGIOS_PLUGIN_VERSION.tar.gz
cd /tmp/$NAGIOS_PLUGIN_VERSION && \
  ./configure --with-nagios-user=nagios \
              --with-nagios-group=nagios \
              --with-openssl && \
              make && \
              make install

echo "+++> SELINUX - disabled"
/usr/sbin/setenforce 0
sed -i --follow-symlinks 's/^SELINUX=.*/SELINUX=disabled/g' /etc/sysconfig/selinux && cat /etc/sysconfig/selinux

echo "+++> ADD EMAIL"
sed -i "s/nagios@localhost/$NAGIOS_ADMIN_EMAIL/g" /usr/local/nagios/etc/objects/contacts.cfg

echo "+++> Enable Services"
systemctl daemon-reload
systemctl enable httpd.service

chkconfig --add nagios
chkconfig nagios on

echo "+++> StartUP"
systemctl start nagios.service
systemctl start httpd.service

yum clean all
