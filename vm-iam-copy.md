## 1. Install gcloud
    this will allow you to use your local machine to create service accounts.

    Use this command to check if you have gcloud installed:
        gcloud --version

    configure it with your project id:
        gcloud config set project my-first-project

    configure your shell variables with these commands:
        export PROJECT_ID="my-first-project"
        export JENKINS_SA="jenkins-sa@${PROJECT_ID}.iam.gserviceaccount.com"
        export JENKINS_VM="jenkins-vm-1"
        export ZONE="us-central1-b"

## 2. Create a service account for the jenkins vm
    use this command:

    gcloud iam service-accounts create jenkins-sa \
  --display-name="Jenkins Terraform Service Account"

## 3. Bind the policies to the service account
    use these commands:

    gcloud projects add-iam-policy-binding my-first-project \
  --member="serviceAccount:${JENKINS_SA}" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding my-first-project \
  --member="serviceAccount:${JENKINS_SA}" \
  --role="roles/compute.instanceAdmin.v1"

## 4. Attach service account to VM
    use these commands:

    gcloud compute instances stop jenkins-vm-1 --zone=us-central1-b

    gcloud compute instances set-service-account jenkins-vm-1 \
  --zone=us-central1-b \
  --service-account=jenkins-sa@my-first-project.iam.gserviceaccount.com \
  --scopes=https://www.googleapis.com/auth/cloud-platform

    gcloud compute instances start jenkins-vm-1 --zone=us-central1-b

## 5. Troubleshooting
    If you desire to switch the zone of the instance you will need to do so in the tfvars file

        the current way this setup is configured needs the var:
        zone = "us-central1-b"

    You can check the current zone of your instance using this command:

        gcloud compute instances list

    You can verify on the vm that the service account has been attached using this command:

        gcloud auth list
gcloud auth application-default print-access-token


