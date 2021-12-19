#!/bin/bash


myname="Rajesh"
timestamp=$(date '+%d%m%Y-%H%M%S')
s3_bucket="upgrad-rajesh"

sudo apt update -y 

if [[ !$(dpkg --get-selections | grep apache) ]];
then
	sudo apt-get install apache2 -y
fi

ps -ef | grep apache2 |grep -v grep > /dev/null
if [ $? != 0 ]
then
       /etc/init.d/apache2 start > /dev/null
fi

systemctl enable apache2


sudo apt get update -y 
sudo apt install awscli -y

sudo tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar


