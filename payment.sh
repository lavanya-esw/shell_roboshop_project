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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating system user"
else
    echo -e "User already exist ... $Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "Creating app directory"

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading payment application"

cd /app 
VALIDATE $? "Changing to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip payment"

pip3 install -r requirements.txt &>>$LOG_FILE

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service
systemctl daemon-reload
systemctl enable payment  &>>$LOG_FILE

systemctl restart payment

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo -e " $B script executed in $TOTAL_TIME seconds $N"

