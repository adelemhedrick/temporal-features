terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.12"
}

provider "google" {
  /*
  If you don't have your GOOGLE_APPLICATION_CREDENTIALS env var set
  you can set this variable below
  credentials = file("<your credential file name>.json")
  */
  project     = var.project_id
  region      = var.region
}