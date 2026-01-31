#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="$LOG_FOLDER/$0.log"
MONGODB_HOST="mongodb.opsora.space"
CATALOGUE_HOST="catalogue.opsora.space"
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

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling default nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx 1.24 Version"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing Nginx -y"

systemctl enable nginx &>>$LOG_FILE

VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOG_FILE

VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default nginx"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Frontend Content"

cd /usr/share/nginx/html $>>$LOG_FILE

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping frontend content"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Creating Reverse Proxy configuration"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting Nginx Service"