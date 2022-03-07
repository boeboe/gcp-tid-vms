# TID vm-onboarding demo on GCP with GKE

## Setup

Change `environment.sh` to meet your requirements and environment

## Run

To start the demo, use `make` to go through the process


```
  # make

  help                           This help
  glcoud-init                    Login into GCP environment and create or switch to project
  gke-create-cluster             Create GKE cluster
  gke-delete-cluster             Delete GKE cluster
  gke-credentials-cluster        Set kube context to GKE cluster
  gke-info-clusters              Get info of KGE clusters
  gcp-create-vms                 Create and start GCP virtual machines
  gcp-delete-vms                 Delete GCP virtual machines
  istio-certs                    Install istio certificates
  istio-install                  Install Tetrate Istio Distro
  istio-info                     Get Tetrate Istio Distro information
  deploy-worloads-k8s            Deploy workloads on k8s
  undeploy-worloads-k8s          Undeploy workloads from k8s
  onboard-worloads-vms           Onboard workloads on vms into istio
  clean                          Clean temporary artifacts
  up                             [DEMO] Create all
  down                           [DEMO] Destroy all
  reset                          [DEMO] Destroy and recreate
```

Temporary artifacts specific to your environment will be stored in

 - `output/generated/*` : VM onboarding files, VM bootstrap scripts and istio/k8s generated yaml files
