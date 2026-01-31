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
       echo -e " $R $2... Failed $N " | tee -a $LOG_FILE
    else
       echo -e " $G $2.... Success $N " | tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>> $LOG_FILE
VALIDATE $? "Installing MySql"

systemctl enable mysqld &>> $LOG_FILE

VALIDATE $? "Enabling MySql"


systemctl start mysqld  &>> $LOG_FILE

VALIDATE $? "Starting MySql"

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE $? "Configured Default Password"