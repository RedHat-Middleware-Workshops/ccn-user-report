## Color Code Cheat Sheet
# Dark Red     0;31
# Dark Green  0;32
# Dark Yellow 0;33

function openshift101-started(){
    USERNAME=${1}
    USERLANG=${2:-java}
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
    
    # Check if file has USERNAME variables defined
    if cat $TFILE | grep -q "${USERNAME}"
    then
        if [ "${USERLANG}" = "java" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Java edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Java edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "python" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Python edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Python edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "javascript" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - Node.js edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Node.js edition"  "TRUE"
        fi
        
        if [ "${USERLANG}" = "php" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;32m${USERNAME} has started Getting Started with OpenShift - PHP edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - PHP edition"  "TRUE"
        fi
    else
        if [ "${USERLANG}" = "java" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Java edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Java edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "python" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Python edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Python edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "javascript" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - Node.js edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - Node.js edition"  "FALSE"
        fi
        
        if [ "${USERLANG}" = "php" ]; then
            [[ "$DEBUG" == true ]] && echo -e "\e[0;31m${USERNAME} has not started  Getting Started with OpenShift - PHP edition\e[0m"
            update-report ${USERNAME}  "Getting Started with OpenShift - PHP edition"  "FALSE"
        fi
    fi
    
    # Remove temporary file from directory
    rm -f $TFILE
}