# Backend Storage for Statefile
terraform {
  backend "azurerm" {
	resource_group_name  = "gw-icap-tfstate"
    storage_account_name = "tfstate263"
    container_name       = "gw-icap-tfstate"
    key                  = "qa.terraform.tfstate"
  }
}

# Cluster Modules
module "create_aks_cluster_UKSouth" {
	source						="./modules/clusters/qa-neu-01"
}

module "create_aks_cluster_NEU" {
	source						="./modules/clusters/qa-uks-02"
}

# Key Vault Modules
module "create_key_vault_NEU" {
	source						="./modules/keyvaults/keyvault-neu-01"
}

module "create_key_vault_UKSouth" {
	source						="./modules/keyvaults/keyvault-uks-02"
}

# Storage Account Modules
module "create_storage_account_NEU" {
	source						="./modules/storage-accounts/storage-account-neu-01"
}

module "create_storage_account_UKSouth" {
	source						="./modules/storage-accounts/storage-account-uks-02"
}


