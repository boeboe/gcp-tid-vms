#!/usr/bin/env bash

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${BASE_DIR}/helpers.sh

check_local_requirements

### GCP SECTION ###
export GCP_PROJECT_ID=bart-tid-vms-demo
export GCP_PROJECT_NAME=Bart TID VM Demo
export GCP_DOMAIN=k8s.local
export GCP_SSH_CIDR=$(curl ipinfo.io/ip)/32

export GKE_CLUSTER_NAME=bart-tid-vms-cluster
export GKE_RELEASE_CHANNEL=regular
export GKE_COMPUTE_REGION=europe-west1
export GKE_COMPUTE_ZONE=europe-west1-b
export GKE_NODE_COUNT=5
export GKE_MACHINE_TYPE=e2-standard-8

export VM_BASE_IMAGE=ubuntu-pro-2004-focal-v20220204
export VM_BASE_IMAGE_PROJECT=ubuntu-os-pro-cloud
export VM_MACHINE_TYPE=e2-standard-2

### ISTIO SECTION ###
export ISTIO_VERSION=1.11.6
export ISTIO_FLAVOR=istio
# export ISTIO_FLAVOR=tetrate
# export ISTIO_FLAVOR=tetratefips
export ISTIO_VM_NAMESPACE=vm-namespace

export ISTIO_VM_SERVICEACCOUNT_1=vm-service-account-1
export ISTIO_VM_SERVICEACCOUNT_2=vm-service-account-2

export ISTIO_VM_APP_1_NAME=vm-app-1
export ISTIO_VM_APP_1_INSTANCES="vm-app-1-a vm-app-1-b"
export ISTIO_VM_APP_2_NAME=vm-app-2
export ISTIO_VM_APP_2_INSTANCES="vm-app-2-a vm-app-2-b"
