## terraform-openshift-inventory

This is meant to be used as a module, make sure your module implementation sets all the variables in its terraform.tfvars file.

It creates a folder called `inventory_repo` and places a `hosts` and `inventory.cfg` file to be used for OpenShift installation



```terraform
module "inventory" {
    source                  = "git::ssh://git@github.ibm.com/ncolon/terraform-openshift-inventory.git"
    domain                  = "${var.domain}"
    bastion_private_ip      = "${module.infrastructure.bastion_private_ip}"
    master_private_ip       = "${module.infrastructure.master_private_ip}"
    master_public_ip        = "${module.infrastructure.master_public_ip}"
    infra_private_ip        = "${module.infrastructure.infra_private_ip}"
    infra_public_ip         = "${module.infrastructure.infra_public_ip}"
    app_private_ip          = "${module.infrastructure.app_private_ip}"
    storage_private_ip      = "${module.infrastructure.storage_private_ip}"
    master_hostname         = "${module.infrastructure.master_hostname}"
    infra_hostname          = "${module.infrastructure.infra_hostname}"
    app_hostname            = "${module.infrastructure.app_hostname}"
    storage_hostname        = "${module.infrastructure.storage_hostname}"
    master_count            = "${var.master_count}"
    infra_count             = "${var.infra_count}"
    app_count               = "${var.app_count}"
    storage_count           = "${var.storage_count}"
    ose_version             = "${var.ose_version}"
    ose_deployment_type     = "${var.ose_deployment_type}"
    image_registry          = "${var.image_registry}"
    image_registry_username = "${var.image_registry_username == "" ? var.rhn_username : ""}"
    image_registry_password = "${var.image_registry_password == "" ? var.rhn_password : ""}"
    master_cluster_hostname = "${module.infrastructure.public_master_vip}"
    cluster_public_hostname = "${var.master_cname}-${random_id.tag.hex}.${var.domain}"
    app_cluster_subdomain   = "${var.app_cname}-${random_id.tag.hex}.${var.domain}"
    letsencrypt             = "${var.letsencrypt}"
    registry_volume_size    = "${var.registry_volume_size}"
}
```

## Module Inputs Variables

|Variable Name|Description|Default Value|Type|
|-------------|-----------|-------------|----|
|domain|Custom domain for OpenShift|-|string|
|bastion_private_ip|Private IPv4 Address of Bastion Server|-|string|
|master_private_ip|Private IPv4 Address of Master Nodes|-|list|
|master_public_ip|Public IPv4 Address of Master Nodes|-|list|
|infra_private_ip|Private IPv4 Address of Infra Nodes|-|list|
|infra_public_ip|Public IPv4 Address of Infra Nodes|-|list|
|storage_private_ip|Private IPv4 Address of Storage Nodes|-|list|
|master_hostname|Hostnames of Master Nodes|-|list|
|infra_hostname|Hostnames of Infra Nodes|-|list|
|app_hostname|Hostnames of App Nodes|-|list|
|storage_hostname|Hostnames of Storage Nodes|-|list|
|master_count|Number of Master Nodes|-|int|
|infra_count|Number of Infra Nodes|-|int|
|app_count|Number of App Nodes|-|int|
|storage_count|Number of Storage Nodes|-|int|
|ose_version|Version of OpenShift to install|3.11|string|
|ose_deployment_type|OpenShift Product Type|openshift-enterprise|string|
|image_registry|Image registry to pull installation images from|registry.redhat.io|string|
|image_registry_username|Username for image registry|-|string|
|image_registry_password|Password for image registry|-|string|
|image_registry_path|Path for OSE regirty|/openshift3/ose-$${component}:$${version}|string|
|master_cluster_hostname|Complete CNAME for master VIP Ex.:`master-ibm-5e5fd6c5.ncolon.xyz`|-|string|
|cluster_public_hostname|VIP of master loadbalancer Ex.:`ncolon-ocp-master-76fbf24d-625675-wdc04.clb.appdomain.cloud`|-|string|
|app_cluster_subdomain|Complete CNAME for apps VIP Ex.:`apps.master-ibm-5e5fd6c5.ncolon.xyz`|-|string|
|letsencrypt|If set to true, pushes certificates to master server|false|bool|
|registry_volume_size|Registry Size in GB|100|int|
|pod_network_cidr|CIDR Network for Pods|10.128.0.0/14|string|
|service_network_cidr|Network CIDR for Services|172.30.0.0/16|string|
|host_subnet_length|Host subnet length|9|int|
|openshift_identity_provider|String for Identity Provider|openshift_master_htpasswd_users={'admin': '$apr1$qSzqkDd8$fU.yI4bV8KmXD9kreFSL//'} `admin/admin`|string|


## Module Output
This module produces no terraform output.  

----
