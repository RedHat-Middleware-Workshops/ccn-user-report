function module3-started(){
    MODULE3_GUIDE=$(oc get pods -n labs-infra | grep guides-m3-  | grep -v 'deploy\|build' | awk '{print $1}')
    USERNAME=${1}
    echo -e ${MODULE3_GUIDE}
    oc logs ${MODULE3_GUIDE} -n labs-infra | grep -o ${USERNAME} | tee ~/tmp/result.log
    if cat ~/tmp/result.log | grep -q "${USERNAME}"
    then
      echo -e "\e[0;32m${USERNAME} has started Module 3 - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 3 - 1 Your Workshop Environment"  "TRUE"
    else 
      echo -e "\e[0;31m${USERNAME} has not started  Module 3  - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 3 - 1 Your Workshop Environment"  "FALSE"
    fi
    rm ~/tmp/result.log
}


function istio-destinationrules-check(){
  USERNAME=${1}
  CONTAINER=${2}
  NAMESPACE=${3}
  MESSAGE=${4}

  container-input-check ${USERNAME} ${CONTAINER} ${NAMESPACE} ${MESSAGE}
  
  oc get destinationrules -n  ${NAMESPACE} | grep -E ${CONTAINER} | tee  ~/tmp/result.log 
  if cat ~/tmp/result.log | grep  -q "${CONTAINER}"
  then
    echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed ${MESSAGE}\e[0m"
    update-report  ${USERNAME} "${MESSAGE}"  "FALSE"
  fi
  rm  ~/tmp/result.log 
}


function istio-virtualservices-check(){
  USERNAME=${1}
  CONTAINER=${2}
  NAMESPACE=${3}
  MESSAGE=${4}

  container-input-check ${USERNAME} ${CONTAINER} ${NAMESPACE} ${MESSAGE}
  
  oc get virtualservices -n  ${NAMESPACE} | grep -E ${CONTAINER} | tee  ~/tmp/result.log 
  if cat ~/tmp/result.log | grep  -q "${CONTAINER}"
  then
    echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed ${MESSAGE}\e[0m"
    update-report  ${USERNAME} "${MESSAGE}"  "FALSE"
  fi
  rm  ~/tmp/result.log 
}

function sidecar-injected(){
  USERNAME=${1}
  CONTAINER=${2}
  NAMESPACE=${3}
  MESSAGE=${4}

  container-input-check ${USERNAME} ${CONTAINER} ${NAMESPACE} ${MESSAGE}
  oc get pods -n ${NAMESPACE} --field-selector="status.phase=Running" | grep ${CONTAINER} | awk '{print $2}'  | tee  ~/tmp/result.log 

  if cat ~/tmp/result.log | grep  -q "2/2"
  then
    echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed ${MESSAGE}\e[0m"
    update-report  ${USERNAME} "${MESSAGE}"  "FALSE"
  fi
  rm  ~/tmp/result.log 
}