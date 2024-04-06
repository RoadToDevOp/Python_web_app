variable "resource_group_name" {
  default = "python_web_app"
}

variable "resource_group_location" {
  default = "uksouth"
}

variable "web_vm_name" {
  default = "default_web_vm_name"
}

variable "app_vm_name" {
  default = "default_app_vm_name"
}

variable "vm_name" {
  default = "B1s"
}

variable "CIDR" {
  default = ["192.168.0.1/24"]
}