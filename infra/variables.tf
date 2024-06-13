variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "application_name" {
  type = string
  #   default = "sample-api"
  default = "tum-tf-test"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "container_image_uri" {
  type    = string
  default = "tumbone/sample-customer-api:latest"
}
variable "container_port" {
  type    = number
  default = 3000
}
variable "host_port" {
  type    = number
  default = 3000
}
variable "container_command" {
  type    = list(string)
  default = []
}
variable "container_entry_point" {
  type    = list(string)
  default = []
}
variable "inbound_port" {
  type = number
  default = 80
}