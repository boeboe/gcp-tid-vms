#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

KUBE_CONTEXT=gke_${GCP_PROJECT_ID}_${GKE_COMPUTE_ZONE}_${GKE_CLUSTER_NAME}
CERT_DIR=${BASE_DIR}/certs/${GKE_CLUSTER_NAME}
ISTIO_DIR=${BASE_DIR}/istio

shopt -s expand_aliases
alias k="kubectl --context=${KUBE_CONTEXT}"
alias istioctl="getmesh istioctl --context ${KUBE_CONTEXT}"


if [[ $1 = "install-certs" ]]; then
  if ! k get ns istio-system; then k create ns istio-system; fi

  if ! k -n istio-system get secret cacerts; then
    k create secret generic cacerts -n istio-system \
    --from-file=${CERT_DIR}/ca-cert.pem \
    --from-file=${CERT_DIR}/ca-key.pem \
    --from-file=${CERT_DIR}/root-cert.pem \
    --from-file=${CERT_DIR}/cert-chain.pem
  fi

  print_info "Certificates installed"
  exit 0
fi


if [[ $1 = "install-istio" ]]; then
  print_info "Switching to istio ${ISTIO_VERSION}, flavor ${ISTIO_FLAVOR}"
  getmesh switch ${ISTIO_VERSION} --flavor ${ISTIO_FLAVOR}

  print_info "Install istio cluster with istio-eastwestgateway"
  istioctl install -y --set profile=default -f${ISTIO_DIR}/cluster-operator.yaml

  k wait --timeout=5m --for=condition=Ready pods --all -n istio-system

  print_info "Create istiod-gateway with PASSTHROUGH"
  k apply -f ${ISTIO_DIR}/istiod-gateway.yaml

  print_info "Istio installed"
  exit 0
fi


if [[ $1 = "info-istio" ]]; then
  print_info "Get istio info"
  k get po,svc -n istio-system -o wide
  exit 0
fi


print_error "Please specify correct option"
exit 1