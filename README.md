# High-availability

Terraform + GCP + GitHub Actions setup 👇

# 🚀 GCP Regional MIG + Load Balancer with Terraform & GitHub Actions

This repository provisions a **Highly Available (HA)** infrastructure on **Google Cloud Platform (GCP)** using **Terraform**, with automation powered by **GitHub Actions**.


## 📌 Features

* ✅ Create a **Custom Image** from an existing VM (`vm1-monitoring`)
* ✅ Build an **Instance Template** from the image
* ✅ Deploy a **Regional Managed Instance Group (MIG)** across multiple zones
* ✅ Configure **Autoscaling** based on CPU utilization
* ✅ Create a **Load Balancer** with Global IP & Forwarding Rule
* ✅ Setup **Health Checks** for auto-healing
* ✅ Full **CI/CD automation** using **GitHub Actions**

## 🏗 Architecture


        ┌────────────────────────────────────────┐
        │            Global Load Balancer         │
        │  (HTTP Proxy + URL Map + Global IP)     │
        └───────────────┬────────────────────────┘
                        │
                ┌───────▼─────────┐
                │   Backend MIG   │
                │ (Multi-Zone VMs)│
                └───────┬─────────┘
                        │
        ┌───────────────┼────────────────┐
        │               │                │
  us-central1-b     us-central1-c   (Regional HA)



## 📂 Project Structure

terraform/
│── main.tf                 # Core Terraform resources
│── variables.tf            # Input variables
│── terraform.tfvars        # Variable values
│── provider.tf             # GCP provider config
│── outputs.tf              # Terraform outputs
│
└── .github/workflows/
    └── terraform.yml        # GitHub Actions pipeline


## ⚙️ Prerequisites

1. **GCP Project** with billing enabled
2. **Service Account Key** with roles:

   * `Compute Admin`
   * `Service Account User`
   * `Storage Admin`
3. Save the Service Account JSON key in **GitHub Secrets** as `GCP_HA_KEY`
4. Install [Terraform](https://developer.hashicorp.com/terraform/downloads) ≥ 1.2 (if running locally)



## 🚀 Deployment Steps

### 🔹 Local (Manual)

**bash**
cd terraform

# Initialize
terraform init

# Validate & Plan
terraform plan -out=tfplan

# Apply
terraform apply -auto-approve tfplan


### 🔹 GitHub Actions (Automated)

* Push to `main` branch OR manually trigger the workflow
* The pipeline will:

  1. Authenticate with GCP
  2. Run `terraform init`
  3. Run `terraform plan`
  4. Run `terraform apply`

---

## 🔑 Important Variables

Edit `terraform.tfvars` to customize:

project               = "<project-id>"
region                = "<region-name-of-existing-vm>"
zone                  = "<zone-name-of-existing-vm>"
zones                 = ["<zone1>", "<zone2>"]   #in which zones want to create
vm_name               = "<existing vm name>"
machine_type          = "<existing vm type>"
min_replicas          = <no.of min.replicas>
max_replicas          = <no.of max.replicas>
cpu_utilization_target = <cpu-target>  # eg...0.8



## 📤 Outputs

After deployment, Terraform will show:

* **Instance Template Name**
* **MIG Name**
* **Load Balancer IP** → Access your app via this IP

Example:

instance_template = "vm1-monitoring-template"
regional_mig_name = "vm1-monitoring-regional-mig"
load_balancer_ip  = "34.120.xx.xx"


## 🛑 Destroy Resources

To avoid extra billing:

terraform destroy -auto-approve


## ✅ Verification

* Open the **Load Balancer IP** in your browser → should route traffic to instances
* Run:

```bash
gcloud compute instance-groups list
gcloud compute forwarding-rules list
```

to verify MIG & Load Balancer

---

## 🤝 Contributing

PRs are welcome! Please ensure:

* Code is formatted (`terraform fmt`)
* Lint checks passed (`terraform validate`)

---

## 📜 License
MIT License. Free to use and modify.
