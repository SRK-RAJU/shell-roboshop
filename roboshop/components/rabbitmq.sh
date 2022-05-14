#!/bin/bash

#source components/common.sh
#
#Print "Configure YUM Repos"
#curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${LOG_FILE}
#StatCheck $?
#
#Print "Install ErLang & RabbitMQ"
#yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG_FILE}
#StatCheck $?
#
#
#Print "Start RabbitMQ Service"
#systemctl enable rabbitmq-server &>>${LOG_FILE} && systemctl start rabbitmq-server &>>${LOG_FILE}
#StatCheck $?
#
#rabbitmqctl list_users | grep roboshop &>>${LOG_FILE}
#if [ $? -ne 0 ]; then
#  Print "Create Application User"
#  rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
#  StatCheck $?
#fi
#
#Print "Configure Application User"
#rabbitmqctl set_user_tags roboshop administrator &>>${LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG_FILE}
#StatCheck $?


source components/common.sh

echo "Configure YUM repos"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>$LOG_FILE
STAT $?

echo "Install RabbitMQ & ErLang"
yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>$LOG_FILE
STAT $?

echo "Start RabbitMQ Server"
systemctl enable rabbitmq-server &>>$LOG_FILE && systemctl start rabbitmq-server &>>$LOG_FILE
STAT $?

echo "Create Application User"
rabbitmqctl list_users | grep roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
  rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
fi
STAT $?

echo "Setup Permissions for App User"
rabbitmqctl set_user_tags roboshop administrator &>>$LOG_FILE && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
STAT $?