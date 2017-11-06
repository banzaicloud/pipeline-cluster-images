#!/usr/bin/env bash
 
set -o nounset
set -o pipefail
set -o errexit


packer_wrap() {
  local OPTS=""

  ${DRY_RUN:+echo ===} docker run -i --tty --rm \
    -e AWS_IMAGE_NAME=$AWS_IMAGE_NAME \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_REGION=$AWS_REGION \
    -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    -e AWS_SSH_USERNAME=$AWS_SSH_USERNAME \
    -e AWS_SOURCE_AMI=$AWS_SOURCE_AMI \
    -e AWS_INTANCE_TYPE=$AWS_INTANCE_TYPE \
    -e KUBERNETES_RELEASE_TAG=$KUBERNETES_RELEASE_TAG \
    -e ETCD_RELEASE_TAG=$ETCD_RELEASE_TAG \
    -e K8S_DNS_RELEASE_TAG=$K8S_DNS_RELEASE_TAG \
    -e SPARK_RELEASE_TAG=$SPARK_RELEASE_TAG \
    -e WEAVE_RELEASE_TAG=$WEAVE_RELEASE_TAG \
    -e HELM_RELEASE_TAG=$HELM_RELEASE_TAG \
    -e ZEPPELIN_RELEASE_TAG=$ZEPPELIN_RELEASE_TAG \
    -e PUSHGATEWAY_RELEASE_TAG=$PUSHGATEWAY_RELEASE_TAG \
    -e PROMETHEUS_RELEASE_TAG=$PROMETHEUS_RELEASE_TAG \
    -v $HOME/.aws:/root/.aws \
    -v $HOME/.ssh:/root/.ssh \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD:$PWD \
    -w $PWD \
    $OPTS \
    hashicorp/packer:1.1.1 "$@" packer.json
}

main() {
  packer_wrap "$@"
}

[[ "$0" == "$BASH_SOURCE" ]] && main "$@"