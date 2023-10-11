# Convert input data to proper format
locals {
  # Choose appropriate template of executable SQL script
  template_to_render = var.revoke_grants ? "destroy-script.sql.tpl" : "script.sql.tpl"

  # Values to be used while rendering the template
  template_variables = {
    affected_schema    = local.schema
    affected_tables    = local.tables
    granted_privileges = local.privileges
    group_role         = var.group_role
    db_owner           = var.database.owner
    admin_user         = var.host.username
    make_admin_own     = local.make_admin_own
  }

  # Render existing template of SQL scirpt
  sql_script = templatefile("${path.module}/${local.template_to_render}", local.template_variables)

  # Set the default schema if one isn't provided
  schema = length(var.schema) == 0 ? "public" : var.schema

  # Set all tables as default value in case of an empty list is provided
  tables_to_string = length(var.tables) == 0 ? "ALL" : join(",", var.tables)

  # If all schemas or all tables are specified grant privileges for all tables
  # otherwise concate all tables names into single string with schema as prefix
  # jsonencode is used to quote schema and each table name additionally to prevent issue with hyphen usage: 
  #   ['"schema_name"."table_name"', ...]
  tables = (
    local.schema == "ALL" || local.tables_to_string == "ALL" ? "ALL" :
    join(",", formatlist("${jsonencode(local.schema)}.%s", [
      for table in var.tables : jsonencode(table)
    ]))
  )

  # Set ALL as default value in case of an empty list of privileges is provided
  privileges = length(var.privileges) == 0 ? "ALL" : join(",", var.privileges)

  # Check if admin user must be granted with db owner role
  make_admin_own = (
    var.host.username != var.database.owner && var.make_admin_own ?
    "true" : "false"
  )
}

# Save rendered script to a file
resource "local_file" "rendered_script" {
  content         = local.sql_script
  filename        = "${path.module}/script-${var.database.name}.sql"
  file_permission = "0664"
}

# Execute rendered SQL script
resource "null_resource" "run_script" {
  triggers = {
    to_always_run_this = timestamp()
  }

  # Apply changes
  provisioner "local-exec" {
    command = "psql -f ${local_file.rendered_script.filename}"

    environment = {
      PGHOST     = var.host.host
      PGPORT     = var.host.port
      PGDATABASE = var.database.name
      PGUSER     = var.host.username
      PGPASSWORD = var.host.password
    }
  }
}

# Drop group role if there are no dependencies
resource "null_resource" "drop_role" {
  count = var.revoke_grants ? 1 : 0

  triggers = {
    to_always_run_this = timestamp()
  }

  provisioner "local-exec" {
    command    = "psql -c 'DROP ROLE ${var.group_role}'"
    on_failure = continue

    environment = {
      PGHOST     = var.host.host
      PGPORT     = var.host.port
      PGDATABASE = var.database.name
      PGUSER     = var.host.username
      PGPASSWORD = var.host.password
    }
  }

  # To prevent role removal before revoking granted privileges
  depends_on = [null_resource.run_script]
}
