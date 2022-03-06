#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh
source ${BASE_DIR}/scripts/vm-helpers.sh

KUBE_CONTEXT=gke_${GCP_PROJECT_ID}_${GKE_COMPUTE_ZONE}_${GKE_CLUSTER_NAME}

shopt -s expand_aliases
alias k="kubectl --context=${KUBE_CONTEXT}"


if [[ $1 = "onboard" ]]; then
  print_info "Prepare istio for VM onboarding"
  k create namespace "${ISTIO_VM_NAMESPACE}"
  k create serviceaccount "${ISTIO_VM_SERVICEACCOUNT_1}" -n "${ISTIO_VM_NAMESPACE}"
  k create serviceaccount "${ISTIO_VM_SERVICEACCOUNT_2}" -n "${ISTIO_VM_NAMESPACE}"

  generate_workloadgroup_yaml \
    ${ISTIO_VM_APP_1} \
    ${ISTIO_VM_NAMESPACE} \
    ${ISTIO_VM_SERVICEACCOUNT_1}
  generate_workloadgroup_yaml \
    ${ISTIO_VM_APP_2} \
    ${ISTIO_VM_NAMESPACE} \
    ${ISTIO_VM_SERVICEACCOUNT_2}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/workloadgroup.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/workloadgroup.yaml
  print_info "VM WorkloadGroup yaml files generated and deployed"
  
  generate_workloadentry_yaml \
    ${ISTIO_VM_APP_1} \
    ${ISTIO_VM_NAMESPACE} \
    ${ISTIO_VM_SERVICEACCOUNT_1} \
    ${GKE_COMPUTE_ZONE}
  generate_workloadentry_yaml \
    ${ISTIO_VM_APP_2} \
    ${ISTIO_VM_NAMESPACE} \
    ${ISTIO_VM_SERVICEACCOUNT_2} \
    ${GKE_COMPUTE_ZONE}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/workloadentry.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/workloadentry.yaml
  print_info "VM WorkloadEntry yaml files generated and deployed"

  generate_serviceentry_yaml \
    ${ISTIO_VM_APP_1} \
    ${ISTIO_VM_NAMESPACE}
  generate_serviceentry_yaml \
    ${ISTIO_VM_APP_2} \
    ${ISTIO_VM_NAMESPACE}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/serviceentry.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/serviceentry.yaml
  print_info "VM ServiceEntry yaml files generated and deployed"

  generate_service_yaml \
    ${ISTIO_VM_APP_1} \
    ${ISTIO_VM_NAMESPACE}
  generate_service_yaml \
    ${ISTIO_VM_APP_2} \
    ${ISTIO_VM_NAMESPACE}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/service.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/service.yaml
  print_info "VM Service yaml files generated and deployed"

  generate_vm_files ${ISTIO_VM_APP_1}
  generate_vm_files ${ISTIO_VM_APP_2}
  print_info "VM onboarding files generated"

  generate_bootstrap_istio \
    ${ISTIO_VM_APP_1} \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/root-cert.pem \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/istio-token \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/cluster.env \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/mesh.yaml \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1}/hosts \
    ${ISTIO_VERSION}  
  generate_bootstrap_istio \
    ${ISTIO_VM_APP_2} \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/root-cert.pem \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/istio-token \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/cluster.env \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/mesh.yaml \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2}/hosts \
    ${ISTIO_VERSION}
  print_info "VM istio bootstrap files generated"

  bootstrap_istio \
    ${ISTIO_VM_APP_1} \
    ${GKE_COMPUTE_ZONE}
  bootstrap_istio \
    ${ISTIO_VM_APP_2} \
    ${GKE_COMPUTE_ZONE}
  print_info "VM istio bootstrap files deployed and started"

  exit 0
fi

print_error "Please specify correct option"
exit 1