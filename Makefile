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

generate_diagrams:
	docker run -it --rm -v "${PWD}":/app/ -w /app/documentation/diagrams/ mjdk/diagrams scripts/architecture_diagram.py
	docker run -it --rm -v "${PWD}":/app/ -w /app/documentation/diagrams/ mjdk/diagrams scripts/detailed_eks_diagram.py

.PHONY: init validate plan apply deploy uninstall destroy

