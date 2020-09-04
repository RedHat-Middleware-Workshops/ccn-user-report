#!/bin/bash 


if [ ! -f ./bin ]; then 
  mkdir -p ./bin 
  echo "Downloading oc cli for application"
  curl -OL https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz
  tar -zxvf openshift-client-linux.tar.gz --directory ./bin 
  chmod +x ./bin/oc
  chmod +x ./bin/kubectl
  rm -rf openshift-client-linux.tar.gz
fi



echo "Building code in $(pwd) with docker"
docker build -t ccn-user-report:$TAG -f scripts/Dockerfile .

rm -rf ./bin
