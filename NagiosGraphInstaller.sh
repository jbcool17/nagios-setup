#!/bin/bash
# NagiosGraph Setup Script
# Tested on Centos 7
# 11/9/2017 - by jb

NAGIOSGRAPH_VERSION=1.5.2

# Yum Update / Dependences
yum update -y
yum install -y perl-GD \
           php-gd \
           rrdtool-perl \
           rrdtool-php \
           rrdtool \
           perl-CGI \
           perl-Time-HiRes \
           perl-Nagios-Plugin \
           perl-Digest-MD5 \
           perl-CPAN


# CPAN
(echo y; echo o conf prerequisites_policy follow; echo o conf commit) | cpan
cpan Module::Build
cpan Nagios::Config

# install ng
wget –quiet https://downloads.sourceforge.net/project/nagiosgraph/nagiosgraph/$NAGIOSGRAPH_VERSION/nagiosgraph-$NAGIOSGRAPH_VERSION.tar.gz -P /tmp
cd /tmp && tar -xzvf nagiosgraph-$NAGIOSGRAPH_VERSION.tar.gz

cd /tmp/nagiosgraph-$NAGIOSGRAPH_VERSION && ./install.pl --check-prereq && \
NG_LAYOUT=overlay \
NG_PREFIX=/usr/local/nagios \
NG_ETC_DIR=$NG_PREFIX/etc/nagiosgraph \
NG_BIN_DIR=$NG_PREFIX/libexec \
NG_CGI_DIR=$NG_PREFIX/sbin \
NG_DOC_DIR=$NG_PREFIX/docs/nagiosgraph \
NG_EXAMPLES_DIR=$NG_PREFIX/docs/nagiosgraph/examples \
NG_WWW_DIR=$NG_PREFIX/share \
NG_UTIL_DIR=$NG_PREFIX/docs/nagiosgraph/util \
NG_VAR_DIR=$NG_PREFIX/var \
NG_RRD_DIR=$NG_PREFIX/var/rrd \
NG_LOG_DIR=$NG_PREFIX/var \
NG_LOG_FILE=$NG_PREFIX/var/nagiosgraph.log \
NG_CGILOG_FILE=$NG_PREFIX/var/nagiosgraph-cgi.log \
NG_URL=/nagios \
NG_CGI_URL=/nagios/cgi-bin \
NG_CSS_URL=/nagios/nagiosgraph.css \
NG_JS_URL=/nagios/nagiosgraph.js \
NG_NAGIOS_CGI_URL=/nagios/cgi-bin \
NG_NAGIOS_PERFDATA_FILE=/tmp/perfdata.log \
NG_NAGIOS_USER=nagios NG_WWW_USER=apache \
NG_MODIFY_NAGIOS_CONFIG=y \
NG_NAGIOS_CONFIG_FILE=$NG_PREFIX/etc/nagios.cfg \
NG_NAGIOS_COMMANDS_FILE=$NG_PREFIX/etc/objects/commands.cfg \
NG_MODIFY_APACHE_CONFIG=y \
NG_APACHE_CONFIG_DIR=/etc/httpd/conf.d \
NG_APACHE_CONFIG_FILE=/etc/httpd/conf/httpd.conf \
./install.pl --prefix=/usr/local/nagiosgraph


# side.php
/bin/cp -pvr /tmp/config-files/side.php /usr/local/nagios/share
chown -R nagios:nagios /usr/local/nagios/share/
chmod 664 /usr/local/nagios/share/side.php

# add to template.cfg & add use graphed-service below name - generic-service
/bin/cp -pvr /tmp/config-files/templates.cfg /usr/local/nagios/etc/objects
chown -R nagios:nagios /usr/local/nagios/etc/objects

chown -R nagios:nagios /usr/local/nagios/var/rrd

systemctl restart nagios
systemctl restart httpd

yum clean all
