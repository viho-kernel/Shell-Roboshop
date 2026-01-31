#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD


R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"

mkdir -p $LOG_FOLDER

if [ $USER_ID -ne 0 ]; then
   echo -e " $R User is not Root, Run the script as root user. :) " | tee -a $LOG_FILE
   exit 1
fi

VALIDATE() {

if [ $1 -ne 0 ]; then
    echo -e " $R $2... Failed $N" | tee -a $LOG_FILE
else
    echo -e " $ $G $2... Success $N" | tee -a $LOG_FILE
fi

}

cp ${SCRIPT_DIR}/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "Copying rabbitmq.repo"

dnf install rabbitmq-server -y &>> ${LOG_FILE}
VALIDATE $? "Installing rabbitmq server"

systemctl enable rabbitmq-server &>> ${LOG_FILE}
VALIDATE $? "Enabling rabbitmq server"

systemctl start rabbitmq-server &>> ${LOG_FILE}
VALIDATE $? "Starting rabbitmq server"

rabbitmqctl list_users | grep roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then 
   rabbitmqctl add_user roboshop roboshop123 &>> $LOG_FILE
   VALIDATE $? "Creating RabbitMQ user roboshop"
else 
  echo -e "RabbitMQ user roboshop already exists ... $Y Skipping $N" 
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"

VALIDATE $? "Setting RabbitMQ permissions for roboshop"
