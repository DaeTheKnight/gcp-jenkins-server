# Jenkins on GCP (Ubuntu) — Terraform + Step‑by‑Step Install

This README walks you from **provisioning an Ubuntu VM on Google Cloud with Terraform** to **installing Jenkins** up to the “Customize Jenkins” screen where you pick your settings. It assumes you already have a GCP project and a Service Account JSON that Terraform can use.

---

## Architecture Overview

- **Terraform** provisions:
  - VPC, subnet(s), and firewall rules (SSH, HTTP, Jenkins on 8080)
  - An Ubuntu VM for Jenkins (optionally with a startup script)
  - (Optional) Remote state in a GCS bucket
- **Jenkins** runs on the VM and is reachable via the instance’s **external IP:8080**.

> Tip: For production, consider a static external IP, a Managed Instance Group + Instance Template, and HTTPS behind a load balancer.


## Repository Layout (example)

```
.
├── 0-authentication.tf     # Google provider & auth (uses your SA JSON)
├── 1-backend.tf            # Terraform backend (GCS state)
├── 2-vpc.tf                # VPC
├── 3-subnets.tf            # Subnets
├── 4-firewall.tf           # Firewall rules (22, 80/443, 8080)
├── 5-instance.tf           # Compute instance (Ubuntu) + (optional) startup script
├── 6-variables.tf          # Variables
├── startup.sh              # (optional) extra bootstrapping
└── terraform.tfvars        # or *.auto.tfvars for environment values
```

If you use environment‑specific tfvars (e.g., `dev.tfvars` / `prod.tfvars`), remember Terraform does **not** auto‑load them unless they end in `.auto.tfvars`. Otherwise pass `-var-file=...` when planning/applying.


## Prerequisites

- **gcloud** installed (optional but helpful)
- **Terraform** v1.4+ (recommend v1.9+)
- **Service Account JSON** with permissions for the resources you create (compute, network, storage, etc.).
- Required GCP APIs enabled (e.g., `compute.googleapis.com`, `iam.googleapis.com`).


## 1) Initialize & Plan Infrastructure

From the Terraform working directory:

```bash
terraform init
# If you use a non-default tfvars file:
terraform plan -var-file="terraform.tfvars"    # or dev.tfvars / prod.tfvars
# Otherwise:
terraform plan
```

Review the plan output to confirm:
- A VPC + subnets will be created
- Firewall rules allow:
  - **22/tcp** (SSH) from your IP
  - **80, 443/tcp** (web traffic, optional)
  - **8080/tcp** to reach Jenkins (you can restrict to your IP)
- An **Ubuntu** VM instance will be created


## 2) Apply Infrastructure

```bash
# With explicit vars:
terraform apply -var-file="terraform.tfvars"

# Or without if using terraform.tfvars / *.auto.tfvars:
terraform apply
```

When the apply completes, note the **external IP** of your VM. If you don’t output it in Terraform, you can find it in the GCP Console → Compute Engine → VM instances.


## 3) (Optional) SSH Into the VM

```bash
gcloud compute ssh YOUR_INSTANCE_NAME --zone YOUR_ZONE --project YOUR_PROJECT
# or use your SSH key directly
```

Update packages first:
```bash
sudo apt-get update
```


## 4) Install Java & Jenkins on Ubuntu

Use the current Jenkins Debian repo (installs OpenJDK 17 runtime and Jenkins):

```bash
# 1) Add Jenkins key to keyrings
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc   https://pkg.jenkins.io/debian/jenkins.io-2023.key

# 2) Add Jenkins apt repository
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" |   sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 3) Update and install Java & Jenkins
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre
sudo apt-get install -y jenkins
```

Check the service:
```bash
sudo systemctl status jenkins
# Press 'q' to exit the pager
```

If `openjdk-11-jdk` isn’t found on newer Ubuntu/Debian versions, prefer OpenJDK 17 as shown above.


## 5) Open Port 8080 (Firewall)

If your Terraform didn’t already open 8080, add a firewall rule (Terraform recommended). From the console (temporary):

```bash
# Example gcloud (replace NETWORK & TARGET TAG)
gcloud compute firewall-rules create allow-jenkins-8080   --network=YOUR_NETWORK   --allow=tcp:8080   --target-tags=jenkins   --source-ranges=YOUR_PUBLIC_IP/32
```

Ensure the VM has a matching **network tag** (e.g., `jenkins`).


## 6) Access Jenkins

On your local machine, open your browser to:
```
http://EXTERNAL_IP:8080
```

You should see the **Unlock Jenkins** page with the path to the initial admin password.


## 7) Unlock Jenkins

On the VM, print the password and copy it:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Paste the password into the Jenkins web form to unlock.


## 8) Customize Jenkins (Pick Your Settings)

Jenkins will ask you to **Install suggested plugins** or **Select plugins to install**. Either is fine to proceed—**suggested** is quickest for a first run. Then you’ll be prompted to:

1. **Create First Admin User** — set username & password  
2. **Instance Configuration** — confirm the Jenkins URL (use `http://EXTERNAL_IP:8080` unless you’ve set DNS/HTTPS)


## 9) (Optional) Hardening & Next Steps

- Restrict firewall rules (limit 8080 to your IP); or front Jenkins with an HTTPS reverse proxy / load balancer.
- Switch to a **static external IP** (reserved address).
- Configure **backups** for the Jenkins home (`/var/lib/jenkins/`).
- Add a **Pipeline** that runs Terraform (`init/plan/apply`) for your web server infra.
- Use **service account** credentials stored securely (e.g., Jenkins Credentials + environment binding).


## Troubleshooting

- **E: Unable to locate package** — Run `sudo apt-get update` first, verify your repo entries and keyrings are present.
- **Jenkins not reachable** — Confirm VM external IP, firewall rules for 8080, and that the Jenkins service is running: `sudo systemctl status jenkins`.
- **Permission errors in Terraform** — Ensure the service account has the required IAM roles (compute, network, storage, etc.).
- **Startup script didn’t run** — Check serial console logs and `journalctl -u google-startup-scripts -xe` (if using GCE metadata startup script).


## Destroy (Clean Up)

When you’re done testing:
```bash
terraform destroy -var-file="terraform.tfvars"
# or simply:
terraform destroy
```

---

**You’re ready to build pipelines!** Start by creating a simple Declarative Pipeline that does `terraform fmt/validate`, then `plan`, then (optionally) a manual approval before `apply`. For production, separate state or workspaces per environment.
