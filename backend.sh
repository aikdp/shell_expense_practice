#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER=$(id -u)
LOG_FOLDER="/var/log/expense_backend"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"

if [ $USER -ne 0 ]
    then
        echo -e "$R Please run with ROOT preveilges $N" 
        exit 1
fi

# USAGE(){
#     echo "USAGE is:: sudo sh <FILENAME> package1 package2 ..."
# }

# if [ $# -eq 0 ]
# then
#     USAGE
# fi

#Every time this will tell you the user when the script executing
echo "Script started executed at:: $(date)"
mkdir -p $LOG_FOLDER

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R Failed $N"
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N"
    fi    
}

dnf module disable nodejs -y
VALIDATE $? "Disable Nodejs package"

dnf module enable nodejs:20 -y
VALIDATE $? "Enabling NodeJS 20"

dnf install nodejs -y
VALIDATE $? "Installing NodeJS"

id expense
if [ $? -ne 0 ]
then
    echo "User expense is not exists, create user"
    useradd expense
else
    echo "user expensse already exists, SKIPPING"
fi

mkdir -p /app

rm -rf /app/*
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading backend applciation"

cd /app
unzip /tmp/backend.zip
VALIDATE $? "Extracting Backend app file"

npm install
VALIDATE $? "NPM installtion"

cp /home/ec2-user/shell_expense_practice/backend.service /etc/systemd/system/backend.service
VALIDATE $? "Copying backend service file"

dnf install mysql -y
VALIDATE $? "mysql client installation"

mysql -h mysql.telugudevops.online -uroot -pExpenseApp@1 < /app/schema/backend.sql
VALIDATE $? "Adding schema to MySQL DB"

systemctl daemon-reload
VALIDATE $? "Deamon reloading"

systemctl enable backend
VALIDATE $? "Enabling Backend service"

systemctl restart backend
VALIDATE $? "Restarting Backend"






