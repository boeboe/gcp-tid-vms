# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

######################
#### GKE Cluster  ####
######################

glcoud-init: ## Login into GCP environment and create or switch to project
	./scripts/gcloud.sh login

gke-create-cluster: ## Create GKE cluster
	./scripts/gcloud.sh create-gke-cluster
	./scripts/gcloud.sh credentials-gke-cluster

gke-delete-cluster: ## Delete GKE cluster
	./scripts/gcloud.sh delete-gke-cluster

gke-credentials-cluster: ## Set kube context to GKE cluster
	./scripts/gcloud.sh credentials-gke-cluster

gke-info-clusters: ## Get info of KGE clusters
	./scripts/gcloud.sh info-gke-cluster


#############
#### VMs ####
#############

gcp-create-vms: ## Create and start GCP virtual machines
	./scripts/gcloud.sh create-gcp-vms

gcp-delete-vms: ## Delete GCP virtual machines
	./scripts/gcloud.sh delete-gcp-vms


###############
#### Istio ####
###############

istio-certs: ## Install istio certificates
	./scripts/istio.sh install-certs

istio-install: istio-certs ## Install Tetrate Istio Distro
	./scripts/istio.sh install-istio

istio-info: ## Get Tetrate Istio Distro information
	./scripts/istio.sh info-istio


###################
#### Workloads ####
###################

deploy-worloads-k8s: ## Deploy workloads on k8s
	./scripts/workloads-k8s.sh deploy

undeploy-worloads-k8s: ## Undeploy workloads from k8s
	./scripts/workloads-k8s.sh undeploy

onboard-worloads-vms: ## Onboard workloads on vms into istio
	./scripts/workloads-vm.sh onboard


#################
#### Helpers ####
#################

clean: ## Clean temporary artifacts
	rm -rf output/generated/*

up: glcoud-init gke-create-cluster gcp-create-vms istio-install deploy-worloads-k8s onboard-worloads-vms ## [DEMO] Create all

down: gcp-delete-vms gke-delete-cluster clean ## [DEMO] Destroy all

reset: down up ## [DEMO] Destroy and recreate
