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

if [ $USER_ID -ne 0 ]; then
    echo -e "$R Please run this script with root user access $N" | tee -a $LOG_FILE
    exit 1
fi

mkdir -p $LOG_FOLDER

VALIDATE() {
if [ $1 -ne 0 ]; then
   echo -e " $R $2... Failed $N" | tee -a $LOG_FILE

else
   echo -e " $G $2... Successful $N" | tee -a $LOG_FILE

fi

}

dnf module disable nodejs -y &>> $LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>> $LOG_FILE
VALIDATE $? "Enabling nodejs 20 version"

dnf install nodejs -y &>> $LOG_FILE

VALIDATE $? "Disabling default nodejs"

id roboshop &>> $LOG_FILE

if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating User"
else
   echo -e "Roboshop user already exist ... $Y Skipping $N"
fi

mkdir -p /app &>> $LOG_FILE
VALIDATE $? "Creating app"

cd /app

VALIDATE $? "Moving to APP Directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>> $LOG_FILE

VALIDATE $? "Downloading Artifact"

unzip /tmp/user.zip &>> $LOG_FILE

VALIDATE $? "Unzipping Code."

npm install &>> $LOG_FILE

VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>> $LOG_FILE


systemctl daemon-reload
systemctl enable user   &>> $LOG_FILE
systemctl start user

VALIDATE $? "Reloading and enabling the user"