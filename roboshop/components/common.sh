#LOG_FILE=/tmp/roboshop.log
#rm -f ${LOG_FILE}
#
#MAX_LENGTH=$(cat components/*.sh  | grep -v -w cat | grep STAT_CHECK | awk -F '"' '{print $2}'  | awk '{ print length }'  | sort  | tail -1)
#
#if [ $MAX_LENGTH -lt 24 ];then
#  MAX_LENGTH=24
#fi
#
#STAT_CHECK() {
#  SPACE=""
#  LENGTH=$(echo $2 |awk '{ print length }' )
#  LEFT=$((${MAX_LENGTH}-${LENGTH}))
#  while [ $LEFT -gt 0 ]; do
#    SPACE=$(echo -n "${SPACE} ")
#    LEFT=$((${LEFT}-1))
#  done
#  if [ $1 -ne 0 ]; then
#    echo -e "\e[1m${2}${SPACE} - \e[1;31mFAILED\e[0m"
#    exit 1
#  else
#    echo -e "\e[1m${2}${SPACE} - \e[1;32mSUCCESS\e[0m"
#  fi
#}
#
#set-hostname -skip-apply ${COMPONENT}
#
#SYSTEMD_SETUP() {
#  chown roboshop:roboshop -R /home/roboshop
#  sed -i  -e 's/MONGO_DNSNAME/mongod.roboshop.internal/' \
#          -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' \
#          -e 's/MONGO_ENDPOINT/mongod.roboshop.internal/' \
#          -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' \
#          -e 's/CARTENDPOINT/cart.roboshop.internal/' \
#          -e 's/DBHOST/mysql.roboshop.internal/' \
#          -e 's/CARTHOST/cart.roboshop.internal/' \
#          -e 's/USERHOST/user.roboshop.internal/' \
#          -e 's/AMQPHOST/rabbitmq.roboshop.internal/' \
#          -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/' /home/roboshop/${component}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${component}/systemd.service /etc/systemd/system/${component}.service  &>>${LOG_FILE}
#  STAT_CHECK $? "Update SystemD Config file"
#
#  systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${component} &>>${LOG_FILE} && systemctl enable ${component} &>>${LOG_FILE}
#  STAT_CHECK $? "Start ${component} Service"
#}
#
#APP_USER_SETUP() {
#  id roboshop &>>${LOG_FILE}
#  if [ $? -ne 0 ]; then
#    useradd roboshop   &>>${LOG_FILE}
#    STAT_CHECK $? "Add Application User"
#  fi
#
#  DOWNLOAD ${component}
#}
#
#DOWNLOAD() {
#  curl -s -L -o /tmp/${1}.zip "https://github.com/roboshop-devops-project/${1}/archive/main.zip" &>>${LOG_FILE}
#  STAT_CHECK $? "Download ${1} Code"
#  cd /tmp
#  unzip -o /tmp/${1}.zip &>>${LOG_FILE}
#  STAT_CHECK $? "Extract ${1} Code"
#  if [ ! -z "${component}" ]; then
#    rm -rf /home/roboshop/${component} && mkdir -p /home/roboshop/${component} && cp -r /tmp/${component}-main/* /home/roboshop/${component} &>>${LOG_FILE}
#    STAT_CHECK $? "Copy ${component} Content"
#  fi
#}
#
#NODEJS() {
#  component=${1}
#  yum install nodejs make gcc-c++ -y &>>${LOG_FILE}
#  STAT_CHECK $? "Install NodeJS"
#
#  APP_USER_SETUP
#
#  cd /home/roboshop/${component} && npm install --unsafe-perm &>>${LOG_FILE}
#  STAT_CHECK $? "Install NodeJS dependencies"
#
#  SYSTEMD_SETUP
#}
#
#JAVA() {
#  component=${1}
#  yum install maven -y &>>${LOG_FILE}
#  STAT_CHECK $? "Installing Maven"
#
#  APP_USER_SETUP
#
#  cd /home/roboshop/${component} && mvn clean package &>>${LOG_FILE} && mv target/${component}-1.0.jar ${component}.jar &>>${LOG_FILE}
#  STAT_CHECK $? "Compile Java Code"
#
#  SYSTEMD_SETUP
#}
#
#PYTHON() {
#  component=${1}
#  yum install python36 gcc python3-devel -y &>>${LOG_FILE}
#  STAT_CHECK $? "Installing Python"
#
#  APP_USER_SETUP
#
#  cd /home/roboshop/${component} && pip3 install -r requirements.txt &>>${LOG_FILE}
#  STAT_CHECK $? "Install Python Dependencies"
#
#  SYSTEMD_SETUP
#}
#
#GOLANG() {
#  component=${1}
#  yum install golang -y &>>${LOG_FILE}
#  STAT_CHECK $? "Installing GoLang"
#
#  APP_USER_SETUP
#
#  cd /home/roboshop/${component} && go mod init dispatch &>>${LOG_FILE} && go get &>>${LOG_FILE}  && go build &>>${LOG_FILE}
#  STAT_CHECK $? "Install GoLang Dependencies & Compile"
#
#  SYSTEMD_SETUP
#}
#StatCheck() {
#  if [ $1 -eq 0 ]; then
#    echo -e "\e[32mSUCCESS\e[0m"
#  else
#    echo -e "\e[31mFAILURE\e[0m"
#    exit 2
#  fi
#}
#
#Print() {
#  echo -e "\n --------------------- $1 ----------------------" &>>$LOG_FILE
#  echo -e "\e[36m $1 \e[0m"
#}
#
#USER_ID=$(id -u)
#if [ "$USER_ID" -ne 0 ]; then
#  echo You should run your script as sudo or root user
#  exit 1
#fi
#LOG_FILE=/tmp/roboshop.log
#rm -f $LOG_FILE
#
#APP_USER=roboshop
#
#APP_SETUP() {
#  id ${APP_USER} &>>${LOG_FILE}
#  if [ $? -ne 0 ]; then
#    Print "Add Application User"
#    useradd ${APP_USER} &>>${LOG_FILE}
#    StatCheck $?
#  fi
#  Print "Download App Component"
#  curl -f -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
#  StatCheck $?
#
#  Print "CleanUp Old Content"
#  rm -rf /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE}
#  StatCheck $?
#
#  Print "Extract App Content"
#  cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/${COMPONENT}.zip &>>${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
#  StatCheck $?
#}
#
#SERVICE_SETUP() {
#  Print "Fix App User Permissions"
#  chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
#  StatCheck $?
#
#  Print "Setup SystemD File"
#  sed -i  -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' \
#          -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' \
#          -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' \
#          -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' \
#          -e 's/CARTENDPOINT/cart.roboshop.internal/' \
#          -e 's/DBHOST/mysql.roboshop.internal/' \
#          -e 's/CARTHOST/cart.roboshop.internal/' \
#          -e 's/USERHOST/user.roboshop.internal/' \
#          -e 's/AMQPHOST/rabbitmq.roboshop.internal/' \
#          /home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service  &>>${LOG_FILE}
#  StatCheck $?
#
#  Print "Restart ${COMPONENT} Service"
#  systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${COMPONENT} &>>${LOG_FILE} && systemctl enable ${COMPONENT} &>>${LOG_FILE}
# StatCheck $?
#  # STAT_CHECK $? "Start ${COMPONENT} Service"
#}
#
#NODEJS() {
#
#  Print "Configure Yum repos"
#  curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>${LOG_FILE}
#  StatCheck $?
#
#  Print "Install NodeJS"
#  yum install nodejs gcc-c++ -y &>>${LOG_FILE}
#  StatCheck $?
#
#  APP_SETUP
#
#  Print "Install App Dependencies"
#  cd /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE} && npm install &>>${LOG_FILE}
#  StatCheck $?
#
#  SERVICE_SETUP
#
#}
#
#MAVEN() {
#  Print "Install Maven"
#  yum install maven -y &>>${LOG_FILE}
#  StatCheck $?
#
#  APP_SETUP
#
#  Print "Maven Packaging"
#  cd /home/${APP_USER}/${COMPONENT} &&  mvn clean package &>>${LOG_FILE} && mv target/shipping-1.0.jar shipping.jar &>>${LOG_FILE}
#  StatCheck $?
#
#  SERVICE_SETUP
#
#}
#
#PYTHON() {
#
#  Print "Install Python"
#  yum install python36 gcc python3-devel -y &>>${LOG_FILE}
#  StatCheck $?
#
#  APP_SETUP
#
#  Print "Install Python Dependencies"
#  cd /home/${APP_USER}/${COMPONENT} && pip3 install -r requirements.txt &>>${LOG_FILE}
#  StatCheck $?
#
#  SERVICE_SETUP
#}
#



LOG_FILE=/tmp/roboshop.log
rm -f $LOG_FILE

## BUG about reaching one endpoint , To fix this we are using this command
rm -f /etc/yum.repos.d/endpoint.repo

STAT() {
  if [ $1 -eq 0 ]; then
    echo -e "\e[1;32m SUCCESS\e[0m"
  else
    echo -e "\e[1;31m FAILED\e[0m"
    exit 2
  fi
}

APP_USER_SETUP_WITH_APP() {
  echo "Create App User"
  id roboshop  &>>$LOG_FILE
  if [ $? -ne 0 ]; then
    useradd roboshop &>>$LOG_FILE
  fi
  STAT $?

  echo "Download ${COMPONENT} Code"
  curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>$LOG_FILE
  STAT $?

  echo "Extract ${COMPONENT} Code"
  cd /tmp/
  unzip -o ${COMPONENT}.zip &>>$LOG_FILE
  STAT $?

  echo "Clean Old ${COMPONENT} Content"
  rm -rf /home/roboshop/${COMPONENT}
  STAT $?

  echo "Copy ${COMPONENT} Content"
  cp -r ${COMPONENT}-main /home/roboshop/${COMPONENT} &>>$LOG_FILE
  STAT $?
}

SYSTEMD_SETUP() {

  echo "Fix App Permissions"
    chown -R roboshop:roboshop /home/roboshop &>>$LOG_FILE
    STAT $?
 # chown -R  roboshop:roboshop /home/roboshop/ &>>$LOG_FILE
  echo "Update ${COMPONENT} SystemD file"
  sed -i -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' \
   -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' \
   -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' \
    -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/'\
     -e 's/CARTENDPOINT/cart.roboshop.internal/' \
     -e 's/DBHOST/mysql.roboshop.internal/' \
     -e 's/CARTHOST/cart.roboshop.internal/' \
     -e 's/USERHOST/user.roboshop.internal/' \
     -e 's/AMQPHOST/rabbitmq.roboshop.internal/' \
     -e 's/RABBITMQ-IP/rabbitmq.roboshop.internal/'\
      /home/roboshop/${COMPONENT}/systemd.service &>>$LOG_FILE
  STAT $?

  echo "Setup ${COMPONENT} SystemD file"
  mv /home/roboshop/${COMPONENT}/systemd.service  /etc/systemd/system/${COMPONENT}.service &>>$LOG_FILE
  STAT $?

  echo "Start ${COMPONENT} Service"
  systemctl daemon-reload &>>$LOG_FILE && systemctl restart ${COMPONENT} &>>$LOG_FILE && systemctl enable ${COMPONENT} &>>$LOG_FILE
 # systemctl daemon-relaod  &>>$LOG_FILE && systemctl enable ${COMPONENT} &>>$LOG_FILE && systemctl restart ${COMPONENT} &>>$LOG_FILE
  STAT $?

}

NODEJS() {
  COMPONENT=$1
  echo "Setup NodeJS repo"
  curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>$LOG_FILE
  STAT $?

  echo "Install NodeJS"
  yum install nodejs gcc-c++ -y &>>$LOG_FILE
  STAT $?

  APP_USER_SETUP_WITH_APP

  echo "Install NodeJS Dependencies"

  cd /home/roboshop/${COMPONENT} &>>$LOG_FILE
  npm install --unsafe-perm  &>>$LOG_FILE
  STAT $?

  SYSTEMD_SETUP
}

JAVA() {
  COMPONENT=$1

  echo "Install Maven"
  yum install maven -y &>>$LOG_FILE
  STAT $?

  APP_USER_SETUP_WITH_APP

  echo "Compile ${COMPONENT} Code"
  cd /home/roboshop/${COMPONENT}
  mvn clean package &>>$LOG_FILE && mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
  STAT $?

  SYSTEMD_SETUP
}

PYTHON() {
  COMPONENT=$1

  echo "Install Python"
  yum install python36 gcc python3-devel -y &>>$LOG_FILE
  STAT $?

  APP_USER_SETUP_WITH_APP

  echo "Install Python Dependencies for ${COMPONENT}"
  cd /home/roboshop/${COMPONENT}
  pip3 install -r requirements.txt &>>$LOG_FILE
  STAT $?

  echo "Update Application Config"
  USER_ID=$(id -u roboshop)
  GROUP_ID=$(id -g roboshop)
  sed -i -e "/uid/ c uid = ${USER_ID}" -e "/gid/ c gid = ${GROUP_ID}" /home/roboshop/${COMPONENT}/${COMPONENT}.ini
  STAT $?

  SYSTEMD_SETUP
}

GOLANG() {
  COMPONENT=$1

  echo "Install GoLang"
  yum install golang -y &>>$LOG_FILE
  STAT $?

  APP_USER_SETUP_WITH_APP

  echo "Build GoLang Code"
  cd /home/roboshop/${COMPONENT}
  go mod init dispatch &>>$LOG_FILE && go get  &>>$LOG_FILE && go build &>>$LOG_FILE
  STAT $?

  SYSTEMD_SETUP
}

CHECK_REDIS_FROM_APP() {
 echo "Checking DB  Connections from APP In Redis "
  sleep 15
 ## echo status = $STAT
  STAT=$(curl -s localhost:8080/health  | jq .redis)
  if [ "$STAT" == "true" ]; then
    STAT 0
  else
    STAT 1
  fi
}

CHECK_MONGO_FROM_APP() {
  echo "Checking DB Connections from APP IN Mongo"
  sleep 10
  ##echo status= $STAT

  STAT=$(curl -s localhost:8080/health  | jq .mongo)
  if [ "$STAT" == "true" ]; then
    STAT 0
  else
    STAT 1
  fi
}


#CHECK_SHIPPING_FROM_APP()
#{
#  echo "Checking DB  Connections from APP In Shipping "
#    sleep 15
#  ##echo status = $STAT
#    STAT=$(curl -s localhost:8080/health  | jq .shipping)
#    if [ "$STAT" == "true" ]; then
#      STAT 0
#    else
#      STAT 1
#    fi
#
#}