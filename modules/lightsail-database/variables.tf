# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "name" {
  description = "Name for the Lightsail relational database"
  type        = string
}

variable "blueprint_id" {
  description = "Database engine and version (e.g. mysql_8_0, postgres_12, mariadb_10_6)"
  type        = string
}

variable "bundle_id" {
  description = "Bundle (size) for the database (e.g. micro_1_0, small_1_0, medium_1_0, large_1_0)"
  type        = string
}

variable "master_database_name" {
  description = "Name of the initial database to create"
  type        = string
}

variable "master_username" {
  description = "Master username for the database"
  type        = string
}

variable "master_password" {
  description = "Master password for the database"
  type        = string
  sensitive   = true
}

variable "default_tags" {
  type = map(any)
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------
variable "availability_zone" {
  description = "Availability zone for the database"
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "Whether the database is publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_enabled" {
  description = "Whether automated backups are enabled"
  type        = bool
  default     = true
}

variable "preferred_backup_window" {
  description = "Daily time range for backups (e.g. 02:00-02:30)"
  type        = string
  default     = "02:00-02:30"
}

variable "preferred_maintenance_window" {
  description = "Weekly time range for maintenance (e.g. Mon:03:00-Mon:03:30)"
  type        = string
  default     = "Mon:03:00-Mon:03:30"
}

variable "apply_immediately" {
  description = "Whether changes are applied immediately or during the next maintenance window"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot on destroy"
  type        = bool
  default     = false
}

variable "final_snapshot_name" {
  description = "Name of the final snapshot taken before destroy (required when skip_final_snapshot is false)"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(any)
  default = {}
}
