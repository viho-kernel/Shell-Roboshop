#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="$LOG_FOLDER/$0.log"

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
   echo -e " $R $2... Successful $N" | tee -a $LOG_FILE

fi

}

dnf module disable redis -y &>> $LOG_FILE
VALIDATE $? "Disabling default redis"

dnf module enable redis:7 -y &>> $LOG_FILE
VALIDATE $? "enabling default redis"

dnf install redis -y  &>> $LOG_FILE
VALIDATE $? "Installing redis"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf

systemctl enable redis &>> $LOG_FILE
VALIDATE $? "Enabling redis"

systemctl start redis &>> $LOG_FILE
VALIDATE $? "Starting redis"