#!/bin/bash

# This script will run create the neccesary namespaces and add the docker service account to the required namespace.

# Naming Variables
RESOURECE_GROUP="gw-icap-neu-test-storage-01"
VAULT_NAME="icap-qa-test-keyvault-01"

# Secret Variables
DOCKER_SERVER="https://index.docker.io/v1/"
USER_EMAIL="mpigram@glasswallsolutions.com"
DOCKER_USERNAME=$(az keyvault secret show --name DH-SA-USERNAME --vault-name $VAULT_NAME --query value -o tsv)
DOCKER_PASSWORD=$(az keyvault secret show --name DH-SA-password --vault-name $VAULT_NAME --query value -o tsv)
FILESHARE_ACCOUNT_NAME=$(az storage account list -g $RESOURECE_GROUP --query "[].name" | awk 'FNR == 2' | tr -d '"[]\040')
FILESHARE_KEY=$(az storage account keys list -g $RESOURECE_GROUP -n $FILESHARE_ACCOUNT_NAME --query "[].value" | awk 'FNR == 2' | tr -d '",\040')
TOKEN_USERNAME=$(az keyvault secret show --name token-username --vault-name $VAULT_NAME --query value -o tsv)
TOKEN_PASSWORD=$(az keyvault secret show --name token-password --vault-name $VAULT_NAME --query value -o tsv)
TOKEN_SECRET=$(az keyvault secret show --name token-secret --vault-name $VAULT_NAME --query value -o tsv)
TRANSACTION_CSV=$(az storage account show-connection-string -g $RESOURECE_GROUP -n $FILESHARE_ACCOUNT_NAME --query connectionString | tr -d '"')

# Namspace Variables
NAMESPACE01="icap-adaptation"
NAMESPACE02="icap-prometheus-stack"
NAMESPACE03="icap-ncfs"
NAMESPACE04="icap-administration"
NAMESPACE05="icap-rabbit-operator"

# Create namespaces for deployment
kubectl create ns $NAMESPACE01
kubectl create ns $NAMESPACE02
kubectl create ns $NAMESPACE03
kubectl create ns $NAMESPACE04
kubectl create ns $NAMESPACE05

# Create secret for Docker Registry - this only needs to be added to the 'icap-adaptation' and 'icap-administration' namespaces
kubectl create -n $NAMESPACE01 secret docker-registry regcred \
	--docker-server=$DOCKER_SERVER \
	--docker-username=$DOCKER_USERNAME \
	--docker-password="$DOCKER_PASSWORD" \
	--docker-email=$USER_EMAIL

# Create secret for Docker Registry - this only needs to be added to the 'icap-adaptation' and 'icap-administration' namespaces
kubectl create -n $NAMESPACE04 secret docker-registry containerregistry \
	--docker-server=$DOCKER_SERVER \
	--docker-username=$DOCKER_USERNAME \
	--docker-password="$DOCKER_PASSWORD" \
	--docker-email=$USER_EMAIL

# Create secrets for the 'icap-adaptation' namespace
kubectl create -n $NAMESPACE01 secret generic policyupdateservicesecret --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

kubectl create -n $NAMESPACE01 secret generic ncfspolicyupdateservicesecret --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

kubectl create -n $NAMESPACE01 secret generic transactionstoresecret --from-literal=azurestorageaccountname=$FILESHARE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$FILESHARE_KEY

kubectl create -n $NAMESPACE01 secret generic transactionqueryservicesecret --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

# Create secret for file share - needs to be part of the 'icap-administration' namespace

kubectl create -n $NAMESPACE04 secret generic policyupdateserviceref --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD 

kubectl create -n $NAMESPACE04 secret generic userstoresecret --from-literal=azurestorageaccountname=$FILESHARE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$FILESHARE_KEY

kubectl create -n $NAMESPACE04 secret generic identitymanagementservicesecrets --from-literal=TokenSecret=$TOKEN_SECRET

kubectl create -n $NAMESPACE04 secret generic policystoresecret --from-literal=azurestorageaccountname=$FILESHARE_ACCOUNT_NAME --from-literal=azurestorageaccountkey=$FILESHARE_KEY

kubectl create -n $NAMESPACE04 secret generic transactionqueryserviceref --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

kubectl create -n $NAMESPACE04 secret generic ncfspolicyupdateserviceref --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

# Create secret for file share - needs to be part of the 'icap-ncfs' namespace
kubectl create -n $NAMESPACE03 secret generic ncfspolicyupdateservicesecret --from-literal=username=$TOKEN_USERNAME --from-literal=password=$TOKEN_PASSWORD

# Create secret for TLS certs & keys - needs to be part of the 'icap-adaptation' namespace
kubectl create -n $NAMESPACE01 secret tls icap-service-tls-config --key tls.key --cert certificate.crt