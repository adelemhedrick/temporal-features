resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

resource "google_project_service" "dataproc" {
  project = var.project_id
  service = "dataproc.googleapis.com"
}

resource "google_bigquery_dataset" "project_dataset" {
  dataset_id                  = "temporal"
  location                    = var.region
  delete_contents_on_destroy  = false

  access {
    role          = "roles/bigquery.dataOwner"
    user_by_email = var.service_account_email
  }
}

resource "google_compute_network" "temporal_network" {
  name                    = "temporal-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "temporal_subnetwork" {
  name          = "temporal-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  network       = google_compute_network.temporal_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = google_compute_network.temporal_network.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.2.0.0/16"]
}

resource "google_dataproc_cluster" "temporal_features" {
  name    = "temporal-features"
  region  = var.region
  project = var.project_id

  cluster_config {
    gce_cluster_config {
      subnetwork = google_compute_subnetwork.temporal_subnetwork.self_link
      internal_ip_only = false
    }

    master_config {
      num_instances = 1
      machine_type = "e2-medium"
      disk_config {
        boot_disk_size_gb = 30
      }
    }

    worker_config {
      num_instances = 2
      machine_type = "e2-medium"
      disk_config {
        boot_disk_size_gb = 30
      }
    }
  }
}



resource "google_dataproc_job" "temporal_features_dataproc_job" {
  region = var.region
  project = var.project_id

  placement {
    cluster_name = google_dataproc_cluster.temporal_features.name
  }

  pyspark_config {
    main_python_file_uri = "gs://${google_storage_bucket.dataproc_bucket.name}/pyspark_script.py"
    jar_file_uris = ["gs://${google_storage_bucket.dataproc_bucket.name}/dependencies.zip"]

    properties = {
      "spark.executor.instances" = "4"
    }
  }
}


resource "google_storage_bucket" "dataproc_bucket" {
  name     = "temporal-features-dataproc-bucket"
  location = var.region
}



