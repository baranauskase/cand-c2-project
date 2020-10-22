variable "region" {
     default = "eu-west-2"
}

variable "vpcCIDRblock" {
    default = "10.0.0.0/16"
}

variable "instanceTenancy" {
    default = "default"
}

variable "dnsSupport" {
    default = true
}
variable "dnsHostNames" {
    default = true
}

variable "availabilityZone" {
     default = "eu-west-2a"
}

variable "subnetCIDRblock" {
    default = "10.0.1.0/24"
}

variable "destinationCIDRblock" {
    default = "0.0.0.0/0"
}
variable "ingressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "egressCIDRblock" {
    type = list
    default = [ "0.0.0.0/0" ]
}
variable "mapPublicIP" {
    default = true
}
