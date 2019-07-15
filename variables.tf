variable "bastion_private_ip" {

}

variable "master_private_ip" {
  type = "list"

}

variable "master_public_ip" {
  type = "list"

}

variable "infra_private_ip" {
   type = "list"

}

variable "infra_public_ip" {
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

variable "master_count" {

}

variable "infra_count" {

}

variable "app_count" {

}

variable "storage_count" {

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

variable "master_key_file" {
    default = ""
}

variable "letsencrypt" {
    default = false
}

variable "master_cert_file" {
    default = ""
}

variable "registry_volume_size" {
    default = "100"
}
