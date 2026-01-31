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

dnf install golang -y &>> ${LOG_FILE}
VALIDATE $? "Installing Go Language"

id roboshop &>> $LOG_FILE

if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop #creating user
   VALIDATE $? "Creating User"
else
   echo -e "Roboshop user already exist ... $Y Skipping $N"
fi

mkdir -p /app 

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip &>> $LOG_FILE

VALIDATE $? "Installing Artifacts"

cd /app 

unzip /tmp/dispatch.zip &>> $LOG_FILE

cd /app

go mod init dispatch &>> $LOG_FILE
VALIDATE $? "Initializing Go module 'dispatch'"

go get &>> $LOG_FILE
VALIDATE $? "Downloading Go dependencies"

go build &>> $LOG_FILE
VALIDATE $? "Building Go application"

cp $SCRIPT_DIR/${dispatch.repo} /etc/systemd/system/dispatch.service &>> $LOG_FILE
VALIDATE $? "Copying Scripts"

systemctl daemon-reload
systemctl enable dispatch &>> $LOG_FILE
systemctl start dispatch
VALIDATE $? "Reloading and enabling dispatch service"