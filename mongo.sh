#!/bin/bash

#colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"

SCRIPT_DIR=$PWD

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


