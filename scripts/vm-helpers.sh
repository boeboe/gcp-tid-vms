#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )

# Generate Istio WorkloadGroup
#   REF: https://istio.io/latest/docs/reference/config/networking/workload-group
# Arguments: 
#   (1) VM_APP_NAME
#   (2) VM_NAMESPACE
#   (3) VM_SERVICEACCOUNT
generate_workloadgroup_yaml() { 
  mkdir -p ${BASE_DIR}/output/generated/${1}

  cat ${BASE_DIR}/istio/workloadgroup.tpl.yaml \
    | sed "s/REPLACE_VM_APP_NAME/${1}/g" \
    | sed "s/REPLACE_VM_NAMESPACE/${2}/g" \
    | sed "s/REPLACE_VM_SERVICEACCOUNT/${3}/g" \
    > ${BASE_DIR}/output/generated/${1}/workloadgroup.yaml
}

# Generate Istio WorkloadEntry
#   REF: https://istio.io/latest/docs/reference/config/networking/workload-entry
# Arguments: 
#   (1) VM_APP_NAME
#   (2) VM_APP_INSTANCE
#   (3) VM_NAMESPACE
#   (4) VM_SERVICEACCOUNT
#   (5) GKE_COMPUTE_ZONE
generate_workloadentry_yaml() { 
  mkdir -p ${BASE_DIR}/output/generated/${1}
  
  VM_IPADDRESS=$(gcloud compute instances describe ${2} \
    --format='get(networkInterfaces[0].networkIP)' \
    --zone=${5})

  cat ${BASE_DIR}/istio/workloadentry.tpl.yaml \
    | sed "s/REPLACE_VM_APP_NAME/${1}/g" \
    | sed "s/REPLACE_VM_APP_INSTANCE/${2}/g" \
    | sed "s/REPLACE_VM_NAMESPACE/${3}/g" \
    | sed "s/REPLACE_VM_SERVICEACCOUNT/${4}/g" \
    | sed "s/REPLACE_VM_IPADDRESS/${VM_IPADDRESS}/g" \
    > ${BASE_DIR}/output/generated/${1}/workloadentry-${2}.yaml
}

# Generate Istio WorkloadGroup
#   REF: https://istio.io/latest/docs/reference/config/networking/service-entry
# Arguments: 
#   (1) VM_APP_NAME
#   (2) VM_NAMESPACE
generate_serviceentry_yaml() { 
  mkdir -p ${BASE_DIR}/output/generated/${1}

  cat ${BASE_DIR}/istio/serviceentry.tpl.yaml \
    | sed "s/REPLACE_VM_APP_NAME/${1}/g" \
    | sed "s/REPLACE_VM_NAMESPACE/${2}/g" \
    > ${BASE_DIR}/output/generated/${1}/serviceentry.yaml
}

# Generate Kubernetes Service
#   REF: https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1
# Arguments: 
#   (1) VM_APP_NAME
#   (2) VM_NAMESPACE
generate_service_yaml() { 
  mkdir -p ${BASE_DIR}/output/generated/${1}

  cat ${BASE_DIR}/istio/service.tpl.yaml \
    | sed "s/REPLACE_VM_APP_NAME/${1}/g" \
    | sed "s/REPLACE_VM_NAMESPACE/${2}/g" \
    > ${BASE_DIR}/output/generated/${1}/service.yaml
}

# Arguments:
#   (1) VM_APP_NAME
generate_vm_files() {
  mkdir -p ${BASE_DIR}/output/generated/${1}

  istioctl x workload entry configure \
    -f ${BASE_DIR}/output/generated/${1}/workloadgroup.yaml \
    -o ${BASE_DIR}/output/generated/${1} \
    --clusterID "istio-cluster"
}

# Generate VM istio bootstrap files
#  REF: https://istio.io/latest/docs/setup/install/virtual-machine
#       https://istio.io/latest/docs/reference/commands/istioctl/#istioctl-experimental-workload-entry-configure
# Arguments: 
#   (1) VM_APP_NAME
#   (2) ROOT_CERT
#   (3) ISTIO_TOKEN
#   (4) CLUSER_ENV
#   (5) MESH_CONFIG
#   (6) ISTIOD_HOSTS
#   (7) ISTIO_VERSION
generate_bootstrap_istio() { 
  mkdir -p ${BASE_DIR}/output/generated/${1}

  cat ${BASE_DIR}/vm/bootstrap-istio.tpl.sh \
    | sed -e "/REPLACE_ROOT_CERT/r ${2}" -e "/REPLACE_ROOT_CERT/d" \
    | sed -e "/REPLACE_ISTIO_TOKEN/r ${3}" -e "/REPLACE_ISTIO_TOKEN/d" \
    | sed -e "/REPLACE_CLUSTER_ENV/r ${4}" -e "/REPLACE_CLUSTER_ENV/d" \
    | sed -e "/REPLACE_MESH_CONFIG/r ${5}" -e "/REPLACE_MESH_CONFIG/d" \
    | sed -e "/REPLACE_ISTIOD_HOSTS/r ${6}" -e "/REPLACE_ISTIOD_HOSTS/d" \
    | sed "s/REPLACE_ISTIO_VERSION/${7}/g" \
    > ${BASE_DIR}/output/generated/${1}/bootstrap-istio.sh
}

# Tranfer istio bootstrap script to VM ad start it
# Arguments:
#   (1) VM_APP_NAME
#   (2) VM_APP_INSTANCE
#   (3) GKE_COMPUTE_ZONE
bootstrap_istio() {
  gcloud compute scp ${BASE_DIR}/output/generated/${1}/bootstrap-istio.sh ${2}:~ --zone=${3}
  gcloud compute ssh ${2} --zone=${3} --command="sudo mv ~/bootstrap-istio.sh /usr/local/bin/bootstrap-istio.sh"
  gcloud compute ssh ${2} --zone=${3} --command="sudo chmod +x /usr/local/bin/bootstrap-istio.sh"
  gcloud compute ssh ${2} --zone=${3} --command="sudo bootstrap-istio.sh"
}
