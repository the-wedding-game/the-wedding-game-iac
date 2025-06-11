variable "image_hash" {
  type = string
}

variable "db_pass" {
  type    = string
  default = "postgres"
}

variable "db_user" {
  type    = string
  default = "postgres"
}

variable "db_name" {
  type    = string
  default = "postgres"
}