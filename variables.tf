variable "host" {
  description = "RDS connection data"
  type = object({
    host     = string
    port     = number
    username = string
    password = string
  })
}

variable "database" {
  description = "Database to manage permissions at"
  type = object({
    name  = string,
    owner = string
  })
}

variable "schema" {
  description = "New privileges will be granted on tables from this database schema, default value is 'public'. In case of 'ALL' value specified privileges will be granted for all tables in all schemas no matter what consists in var.tables"
  type        = string
  default     = "public"
}

variable "tables" {
  description = "List of tables within current schema for which specified privileges will be granted, default value is 'ALL'. There is no need to set schema as prefix"
  type        = list(string)
  default     = ["ALL"]
}

variable "privileges" {
  description = "Granted privileges, default value is 'ALL'. The value of 'ALL' can be specified"
  type        = list(string)
  default     = ["ALL"]
}

variable "group_role" {
  description = "Group role to be granted with specified privileges"
  type        = string
  default     = ""
}

variable "make_admin_own" {
  description = "Is it necessary to grant admin user to database owner role or not. It is in case of RDS, because standard root account isn't a superuser."
  type        = bool
  default     = true
}

variable "revoke_grants" {
  description = "Revoke all grants which were provided by this module just before or not"
  type        = bool
  default     = false
}
