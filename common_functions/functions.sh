function userlist(){
    filename=${PWD}'/workspace/userlist'
    arr=()
    n=1
    while read -r line; do
      echo $line
      arr+=($line)
    done < $filename
}

function logincheck(){
    if [ "${1}" ];
    then
         echo "checking if $1 is logged on"
    else
       for x in "${arr[@]}"
       do 
         echo "checking if ${x} is logged on"
       done 
    fi
}

function openshift-login-check(){
    if ! $(oc whoami &>/dev/null); then
        printf "%s\n" "###############################################################################"
        printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER BEFORE Continuing:                       #"
        printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
        printf "%s\n" "###############################################################################"
        exit 1
    fi
}

function login-to-openshift(){
  if [ -z $OPENSHIFT_USERNAME ] ;
  then 
    echo "Openshift username not found"
    exit 1 
  fi

  if [ -z $OPENSHIFT_PASSWORD ] ;
  then 
    echo "Openshift password not found"
    exit 1 
  fi
  
  if [ -z $OPENSHIFT_URL ] ;
  then 
    echo "Openshift url not found"
    exit 1 
  fi

  if [ -z $OPENSHIFT_SKIP_TLS ] ;
    then 
      echo "Openshift skip tls variable not found"
      exit 1 
    fi

   oc login -u $OPENSHIFT_USERNAME -p $OPENSHIFT_PASSWORD  $OPENSHIFT_URL  --insecure-skip-tls-verify=$OPENSHIFT_SKIP_TLS || exit 1
}

function confirm_run(){
  while true; do
    read -p "Do you want this script against all users? (Y/N) " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit $?;;
        * ) echo "Please answer yes or no.";;
    esac
  done
}

function call_modules(){
    if [ "${1}" != "all" ];
    then
        echo "*********************************" 
        echo "$1 CCN Roadshow(Dev Track) Report"
        echo "*********************************"
        run_modules ${1} ${2}
    elif [ "${1}" == "all" ];
    then
      run_all_users ${2}
    else
      echo "incorrect flag passed."
      exit $?
    fi
}

function run_all_users(){
  if [[ "$PWD" =~ workspace ]];
  then 
    cd ..
  fi 
  filename=${PWD}'/workspace/userlist'

  for line in $(cat $filename);
  do
    echo "*********************************" 
    echo "$line CCN Roadshow(Dev Track) Report"
    echo "*********************************"
    run_modules $line ${1}
  done 
}

function run_modules(){
  MODULE=${2}
  USER_NAME=${1}
  case $MODULE in

  module1)
    module1-started $USER_NAME
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-git-clone-status $USER_NAME "Module 1 - 3 Migrate to JBoss EAP" "cloud-native-workshop-v2m1-labs"
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-build-status $USER_NAME monolith
    project-created $USER_NAME ${USERNAME}-coolstore-dev "Module 1 - 3 Migrate to JBoss EAP  - CoolStore project Exists in OpenShift"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-coolstore-dev "Module 1 - 3 Migrate to JBoss EAP - CoolStore application successfully deployed on OpenShift" "www-${USER_NAME}-coolstore-dev"
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] && codeready-build-status $USER_NAME catalog
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-build-status  $USER_NAME inventory 
    container-check $USER_NAME inventory-database ${USER_NAME}-inventory "Module 1 - 4 Break Monolith Apart - I - inventory-database was deployed."
    container-check $USER_NAME inventory-[0-9] ${USER_NAME}-inventory "Module 1 - 4 Break Monolith Apart - I - inventory application was deployed to OpenShift." "build\|deploy"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-inventory "Module 1 - 4 Break Monolith Apart - I - inventory application is accessible from the browser." "inventory"
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-build-status  $USER_NAME catalog 
    container-check $USER_NAME catalog-database ${USER_NAME}-catalog "Module 1 - 4 Break Monolith Apart - II - catalog-database was deployed."
    app-is-accessible-from-browser $USER_NAME $USER_NAME-catalog "Module 1 - 4 Break Monolith Apart - II - catalog application is accessible from the browser." "catalog"
    ;;

  module2)
    module2-started $USER_NAME
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-git-clone-status $USER_NAME  "Module 2 - 2 Advanced Cloud-Native Services" "cloud-native-workshop-v2m2-labs"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-coolstore-dev "Module 2 - 2 Advanced Cloud-Native Services - CoolStore application successfully deployed on OpenShift" "www-${USER_NAME}-coolstore-dev"
    app-is-accessible-from-browser ${USER_NAME} ${USER_NAME}-inventory "Module 2 - 2 Advanced Cloud-Native Services - inventory application is accessible from the browser." "inventory"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-catalog "Module 2 - 2 Advanced Cloud-Native Services - catalog application is accessible from the browser." "catalog"
    project-created ${USER_NAME} ${USERNAME}-coolstore-prod "Module 2 - 2 Advanced Cloud-Native Services - CoolStore project Exists in OpenShift"
    monolith-pipelines-staged ${USER_NAME}
    container-check $USER_NAME jenkins-[0-9] ${USER_NAME}-coolstore-prod "Module 2 - 3 Advanced Cloud-Native Services - Jenkins ephemeral Container has started." "build\|deploy"
    pipeline-build-status  $USER_NAME "First pipeline build"
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-build-status-m2 $USERNAME inventory
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] && last-letter-check $USERNAME
    project-created ${USER_NAME} ${USERNAME}-monitoring "Module 2 - 5 Application Monitoring  - userX-monitoring project Exists in OpenShift"
    container-check $USER_NAME "jaeger-all-in-one-inmemory" ${USER_NAME}-monitoring "Module 2 - 5 Application Monitoring - jaeger-all-in-one-inmemory deployed." "build\|deploy"
    container-check $USER_NAME "prometheus" ${USER_NAME}-monitoring "Module 2 - 5 Application Monitoring - prometheus container was deployed." "build\|deploy"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-monitoring "Module 2 - 5 Application Monitoring - prometheus application is accessible from the browser." "prometheus"
    container-check $USER_NAME "grafana" ${USER_NAME}-monitoring "Module 2 - 5 Application Monitoring - grafana container was deployed." "build\|deploy"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-monitoring "Module 2 - 5 Application Monitoring - grafana application is accessible from the browser." "grafana"
    promethous-configmap-check ${USER_NAME}
    ;;

  module3)
    module3-started $USER_NAME
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  loggedin-to-codeready $USER_NAME  "Module 3 - 2 Getting Started with Service Mesh"
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-git-clone-status $USER_NAME  "Module 3 - 2 Getting Started with Service Mesh" "cloud-native-workshop-v2m3-labs"
    container-check $USER_NAME "details-v1" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - details-v1 container was deployed." "build\|deploy"
    container-check $USER_NAME "productpage-v1" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - productpage-v1 container was deployed." "build\|deploy"
    container-check $USER_NAME "ratings-v1" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - ratings-v1 container was deployed." "build\|deploy"
    container-check $USER_NAME "reviews-v1" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - reviews-v1 container was deployed." "build\|deploy"
    container-check $USER_NAME "reviews-v2" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - reviews-v2 container was deployed." "build\|deploy"
    container-check $USER_NAME "reviews-v3" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - reviews-v3 container was deployed." "build\|deploy"
    istio-destinationrules-check $USER_NAME "details" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - details destinationrules was deployed."
    istio-destinationrules-check $USER_NAME "productpage" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - productpage destinationrules was deployed."
    istio-destinationrules-check $USER_NAME "ratings" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - ratings destinationrules was deployed."
    istio-destinationrules-check $USER_NAME "reviews" ${USER_NAME}-bookinfo "Module 3 - 3 Creating Distributed Services - reviews destinationrules was deployed."
    app-is-accessible-from-browser $USER_NAME $USER_NAME-istio-system "Module 3 - 3 Creating Distributed Services - bookinfo productpage  is accessible from the browser." "istio-ingressgateway"
    istio-virtualservices-check $USER_NAME "bookinfo" ${USER_NAME}-bookinfo "Module 3 - 4 - Service Visualization and Monitoring - bookinfo virtualservices was deployed."
    istio-virtualservices-check $USER_NAME "details" ${USER_NAME}-bookinfo "Module 3 - 4 - Service Visualization and Monitoring - details virtualservices was deployed."
    istio-virtualservices-check $USER_NAME "productpage" ${USER_NAME}-bookinfo "Module 3 - 4 - Service Visualization and Monitoring - productpage virtualservices was deployed."
    istio-virtualservices-check $USER_NAME "ratings" ${USER_NAME}-bookinfo "Module 3 - 4 - Service Visualization and Monitoring - ratings virtualservices was deployed."
    istio-virtualservices-check $USER_NAME "reviews" ${USER_NAME}-bookinfo "Module 3 - 4 - Service Visualization and Monitoring - reviews virtualservices was deployed."
    container-check $USER_NAME inventory-database ${USER_NAME}-inventory "Module 3 - 5 - Advanced Service Mesh Development - inventory-database was deployed."
    container-check $USER_NAME inventory-[0-9] ${USER_NAME}-inventory "Module 3 - Advanced Service Mesh Development - inventory application was deployed to OpenShift." "build\|deploy"
    container-check $USER_NAME catalog-database ${USER_NAME}-catalog "Module 3 - Advanced Service Mesh Development - catalog-database was deployed."
    container-check $USER_NAME catalog-springboot-[0-9] ${USER_NAME}-catalog "Module 3 - Advanced Service Mesh Development  - catalog-springboot application was deployed."
    sidecar-injected $USER_NAME inventory-database ${USER_NAME}-inventory "Module 3 - 5 - Advanced Service Mesh Development - inventory-database sidecar-injected was injected."
    sidecar-injected $USER_NAME inventory-[0-9] ${USER_NAME}-inventory "Module 3 - 5 - Advanced Service Mesh Development - inventory application sidecar-injected was injected."
    sidecar-injected $USER_NAME catalog-database ${USER_NAME}-catalog "Module 3 - 5 - Advanced Service Mesh Development - catalog-database sidecar-injected was injected."
    sidecar-injected $USER_NAME catalog-springboot-[0-9] ${USER_NAME}-catalog "Module 3 - 5 - Advanced Service Mesh Development - catalog-springboot application sidecar-injected was injected."
    istio-virtualservices-check $USER_NAME "catalog" ${USER_NAME}-catalog "Module 3 - 5 - Advanced Service Mesh Development - catalog virtualservices was deployed."
    project-created ${USER_NAME} ${USERNAME}-rhsso "Module 3 - 5 - Advanced Service Mesh Development - userX-rhsso  project Exists in OpenShift"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-istio-system "Module 3 - 5 - Advanced Service Mesh Development - catalog service  is accessible from the browser and sso is configured." "istio-ingressgateway-catalog"
  ;;

  module4)
    module4-started $USER_NAME
    [ ${SKIP_CODE_READY_CHECKS} == FALSE ] &&  codeready-git-clone-status $USER_NAME  "Module 4 - 2 Cloud Native Application Architectures" "cloud-native-workshop-v2m4-labs"
    container-check $USER_NAME inventory-database ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - inventory-database was deployed."
    container-check $USER_NAME inventory-[0-9] ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - inventory application was deployed to OpenShift." "build\|deploy"
    container-check $USER_NAME catalog-database ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - catalog-database was deployed."
    container-check $USER_NAME catalog-[0-9] ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - catalog application was deployed to OpenShift." "build\|deploy"
    container-check $USER_NAME datagrid-service ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - datagrid-service was deployed."
    container-check $USER_NAME cart-[0-9] ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - cart application was deployed to OpenShift." "build\|deploy"
    container-check $USER_NAME order-database ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - order-database was deployed."
    container-check $USER_NAME order-[0-9] ${USER_NAME}-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - order application was deployed to OpenShift." "build\|deploy"
    app-is-accessible-from-browser $USER_NAME $USER_NAME-cloudnativeapps "Module 4 - 3 - Creating High-performing Cacheable Services - coolstore application is accessible from the browser." "coolstore-ui"
    container-check $USER_NAME my-cluster-kafka-[0-9] ${USER_NAME}-cloudnativeapps "Module 4 - 4 - Creating Event-Driven Services - kafka cluster was deployed to OpenShift." "build\|deploy"
    validate-kafka-topic $USER_NAME my-cluster-kafka-0 ${USER_NAME}-cloudnativeapps "Module 4 - 4 - Creating Event-Driven Services - orders kafka topic exists." "orders"
    validate-kafka-topic $USER_NAME my-cluster-kafka-0 ${USER_NAME}-cloudnativeapps "Module 4 - 4 - Creating Event-Driven Services - payments kafka topic exists." "payments"
    knative-serving-check $USER_NAME payment ${USER_NAME}-cloudnativeapps "Module 4 - 5 - Evolving to Serverless Services - payment knative serving config exists."
    pipeline-build-attempted $USER_NAME ${USER_NAME}-cloudnative-pipeline "Module 4 - 5 - Evolving to Serverless Services - build-and-deploy pipeline  was attempted." build-and-deploy
    container-check $USER_NAME vote-api ${USER_NAME}-cloudnative-pipeline "Module 4 - 5 - Evolving to Serverless Services - vote-api application was deployed to OpenShift." "build\|deploy"
    container-check $USER_NAME vote-ui ${USER_NAME}-cloudnative-pipeline "Module 4 - 5 - Evolving to Serverless Services - vote-ui application was deployed to OpenShift." "build\|deploy"
    ;;

  openshift101)
    openshift101-started $USER_NAME java
    openshift101-started $USER_NAME php
    openshift101-started $USER_NAME python
    openshift101-started $USER_NAME javascript
    container-check $USER_NAME parksmap-[0-9] $USER_NAME "Lab 5 - Deploying Your First Container Image" "build\|deploy"
    app-is-accessible-from-browser $USER_NAME $USER_NAME "Lab 7 - Exposing Your Application to the Outside World" "parksmap"
    get-rolebinding $USER_NAME $USER_NAME "Lab 9 - Role-Based Access Control" "view"
    container-check $USER_NAME nationalparks-[0-9] $USER_NAME "Lab 11 - Deploying National Parks Code" "build\|deploy"
    container-check $USER_NAME mongodb-nationalparks-[0-9] $USER_NAME "Lab 12 - Adding a Database" "build\|deploy"
    get-nationalparks-health-check $USER_NAME $USER_NAME "Lab 13 - 1 Application Health Readiness Probe" "readinessProbe"
    get-nationalparks-health-check $USER_NAME $USER_NAME "Lab 13 - 2 Application Health Liveness Probe" "livenessProbe"
    get-nationalparks-trigger $USER_NAME $USER_NAME "Lab 14 - Trigger Automatic Rebuilds on Code Changes" "automatic"
    get-pipelinerun-success $USER_NAME $USER_NAME "Lab 15 - Automation for Your Application on Code Changes" "nationalparks"
    check-template-exists $USER_NAME $USER_NAME "Lab 17 - Using Application Templates" "mlbparks"
    container-check $USER_NAME mlbparks-[0-9] $USER_NAME "Lab 18 - Binary Builds for Day to Day Development" "build\|deploy"
    ;;

  machinelearning)
    container-check $USER_NAME "jupyterhub" ${USERNAME}-notebooks "Lab 1 - Deploy Open Data Hub"
    container-check $USER_NAME "jupyterhub-nb" ${USERNAME}-notebooks "Lab 1 - Launch Jupyter"
    container-check $USER_NAME "xraylabdb" ${USERNAME}-notebooks "Lab 3 - Deploying the Database"
    validate-kafka-topic $USER_NAME my-cluster-kafka-0 ${USER_NAME}-notebooks "Lab 3 - Create the Kafka Cluster and Topic" "xray-images"
    container-check $USER_NAME "image-generator" ${USERNAME}-notebooks "Lab 3 - Deploy the Image Generator"
    container-check $USER_NAME "image-server" ${USERNAME}-notebooks "Lab 3 - Deploy the Image Server"
    knative-serving-check $USER_NAME risk-assessment ${USER_NAME}-notebooks "Lab 3 - Deploy the Risk Assessment Service"
    ;;

  *)
    echo -n "unknown module"
    exit $?
    ;;
esac
}

function loggedin-to-codeready(){
    CODEREADYLOGIN=$(oc get pods -n labs-infra | grep codeready- | grep -v 'deploy\|build|\|operator'| awk '{print $1}')
    USERNAME=${1}
    MESSAGE=${2}
    # echo -e ${CODEREADYLOGIN}
    RESULT=$(oc logs ${CODEREADYLOGIN} -n labs-infra | grep -o ${USERNAME} > ~/tmp/result.log)
    if cat ~/tmp/result.log | grep -q "${USERNAME}"
    then
       echo -e "\e[0;32m${USERNAME} has started ${MESSAGE} - Logged into CodeReady Workspaces\e[0m"
      update-report  ${USERNAME}  "${MESSAGE} - Logged into CodeReady Workspaces"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME} has not Logged Into ${MESSAGE} - Logged into CodeReady Workspaces\e[0m"
      update-report  ${USERNAME}  "${MESSAGE} - Logged into CodeReady Workspaces"   "FALSE"
    fi
    rm ~/tmp/result.log
}

function project-created(){
    USERNAME=${1}
    PROJECT_NAME=${2}
    MESSAGE=${3}
    oc get project | grep ${PROJECT_NAME} > ~/tmp/result.log
    if cat ~/tmp/result.log | grep  -q "${USERNAME}"
    then
       echo -e "\e[0;32m${USERNAME} has completed  ${MESSAGE}\e[0m"
      update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else 
       echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
      update-report  ${USERNAME}  "${MESSAGE}"  "FALSE"
    fi
    rm ~/tmp/result.log
}

function codeready-exec(){
# Executes a given command inside the codeready container for this user.
  USERNAME=${1}
  COMMAND=${2}
  PATTERN=${3}

  CODEREADYNAMESPACE=${USERNAME}-che
  CODEREADYCONTAINER=$(oc get pods -n $CODEREADYNAMESPACE | tail -1 | awk '{print $1}')
  THEIACONTAINER=$(oc describe pod ${CODEREADYCONTAINER} -n ${CODEREADYNAMESPACE} | grep -E theia-ide[a-z0-9]{3} | tr -d ":" | head -1 | awk '{print $2}')

  oc exec -it ${CODEREADYCONTAINER}  -n ${CODEREADYNAMESPACE} -c ${THEIACONTAINER} -- ${COMMAND} > ~/tmp/result.log
  STATUS=$?
  if [ ${PATTERN} ]
  then
    cat ~/tmp/result.log | grep -q ${PATTERN}
    STATUS=$?
  fi
  rm ~/tmp/result.log
  return $STATUS
}
