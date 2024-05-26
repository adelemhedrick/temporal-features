resource "google_service_account" "temporal_service_account" {
  account_id   = "temporal-service-account"
  display_name = "Temporal Service Account"
}

resource "google_project_iam_member" "bigquery_user" {
  project = var.project_id
  role    = "roles/bigquery.user"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_iam_member" "compute_network_user" {
  project = var.project_id
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_iam_member" "compute_security_user" {
  project = var.project_id
  role    = "roles/compute.securityAdmin"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_iam_member" "dataproc_worker" {
  project = var.project_id
  role    = "roles/dataproc.worker"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_iam_member" "service_account_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_iam_member" "storage_object_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.temporal_service_account.email}"
}

resource "google_project_service" "bigquery" {
  project = var.project_id
  service = "bigquery.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy = true
}

resource "google_project_service" "dataproc" {
  project = var.project_id
  service = "dataproc.googleapis.com"
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
  force_destroy = true
}
