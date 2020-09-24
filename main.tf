locals {
  tags = {
      projet      = "Demo"
      environment = "Dev"
    }
}

terraform {
  backend "azurerm" {
    resource_group_name   = "terraform-storage-westeurope"
    storage_account_name  = "terraformstorageaccount"
    container_name        = "terraform-azure-kubernetes-tfstate"
    key                   = "terraform.tfstate"
  }
}

# ======================================================================================
# Resource Group
# ======================================================================================
 resource "azurerm_resource_group" "tf-rg-aks-01" {
    name        = "${var.aks-resource-group-name}"
    location    = "${var.aks-resource-group-location}"
    tags        = "${local.tags}"
 }

# ======================================================================================
# Cluster kubernetes
# ======================================================================================
resource "azurerm_kubernetes_cluster" "cluster-aks" {
  name                    = "${var.aks-cluster-name}"
  location                = "${azurerm_resource_group.tf-rg-aks-01.location}"
  resource_group_name     = "${azurerm_resource_group.tf-rg-aks-01.name}"   
  kubernetes_version      = "1.18.8"
  dns_prefix              = "${var.aks-cluster-name}-dns"
  tags                    = "${local.tags}"
   
  default_node_pool {
    name                  = "default"
    vm_size               = "Standard_D2_v2"
    enable_auto_scaling   = false
    node_count            = 3
    availability_zones    = ["1", "2", "3"]
    type                  = "VirtualMachineScaleSets"
  }

  network_profile {
    network_plugin = "azure"
    load_balancer_sku = "standard"
  }

  service_principal {
    client_id     = "${var.aks-cluster-sp-client-id}"
    client_secret = "${var.aks-cluster-sp-client-secret}"
  }
}