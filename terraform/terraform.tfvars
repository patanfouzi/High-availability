project = "absolute-hub-460713-v0"
region  = "us-central1"
zone    = "us-central1-c"   # used only for snapshot/image
zones   = ["us-central1-b", "us-central1-c"]

vm_name      = "vm1-monitoring"
machine_type = "e2-medium"
min_replicas = 1
max_replicas = 5
cpu_utilization_target = 0.8
