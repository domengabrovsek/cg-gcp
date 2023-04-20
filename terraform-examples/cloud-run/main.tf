terraform {
  required_version = "= 1.4.4"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.61.0"
    }
  }

  backend "gcs" {
    bucket = "gcp-cg-terraform-state-bucket"
    prefix = "domen/cloud-run"
  }
}

module "cloud_run" {
  source  = "GoogleCloudPlatform/cloud-run/google"
  version = "~> 0.2.0"

  # Required variables
  service_name = "cloud-run-terraform-domen"
  project_id   = "gcp-competence-group"
  location     = "europe-central2"
  image        = "gcr.io/cloudrun/hello"
  members      = ["allUsers"]
}

# output url of service to terminal
output "url" {
    value = module.cloud_run.service_url
}