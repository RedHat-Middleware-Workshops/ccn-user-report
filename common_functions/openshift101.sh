## Color Code Cheat Sheet
# Dark Red     0;31
# Dark Green  0;32
# Dark Yellow 0;33

function openshift101-started(){
    USERNAME=${1}
    USERLANG=${2}
    DEBUG=false
    
    # Get all pods in running state with prefix
    USER_GUIDE=$(oc get pods -n labs | grep lab-getting-started-${USERLANG}-user- | grep -v 'deploy\|build' | awk '{print $1}')
    
    # Debug USER_GUIDE variable definition
    [[ "$DEBUG" == true ]] && echo -e ${USER_GUIDE}
    
    # Check if tmp home folder directory exists
    [[ ! -d "$HOME/tmp" ]] && mkdir -p "$HOME/tmp"
    
    # Create a temporary file in tmp home folder
    TFILE=$(mktemp $HOME/tmp/result.XXXXXXXXX)
    
    for i in ${USER_GUIDE}; do
        if [ "${i}" = "lab-getting-started-${USERLANG}-user-${USERNAME}" ]; then
            RESULT=$(oc logs ${i} -n labs >> $TFILE)
        fi
    done
    
    # Check if file has USERNAME variables defined and update report
    if cat $TFILE | grep -q "${USERNAME}"; then
        if [ "${USERLANG}" = "java" ]; then
            echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Java edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Java edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "python" ]; then
            echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Python edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Python edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "javascript" ]; then
            echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Node.js edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Node.js edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "php" ]; then
            echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - PHP edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - PHP edition"  "TRUE"
        fi
    else
        if [ "${USERLANG}" = "java" ]; then
            echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Java edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Java edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "python" ]; then
            echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Python edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Python edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "javascript" ]; then
            echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Node.js edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - Node.js edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "php" ]; then
            echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - PHP edition\e[0m"
            update-report ${USERNAME}  "Lab 0 - Getting Started with OpenShift - PHP edition"  "FALSE"
        fi
    fi
    
    # Remove temporary file from directory
    rm -f $TFILE
}

function get-rolebinding() {
    USERNAME=${1}
    PROJECTNAME=${2}
    MESSAGE=${3}
    SEARCHVAL=${4}
    DEBUG=false
    
    # Get user role bindings
    ROLE=$(oc get rolebindings -n ${PROJECTNAME} | grep ${SEARCHVAL}  | awk '{print $1}')
    
    # Debug ROLE variable definition
    [[ "$DEBUG" == true ]] && echo -e ${ROLE}
    
    # Check if role bindng was found and update report
    if [ ! -z ${ROLE} ]; then
        echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
        update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
        echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
        update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
}

function get-nationalparks-health-check() {
    USERNAME=${1}
    PROJECTNAME=${2}
    MESSAGE=${3}
    SEARCHVAL=${4}
    DEBUG=false
    
    # Get health check
    HEALTH_CHECK="$(oc get dc/nationalparks -n ${PROJECTNAME} -o yaml | grep ${SEARCHVAL} | awk '{print $1}' | grep ^${SEARCHVAL}:$ )"
    
    # Debug HEALTH_CHECK variable definition
    [[ "$DEBUG" == true ]] && echo -e ${HEALTH_CHECK}
    
    # Check if health check was found and update report
    if [ ! -z ${HEALTH_CHECK} ]; then
        echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
        update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
        echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
        update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
}

function get-nationalparks-trigger() {
    USERNAME=${1}
    PROJECTNAME=${2}
    MESSAGE=${3}
    SEARCHVAL=${4}
    DEBUG=false
    
    # Get health check
    TRIGGER=$(oc get dc/nationalparks -n ${PROJECTNAME} -o yaml | grep ${SEARCHVAL} | awk '{print $1}' )
    
    # Debug HEALTH_CHECK variable definition
    [[ "$DEBUG" == true ]] && echo -e ${TRIGGER}
    
    # Check if health check was found and update report
    if [ ! -z ${TRIGGER} ]; then
        echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
        update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
        echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
        update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
}

function get-pipelinerun-success() {
    USERNAME=${1}
    PROJECTNAME=${2}
    MESSAGE=${3}
    SEARCHVAL=${4}
    DEBUG=false
    
    # Get health check
    PIPELINE_SUCCESS=$(oc get PipelineRun -n ${PROJECTNAME} | grep ${SEARCHVAL} | awk '{print $2}' )
    
    # Debug HEALTH_CHECK variable definition
    [[ "$DEBUG" == true ]] && echo -e ${PIPELINE_SUCCESS}
    
    # Check if health check was found and update report
    if [ "${PIPELINE_SUCCESS}" = "True" ]; then
        echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
        update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
        echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
        update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
}

function check-template-exists() {
    USERNAME=${1}
    PROJECTNAME=${2}
    MESSAGE=${3}
    SEARCHVAL=${4}
    DEBUG=false
    
    # Get health check
    TEMPLATE=$(oc get template -n ${PROJECTNAME} | grep ${SEARCHVAL} | awk '{print $1}' )
    
    # Debug HEALTH_CHECK variable definition
    [[ "$DEBUG" == true ]] && echo -e ${TEMPLATE}
    
    # Check if health check was found and update report
    if [ ! -z ${TEMPLATE} ]; then
        echo -e "\e[0;32m${USERNAME} has completed ${MESSAGE}\e[0m"
        update-report  ${USERNAME}  "${MESSAGE}"  "TRUE"
    else
        echo -e "\e[0;31m${USERNAME} has not completed  ${MESSAGE}\e[0m"
        update-report  ${USERNAME}   "${MESSAGE}"  "FALSE"
    fi
}