## Color Code Cheat Sheet
# Dark Red     0;31
# Dark Green  0;32
# Dark Yellow 0;33

function module2-started(){
    MODULE2_GUIDE=$(oc get pods -n labs-infra | grep guides-m2-  | grep -v 'deploy\|build'| awk '{print $1}')
    USERNAME=${1}
    oc logs ${MODULE2_GUIDE} -n labs-infra | grep -o ${USERNAME} > ~/tmp/result.log
    if cat ~/tmp/result.log | grep -q "${USERNAME}"
    then
       echo -e "\e[0;32m${USERNAME} has started Module 2 - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 2 - 1 Your Workshop Environment"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME} has not started  Module 2  - 1 Your Workshop Environment\e[0m"
      update-report  ${USERNAME}  "Module 2 - 1 Your Workshop Environment"  "FALSE"
    fi
    rm ~/tmp/result.log
}

function monolith-pipelines-staged(){
  USERNAME=${1}
  oc describe bc/monolith-pipeline -n ${USERNAME}-coolstore-prod | grep -o JenkinsPipeline > ~/tmp/result.log
  if cat ~/tmp/result.log | grep -q "JenkinsPipeline"
    then
       echo -e "\e[0;32m${USERNAME} has started Module 2 - 3 - Implementing Continuous Delivery - monolith-pipeline has been staged\e[0m"
      update-report  ${USERNAME}  "Module 2 - 3 - Implementing Continuous Delivery - monolith-pipeline has been staged"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME} has not started  Module 3 - Implementing Continuous Delivery - monolith-pipeline has been staged\e[0m"
      update-report  ${USERNAME}  "Module 2 - 3 - Implementing Continuous Delivery - monolith-pipeline has been staged"  "FALSE"
    fi
    rm ~/tmp/result.log
}


function pipeline-build-status(){
  USERNAME=${1}
  MESSAGE=${2}
  oc get builds  -n ${USERNAME}-coolstore-prod | grep monolith-pipeline-1 | awk '{print $3}' > ~/tmp/result.log
  if cat ~/tmp/result.log | grep -q "Complete"
    then
       echo -e "\e[0;32m${USERNAME} Module 2 - 3 - Implementing Continuous Delivery - Jenkins monolith-pipeline ${MESSAGE} Completed\e[0m"
      update-report  ${USERNAME}  "Module 2 - 3 - Implementing Continuous Delivery - monolith-pipeline ${MESSAGE}  Completed"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME}'s ${MESSAGE}  has  not Completed  Module 2 - 3  - Implementing Continuous Delivery - Jenkins monolith-pipeline\e[0m"
      update-report  ${USERNAME}  "Module 2 - 3 - Implementing Continuous Delivery - monolith-pipeline ${MESSAGE}  Completed"  "FALSE"
    fi
    rm ~/tmp/result.log
}


function codeready-build-status-m2(){
  USERNAME=${1}
  APP=${2}

  case $APP in
  catalog)
    codeready-exec $USERNAME "ls /projects/cloud-native-workshop-v2m2-labs/catalog/target/catalog-1.0.0-SNAPSHOT.jar2"
    STATUS=$?
    MODULENAME="4 Break Monolith Apart - II"
    ;;
  inventory)
    codeready-exec $USERNAME "ls /projects/cloud-native-workshop-v2m2-labs/inventory/target/inventory-1.0-SNAPSHOT-runner.jar"
    STATUS=$?
    MODULENAME="4 Debugging Applications"
    ;;
  *)
    exit $?
    ;;
  esac

  if [ $STATUS -eq 0 ]
  then
     echo -e "\e[0;32m${USERNAME} has attempted to build  - ${MODULENAME} - ${APP}\e[0m"
    update-report  ${USERNAME}  "Module 2 - ${MODULENAME} - ${APP} Build Attempted"  "TRUE"
  else 
     echo -e "\e[0;31m${USERNAME} has not attempted to build ${MODULENAME} - ${APP}\e[0m"
    update-report  ${USERNAME}  "Module 2 - ${MODULENAME} - ${APP} Build Attempted"   "FALSE"
  fi
}

function last-letter-check() {
  USERNAME=${1}
  
  if codeready-exec $USERNAME "grep lastLetter cloud-native-workshop-v2m2-labs/inventory/src/main/java/com/redhat/coolstore/InventoryResource.java" lastLetter
  then
    echo -e "\e[0;32m${USERNAME} Module 2 - 4 Debugging Applications - lastLetter method created.\e[0m"
    update-report  ${USERNAME}  "Module 2 - 4 Debugging Applications - lastLetter method created."  "TRUE"
  else
    echo -e "\e[0;31m${USERNAME} has not completed 4 Debugging Applications - lastLetter method created.\e[0m"
    update-report  ${USERNAME}  "Module 2 - 4 Debugging Applications - lastLetter method created."  "FALSE"
  fi
}

function promethous-configmap-check(){
    USERNAME=${1}
    oc get cm -n ${USERNAME}-monitoring | grep prometheus-config | awk '{print $1}'  > ~/tmp/result.log
    if cat ~/tmp/result.log | grep -q "prometheus-config"
    then
      echo -e "\e[0;32m${USERNAME} Module 2 - 5 - Application Monitoring - prometheus-config created.\e[0m"
      update-report  ${USERNAME}  "Module 2 - 5 - Application Monitoring - prometheus-config created."  "TRUE"
    else 
      echo -e "\e[0;31m${USERNAME}'s ${MESSAGE}  has  not Completed  Module 2 - 5 - Application Monitoring - prometheus-config created.\e[0m"
      update-report  ${USERNAME}  "Module 2 - 5 - Application Monitoring - prometheus-config created."  "FALSE"
    fi
    rm ~/tmp/result.log
}
