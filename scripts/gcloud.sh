#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

KUBE_CONTEXT=gke_${GCP_PROJECT_ID}_${GKE_COMPUTE_ZONE}_${GKE_CLUSTER_NAME}


if [[ $1 = "login" ]]; then
  if [[ $(gcloud config get-value project) != ${GCP_PROJECT_ID} ]]; then
    gcloud auth login
  fi

  if ! gcloud auth application-default print-access-token; then
    gcloud auth application-default login
    print_info "Successfully logged in to GCP"
  fi

  gcloud config set project ${GCP_PROJECT_ID}
  gcloud services enable artifactregistry.googleapis.com --project ${GCP_PROJECT_ID}
  gcloud services enable container.googleapis.com --project ${GCP_PROJECT_ID}
  gcloud config get-value project
  print_info "Successfully switched to GCP project ${GCP_PROJECT_ID}"
  exit 0
fi


if [[ $1 = "create-gke-cluster" ]]; then
  gcloud container clusters create ${GKE_CLUSTER_NAME} \
    --node-locations ${GKE_COMPUTE_ZONE} \
    --num-nodes ${GKE_NODE_COUNT} \
    --machine-type ${GKE_MACHINE_TYPE} \
    --release-channel ${GKE_RELEASE_CHANNEL} \
    --zone ${GKE_COMPUTE_ZONE}
  print_info "GKE cluster created"
  gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} \
    --zone ${GKE_COMPUTE_ZONE}
  print_info "GKE cluster credentials updated"
  exit 0
fi


if [[ $1 = "credentials-gke-cluster" ]]; then
  gcloud container clusters get-credentials ${GKE_CLUSTER_NAME} --zone ${GKE_COMPUTE_ZONE}
  print_info "GKE cluster credentials updated"
  exit 0
fi


if [[ $1 = "info-gke-cluster" ]]; then
  gcloud container clusters describe ${GKE_CLUSTER_NAME} --zone ${GKE_COMPUTE_ZONE}
  gcloud container clusters list --zone ${GKE_COMPUTE_ZONE}
  kubectl --context ${KUBE_CONTEXT} get nodes -o wide
  exit 0
fi


if [[ $1 = "delete-gke-cluster" ]]; then
  gcloud container clusters delete ${GKE_CLUSTER_NAME} --zone ${GKE_COMPUTE_ZONE}
  print_info "GKE cluster deleted"
  exit 0
fi


if [[ $1 = "create-gcp-vms" ]]; then
  gcloud compute instances create ${ISTIO_VM_APP_1} \
    --image=${VM_BASE_IMAGE} \
    --image-project=${VM_BASE_IMAGE_PROJECT} \
    --machine-type=${VM_MACHINE_TYPE} \
    --metadata-from-file=startup-script=${BASE_DIR}/vm/cloud-init.sh \
    --tags=allow-8080 \
    --zone ${GKE_COMPUTE_ZONE}

  gcloud compute instances create ${ISTIO_VM_APP_2} \
    --image=${VM_BASE_IMAGE} \
    --image-project=${VM_BASE_IMAGE_PROJECT} \
    --machine-type=${VM_MACHINE_TYPE} \
    --metadata-from-file=startup-script=${BASE_DIR}/vm/cloud-init.sh \
    --tags=allow-8080 \
    --zone ${GKE_COMPUTE_ZONE}
  print_info "GCP vms deployed"

  gcloud compute firewall-rules create allow-8080 --allow=tcp:8080 --description="Allow incoming traffic on TCP port 8080" --direction=INGRESS --target-tags allow-8080
  print_info "GCP firewall rule created"
  exit 0
fi


if [[ $1 = "delete-gcp-vms" ]]; then
  gcloud compute firewall-rules delete allow-8080 
  print_info "GCP firewall rule deleted"
  gcloud compute instances delete ${ISTIO_VM_APP_1} --zone ${GKE_COMPUTE_ZONE}
  gcloud compute instances delete ${ISTIO_VM_APP_2} --zone ${GKE_COMPUTE_ZONE}
  print_info "GCP vms deleted"
  exit 0
fi


print_error "Please specify correct option"
exit 1