#!/bin/bash

#LID="lt-00ca4f838057de89d"
#LVER=2
#INSTANCE_NAME=$1
#
#if [ -z "${INSTANCE_NAME}" ]; then
#  echo "Input is missing"
#  exit 1
#fi
#
#aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" | jq .Reservations[].Instances[].State.Name | grep running &>/dev/null
#if [ $? -eq 0 ]; then
#  echo "Instance $INSTANCE_NAME is already running"
#  exit 0
#fi
#
#aws ec2 describe-instances --filters "Name=tag:Name,Values=$INSTANCE_NAME" | jq .Reservations[].Instances[].State.Name | grep stopped &>/dev/null
#if [ $? -eq 0 ]; then
#  echo "Instance $INSTANCE_NAME is already created and stopped"
#  exit 0
#fi
#
#IP=$(aws ec2 run-instances --launch-template LaunchTemplateId=$LID,Version=$LVER --tag-specifications "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]" | jq .Instances[].PrivateIpAddress | sed -e 's/"//g')
#
#sed -e "s/INSTANCE_NAME/$INSTANCE_NAME/" -e "s/INSTANCE_IP/$IP/" record.json >/tmp/record.json
#aws route53 change-resource-record-sets --hosted-zone-id Z0154279NRNJNHPQSM7G --change-batch file:///tmp/record.json | jq

CREATE() {

COUNT=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null | wc -l )

if [ $COUNT -eq 0 ]; then
aws ec2 run-instances --image-id ami-0bb6af715826253bf --instance-type t2.micro  --security-group-ids sg-063120a81cc0aff8a  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$1}]" | jq &>/dev/null
else
  echo -e "\e[1;33m$1 Instance Already Exists\e[0m"
  return
  fi
  sleep 2

 IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$1" | jq ".Reservations[].Instances[].PrivateIpAddress" | grep -v null  | xargs )

 ## xargs is used to remove the double quotes in displaying the output

 sed -e "s/DNSNAME/$1.roboshop.internal/"  -e "s/IPADDRESS/${IP}/" route53.json >/tmp/record.json
 aws route53 change-resource-record-sets --hosted-zone-id Z0154279NRNJNHPQSM7G --change-batch  file:///tmp/record.json | jq &>/dev/null


}

if [ "$1" == "all" ]; then
  ALL=(frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment)
  for component in ${ALL[*]}; do
    echo "Creating Instance - $component "
    CREATE $component
  done
else
  CREATE $1
fi
#
#if [ -z "$1" ]; then
#  echo -e "\e[31mInput Machine Name is needed\e[0m"
#  exit 1
#fi
#
#COMPONENT=$1
#ZONE_ID="Z0154279NRNJNHPQSM7G"
#
#create_ec2() {
#  PRIVATE_IP=$(aws ec2 run-instances \
#      --image-id ${AMI_ID} \
#      --instance-type t2.micro \
#      --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${COMPONENT}}]" \
#      --instance-market-options "MarketType=spot,SpotOptions={SpotInstanceType=persistent,InstanceInterruptionBehavior=stop}"\
#      --security-group-ids ${SGID} \
#      | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')
#
#  sed -e "s/IPADDRESS/${PRIVATE_IP}/" -e "s/COMPONENT/${COMPONENT}/" route53.json >/tmp/record.json
#  aws route53 change-resource-record-sets --hosted-zone-id ${ZONE_ID} --change-batch file:///tmp/record.json | jq
#}
#
#AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" | jq '.Images[].ImageId' | sed -e 's/"//g')
#SGID=$(aws ec2 describe-security-groups --filters Name=group-name,Values=SRK | jq  '.SecurityGroups[].GroupId' | sed -e 's/"//g')
#
##if [ "$1" == "all" ]; then
##  for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis ; do
##    COMPONENT=$component
##    create_ec2 ${component}
##  done
##else
##  create_ec2 $1
##fi
#if [ "$1" == "all" ]; then
#  ALL=(frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment)
#  for component in ${ALL[*]}; do
#    echo "Creating Instance - $component "
#   create_ec2 $component
#  done
#else
#  create_ec2 $1
#fi
#
#
#
##LOG=/tmp/instance-create.log
##rm -f $LOG
##
##INSTANCE_CREATE() {
##  INSTANCE_NAME=$1
##  if [ -z "${INSTANCE_NAME}" ]; then
##    echo -e "\e[1;33mInstance Name Argument is needed\e[0m"
##    exit
##  fi
##
##  AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=Centos-7-DevOps-Practice" --query 'Images[*].[ImageId]' --output text)
##
##  if [ -z "${AMI_ID}" ]; then
##    echo -e "\e[1;31mUnable to find Image AMI_ID\e[0m"
##    exit
##  else
##    echo -e "\e[1;32mAMI ID = ${AMI_ID}\e[0m"
##  fi
##
##  PRIVATE_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
##
##  if [ -z "${PRIVATE_IP}" ]; then
##    # Find Security Group
##    SG_ID=$(aws ec2 describe-security-groups --filter Name=group-name,Values=SRK --query "SecurityGroups[*].GroupId" --output text)
##    if [ -z "${SG_ID}" ]; then
##      echo -e "\e[1;33m Security Group allow-all-ports does not exist"
##      exit
##    fi
##    # Creating Instance
##    aws ec2 run-instances --image-id ${AMI_ID} --instance-type t3.micro --output text --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]" "ResourceType=spot-instances-request,Tags=[{Key=Name,Value=${INSTANCE_NAME}}]"  --instance-market-options "MarketType=spot,SpotOptions={InstanceInterruptionBehavior=stop,SpotInstanceType=persistent}" --security-group-ids "${SG_ID}"  &>>$LOG
##    echo -e "\e[1m Instance Created\e[0m"
##  else
##    echo "Instance ${INSTANCE_NAME} is already exists, Hence not creating"
##  fi
##
##  IPADDRESS=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${INSTANCE_NAME}" --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)
##
##  echo '{
##              "Comment": "CREATE/DELETE/UPSERT a record ",
##              "Changes": [{
##              "Action": "UPSERT",
##                          "ResourceRecordSet": {
##                                      "Name": "DNSNAME.roboshop.internal",
##                                      "Type": "A",
##                                      "TTL": 300,
##                                   "ResourceRecords": [{ "Value": "IPADDRESS"}]
##  }}]
##  }' | sed -e "s/DNSNAME/${INSTANCE_NAME}/" -e "s/IPADDRESS/${IPADDRESS}/"  >/tmp/record.json
##
##  ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[*].{name:Name,ID:Id}" --output text | grep roboshop.internal  | awk '{print $1}' | awk -F / '{print $3}')
##  aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch file:///tmp/record.json --output text &>>$LOG
##  echo -e "\e[1m DNS Record Created\e[0m"
##}
##
##### Main Program
##
##
##if [ "$1" == "list" ]; then
##  aws ec2 describe-instances  --query "Reservations[*].Instances[*].{PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name}"  --output table
##  exit
##elif [ "$1" == "all" ]; then
##  for component in cart catalogue dispatch frontend mongodb mysql payment rabbitmq redis shipping user ; do
##    INSTANCE_CREATE ${component}
##  done
##else
##  INSTANCE_CREATE $1
##fi