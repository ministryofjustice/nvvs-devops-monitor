#!/usr/bin/env bash

## This script will generate .env file for use with the Makefile
## or to export the TF_VARS into the environment

set -x

get-environment-secrets() {
  local tag_name="supported-application-secret-for"
  local application_name="nvvs-devops-monitor"

  local tag_name2=supported-application-environment
  local environment=${1}

  local secrets
  local secret_value
  local tf_env
  local env_var
  local comment

  echo "" > ./.env.tmp

  secrets=$(aws secretsmanager list-secrets --no-cli-pager \
    --query "SecretList[].Name" \
    --filters Key=tag-key,Values=${tag_name} Key=tag-value,Values=${application_name} \
    --filters Key=tag-key,Values=${tag_name2} Key=tag-value,Values=${environment} \
    --output json | jq '.[]' --raw-output)

  for secret_id in ${secrets}
  do
    tf_env=$(aws secretsmanager describe-secret --secret-id ${secret_id} --query "Tags[?Key=='tf_var'].Value[]" --output text)
    env_var=$(aws secretsmanager describe-secret --secret-id ${secret_id} --query "Tags[?Key=='env_var'].Value[]" --output text)
    secret_value=$(aws secretsmanager get-secret-value --secret-id ${secret_id} --query "SecretString" --output text)

    [[ ! -z "${tf_env}" ]] && echo "${comment} export TF_VAR_${tf_env}=${secret_value}" >> ./.env.tmp
    [[ ! -z "${env_var}" ]] && echo "${comment} export ${env_var}=${secret_value}" >> ./.env.tmp
  done

  cat ./.env.tmp | sort >> ./.env
  rm ./.env.tmp
}

export ENV="${1:-development}"

printf "\n\nEnvironment is %s\n\n" "${ENV}"

case "${ENV}" in
    development)
        echo "development -- Continuing..."
        ;;
    pre-production)
        echo "pre-production -- Continuing..."
        ;;
    production)
        echo "production shouldn't really be running this locally."
        ;;
    *)
        echo "Invalid input."
        ;;
esac

echo "Press 'y' to continue or 'n' to exit."

# Wait for the user to press a key
read -s -n 1 key

# Check which key was pressed
case $key in
    y|Y)
        echo "You pressed 'y'. Continuing..."
        ;;
    n|N)
        echo "You pressed 'n'. Exiting..."
        exit 1
        ;;
    *)
        echo "Invalid input. Please press 'y' or 'n'."
        ;;
esac


cat << EOF > ./.env
# env file
# regenerate by running "./scripts/generate-env-file.sh"
# defaults to "development"
# To test against another environment
# regenerate by running "./scripts/generate-env-file.sh [pre-production | production]"
# Also run "make clean"
# then run "make init"


### ${ENV} ###
export ENV=${ENV}
export TF_VAR_env=${ENV}
EOF

assume_role_development_id="nvvs-devops-monitor/development/assume_role_arn"
assume_role_development=$(aws secretsmanager get-secret-value --secret-id ${assume_role_development_id} --query "SecretString" --output text)

assume_role_pre_production_id="nvvs-devops-monitor/pre_production/assume_role_arn"
assume_role_pre_production=$(aws secretsmanager get-secret-value --secret-id ${assume_role_pre_production_id} --query "SecretString" --output text)

cat << EOF >> ./.env
export TF_VAR_assume_role_development=${assume_role_development}
export TF_VAR_assume_role_pre_production=${assume_role_pre_production}
EOF


get-environment-secrets ${ENV}
chmod u+x ./.env

rm -rf .terraform/ terraform.tfstate*

printf "\n\n run \"make init\"\n\n"
