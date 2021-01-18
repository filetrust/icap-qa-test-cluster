# icap-qa-test-cluster

Purpose of this repo is to create a test environment for the QA team, so that create and destroy clusters with ease and when ever they want to.

There should be no manual processes outside of running scripts.

### Prerequisites

The following utilities need to be installed:

- Terraform
- Kubectl
- Helm
- WSL (Linux)
- Az Cli

### Guide to Terraform deployment

***ALL FOLLOWING COMMANDS NEED TO BE RUN IN THE ROOT DIRECTORY***

You will need to do the following:

```bash
terraform init
```

```bash
terraform apply
```

Type yes to apply the changes and deploy the clusters. Wait for the deployment to finish before moving onto the next step.

### Add secrets to keyvault

You will then need to add the secrets to the keyvault, which are needed for the K8s cluster. Use the following script

```bash
./script/secrets/create-az-secrets.sh
```

### Create namespaces and add secrets

Use the following script to create namespaces and add the necessary secrets.

Before you run the following script you need to be using the correct context:

Kubectl contexts

```
az aks get-credentials --resource-group icap-aks-qa-test-neu-01 --name gw-icap-qa-neu-01

az aks get-credentials --resource-group icap-aks-qa-test-uks-02 --name gw-icap-qa-uks-02
```

You will also need to generate a TLS key and a cert, use the following command:

***You do not need to enter any text when you run this command, you can press enter until it executes***

```bash
openssl req -newkey rsa:2048 -nodes -keyout tls.key -x509 -days 365 -out certificate.crt
```

NEU Secret Script
```bash
./scripts/k8-add-secrets/neu/create-ns-docker-secret-neu.sh
```
UKS Secret Script
```bash
./scripts/k8-add-secrets/uks/create-ns-docker-secret-uks.sh
```

### Install charts via Helm

You need to run this script on both contexts in order to deploy the services for the icap client and UI:

```bash
./script/install-helm-charts/install-charts.sh
```

