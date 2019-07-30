
variable "master_private_ip" {
  type = "list"
}

variable "dnscerts" {
    default = false
}

variable "infra_private_ip" {
   type = "list"
}


variable "app_private_ip" {
   type = "list"
}

variable "storage_private_ip" {
   type = "list"
}

variable "master_hostname" {
   type = "list"
}

variable "infra_hostname" {
   type = "list"

}

variable "app_hostname" {
   type = "list"

}

variable "storage_hostname" {
   type = "list"

}


variable "domain" {

}

variable os_reference_code {
    default = "REDHAT_7_64"
}

variable "ose_version" {
    default = "3.11"
}

variable "ose_deployment_type" {
    default = "openshift-enterprise"
}

variable "pod_network_cidr" {
    default = "10.128.0.0/14"
}

variable "service_network_cidr" {
     default = "172.30.0.0/16"
}

variable "host_subnet_length" {
    default = 9
}

variable "image_registry" {
  default = "registry.redhat.io"
}

variable "image_registry_path" {
   default = "/openshift3/ose-$${component}:$${version}"
}

variable "image_registry_username" {}
variable "image_registry_password" {}
variable "master_cluster_hostname" {}
variable "app_cluster_subdomain" {}
variable "cluster_public_hostname" {}
variable "openshift_identity_provider" {
    default = "openshift_master_htpasswd_users={'admin': '$apr1$qSzqkDd8$fU.yI4bV8KmXD9kreFSL//'}"
}

variable "registry_volume_size" {
    default = "100"
}

variable "ssh_username" {
    default = "root"
}

variable "cloudprovider" {
    default = "ibm"
}


variable "bastion_ip_address" {}
variable "bastion_hostname" {}
variable "bastion_private_ssh_key" {}

variable "bastion" {type = "map"}
variable "master"  {type = "map"}
variable "infra"   {type = "map"}
variable "worker"  {type = "map"}
variable "storage" {type = "map"}

variable "haproxy" {
    default = false
}

variable "admin_password" {
    default = "admin"
}

variable "dependencies" {
    type = "list"
    default = []
}
