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

***You do not need to enter any text when you run this command, you can press enter until it completes***

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

***Please make sure you're using the correct context when running this script***

Run the script below to install the charts via helm on both clusters

```bash
./script/install-helm-charts/install-charts.sh
```

If you wish to use a different branch of the `icap-infrastructure` repo, then you will need to `cd` into the submodule within this repo and use the following:

```bash
git checkout <branch name>
```

Then all you need to do is run the script above and it will deploy that branch of `icap-infrastructure`.

### ***Specify a path that isn't in the script***

You have two options here, you can deploy manually with `helm install` or add to the script. To add it to the script use the following:

The basic command for the `helm install` within the script is below

```bash
(cd $DIRECTORY; helm install $NCFS -n $NAMESPACE03 --generate-name --set secrets=null)
```

If you need to deploy to a different `namespace` and a different chart or either, then you need to add the following variables to the script:

***Path and Namespace - see below***

```bash
# Namespaces
NAMESPACE01="icap-adaptation"
NAMESPACE02="icap-administration"
NAMESPACE03="icap-ncfs"
NAMESPACE04="icap-rabbit-operator" 
NAMESPACE05="icap-central-monitoring"
NAMESPACE06="NEW NAME SPACE HERE"

# Chart file path
ADAPTATION="./adaptation"
ADMINISTRATION="./administration"
NCFS="./ncfs"
RABBIT_OP="./rabbitmq-operator"
MONITORING=
NEW_FILE_PATH="NEW CHART PATH HERE"
```

Finally you will need to add another layer of the `helm install` commands like below, including the new clusters context. See below for exaple:

```bash
kubectl config use-context <new context here>

# Deploy charts
(cd $DIRECTORY; helm install $RABBIT_OP -n $NAMESPACE04 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $ADAPTATION -n $NAMESPACE01 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $ADMINISTRATION -n $NAMESPACE02 --generate-name --set secrets=null)
echo ""
(cd $DIRECTORY; helm install $NCFS -n $NAMESPACE03 --generate-name --set secrets=null)
```

Once updated then you can save the script and execute it again to add the new chart.

### ***Command to install new chart manually***

If you wish to just install a chart as a one off or do not want to add it to the script, then use the below:

```bash
helm install ./<path to chart> --generate-name -n <namespace>
```

This will deploy a single helm chart from the specified path and to the specified namesace.

### Destroying the clusters

You can use `terraform destroy` to take down all modules. Be careful with this as it will destroy every module that has been deployed. 

To combat this you can use `-target=module` after the `terraform destroy` - this will target only modules that you have specified:

```bash
terraform destroy -target=module.create_aks_cluster_UKSouth.azurerm_kubernetes_cluster.icap-deploy -target=module.create_aks_cluster_NEU.azurerm_kubernetes_cluster.icap-deploy
```

Type yes and then wait for terraform to complete the destruction of the clusters

### Creating more infrastructure

Adding more clusters is fairly simple and can be done quite quickly.

#### A quick breakdown of modules:

The `main.tf` contains all of the individual modules that will deploy the following:

- Clusters
- Storage accounts
- Keyvaults

Each part of the module code needs to have a module name, and a path to the module, like below:

```bash
module "create_aks_cluster_UKSouth" {
	source						="./modules/clusters/qa-neu-01"
}
```

This tells Terraform where to find the terraform code to deploy the infrastructure. 

#### Add another cluster

To add another cluster first you need to create a new folder within `modules/clusters` and then copy the following files across from another cluster:

- main.tf
- outputs.tf
- variables.tf

The only part of the code you need to change is the variables within the `variables.tf` file. The following will need to be unique:

- Resource Group
- Region
- Cluster Name

Once this has been done, you need to add the module name and path to the `main.tf` file in the root directory.

```bash
module "create_aks_cluster_<regon>" {
	source						="./modules/clusters/<new module here>"
}
```

#### Adding storage accounts

To add another storage account first you need to create a new folder within `modules/storage-accounts` and then copy the following files across from another cluster:

- main.tf
- outputs.tf
- variables.tf

The only part of the code you need to change is the variables within the `variables.tf` file. The following will need to be unique:

- Resource Group
- Region

Once this has been done, you need to add the module name and path to the `main.tf` file in the root directory.

```bash
module "create_aks_cluster_<regon>" {
	source						="./modules/clusters/<new module here>"
}
```

#### Adding key vaults

To add another keyvault first you need to create a new folder within `modules/keyvaults` and then copy the following files across from another cluster:

- main.tf
- variables.tf

The only part of the code you need to change is the variables within the `variables.tf` file. The following will need to be unique:

- Resource Group
- Region
- KV name

Once this has been done, you need to add the module name and path to the `main.tf` file in the root directory.

```bash
module "create_aks_cluster_<regon>" {
	source						="./modules/keyvaults/<new module here>"
}
```

#### Adding the new clusters/storage accounts/keyvaults to scripts

The scripts that you run to add the secrets to the keyvault, add secrets to the clusters and deploy the helm charts, will need to be updated.

The scripts that need to be updated are as follows:

- k8-add-secrets
- create-az-screts.sh

#### Updating create-az-secrets.sh

So first of all you need to know the name of the new keyvault you created. Next open up the script within `./scripts/secrets/create-az-secrets.sh`.

You will need to add a variable to `Vault Variables` this is for the keyvault. Next you need to add a whole new row of `az keyvault set` commands below the current ones. See example of commandsd here:

```bash
# AZ Command to set Secrets
az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME01 --value $DOCKER_USERNAME

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME02 --value $DOCKER_PASSWORD

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME03 --value $TOKEN_USERNAME

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME04 --value $TOKEN_PASSWORD

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME05 --value $TOKEN_SECRET

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME06 --value $ENCRYPTION_SECRET

az keyvault secret set --vault-name $NEU_VAULT --name $SECRET_NAME07 --value $MANAGEMENT_ENDPOINT
```

Once you've pasted the new commands then you need to replace the vault name variable (example of above is $NEU_VAULT) with the new vault name variable you added at the start.

Next run the script and the secrets will be populated in the new keyvault.

#### Updating k8-add-secrets

First you'll need to create a new folder within `./scripts/k8-add-secrets` and then copy the script from one of the other folders.

The only varibles within the scripts you need to change are the following:

- RESOURCE_GROUP (This is the resource group for the storage account)
- VAULT_NAME

These two variables will tell the rest of the commands where to get the secrets from.

Once this has been updated you can run the script to add the secrets, and create the namespaces on the clusters

### DNS Work Around

When you deploy multiple clusters into the same region there may become an issue with the DNS name being in use. We do not have an automated way of updated this at the moment but thankfully there is an easy work around.

Once you have deployed the new charts onto the cluster, the easiest way to check if the dns name is valid or not is to run the following:

```bash
kubectl get svc -A
```

Once you've run this, look for `frontend-icap-lb` and if this has a public IP, then the dns name for that region will work. If it doesn't have a public IP, then you need to follow the steps below to add it.

Firstly you need to run the command below:

```bash
kubectl edit svc -n icap-adaptation frontend-icap-lb
```

Next find the following line:

```yaml
service.beta.kubernetes.io/azure-dns-label-name: icap-client-main
```

No change the value after client to what ever you like `icap-client-test-neu` for example.

Next save the changes and exit.

Now when you check on the service you should see if has a public IP and when you go use the new DNS name it should resolve.

The same can be done for the management ui you just need to use the following command to edit the service:

```bash
kubectl edit svc -n icap-administration icap-management-ui-service
```

And then change the following line:

```yaml
service.beta.kubernetes.io/azure-dns-label-name: icap-client-main
```






