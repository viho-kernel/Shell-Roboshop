#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="$LOG_FOLDER/$0.log"
MONGODB_HOST="mongodb.opsora.space"
SCRIPT_DIR=$PWD

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"

if [ $USER_ID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
       echo -e " $R $2... Failed $N " | tee -a $LOG_FILE
    else
       echo -e " $G $2.... Success $N " | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"
 
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating User"
else
   echo -e "Roboshop user already exist ... $Y Skipping $N"
fi

mkdir -p /app
VALIDATE $? "Creating APP Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Installing Artifact"

cd /app
VALIDATE $? "Moving to App Directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the catalogue in APP Directory"

npm install &>> $LOG_FILE
VALIDATE $? "Downloading dependencies"

touch /etc/systemd/system/catalogue.service

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Created systemctl service"

systemctl daemon-reload
systemctl enable catalogue &>>$LOG_FILE
systemctl start catalogue
VALIDATE $? "Starting and enabling catalogue"

cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying mongodb repo file"

dnf install mongodb-mongosh -y &>>$LOGS_FILE

mongosh --host $MONGODB_HOST </app/db/master-data.js

VALIDATE $? "Loading catalogue schema"

systemctl restart catalogue &>>$LOG_FILE

VALIDATE $? "Restarting Catalogue" 

systemctl status catalogue &>>$LOGFILE

VALIDATE $? "Checking catalogue status" 

