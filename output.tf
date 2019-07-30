output "admin_password" {
    value = "${var.admin_password}"
}


resource "random_id" "completed" {
    byte_length = 1
    depends_on = [
        "local_file.ose_inventory_file",
        "local_file.host_file_render",
        "null_resource.copy_repo_bastion",
        "null_resource.copy_repo_master",
        "null_resource.copy_repo_infra",
        "null_resource.copy_repo_app",
        "null_resource.copy_repo_storage",
    ]
}

output "completed" {
    value = "${random_id.completed.hex}"
}
