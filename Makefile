#!make

fmt:
	terraform fmt --recursive

init:
	terraform init -upgrade

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

destroy: uninstall
	terraform destroy

.PHONY: init validate plan apply deploy uninstall destroy

