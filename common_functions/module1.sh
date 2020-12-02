## Color Code Cheat Sheet
# Dark Red     0;31
# Dark Green  0;32
# Dark Yellow 0;33

function module1-started(){
    MODULE1_GUIDE=$( oc get pods -n labs-infra | grep guides-m1-  | grep -v 'deploy\|build' | awk '{print $1}')
    USERNAME=${1}
     echo -e ${MODULE1_GUIDE}
    RESULT=$(oc logs ${MODULE1_GUIDE} -n labs-infra | grep -o ${USERNAME} > ~/tmp/result.log)
   if cat ~/tmp/result.log | grep -q "${USERNAME}"
    then
       echo -e "\e[0;32m${USERNAME} has started Module 1 - 2 Getting Started with Application Migration Toolkit\e[0m"
      update-report  ${USERNAME}  "Module 1 - 2 Getting Started with Application Migration Toolkit"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME} has not started  Module 1 - 2 Getting Started with Application Migration Toolkit\e[0m"
      update-report  ${USERNAME}  "Module 1 - 2 Getting Started with Application Migration Toolkit"  "FALSE"
    fi
    rm ~/tmp/result.log
}

function codeready-git-clone-status(){
  USERNAME=${1}
  MESSAGE=${2}
  SOURCE_CODE=${3}
  
  CODEREADYNAMESPACE=${USERNAME}-che
  CODEREADYCONTAINER=$(oc get pods -n $CODEREADYNAMESPACE | tail -1 | awk '{print $1}')
  THEIACONTAINER=$(oc describe pod ${CODEREADYCONTAINER} -n ${CODEREADYNAMESPACE} | grep -E theia-ide[a-z0-9]{3} | tr -d ":" | head -1 | awk '{print $2}')
  oc exec -it ${CODEREADYCONTAINER}  -n ${CODEREADYNAMESPACE} -c ${THEIACONTAINER} -- ls /projects/${SOURCE_CODE} > ~/tmp/result.log
  if cat ~/tmp/result.log | grep -q "README.md"
  then
    echo -e "\e[0;32m${USERNAME} has started ${MESSAGE} - Git Clone Completed\e[0m"
    update-report  ${USERNAME}  "${MESSAGE} - Git Clone Completed"  "TRUE"
  else 
    echo -e "\e[0;31m${USERNAME} has not Logged Into ${MESSAGE} - Git Clone Completed\e[0m"
    update-report  ${USERNAME}  "${MESSAGE} - Git Clone Completed"   "FALSE"
  fi
  rm ~/tmp/result.log
}

function codeready-build-status(){
  #oc exec -it workspacevcrfmajrels996ep.quarkus-tools-d88b6d4c5-4rl9t  -n labs-infra -c theia-idedum ls /projects/cloud-native-workshop-v2m1-labs/monolith/target
  #
  USERNAME=${1}
  APP=${2}
  CODEREADYNAMESPACE=${USERNAME}-che
  CODEREADYCONTAINER=$(oc get pods -n $CODEREADYNAMESPACE | tail -1 | awk '{print $1}')
  THEIACONTAINER=$(oc describe pod ${CODEREADYCONTAINER} -n ${CODEREADYNAMESPACE} | grep -E theia-ide[a-z0-9]{3} | tr -d ":" | head -1 | awk '{print $2}')
  RESULT=$(oc exec -it ${CODEREADYCONTAINER}  -n ${CODEREADYNAMESPACE} -c ${THEIACONTAINER} ls /projects/cloud-native-workshop-v2m1-labs/${APP}/target > ~/tmp/result.log)

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
    COMPAREWITH=inventory-dev.jar
    MODULENAME="4 Break Monolith Apart - I"
    ;;
  *)
    exit $?
    ;;
esac
  if cat ~/tmp/result.log | grep -q "$COMPAREWITH"
  then
     echo -e "\e[0;32m${USERNAME} has attempted to build  - ${MODULENAME} - ${APPNAME}\e[0m"
    update-report  ${USERNAME}  "Module 1 - ${MODULENAME} - ${APPNAME} Build Attempted"  "TRUE"
  else 
     echo -e "\e[0;31m${USERNAME} has not attempted to build ${MODULENAME} - ${APPNAME}\e[0m"
    update-report  ${USERNAME}  "Module 1 - ${MODULENAME} - ${APPNAME} Build Attempted"   "FALSE"
  fi
  rm ~/tmp/result.log
}

function app-is-accessible-from-browser(){
  USERNAME=${1}
  PROJECTNAME=${2}
  MESSAGE=${3}
  SEARCHVAL=${4}
  ENDPOINT=$(oc get route -n ${PROJECTNAME} | grep ${SEARCHVAL}  | awk '{print $2}')

  if [ ! -z ${ENDPOINT} ];
  then
    if [ $SEARCHVAL == "prometheus" ];
    then 
      ENDPOINT="${ENDPOINT}/graph"
    elif [ $SEARCHVAL == "grafana"  ];
    then 
      ENDPOINT="${ENDPOINT}/login"
    elif [ $SEARCHVAL == "istio-ingressgateway"  ];
    then 
      ENDPOINT="${ENDPOINT}/productpage"
    fi

    status_code=$(curl --write-out %{http_code} --silent --output /dev/null ${ENDPOINT})
    if [[ "$status_code" -eq 200 ]] ; then
      echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
      update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
      echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
      update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
  elif [ $SEARCHVAL ==  "istio-ingressgateway-catalog" ]
  then
    ENDPOINT=$(oc get route -n ${PROJECTNAME} | grep istio-ingressgateway  | awk '{print $2}')
    ENDPOINT="${ENDPOINT}/services/products"
    status_code=$(curl --write-out %{http_code} --silent --output /dev/null ${ENDPOINT})
    if [[ "$status_code" -eq 401 ]]; then 
      echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
      update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
      echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
      update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
  else
    echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
    update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
  fi
}

function container-input-check(){
    if [[ -z ${1}  ]];
    then 
         echo -e "\e[0;31mPlease pass required values.\e[0m"
         echo -e "\e[0;33mUSERNAME: userX CONTAINER: container-name NAMESPACE: project-name  MESSAGE: My Message \e[0m"
        exit 1
    fi

    if [[ -z ${2} ]];
    then 
       echo -e "\e[0;31mPlease pass required values.\e[0m"
       echo -e "\e[0;33mUSERNAME: userX CONTAINER: container-name NAMESPACE: project-name  MESSAGE: My Message \e[0m"
      exit 1
    fi

    if [[ -z ${3} ]];
    then 
       echo -e "\e[0;31mPlease pass required values.\e[0m"
      echo -e "\e[0;33mUSERNAME: userX CONTAINER: container-name NAMESPACE: project-name  MESSAGE: My Message \e[0m"
      exit 1
    fi

    if [[ -z ${4} ]];
    then 
       echo -e "\e[0;31mPlease pass required values.\e[0m"
       echo -e "\e[0;33mUSERNAME: userX CONTAINER: container-name NAMESPACE: project-name  MESSAGE: My Message \e[0m"
      exit 1
    fi

}

function container-check(){
  USERNAME=${1}
  CONTAINER=${2}
  NAMESPACE=${3}
  MESSAGE=${4}
  SEARCHVAL=${5}

  container-input-check ${USERNAME} ${CONTAINER} ${NAMESPACE} ${MESSAGE}
  if [[ -z $SEARCHVAL ]];
  then
   SEARCHVAL="deploy"
  fi 
  
  oc get pods -n  ${NAMESPACE} | grep -E ${CONTAINER} | grep -v ${SEARCHVAL} > ~/tmp/result.log 
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
