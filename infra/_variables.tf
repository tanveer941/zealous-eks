variable "ProjectName" {
  type = string
  default = null
}
variable "ClusterName" {}
variable "GroupName" {}
variable "OwnerName" {}
variable "Moniker" {}
variable "AWSProfile" {
  type = string
  default = "default"
}
variable "Vpc" {}
variable "Subnet1" {}
variable "Subnet2" {}


locals {
  common_tags = {
    group_name: var.GroupName
    owner_name: var.OwnerName
    "adsk:moniker": var.Moniker
  }
}
