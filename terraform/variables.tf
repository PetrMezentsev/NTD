variable "vpc_name" {
  type        = string
  default     = "papercut"
  description = "VPC network for test-app"
}

variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "default_zone" {
  type = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone-a" {
  type    = string
  default = "ru-central1-a"
}

variable "zone-b" {
  type    = string
  default = "ru-central1-b"
}

variable "zone-d" {
  type    = string
  default = "ru-central1-d"
}
variable "cloud_id" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "folder_id" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "ssh_adm_key" {
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINzXn4HqEZWkxR/7afwjSQpJpptBdCgoin4uClO4L25Y mp"
  description = "ssh-keygen -t ed25519"
  #description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "platform" {
  type    = string
  default = "standard-v2"
}
variable "public_cidr_a" {
  type        = list(string)
  default     = ["10.10.10.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "public_cidr_b" {
  type        = list(string)
  default     = ["10.10.20.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "public_cidr_d" {
  type        = list(string)
  default     = ["10.10.30.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "sa" {
  type = string
  default = "ajeufu22cvnmni0bn977"
}

variable "root_user" {
  type    = string
  default = "ubuntu"
}

variable "vm_user" {
  type    = string
  default = "ubuntu"
}
