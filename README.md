# Terraform module: grant privileges on table
Module is used for granting privileges on specified tables.

## Specs
Some variables have default values, thus could be omitted. Look at the description in *Inputs* section below.

## Usage example
```
module "grant_on_some_tables" {
  source = "github.com/antonvigo/pg-iac-grant-table"

  host = {
    host             = "pg.host.com"
    port             = 5432
    username         = "root"
    password         = "Password123"
  }

  database = {
    name  = "some_db"
    owner = "some_db_admin"
  }

  schema         = "public"
  tables         = []
  privileges     = ["UPDATE","SELECT"]
  group_role     = "new_group_role"
  make_admin_own = false
  revoke_grants  = false

  depends_on = [module.last_existing_privileges_module_call]
}
```
* It's strongly recommended to replace input constants with predefined variables containing corresponding values.
* Even if empty list of privilegs is provided all possbile privileges will be granted. Same way for some other variables.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.rendered_script](https://registry.terraform.io/providers/hashicorp/local/2.4.0/docs/resources/file) | resource |
| [null_resource.drop_role](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |
| [null_resource.run_script](https://registry.terraform.io/providers/hashicorp/null/3.2.1/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database"></a> [database](#input\_database) | Database to manage permissions at | <pre>object({<br>    name  = string,<br>    owner = string<br>  })</pre> | n/a | yes |
| <a name="input_group_role"></a> [group\_role](#input\_group\_role) | Group role to be granted with specified privileges | `string` | `""` | no |
| <a name="input_host"></a> [host](#input\_host) | RDS connection data | <pre>object({<br>    host     = string<br>    port     = number<br>    username = string<br>    password = string<br>  })</pre> | n/a | yes |
| <a name="input_make_admin_own"></a> [make\_admin\_own](#input\_make\_admin\_own) | Is it necessary to grant admin user to database owner role or not. It is in case of RDS, because standard root account isn't a superuser. | `bool` | `true` | no |
| <a name="input_privileges"></a> [privileges](#input\_privileges) | Granted privileges, default value is 'ALL'. The value of 'ALL' can be specified | `list(string)` | <pre>[<br>  "ALL"<br>]</pre> | no |
| <a name="input_revoke_grants"></a> [revoke\_grants](#input\_revoke\_grants) | Revoke all grants which were provided by this module just before or not | `bool` | `false` | no |
| <a name="input_schema"></a> [schema](#input\_schema) | New privileges will be granted on tables from this database schema, default value is 'public'. In case of 'ALL' value specified privileges will be granted for all tables in all schemas no matter what consists in var.tables | `string` | `"public"` | no |
| <a name="input_tables"></a> [tables](#input\_tables) | List of tables within current schema for which specified privileges will be granted, default value is 'ALL'. There is no need to set schema as prefix | `list(string)` | <pre>[<br>  "ALL"<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_grants_to_group"></a> [grants\_to\_group](#output\_grants\_to\_group) | List of granted privileges for specified role |
| <a name="output_sql_script"></a> [sql\_script](#output\_sql\_script) | Applied SQL script |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
