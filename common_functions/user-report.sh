function check-for-user-report(){
    if [[ "$PWD" =~ workspace ]];
    then 
      echo ""
    else
      cd ${PWD}/workspace
    fi 

    if [ ! -f $1 ];
    then
cat >$1<<EOF
*********************************
${1} CCN Roadshow(Dev Track) Report
*********************************
EOF
    fi
    echo ${PWD}
}

function generate-user-report(){
  if [ "${1}" != "all" ];
  then
        echo "checking if $1 report exists"
        check-for-user-report $1
  elif [ "${1}" == "all" ];
  then

    if [[ "$PWD" =~ workspace ]];
    then 
      cd ..
    fi 

    filename=${PWD}'/workspace/userlist'
    while IFS= read -r line
    do
      echo "checking if ${line} report exists"
      check-for-user-report ${line}
    done <<< $(cat $filename )
  else
    echo "incorrect flag passed"
    exit $?
  fi
}

function report-input-check(){
    if [[ -z ${USERNAME}  ]];
    then 
        echo "Please pass required values."
        echo "USERNAME: userX MESSAGE: My Message RESULT: TRUE"
        exit 1
    fi

    if [[ -z ${MESSAGE} ]];
    then 
      echo "Please pass required values."
      echo "USERNAME: userX MESSAGE: My Message RESULT: TRUE"
      exit 1
    fi

    if [[ -z ${RESULT} ]];
    then 
      echo "Please pass required values."
      echo "USERNAME: userX MESSAGE: My Message RESULT: TRUE"
      exit 1
    fi
}

function update-report(){
    #echo "Update report for $1"
    if [[ "$PWD" =~ workspace ]];
    then 
      echo ""
    else
      cd ${PWD}/workspace
    fi 
    USERNAME=${1}
    MESSAGE=${2}
    RESULT="${3}"
    
    report-input-check  ${USERNAME} ${MESSAGE} ${RESULT}

    if cat ${USERNAME} | grep -q  -o  "${MESSAGE}"
    then 
        #echo "$RESULT Found in ${USERNAME}"
        if [ "${RESULT}" == "TRUE" ];
        then 
            sed -i "s/${MESSAGE}:.*/${MESSAGE}: TRUE/g" ${USERNAME}
        elif [ "${RESULT}" == "FALSE" ];
        then
            sed -i "s/${MESSAGE}:.*/${MESSAGE}: FALSE/g" ${USERNAME}
        fi
    else
      echo "${MESSAGE}: " $RESULT >> ${USERNAME}
    fi 
}
