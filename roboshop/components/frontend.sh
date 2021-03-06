#!/bin/bash
#
## source is nothing but import , like export command
#source components/common.sh
#
#yum install nginx -y &>>${LOG_FILE}
#STAT_CHECK $? "Nginx Installation"
#
#DOWNLOAD frontend
#
#rm -rf /usr/share/nginx/html/*
#STAT_CHECK $? "Remove old HTML Pages"
#
#cd  /tmp/frontend-main/static/ && cp -r * /usr/share/nginx/html/
#STAT_CHECK $? "Copying Frontend Content"
#
#cp /tmp/frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf
#STAT_CHECK $? "Copy Nginx Config File"
#
#for component in catalogue cart user shipping payment ; do
#  sed -i -e "/${component}/ s/localhost/${component}.roboshop.internal/" /etc/nginx/default.d/roboshop.conf
#done
#STAT_CHECK $? "Update Nginx Config File"
#
#systemctl enable nginx &>>${LOG_FILE} && systemctl restart nginx &>>${LOG_FILE}
#STAT_CHECK $? "Restart Nginx"
#source components/common.sh
#
#Print "Installing Nginx"
#yum install nginx -y &>>$LOG_FILE
#StatCheck $?
#
#Print "Downloading Nginx Content"
#curl -f -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
#StatCheck $?
#
#Print "Cleanup Old Nginx Content"
#rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
#StatCheck $?
#
#cd /usr/share/nginx/html/
#
#Print "Extracting Archive"
#unzip /tmp/frontend.zip &>>$LOG_FILE  && mv frontend-main/* . &>>$LOG_FILE  && mv static/* &>>$LOG_FILE .
#StatCheck $?
#
#
#Print "Update RoboShop Configuration"
#mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
#for component in catalogue user cart shipping payment; do
#  echo -e "Updating $component in Configuration"
#  sed -i -e "/${component}/s/localhost/${component}.roboshop.internal/"  /etc/nginx/default.d/roboshop.conf
#  StatCheck $?
#done
#
#
#Print "Starting Nginx"
#systemctl restart nginx &>>$LOG_FILE  && systemctl enable nginx &>>$LOG_FILE
#StatCheck $?



source components/common.sh

echo "Installing NGINX"
yum install nginx -y &>>$LOG_FILE
STAT $?

echo "Download Frontend Content"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>$LOG_FILE
STAT $?

echo "Clean Old Content"
rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
STAT $?

echo "Extract Frontend Content"
cd /tmp
unzip -o frontend.zip &>>$LOG_FILE
STAT $?

echo "Copy Extracted Content to Nginx Path"
cp -r frontend-main/static/* /usr/share/nginx/html/ &>>$LOG_FILE
STAT $?

echo "Copy Nginx RoboShop Config"
cp frontend-main/localhost.conf /etc/nginx/default.d/roboshop.conf &>>$LOG_FILE
STAT $?

echo "Update RoboShop Config"
sed -i -e "/catalogue/ s/localhost/catalogue.roboshop.internal/" -e '/user/ s/localhost/user.roboshop.internal/' -e '/cart/ s/localhost/cart.roboshop.internal/' -e '/shipping/ s/localhost/shipping.roboshop.internal/' -e '/payment/ s/localhost/payment.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
STAT $?

echo "Start Nginx Service"
systemctl enable nginx &>>$LOG_FILE
systemctl restart nginx  &>>$LOG_FILE
STAT $?



