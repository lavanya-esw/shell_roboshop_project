#!/bin/bash
#colour codes
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[37m"
B="\e[34m"

SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
LOG_DIR=/var/log/shell_roboshop_project
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE=${LOG_DIR}/${SCRIPT_NAME}.log
mkdir -p $LOG_DIR

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

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "Copy systemctl service"

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling NodeJS"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading user application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "unzip user"

npm install &>>$LOG_FILE
VALIDATE $? "Install dependencies"

systemctl daemon-reload
systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enable user"

systemctl restart user
VALIDATE $? "Restarted user"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e " $B script executed in $TOTAL_TIME seconds $N"