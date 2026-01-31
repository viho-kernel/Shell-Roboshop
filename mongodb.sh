#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="/var/log/shell-sctipt-logs/$0.log"

R="\e[31m"
G="\e[32m"
Y="\e[33m"
B="\e[34m"
P="\e[35m"
C="\e[36m"
N="\e[0m"

mkdir -p $LOG_FOLDER

VALIDATE() {
    if [ $1 -ne 0 ]; then
       echo -e " $R $2... Failed $N " | tee -a $LOG_FILE
    else
       echo -e " $G $2.... Success $N " | tee -a $LOG_FILE
    fi
}

cp mongodb.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "Copying Mongo Repo"

dnf install mongodb-org -y &>> $LOG_FILE

VALIDATE $? "Installation of Mongodb"

systemctl enable mongod &>> $LOG_FILE

VALIDATE $? "Enabling of Mongodb"

systemctl start mongod &>> $LOG_FILE

VALIDATE $? "Starting of Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE $? "editing application service"

systemctl restart mongod

VALIDATE $? "Restarting mondoDB service is "