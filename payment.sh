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

dnf install python3 gcc python3-devel -y $>> ${LOG_FILE}
VALIDATE $? "Install Python3" 

id roboshop &>> $LOG_FILE

if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating User"
else
   echo -e "Roboshop user already exist ... $Y Skipping $N"
fi

mkdir -p /app

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>> ${LOG_FILE}

VALIDATE $? "Installing Python Dependency"

cd /app

unzip /tmp/payment.zip
VALIDATE $? "Unzipping Payment file."

cd /app 

pip3 install -r requirements.txt &>> ${LOG_FILE}
VALIDATE $? "Installing Dependencies."

cp ${SCRIPT_DIR}/payment.repo /etc/systemd/system/payment.service
VALIDATE $? "Copying payment.repo file"

systemctl daemon-reload
systemctl enable payment &>> ${LOG_FILE}
systemctl start payment