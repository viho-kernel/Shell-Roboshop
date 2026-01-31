#!/bin/bash

USER_ID=$(id -u)
LOG_FOLDER="/var/log/Shell-Roboshop-logs"
LOG_FILE="$LOG_FOLDER/$0.log"
SCRIPT_DIR=$PWD
MYSQL_HOST="mysql.opsora.space"

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

dnf install maven -y &>> $LOG_FILE
VALIDATE $? "Installing Maven (Java)"

id roboshop &>> $LOG_FILE
if [ $? -ne 0 ]; then
   useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
   VALIDATE $? "Creating Roboshop User"
else
   echo -e "Roboshop user already exist ... $Y Skipping $N"
fi

#SETUP APP DIRECTORY

mkdir -p /app $>> $LOG_FILE
VALIDATE $? "Creating /app directory"

cd /app
VALIDATE $? "Moving to /app directory"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>> $LOG_FILE
VALIDATE $? "Downloading Shipping Artifact"

unzip /tmp/shipping.zip &>> $LOG_FILE
VALIDATE $? "Unzipping the shipping"

mvn clean package &>> $LOG_FILE
VALIDATE $? "Building Shipping Application with Maven"

mv target/shipping-1.0.jar shipping.jar &>> $LOG_FILE
VALIDATE $? "Renaming shipping jar"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>> $LOG_FILE
VALIDATE $? "Copying Shipping Service file"

systemctl daemon-reload
systemctl enable shipping &>>$LOG_FILE
systemctl start shipping
VALIDATE $? "Starting Shipping Service"

dnf install mysql -y &>> $LOG_FILE
VALIDATE $? "Installing MySQL Client"

mysql -h ${MYSQL_HOST} -uroot -pRoboShop@1 < /app/db/schema.sql
VALIDATE $? "Loading schema.sql into MySQL"

mysql -h ${MYSQL_HOST} -uroot -pRoboShop@1 < /app/db/app-user.sql 
VALIDATE $? "Loading app-user.sql into MySQL"

mysql -h ${MYSQL_HOST} -uroot -pRoboShop@1 < /app/db/master-data.sql
VALIDATE $? "Loading master-data.sql into MySQL"

systemctl restart shipping
VALIDATE $? "Restarting Shipping Service"