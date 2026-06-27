#!/usr/bin/env bash
# Deploys the lab using your currently-active Azure subscription
# (set via `az login` / `az account set`). To pin a specific subscription,
# export ARM_SUBSCRIPTION_ID before running this script.

# local state (terraform.tfstate in this folder) - no remote backend
terraform init

# run terraform with whatever args you pass (plan / apply / destroy)
terraform "$@"
