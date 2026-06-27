variable "resource_group_name" {
  description = "Name of the Azure resource group to create."
  type        = string
  default     = "lab-5"
}

variable "location" {
  description = "Azure region where resources will be deployed."
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default = {
    environment = "learning"
    project     = "ad-lab"
    managed_by  = "terraform"
  }
}

variable "vm_size" {
  description = "Azure VM size/SKU. Windows Server + AD DS needs at least ~4 GB RAM."
  type        = string
  default     = "Standard_B2s" # 2 vCPU / 4 GB - good for a lab DC
}

variable "admin_username" {
  description = "Local admin username for the VM (cannot be 'admin' or 'administrator')."
  type        = string
  default     = "azureadmin"
}

variable "admin_password" {
  description = "Local admin password. 12-123 chars, 3 of: upper, lower, digit, symbol. Terraform will prompt if unset."
  type        = string
  sensitive   = true
}

variable "allowed_rdp_source_cidr" {
  description = "Source IP/CIDR allowed to RDP in. Set to your public IP in terraform.tfvars."
  type        = string
  default     = "*" # WARNING: '*' = open to the whole internet; override in tfvars
}
