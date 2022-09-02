#!make
-include .env
export

fmt:
	terraform fmt --recursive

init:
	terraform init -upgrade -reconfigure \
	--backend-config="key=terraform.production.state"

validate:
	terraform validate

plan:
	terraform plan

apply:
	terraform apply

deploy:
	./scripts/deploy.sh

uninstall:
	./scripts/uninstall_all_deployments.sh

destroy:
	terraform destroy

.PHONY: init validate plan apply deploy uninstall destroy

