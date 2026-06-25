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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable Nodejs package" | tee -a $LOG_FILE

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS 20" | tee -a $LOG_FILE

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS" | tee -a $LOG_FILE

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    echo "User expense is not exists, create user" | tee -a $LOG_FILE
    useradd expense &>>$LOG_FILE
else
    echo "user expensse already exists, SKIPPING" | tee -a $LOG_FILE
fi

mkdir -p /app &>>$LOG_FILE
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading backend applciation" | tee -a $LOG_FILE

cd /app &>>$LOG_FILE 
rm -rf /app/* &>>$LOG_FILE
unzip /tmp/backend.zip &>>$LOG_FILE
VALIDATE $? "Extracting Backend app file" | tee -a $LOG_FILE

npm install &>>$LOG_FILE
VALIDATE $? "NPM installtion" | tee -a $LOG_FILE

cp /home/ec2-user/shell_expense_practice/backend.service /etc/systemd/system/backend.service &>>$LOG_FILE
VALIDATE $? "Copying backend service file" | tee -a $LOG_FILE

dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "mysql client installation" | tee -a $LOG_FILE

mysql -h mysql.telugudevops.online -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Adding schema to MySQL DB" | tee -a $LOG_FILE

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Deamon reloading" | tee -a $LOG_FILE

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "Enabling Backend service" | tee -a $LOG_FILE

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "Restarting Backend" | tee -a $LOG_FILE






