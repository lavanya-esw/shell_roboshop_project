#!/bin/bash

#colour codes

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"


SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
LOG_DIR=/var/log/shell_roboshop_project

SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}.log
mkdir -p $LOGS_FOLDER
#To check root user or not
ROOT_USER=$(id -u)
if [ $ROOT_USER -ne 0 ]; then
    echo "Pease run the script under root privilages"
    exit 1
fi

VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo -e "$2...$R FAILURE $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf list installed | grep momgodb $>>$LOG_FILE
if [ $? -ne 0 ]; then
    dnf install mongodb-org -y &>>$LOG_FILE
    VALIDATE $? "install mongodb"
else
    echo -e "Mongodb already installed....$Y SKIPPING $N"
fi

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongodb"

systemctl start mongod 
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "start mongodb"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e " $B script executed in $TOTAL_TIME seconds $N"


