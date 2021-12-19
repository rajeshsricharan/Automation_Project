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
SIZE=$(du -h /tmp/${myname}-httpd-logs-$timestamp.tar | awk '{print $1}')

aws s3 \
cp /tmp/${myname}-httpd-logs-${timestamp}.tar \
s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar




#Bookkeeping

cd /var/www/html

search=$(ls)

if  [[ $search == *"inventory.html"* ]]; then
        echo "Inventory File found"
else
        cd /var/www/html && touch inventory.html
	echo "<!DOCTYPE html>
		<html>
		<body>
		<table style="width:100%">
		  <tr>
		    <th>Log Type</th>
		    <th>Time Created</th>
		    <th>Type</th>
		    <th>Size</th>
		  </tr>
		</table>
		</body>
		</html>" > inventory.html

	echo "New Inventory file Created"
fi


echo  "<!DOCTYPE html>
                <html>
                <body>
                <table style="width:100%">
                  <tr>
                    <th>${myname}-httpd</th>
                    <th>${timestamp}</th>
                    <th>.tar</th>
                    <th>$SIZE</th>
                  </tr>
                </table>
                </body>
                </html>" >> /var/www/html/inventory.html


#Cron job

if [ -f "/etc/cron.d/automation" ];
then
	echo "cronjob already in place for automation script"
else
	touch /etc/cron.d/automation
	printf "0 0 * * * root /root/Automation_Project/auotmation.sh" > /etc/cron.d/automation
fi

