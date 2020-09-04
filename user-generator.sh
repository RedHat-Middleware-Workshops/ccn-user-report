#!/bin/bash

# Check is Lock File exists, if not create it and set trap on exit
 if { set -C; 2>/dev/null >~/manlocktest.lock; }; then
         trap "rm -f ~/manlocktest.lock" EXIT
 else
         echo "Lock file exists… exiting"
         exit
 fi


if [ -z $1  ];
then 
  read -p "Enter number of users: " usercount
  echo "Generating $usercount users"
else
  usercount=${1}
fi

if [ ! -d workspace ]
then 
  mkdir workspace
fi 

if [ -f workspace/userlist ]
then 
  rm workspace/userlist
  touch workspace/userlist
fi

i=1
until [ $i -gt $usercount ]
do
  echo "Adding user$i to workspace/userlist"
  echo "user$i" >> workspace/userlist
  ((i=i+1))
done

#echo "Printing out workspace/userlist"
#cat workspace/userlist
