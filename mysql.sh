#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER=$(id -u)
LOG_FOLDER="/var/log/expense_shell"
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
        echo -e "$2 is $R Failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    fi    
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing MySQL server" | tee -a $LOG_FILE

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling of MySQL server" | tee -a $LOG_FILE

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Started the MySQL" | tee -a $LOG_FILE

mysql -h mysql.telugudevops.online -u root -pExpenseApp@1 -e "show databases"
if [ $? -ne 0 ]
then 
    echo "MySQL password is not setup, going to be set"
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "Setup MySQL Password" | tee -a $LOG_FILE
else
    echo "MYSQL password alredy setup, SKKIPPING"
fi

