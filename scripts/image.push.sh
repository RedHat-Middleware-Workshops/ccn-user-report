#!/bin/bash
TAG=${TAG:-latest}

if [[ -z "${QUAY_USER}" ]]; then
  echo "QUAY_USER variable must be set to push image"
  exit 1
fi

docker tag ccn-user-report:${TAG} quay.io/$QUAY_USER/ccn-user-report:${TAG}
docker push quay.io/$QUAY_USER/ccn-user-report:$TAG