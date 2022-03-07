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

  generate_workloadgroup_yaml ${ISTIO_VM_APP_1_NAME} ${ISTIO_VM_NAMESPACE} ${ISTIO_VM_SERVICEACCOUNT_1}
  generate_workloadgroup_yaml ${ISTIO_VM_APP_2_NAME} ${ISTIO_VM_NAMESPACE} ${ISTIO_VM_SERVICEACCOUNT_2}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/workloadgroup.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/workloadgroup.yaml
  print_info "VM WorkloadGroup yaml files generated and deployed"
  
  for ISTIO_VM_APP_1_INSTANCE in ${ISTIO_VM_APP_1_INSTANCES}; do
    generate_workloadentry_yaml \
      ${ISTIO_VM_APP_1_NAME} \
      ${ISTIO_VM_APP_1_INSTANCE} \
      ${ISTIO_VM_NAMESPACE} \
      ${ISTIO_VM_SERVICEACCOUNT_1} \
      ${GKE_COMPUTE_ZONE}
    k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/workloadentry-${ISTIO_VM_APP_1_INSTANCE}.yaml
  done
  for ISTIO_VM_APP_2_INSTANCE in ${ISTIO_VM_APP_2_INSTANCES}; do
    generate_workloadentry_yaml \
      ${ISTIO_VM_APP_2_NAME} \
      ${ISTIO_VM_APP_2_INSTANCE} \
      ${ISTIO_VM_NAMESPACE} \
      ${ISTIO_VM_SERVICEACCOUNT_2} \
      ${GKE_COMPUTE_ZONE}
    k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/workloadentry-${ISTIO_VM_APP_2_INSTANCE}.yaml
  done
  print_info "VM WorkloadEntry yaml files generated and deployed"

  generate_serviceentry_yaml ${ISTIO_VM_APP_1_NAME} ${ISTIO_VM_NAMESPACE}
  generate_serviceentry_yaml ${ISTIO_VM_APP_2_NAME} ${ISTIO_VM_NAMESPACE}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/serviceentry.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/serviceentry.yaml
  print_info "VM ServiceEntry yaml files generated and deployed"

  generate_service_yaml ${ISTIO_VM_APP_1_NAME} ${ISTIO_VM_NAMESPACE}
  generate_service_yaml ${ISTIO_VM_APP_2_NAME} ${ISTIO_VM_NAMESPACE}
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/service.yaml
  k apply -f ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/service.yaml
  print_info "VM Service yaml files generated and deployed"

  generate_vm_files ${ISTIO_VM_APP_1_NAME}
  generate_vm_files ${ISTIO_VM_APP_2_NAME}
  print_info "VM onboarding files generated"

  generate_bootstrap_istio \
    ${ISTIO_VM_APP_1_NAME} \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/root-cert.pem \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/istio-token \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/cluster.env \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/mesh.yaml \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_1_NAME}/hosts \
    ${ISTIO_VERSION}  
  generate_bootstrap_istio \
    ${ISTIO_VM_APP_2_NAME} \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/root-cert.pem \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/istio-token \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/cluster.env \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/mesh.yaml \
    ${BASE_DIR}/output/generated/${ISTIO_VM_APP_2_NAME}/hosts \
    ${ISTIO_VERSION}
  print_info "VM istio bootstrap files generated"

  for ISTIO_VM_APP_1_INSTANCE in ${ISTIO_VM_APP_1_INSTANCES}; do
    bootstrap_istio ${ISTIO_VM_APP_1_NAME} ${ISTIO_VM_APP_1_INSTANCE} ${GKE_COMPUTE_ZONE}
  done
  for ISTIO_VM_APP_2_INSTANCE in ${ISTIO_VM_APP_2_INSTANCES}; do
    bootstrap_istio ${ISTIO_VM_APP_2_NAME} ${ISTIO_VM_APP_2_INSTANCE} ${GKE_COMPUTE_ZONE}
  done
  print_info "VM istio bootstrap files deployed and started"

  exit 0
fi

print_error "Please specify correct option"
exit 1