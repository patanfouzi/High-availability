# -----------------------------
# Get existing VM info (source for snapshot)
# -----------------------------
data "google_compute_instance" "vm1" {
  name    = var.vm_name
  zone    = var.zone
  project = var.project
}

# Snapshot from VM boot disk
resource "google_compute_snapshot" "vm_snapshot" {
  name        = "${var.vm_name}-snapshot"
  project     = var.project
  source_disk = data.google_compute_instance.vm1.boot_disk[0].source
}

# Custom image from snapshot
resource "google_compute_image" "vm1_custom_image" {
  name            = "${var.vm_name}-custom-image"
  project         = var.project
  source_snapshot = google_compute_snapshot.vm_snapshot.name
}

# -----------------------------
# Instance Template
# -----------------------------
resource "google_compute_instance_template" "vm1_template" {
  name         = "${var.vm_name}-template"
  machine_type = var.machine_type
  project      = var.project

  disk {
    source_image = google_compute_image.vm1_custom_image.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {}
  }

  tags = ["http-server"]
}

# -----------------------------
# Regional Health Check
# -----------------------------
resource "google_compute_region_health_check" "http_health_check" {
  name                = "${var.vm_name}-health-check"
  project             = var.project
  region              = var.region
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# -----------------------------
# Regional MIG
# -----------------------------
resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${var.vm_name}-regional-mig"
  project            = var.project
  region             = var.region
  base_instance_name = var.vm_name
  target_size        = var.min_replicas

  version {
    instance_template = google_compute_instance_template.vm1_template.self_link
  }

  distribution_policy_zones = var.zones

  auto_healing_policies {
    health_check      = google_compute_region_health_check.http_health_check.self_link
    initial_delay_sec = 300
  }
}

# -----------------------------
# Regional Autoscaler
# -----------------------------
resource "google_compute_region_autoscaler" "autoscaler" {
  name    = "${var.vm_name}-regional-autoscaler"
  project = var.project
  region  = var.region
  target  = google_compute_region_instance_group_manager.mig.id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cpu_utilization {
      target = var.cpu_utilization_target
    }
    cooldown_period = 60
  }
}

# -----------------------------
# Regional Backend Service
# -----------------------------
resource "google_compute_region_backend_service" "backend_service" {
  name                  = "${var.vm_name}-backend-service"
  project               = var.project
  region                = var.region
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_region_health_check.http_health_check.self_link]

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }
}

# -----------------------------
# Regional URL Map
# -----------------------------
resource "google_compute_region_url_map" "url_map" {
  name            = "${var.vm_name}-url-map"
  project         = var.project
  region          = var.region
  default_service = google_compute_region_backend_service.backend_service.self_link
}

# -----------------------------
# Regional Target HTTP Proxy
# -----------------------------
resource "google_compute_region_target_http_proxy" "http_proxy" {
  name    = "${var.vm_name}-http-proxy"
  project = var.project
  region  = var.region
  url_map = google_compute_region_url_map.url_map.self_link
}

# -----------------------------
# Regional Static IP
# -----------------------------
resource "google_compute_address" "lb_ip" {
  name    = "${var.vm_name}-lb-ip"
  project = var.project
  region  = var.region
}

# -----------------------------
# Regional Forwarding Rule
# -----------------------------
resource "google_compute_forwarding_rule" "forwarding_rule" {
  name                  = "${var.vm_name}-forwarding-rule"
  project               = var.project
  region                = var.region
  ip_address            = google_compute_address.lb_ip.address
  target                = google_compute_region_target_http_proxy.http_proxy.self_link
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}
