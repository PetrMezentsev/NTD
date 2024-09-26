resource "yandex_kubernetes_cluster" "k8s-for-test-app" {
  network_id              = yandex_vpc_network.papercut.id
  service_account_id      = var.sa
  node_service_account_id = var.sa
  release_channel         = "STABLE"

  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }

  labels = {
    cluster  = "test-app"
    location = "yandex"
  }
  master {
    version   = "1.28"
    public_ip = true

    maintenance_policy {
      auto_upgrade = false

      maintenance_window {
        duration   = "3h"
        start_time = "03:00"
        day        = "sunday"
      }
    }

    master_logging {
      enabled = false
      folder_id = var.folder_id
      kube_apiserver_enabled = false
      cluster_autoscaler_enabled = false
      events_enabled = false
      audit_enabled = false
    }

    regional {
      region = "ru-central1"

      location {
        zone      = var.zone-a
        subnet_id = "${yandex_vpc_subnet.public-a.id}"
      }

      location {
        zone      = var.zone-b
        subnet_id = "${yandex_vpc_subnet.public-b.id}"
      }

      location {
        zone      = var.zone-d
        subnet_id = "${yandex_vpc_subnet.public-d.id}"
      }
    }
  security_group_ids = [yandex_vpc_security_group.nat-instance-sg.id]
  }
}

resource "yandex_kms_symmetric_key" "kms-key" {
  name              = "kms-key"
  default_algorithm = "AES_128"
  rotation_period   = "8760h"
}

resource "yandex_kubernetes_node_group" "ng" {
  cluster_id  = "${yandex_kubernetes_cluster.k8s-for-test-app.id}"
  name        = "node-group-for-test-app"
  version     = "1.28"

  instance_template {
    platform_id = var.platform
    network_acceleration_type = "standard"
    network_interface {
      nat         = true
      subnet_ids = ["${yandex_vpc_subnet.public-a.id}","${yandex_vpc_subnet.public-b.id}","${yandex_vpc_subnet.public-d.id}"]
        }

    resources {
      core_fraction = 5
      cores         = 2
      memory        = 2
    }
    boot_disk {
      size = 33
      type = "network-hdd"
    }
    container_runtime {
      type = "containerd"
    }
    scheduling_policy {
      preemptible =  true
    }
  }
  scale_policy {
    fixed_scale {
      size = 3
    }
  }
  allocation_policy {
    location {
      zone = var.zone-a
    }
    location {
      zone = var.zone-b
    }
    location {
      zone = var.zone-d
    }
  }
  maintenance_policy {
    auto_repair  = true
    auto_upgrade = false
  }
}