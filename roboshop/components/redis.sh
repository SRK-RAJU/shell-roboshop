#!/bin/bash

#source components/common.sh
#
#Print "Setup YUM Repos"
#curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
#StatCheck $?
#
#Print "Install Redis"
#yum install redis -y &>>${LOG_FILE}
#StatCheck $?
#
#Print "Update Redis Config"
#if [ -f /etc/redis.conf ]; then
#  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
#fi
#if [ -f /etc/redis/redis.conf ] ; then
#  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
#fi
#StatCheck $?
#
#Print "Start Redis Service"
#systemctl enable redis &>>${LOG_FILE} && systemctl start redis &>>${LOG_FILE}
#StatCheck $?


source components/common.sh
#
#
#
#echo "Configuring Redis repo"
#curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>$LOG_FILE
#STAT $?
#
#echo "Installing EPEL RELEASE"
#yum install epel-release yum-utils -y &>>$LOG_FILE
#Start $?
#
#echo "Installing redis utils repos"
#sudo yum install yum-utils  http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y  &>>$LOG_FILE
#Stat $?
#echo "enable remi Repos "
#sudo yum-config-manager --enable remi &>>$LOG_FILE
#Stat $?
#echo "Install  Redis "
#sudo yum install redis -y &>>$LOG_FILE
#Stat $?
#echo  "Update Redis Listen Address "
#sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>$LOG_FILE
#Stat $?
#
##echo "Update redis configuration"
##if [ -f /etc/redis.conf  ]; then
##  sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf &>>$LOG_FILE
##elif [ -f /etc/redis/redis.conf  ]; then
##  sed -i -e "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf &>>$LOG_FILE
##fi
##STAT $?
#
#echo "Start Redis"
#
#systemctl restart redis  &>>$LOG_FILE
#systemctl enable redis  &>>$LOG_FILE
##systemctl restart redis  &>>$LOG_FILE
#STAT $?


echo "Installing EPEL RELEASE"
yum install yum-utils http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG_FILE
#yum install epel-release yum-utils -y &>>$LOG_FILE
#STAT $?

#echo "Installing redis repos"
#sudo yum install yum-utils  http://rpms.remirepo.net/enterprise/remi-release-7.rpm -y &>>$LOG_FILE
STAT $?
echo "enable Redis Repos "
sudo yum-config-manager --enable remi &>>$LOG_FILE
STAT $?
echo "Install  Redis "
sudo yum install redis -y &>>$LOG_FILE
STAT $?


echo "Update Redis Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>$LOG_FILE
STAT $?

#echo "Configure Redis Listen Address\t\t"
#if [ -f /etc/redis.conf ]; then
#  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf
#fi
#if [ -f /etc/redis/redis.conf ]; then
#  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
#fi
#STAT $?

echo "Start Redis Service\t\t\t"
systemctl enable redis &>>$LOG_FILE && systemctl restart redis &>>$LOG_FILE && systemctl restart redis &>>$LOG_FILE && systemctl enable redis &>>$LOG_FILE
STAT $?

#echo "Update Redis Listen Address "
#sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>$LOG_FILE
#STAT $?
#echo "Start Redis Database"
#systemctl restart redis &>>$LOG_FILE  && systemctl enable redis &>>$LOG_FILE
#STAT $?
echo "Load Schema"
cd redis-main
for app in cart users ; do
  redis < ${app}.js &>>$LOG_FILE
done
STAT $?