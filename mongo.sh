#!/bin/bash

#colour codes

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

SCRIPT_DIR=$PWD

START_TIME=$(date +%s)
#To check root user or not
ROOT_USER=$(id -u)
if [ $ROOT_USER -ne 0 ]; then
    echo "Pease run the script under root privilages"
    exit 1
fi

VALIDATE()
{
    if [ $1 -ne 0 ]; then
        echo "$2...$R FAILURE $N"
    else
        echo "$2...$R SUCCESS $N"
}

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding mongo repo"

dnf list installed mongod
if [ $? -ne 0 ]; then
    dnf install mongodb-org -y 
    VALIDATE $? "install mongodb"
else
    echo -e "Mongodb already installed....$Y SKIPPING $N"
fi

systemctl enable mongod 
VALIDATE $? "enabling mongodb"

systemctl start mongod 
VALIDATE $? "starting mongodb"

sed -i 's/127.0.0.1/0.0.0.0' /etc/mongod.conf
VALIDATE $? "Allowing remote connections to MongoDB"

systemctl restart mongod
VALIDATE $? "start mongodb"

END_TIME=$(date +s)

echo "script executed in ((${START_TIME}-${END_TIME})) seconds"


