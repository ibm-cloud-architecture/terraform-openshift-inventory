#--------------------------------#
#--------------------------------#

data "template_file" "master_block" {
  count = "${var.master_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-master'"
  vars {
   hostname = "${element(var.master_hostname, count.index)}.${var.domain}"
   ip = "${element(var.master_private_ip, count.index)}"
  }
}

data "template_file" "infra_block" {
  count = "${var.infra_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-infra'"
  vars {
   hostname = "${element(var.infra_hostname, count.index)}.${var.domain}"
   ip = "${element(var.infra_private_ip, count.index)}"
  }
}

data "template_file" "compute_block" {
  count = "${var.app_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-compute'"
  vars {
   hostname = "${element(var.app_hostname, count.index)}.${var.domain}"
   ip = "${element(var.app_private_ip, count.index)}"
  }
}

data "template_file" "gluster_block" {
  count = "${var.storage_count}"
  template = "$${hostname} glusterfs_ip=$${hostip} glusterfs_devices='[ \"/dev/dm-0\", \"/dev/dm-1\", \"/dev/dm-2\" ]' openshift_node_group_name='node-config-compute'"
  vars {
   hostname = "${element(var.storage_hostname, count.index)}.${var.domain}"
   hostip = "${element(var.storage_private_ip, count.index)}"
  }
}


# ansible inventory file
data "template_file" "ansible_hosts" {
  template = <<EOF
[OSEv3:children]
masters
etcd
nodes
${var.storage_count == 0 ? "" : "glusterfs"}

[OSEv3:vars]
ansible_user=root
openshift_deployment_type=${var.ose_deployment_type}
openshift_release=v${var.ose_version}
containerized=true
openshift_use_crio=false

os_sdn_network_plugin_name=redhat/openshift-ovs-networkpolicy
osm_cluster_network_cidr=${var.pod_network_cidr}
openshift_portal_net=${var.service_network_cidr}
osm_host_subnet_length=${var.host_subnet_length}

openshift_master_api_port=443
openshift_master_console_port=443
os_firewall_use_firewalld=true
# disable docker_storage check on non-rhel since the python-docker library cannot connect to docker for some reason
openshift_disable_check=docker_storage,docker_image_availability,package_version

oreg_url=${var.image_registry}${var.image_registry_path}
oreg_auth_user=${var.image_registry_username}
oreg_auth_password=${var.image_registry_password}

oreg_test_login=false
openshift_certificate_expiry_fail_on_warn=false
# master console
openshift_master_cluster_method=native
openshift_master_cluster_hostname=${var.master_cluster_hostname}
openshift_master_cluster_public_hostname=${var.cluster_public_hostname}
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_htpasswd_users={'admin': '$apr1$qSzqkDd8$fU.yI4bV8KmXD9kreFSL//'}
# if we're using oidc, and it uses a trusted cert, we can use the system truststore
openshift_master_openid_ca_file=/etc/ssl/certs/ca-bundle.crt

${var.letsencrypt ? "
openshift_master_named_certificates=[{'certfile': '/root/master.crt', 'keyfile': '/root/master.key', 'names': ['${var.cluster_public_hostname}']}]
openshift_master_overwrite_named_certificates=true" : ""}

# router
openshift_master_default_subdomain=${var.app_cluster_subdomain}
${var.letsencrypt ? "openshift_hosted_router_certificate={'certfile': '/root/router.crt', 'keyfile': '/root/router.key', 'cafile': '/root/router_ca.crt'}" : ""}
# cluster console
openshift_console_install=true
${var.letsencrypt ? "openshift_console_cert=/root/router.crt
openshift_console_key=/root/router.key" : ""}
# registry certs
openshift_hosted_registry_routehost=registry.${var.app_cluster_subdomain}
${var.letsencrypt ? "openshift_hosted_registry_routetermination=reencrypt
openshift_hosted_registry_routecertificates={'certfile': '/root/router.crt', 'keyfile': '/root/router.key', 'cafile': '/root/router_ca.crt'}" : "" }
${var.storage_count == 0 ? "" : "openshift_hosted_registry_storage_kind=glusterfs
openshift_hosted_registry_storage_volume_size=${var.registry_volume_size}Gi
openshift_storage_glusterfs_block_deploy=true
openshift_storage_glusterfs_block_storageclass=true
openshift_storage_glusterfs_storageclass=true
openshift_storage_glusterfs_storageclass_default=true
"}
# gluster images
openshift_storage_glusterfs_image=${var.image_registry}/rhgs3/rhgs-server-rhel7:v3.11
openshift_storage_glusterfs_block_image=${var.image_registry}/rhgs3/rhgs-gluster-block-prov-rhel7:v3.11
openshift_storage_glusterfs_s3_image=${var.image_registry}/rhgs3/rhgs-s3-server-rhel7:v3.11
openshift_storage_glusterfs_heketi_image=${var.image_registry}/rhgs3/rhgs-volmanager-rhel7:v3.11
# monitoring
openshift_cluster_monitoring_operator_install=true
openshift_cluster_monitoring_operator_prometheus_storage_enabled=true
openshift_cluster_monitoring_operator_prometheus_storage_class_name=glusterfs-storage
openshift_cluster_monitoring_operator_alertmanager_storage_enabled=true
openshift_cluster_monitoring_operator_alertmanager_storage_class_name=glusterfs-storage
openshift_cluster_monitoring_operator_node_selector={"node-role.kubernetes.io/infra":"true"}
# metrics
openshift_metrics_install_metrics=true
openshift_metrics_cassandra_storage_type=dynamic
openshift_metrics_cassandra_pvc_storage_class_name=glusterfs-storage
# logging
openshift_logging_install_logging=true
openshift_logging_es_pvc_dynamic=true
openshift_logging_es_pvc_storage_class_name=glusterfs-storage
openshift_logging_es_pvc_size=20Gi
openshift_logging_es_ops_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
openshift_logging_es_cluster_size=${var.infra_count}

[masters]
${join("\n", formatlist("%v.%v",
var.master_hostname,
var.domain))}

[etcd]
${join("\n", formatlist("%v.%v etcd_ip=%v",
var.master_hostname,
var.domain,
var.master_private_ip))}

${var.storage_count == 0 ? "" : "[glusterfs]
${join("\n", formatlist("%v.%v glusterfs_devices='[ \"/dev/dm-0\", \"/dev/dm-1\", \"/dev/dm-2\" ]' openshift_node_group_name='node-config-compute'",
var.storage_hostname,
var.domain))}"}

[nodes]
${join("\n", formatlist("%v.%v openshift_node_group_name=\"node-config-master\"",
var.master_hostname,
var.domain))}
${join("\n", formatlist("%v.%v openshift_node_group_name=\"node-config-infra\"",
var.infra_hostname,
var.domain))}
${join("\n", formatlist("%v.%v openshift_node_group_name=\"node-config-compute\"",
var.app_hostname,
var.domain))}
${var.storage_count == 0 ? "" : "${join("\n", formatlist("%v.%v openshift_schedulable=True openshift_node_group_name=\"node-config-compute\"",
var.storage_hostname,
var.domain))}"}
EOF
}

# Create a installer config file for openshift installation
resource "local_file" "ose_inventory_file" {
  content     =  "${data.template_file.ansible_hosts.rendered}"
  filename    = "${path.cwd}/inventory_repo/inventory.cfg"
}


#--------------------------------#
#--------------------------------#

# Create host file
data "template_file" "master_host_file_template" {
  count = "${var.master_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip              = "${element(var.master_private_ip, count.index)}"
    master_hostname        = "${element(var.master_hostname, count.index)}"
    master_hostname_domain = "${element(var.master_hostname, count.index)}.${var.domain}"
  }
}

data "template_file" "master_public_host_file_template" {
  count = "${var.master_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip              = "${element(var.master_public_ip, count.index)}"
    master_hostname        = "${element(var.master_hostname, count.index)}"
    master_hostname_domain = "${element(var.master_hostname, count.index)}.${var.domain}"
  }
}

data "template_file" "app_host_file_template" {
  count = "${var.app_count}"
  template = "$${app_ip} $${app_hostname} $${app_hostname_domain} "
  vars {
    app_ip              = "${element(var.app_private_ip, count.index)}"
    app_hostname        = "${element(var.app_hostname, count.index)}"
    app_hostname_domain = "${element(var.app_hostname, count.index)}.${var.domain}"
  }
}

data "template_file" "infra_host_file_template" {
  count = "${var.infra_count}"
  template = "$${infra_ip} $${infra_hostname} $${infra_hostname_domain} "
  vars {
    infra_ip              = "${element(var.infra_private_ip, count.index)}"
    infra_hostname        = "${element(var.infra_hostname, count.index)}"
    infra_hostname_domain = "${element(var.infra_hostname, count.index)}.${var.domain}"
  }
}

data "template_file" "storage_host_file_template" {
  count = "${var.storage_count}"
  template = "$${storage_ip} $${storage_hostname} $${storage_hostname_domain} "
  vars {
    storage_ip              = "${element(var.storage_private_ip, count.index)}"
    storage_hostname        = "${element(var.storage_hostname, count.index)}"
    storage_hostname_domain = "${element(var.storage_hostname, count.index)}.${var.domain}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "host_file_render" {
    # content     = "${join("\n", concat(data.template_file.master_host_file_template.*.rendered,data.template_file.infra_host_file_template.*.rendered,data.template_file.app_host_file_template.*.rendered,data.template_file.master_public_host_file_template.*.rendered,data.template_file.storage_host_file_template.*.rendered))}"
    content     = "${join("\n", concat(data.template_file.master_host_file_template.*.rendered,data.template_file.infra_host_file_template.*.rendered,data.template_file.app_host_file_template.*.rendered,data.template_file.storage_host_file_template.*.rendered))}"
    filename    = "${path.root}/inventory_repo/hosts"
}