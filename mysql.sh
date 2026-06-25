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

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is $R Failed $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is $G SUCCESS $N" | tee -a $LOG_FILE
    fi    
}

dnf install mysql-server -y
VALIDATE $? "Installing MySQL server"

systemctl enable mysqld
VALIDATE $? "Enabling of MySQL server"

systemctl start mysqld
VALIDATE $? "Started the MySQL"

mysql_secure_installation --set-root-pass ExpenseApp@1
VALIDATE $? "Setup MySQL Password"