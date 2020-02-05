resource "null_resource" "postgresql-read-replica" {
  triggers = {
    resource_group_name            = var.resource_group_name
    postgresql_primary_server_name = var.postgresql_primary_server_name
    postgresql_replica_server_name = var.postgresql_replica_server_name
  }

  # create replica
  provisioner "local-exec" {
    command = <<CREATE_REPLICA
az postgres server replica create \
  --name ${self.triggers.postgresql_replica_server_name} \
  --source-server ${self.triggers.postgresql_primary_server_name} \
  --resource-group ${self.triggers.resource_group_name}
CREATE_REPLICA
  }

  provisioner "local-exec" {
    when = destroy
    command = <<DESTROY_REPLICA
az postgres server delete \
  --name ${self.triggers.postgresql_replica_server_name} \
  --resource-group ${self.triggers.resource_group_name} \
  --yes
DESTROY_REPLICA
  }
}
