terraform {
  required_version = "= 1.4.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.61.0"
    }
  }
}

provider "google" {
  project = "gcp-competence-group"
  region  = "europe-north1"
}

resource "google_compute_instance" "my-vm" {
  name         = "my-vm-instance"
  machine_type = "n1-standard-1"
  zone         = "europe-north1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
}