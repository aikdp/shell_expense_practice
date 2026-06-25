#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER=$(id -u)
LOG_FOLDER="/var/log/expense_frontend"
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

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing NGINX" | tee -a $LOG_FILE

systemctl enable nginx &>>$LOG_FILE
VALIDATE $? "Enabling NGINX" | tee -a $LOG_FILE

systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting NGINX" | tee -a $LOG_FILE

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing default NGINX file" | tee -a $LOG_FILE

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend Application" | tee -a $LOG_FILE

cd /usr/share/nginx/html &>>$LOG_FILE
VALIDATE $? "Chnage the Nginx directory" | tee -a $LOG_FILE

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extractting frontend file" | tee -a $LOG_FILE

cp /home/ec2-user/shell_expense_practice/expense.conf /etc/nginx/default.d/expense.conf &>>$LOG_FILE

systemctl restart nginx &>>$LOG_FILE 
VALIDATE $? "Restarting NGINX" | tee -a $LOG_FILE