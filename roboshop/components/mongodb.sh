#!/bin/bash
#
#source components/common.sh
#
#### MongoDB Setup
#echo -e "        ------>>>>>> \e[1;35mMongoDB Setup\e[0m <<<<<<------"
#curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>${LOG_FILE}
#STAT_CHECK $? "Download MongoDB repo"
#
#
#yum install -y mongodb-org &>>${LOG_FILE}
#STAT_CHECK $? "Install MongoDB"
#
#sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG_FILE}
#STAT_CHECK $? "Update MongoDB Service"
#
#systemctl enable mongod &>>${LOG_FILE} && systemctl restart mongod &>>${LOG_FILE}
#STAT_CHECK $? "Start MongoDB Service"
#
#DOWNLOAD mongodb
#
#cd /tmp/mongodb-main
#mongo < catalogue.js &>>${LOG_FILE} && mongo < users.js &>>${LOG_FILE}
#STAT_CHECK $? "Load Schema"
#
#
#### Redis Setup
#echo -e "        ------>>>>>> \e[1;35mRedis Setup\e[0m <<<<<<------"
#
#curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
#STAT_CHECK $? "Download Redis Repo"
#
#yum install redis -y  &>>${LOG_FILE}
#STAT_CHECK $? "Install Redis"
#
#
#sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf /etc/redis/redis.conf &>>${LOG_FILE}
#STAT_CHECK $? "Update Redis Config"
#
#systemctl enable redis &>>${LOG_FILE}  && systemctl restart redis &>>${LOG_FILE}
#STAT_CHECK $? "Update Redis"
#
#### RabbitMQ Setup
#echo -e "        ------>>>>>> \e[1;35mRabbitMQ Setup\e[0m <<<<<<------"
#
#curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash &>>${LOG_FILE}
#STAT_CHECK $? "Download RabbitMQ Repo"
#
#yum install https://github.com/rabbitmq/erlang-rpm/releases/download/v23.2.6/erlang-23.2.6-1.el7.x86_64.rpm rabbitmq-server -y &>>${LOG_FILE}
#STAT_CHECK $? "Install Erlang & RabbitMQ"
#
#
#systemctl enable rabbitmq-server &>>${LOG_FILE}  && systemctl start rabbitmq-server &>>${LOG_FILE}
#
#rabbitmqctl  list_users | grep roboshop &>>${LOG_FILE}
#if [ $? -ne 0 ]; then
#  rabbitmqctl add_user roboshop roboshop123 &>>${LOG_FILE}
#  STAT_CHECK $? "Create APp User in RabbitMQ"
#fi
#
#rabbitmqctl set_user_tags roboshop administrator  &>>${LOG_FILE} && rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"  &>>${LOG_FILE}
#STAT_CHECK $? "Configure APp User Permissions"
#
#### MySQL Setup
#
#echo -e "        ------>>>>>> \e[1;35mMySQL Setup\e[0m <<<<<<------"
#
#curl -s -L -o /etc/yum.repos.d/mysql.repo https://raw.githubusercontent.com/roboshop-devops-project/mysql/main/mysql.repo &>>${LOG_FILE}
#STAT_CHECK $? "Configure YUM Repos"
#
#
#yum install mysql-community-server -y &>>${LOG_FILE}
#STAT_CHECK $? "Installing MySQL"
#
#systemctl enable mysqld &>>${LOG_FILE} && systemctl start mysqld &>>${LOG_FILE}
#STAT_CHECK $? "Start MySQL Service"
#
#DEFAULT_PASSWORD=$(grep 'temporary password' /var/log/mysqld.log  | awk '{print $NF}')
#
#echo 'show databases;' | mysql -uroot -pRoboShop@1 &>>${LOG_FILE}
#if [ $? -ne 0 ]; then
#  echo "ALTER USER 'root'@'localhost' IDENTIFIED BY 'RoboShop@1';" >/tmp/pass.sql
#  mysql --connect-expired-password -uroot -p"${DEFAULT_PASSWORD}" </tmp/pass.sql &>>${LOG_FILE}
#  STAT_CHECK $? "Setup new root password"
#fi
#
#echo 'show plugins;' | mysql -uroot -pRoboShop@1 2>>${LOG_FILE} | grep validate_password &>>${LOG_FILE}
#if [ $? -eq 0 ]; then
#  echo 'uninstall plugin validate_password;' | mysql -uroot -pRoboShop@1 &>>${LOG_FILE}
#  STAT_CHECK $? "Uninstall Password Plugin"
#fi
#
#DOWNLOAD mysql
#
#cd /tmp/mysql-main
#mysql -u root -pRoboShop@1 <shipping.sql &>>${LOG_FILE}
#STAT_CHECK $? "Load Schema"
#source components/common.sh
#
#Print "Setup YUM Repos"
#curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
#StatCheck $?
#
#Print "Install MongoDB"
#yum install -y mongodb-org &>>$LOG_FILE
#StatCheck $?
#
#Print "Update MongoDB Listen Address"
#sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
#StatCheck $?
#
#Print "Start MongoDB"
#systemctl enable mongod &>>$LOG_FILE && systemctl restart mongod &>>$LOG_FILE
#StatCheck $?
#
#Print "Download Schema"
#curl -f -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip" &>>$LOG_FILE
#StatCheck $?
#
#Print "Extract Schema"
#cd /tmp && unzip -o mongodb.zip &>>$LOG_FILE
#StatCheck $?
#
#Print "Load Schema"
#cd mongodb-main
#for schema in catalogue users; do
#  echo "Load $schema Schema"
#  mongo < ${schema}.js &>>$LOG_FILE
#  StatCheck $?
#done


source components/common.sh

echo "Download MongoDb repo file"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
STAT $?

echo "Install MongoDB"
yum install -y mongodb-org &>>$LOG_FILE
STAT $?

echo "Update MongoDB Config file"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf  &>>$LOG_FILE
STAT $?

echo "Start Database"
systemctl enable mongod  &>>$LOG_FILE && systemctl start mongod &>>$LOG_FILE
STAT $?

echo "Download Schema"
curl -s -L -o /tmp/mongodb.zip "https://github.com/roboshop-devops-project/mongodb/archive/main.zip"  &>>$LOG_FILE
STAT $?

echo "Extract Schema"
cd /tmp/
unzip -o mongodb.zip  &>>$LOG_FILE
STAT $?

echo "Load Schema"
cd mongodb-main
for app in catalogue users ; do
  mongo < ${app}.js &>>$LOG_FILE
done
STAT $?