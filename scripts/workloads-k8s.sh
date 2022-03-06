#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

KUBE_CONTEXT=gke_${GCP_PROJECT_ID}_${GKE_COMPUTE_ZONE}_${GKE_CLUSTER_NAME}

shopt -s expand_aliases
alias k="kubectl --context=${KUBE_CONTEXT}"

generate_json_server_yaml() {
  mkdir -p ${BASE_DIR}/output/generated

  cat ${BASE_DIR}/istio/json-server.tpl.yaml \
    | sed "s/REPLACE_REGION/${GKE_COMPUTE_REGION}/g" \
    | sed "s/REPLACE_ZONE/${GKE_COMPUTE_ZONE}/g" \
    > ${BASE_DIR}/output/generated/json-server.yaml
}

if [[ $1 = "deploy" ]]; then
  generate_json_server_yaml

  k apply -f ${BASE_DIR}/istio/namespace.yaml
  k apply -f ${BASE_DIR}/output/generated/json-server.yaml

  print_info "Workload json-server deployed to k8s"
  exit 0
fi

if [[ $1 = "undeploy" ]]; then
  k delete -f ${BASE_DIR}/output/generated/json-server.yaml
  k delete -f ${BASE_DIR}/istio/namespace.yaml

  print_info "Workload json-server removed from k8s"
  exit 0
fi

print_error "Please specify correct option"
exit 1