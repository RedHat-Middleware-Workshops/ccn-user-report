#!/bin/bash
## Uncomment to debug
#set -x 
#export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

# Check is Lock File exists, if not create it and set trap on exit
 if { set -C; 2>/dev/null >~/manlocktest.lock; }; then
         trap "rm -f ~/manlocktest.lock" EXIT
 else
         echo "Lock file exists… exiting"
         exit
 fi

# Set some environment variables if they're unset
if [ -z "$SKIP_CODE_READY_CHECKS" ]
then
  export SKIP_CODE_READY_CHECKS=FALSE
fi

source common_functions/module1.sh
source common_functions/module2.sh
source common_functions/module3.sh
source common_functions/module4.sh
source common_functions/openshift101.sh
source common_functions/user-report.sh
source common_functions/functions.sh

login-to-openshift

openshift-login-check

if  [ ! -d reports ];
then 
  mkdir -p reports 
fi

if [ -z ${1} ];
then 
  echo -n "Enter Module: "
  read MODULE
else
  echo "setting Module to ${1}"
  echo "Current user ${2}"
  MODULE=${1}
fi 

case $MODULE in

  module1)
    echo -e "module1 selected\n"
    ;;

  module2)
    echo -e "module2 selected\n"
    ;;

  module3)
    echo -e "module3 selected\n"
    ;;

  module4)
    echo -e "module4 selected\n"
    ;;

  openshift101)
    echo -e "openshift101 selected\n"
    ;;

  *)
    echo -e "unknown module selected\n"
    echo -e "Options: module1, module2, module3, module4, openshift101\n"
    exit $?
    ;;
esac

if [ -z $2 ]; 
then 
  confirm_run
  echo "Collect Users"
  userlist
  generate-user-report  "all"
  call_modules "all" ${MODULE}
else
  generate-user-report ${2}
  # update report test function
  #update-report ${2} "TEST MESSAGE" "WORKS"
  call_modules ${2} ${MODULE}
fi


