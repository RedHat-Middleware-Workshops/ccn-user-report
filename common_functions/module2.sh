## Color Code Cheat Sheet
# Dark Red     0;31
# Dark Green  0;32
# Dark Yellow 0;33

function module2-started(){
    MODULE2_GUIDE=$(oc get pods -n labs-infra | grep guides-m2-  | grep -v 'deploy\|build'| awk '{print $1}')
    USERNAME=${1}
    echo -e ${MODULE2_GUIDE}
    oc logs ${MODULE2_GUIDE} -n labs-infra | grep -o ${USERNAME} | tee ~/tmp/result.log
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
  oc describe bc/monolith-pipeline -n ${USERNAME}-coolstore-prod | grep -o JenkinsPipeline | tee ~/tmp/result.log
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
  #oc exec -it workspacevcrfmajrels996ep.quarkus-tools-d88b6d4c5-4rl9t  -n labs-infra -c theia-idedum ls /projects/cloud-native-workshop-v2m1-labs/monolith/target
  #
  CODEREADYLOGIN=$(oc get pods -n labs-infra | grep codeready- | grep -v  'deploy\|build|\|operator' | awk '{print $1}')
  USERNAME=${1}
  APP=${2}
  WORKSTATIONID=$(oc logs ${CODEREADYLOGIN}  -n labs-infra | grep ${USERNAME} | grep -o -P 'workspace.[a-z0-9]{15}' | head -1)
  CODEREADYCONTAINER=$(oc get pods -n labs-infra | grep ${WORKSTATIONID} | grep -v  'deploy\|build|\|operator'| awk '{print $1}')
  THEIACONTAINER=$(oc describe pod ${CODEREADYCONTAINER} -n labs-infra | grep -E theia-ide[a-z0-9]{3} | tr -d ":" | head -1 | awk '{print $2}')
  oc exec -it ${CODEREADYCONTAINER}  -n labs-infra -c ${THEIACONTAINER} ls /projects/cloud-native-workshop-v2m2-labs/${APP}/target | tee ~/tmp/result.log

  case $APP in
  monolith)
    APPNAME=Monolith
    COMPAREWITH=ROOT.war
    MODULENAME="3 Migrate to JBoss EAP"
    ;;
  catalog)
    APPNAME=Catalog
    COMPAREWITH=catalog-1.0.0-SNAPSHOT.jar
    MODULENAME="4 Break Monolith Apart - II"
    ;;
  inventory)
    APPNAME=Inventory
    COMPAREWITH=inventory-1.0-SNAPSHOT-runner.jar
    MODULENAME="4 Debugging Applications"
    ;;
  *)
    exit $?
    ;;
  esac

  if cat ~/tmp/result.log | grep -q "$COMPAREWITH"
  then
     echo -e "\e[0;32m${USERNAME} has attempted to build  - ${MODULENAME} - ${APPNAME}\e[0m"
    update-report  ${USERNAME}  "Module 2 - ${MODULENAME} - ${APPNAME} Build Attempted"  "TRUE"
  else 
     echo -e "\e[0;31m${USERNAME} has not attempted to build ${MODULENAME} - ${APPNAME}\e[0m"
    update-report  ${USERNAME}  "Module 2 - ${MODULENAME} - ${APPNAME} Build Attempted"   "FALSE"
  fi
  rm ~/tmp/result.log
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