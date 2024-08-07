#!make
.DEFAULT_GOAL := help
SHELL := '/bin/bash'

CURRENT_TIME := `date "+%Y.%m.%d-%H.%M.%S"`
TERRAFORM_VERSION := `cat versions.tf 2> /dev/null | grep required_version | cut -d "\\"" -f 2 | cut -d " " -f 2`

LOCAL_IMAGE := ministryofjustice/nvvs/terraforms:latest
DOCKER_IMAGE := ghcr.io/ministryofjustice/nvvs/terraforms:v0.2.0

DOCKER_RUN := @docker run --rm \
				--env-file <(aws-vault exec $$AWS_PROFILE -- env | grep ^AWS_) \
				--env-file <(env | grep ^TF_VAR_) \
				--env-file <(env | grep ^ENV) \
				-e TFENV_TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
				-v `pwd`:/data \
				--workdir /data \
				--platform linux/amd64 \
				$(DOCKER_IMAGE)

DOCKER_RUN_IT := @docker run --rm -it \
				--env-file <(aws-vault exec $$AWS_PROFILE -- env | grep ^AWS_) \
				--env-file <(env | grep ^TF_VAR_) \
				--env-file <(env | grep ^ENV) \
				-e TFENV_TERRAFORM_VERSION=$(TERRAFORM_VERSION) \
				-v `pwd`:/data \
				--workdir /data \
				--platform linux/amd64 \
				$(DOCKER_IMAGE)

export DOCKER_DEFAULT_PLATFORM=linux/amd64

.PHONY: debug
debug:  ## debug
	@echo "debug"
	$(info target is $@)

.PHONY: aws
aws:  ## provide aws cli command as an arg e.g. (make aws AWSCLI_ARGUMENT="s3 ls")
	$(DOCKER_RUN) /bin/bash -c "aws $$AWSCLI_ARGUMENT"

.PHONY: shell
shell: ## Run Docker container with interactive terminal
	$(DOCKER_RUN_IT) /bin/bash

.PHONY: fmt
fmt: ## terraform fmt
	$(DOCKER_RUN) terraform fmt --recursive

.PHONY: init
init: ## terraform init (make init ENV_ARGUMENT=pre-production) NOTE: Will also select the env's workspace.

## INFO: Do not indent the conditional below, make stops with an error.
ifneq ("$(wildcard .env)","")
$(info Using config file ".env")
include .env
init: -init
else
$(info Config file ".env" does not exist.)
init: -init-gen-env
endif

.PHONY: -init-gen-env
-init-gen-env:
	$(MAKE) gen-env

.PHONY: -init
-init:
	$(DOCKER_RUN) terraform init --backend-config="key=terraform.$$ENV.state"
	$(MAKE) workspace-select

.PHONY: init-upgrade
init-upgrade: ## terraform init -upgrade
	$(DOCKER_RUN) terraform init -upgrade --backend-config="key=terraform.$$ENV.state"

.PHONY: import
import: ## terraform import e.g. (make import IMPORT_ARGUMENT="module.foo.bar some_resource")
	$(DOCKER_RUN) terraform import $$IMPORT_ARGUMENT

.PHONY: workspace-list
workspace-list: ## terraform workspace list
	$(DOCKER_RUN) terraform workspace list

.PHONY: workspace-select
workspace-select: ## terraform workspace select
	$(DOCKER_RUN) terraform workspace select $$ENV || \
	$(DOCKER_RUN) terraform workspace new $$ENV

.PHONY: validate
validate: ## terraform validate
	$(DOCKER_RUN) terraform validate

.PHONY: plan-out
plan-out: ## terraform plan - output to timestamped file
	$(DOCKER_RUN) terraform plan -no-color > $$ENV.$(CURRENT_TIME).tfplan

.PHONY: plan
plan: ## terraform plan
	$(DOCKER_RUN) terraform plan

.PHONY: refresh
refresh: ## terraform refresh
	$(DOCKER_RUN) terraform refresh

.PHONY: output
output: ## terraform output (make output OUTPUT_ARGUMENT='--raw dns_dhcp_vpc_id')
	$(DOCKER_RUN) terraform output -no-color $$OUTPUT_ARGUMENT

.PHONY: apply
apply: ## terraform apply
	$(DOCKER_RUN_IT) terraform apply
	$(DOCKER_RUN) /bin/bash -c "./scripts/publish_terraform_outputs.sh"

.PHONY: state-list
state-list: ## terraform state list
	$(DOCKER_RUN) terraform state list

.PHONY: show
show: ## terraform show
	$(DOCKER_RUN) terraform show -no-color

.PHONY: destroy
destroy: ## terraform destroy
	$(DOCKER_RUN) terraform destroy

.PHONY: lock
lock: ## terraform providers lock (reset hashes after upgrades prior to commit)
	rm .terraform.lock.hcl
	$(DOCKER_RUN) terraform providers lock -platform=windows_amd64 -platform=darwin_amd64 -platform=linux_amd64

.PHONY: unlock
unlock: ## terraform unlock e.g. (make unlock IMPORT_ARGUMENT=LOCK_ID)
	$(DOCKER_RUN) terraform force-unlock $$IMPORT_ARGUMENT

.PHONY: clean
clean: ## clean terraform cached providers etc
	rm -rf .terraform/ terraform.tfstate* .env .env.tmp
	## Sometimes engineers forget to remove the unnecessary TFVARs file and create issues
	## We move it safely out of the way
	if test -f terraform.tfvars; then mv terraform.tfvars terraform.tfvars.DELETE_ME; fi

.PHONY: gen-env
gen-env: ## generate a ".env" file with the correct TF_VARS for the environment e.g. (make gen-env ENV_ARGUMENT=pre-production)
	$(DOCKER_RUN) /bin/bash -c "./scripts/generate-env-file.sh $$ENV_ARGUMENT"

.PHONY: tfenv
tfenv: ## tfenv pin - terraform version from versions.tf
	tfenv use $(cat versions.tf 2> /dev/null | grep required_version | cut -d "\"" -f 2 | cut -d " " -f 2) && tfenv pin

.PHONY: deploy
deploy: ## deploy
	$(DOCKER_RUN_IT) /bin/bash -c "./scripts/deploy.sh"

.PHONY: uninstall
uninstall: ## uninstall
	$(DOCKER_RUN_IT) /bin/bash -c "./scripts/uninstall_all_deployments.sh"

.PHONY: get-kubeconfig
get-kubeconfig: ## get-kubeconfig
	$(DOCKER_RUN_IT) /bin/bash -c "./scripts/setup-kubeconfig.sh"
	@mkdir -p ~/.kube
	@cp ~/.kube/config ~/.kube/config.backup.$(shell date +%Y%m%d%H%M%S)
	@KUBECONFIG=.kube_config:~/.kube/config kubectl config view --flatten > ~/.kube/config.merged
	@mv ~/.kube/config.merged ~/.kube/config
	@echo "Kubeconfig file has been merged and saved to ~/.kube/config"

.PHONY: grafana-pwd
CURRENT_NAMESPACE=$(shell kubectl config view --minify --output 'jsonpath={..namespace}')
grafana-pwd: ## generate default grafana password for admin
ifeq ($(CURRENT_NAMESPACE),development)
	 	@kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
  else
	 	@echo "This command can only be run in the development namespace."
  endif

.PHONY: generate_diagrams
generate_diagrams: ## generate_diagrams
	docker run -it --rm -v "${PWD}":/app/ -w /app/documentation/diagrams/ mjdk/diagrams scripts/architecture_diagram.py
	docker run -it --rm -v "${PWD}":/app/ -w /app/documentation/diagrams/ mjdk/diagrams scripts/detailed_eks_diagram.py

help:
	@grep -h -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
