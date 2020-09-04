function module4-started(){
    MODULE3_GUIDE=$(oc get pods -n labs-infra | grep guides-m4- | grep -v 'deploy\|build' | awk '{print $1}')
    USERNAME=${1}
    echo -e ${MODULE3_GUIDE}
    oc logs ${MODULE3_GUIDE} -n labs-infra | grep -o ${USERNAME} | tee ~/tmp/result.log
    if cat ~/tmp/result.log | grep -q "${USERNAME}"
    then
      echo -e "\e[0;32m${USERNAME} has started Module 4 - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 4 - 1 Your Workshop Environment"  "TRUE"
    else 
      echo -e "\e[0;31m${USERNAME} has not started  Module 4  - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 4 - 1 Your Workshop Environment"  "FALSE"
    fi
    rm ~/tmp/result.log
}

function validate-kafka-topic(){
  USERNAME=${1}
  CONTAINER=${2}
  NAMESPACE=${3}
  MESSAGE=${4}
  SEARCHVAL=${5}

  
  oc logs ${CONTAINER} -c kafka -n ${NAMESPACE} | grep ${SEARCHVAL} | tee  ~/tmp/result.log 
  if cat ~/tmp/result.log | grep  -q "${SEARCHVAL}"
  then
    echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed ${MESSAGE}\e[0m"
    update-report  ${USERNAME} "${MESSAGE}"  "FALSE"
  fi
  rm  ~/tmp/result.log 
}

function pipeline-build-attempted(){
  USERNAME=${1}
  NAMESPACE=${2}
  MESSAGE=${3}
  SEARCHVAL=${4}

  oc get pods -n ${NAMESPACE} | grep "${SEARCHVAL}"  | tee  ~/tmp/result.log 

  if cat ~/tmp/result.log | grep  -q "${SEARCHVAL}"
  then
    echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed ${MESSAGE}\e[0m"
    update-report  ${USERNAME} "${MESSAGE}"  "FALSE"
  fi
  rm  ~/tmp/result.log 
}