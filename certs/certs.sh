#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

DOMAIN=${GCP_DOMAIN}

cd ${BASE_DIR}/certs

if [[ $1 = "root-ca" ]]; then
  make -f Makefile.selfsigned.mk root-ca 
  exit 0
fi

if [[ $1 = "cluster" ]]; then
  make -f Makefile.selfsigned.mk ${GKE_CLUSTER_NAME}-cacerts
  exit 0
fi


if [[ $1 = "wildcard" ]]; then
  mkdir -p ./wildcard
  openssl req -out ./wildcard/${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./wildcard/${DOMAIN}.key -subj "/CN=*.${DOMAIN}/O=Istio"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial 0 -in ./wildcard/${DOMAIN}.csr -out ./wildcard/${DOMAIN}.pem -extfile <(printf "subjectAltName=DNS:${DOMAIN},DNS:*.${DOMAIN},DNS:localhost")
  cat ./wildcard/${DOMAIN}.pem ./root-cert.pem >> ./wildcard/${DOMAIN}-bundle.pem
  exit 0
fi

if [[ $1 = "client" ]]; then
  mkdir -p ./client
  openssl req -out ./client/client.${DOMAIN}.csr -newkey rsa:4096 -sha512 -nodes -keyout ./client/client.${DOMAIN}.key -subj "/CN=client.${DOMAIN}/O=Client"
  openssl x509 -req -sha512 -days 3650 -CA ./root-cert.pem -CAkey ./root-key.pem -set_serial 1 -in ./client/client.${DOMAIN}.csr -out ./client/client.${DOMAIN}.pem
  exit 0
fi

if [[ $1 = "print-root-ca" ]]; then
  openssl x509 -in ./root-cert.pem -text
  exit 0
fi

if [[ $1 = "print-cluster" ]]; then
  openssl x509 -in ./${GKE_CLUSTER_NAME}/ca-cert.pem -text
  exit 0
fi

if [[ $1 = "print-wildcard" ]]; then
  openssl x509 -in ./wildcard/${DOMAIN}.pem -text
  openssl x509 -in ./wildcard/${DOMAIN}-bundle.pem -text
  exit 0
fi

if [[ $1 = "print-client" ]]; then
  openssl x509 -in ./client/client.${DOMAIN}.pem -text
  exit 0
fi

print_error "Please specify correct option"
exit 1