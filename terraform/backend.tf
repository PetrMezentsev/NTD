terraform {
  backend "s3" {
    endpoint = "storage.yandexcloud.net"
    bucket = "mpv-state-storage"
    region = "ru-central1"
    key = "state-storage/terraform.tfstate"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}