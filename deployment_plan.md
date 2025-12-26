# EC2 Deployment Plan

This guide outlines the steps to deploy your Trino/dbt/Superset stack to an AWS EC2 instance.

## Prerequisites
*   An AWS Account.
*   The project code committed to a Git repository (GitHub/GitLab) OR ready to be copied via SCP.

## Step 1: Launch EC2 Instance

1.  **Go to EC2 Console** -> **Launch Instance**.
2.  **Name**: `trino-data-stack`.
3.  **OS Image (AMI)**: `Ubuntu Server 24.04 LTS` (Recommended for ease of use).
4.  **Instance Type**:
    *   **Minimum**: `t3.xlarge` (4 vCPU, 16 GiB RAM).
    *   *Reason*: Trino and Superset are memory-intensive. `t3.medium` (4GB) will likely crash.
5.  **Key Pair**: Create a new key pair (e.g., `trino-key`) and download the `.pem` file.
6.  **Network Settings**:
    *   **Auto-assign Public IP**: Enable.
    *   **Security Group**: Create a new one.
        *   Allow **SSH (22)** from `My IP`.
        *   Allow **Custom TCP (8080)** (Trino) from `My IP` (or `0.0.0.0/0` for public access).
        *   Allow **Custom TCP (8088)** (Superset) from `My IP` (or `0.0.0.0/0`).

## Step 2: Configure IAM Role (Best Practice)

Instead of putting keys in `.env`, it's safer to give the EC2 instance permission directly.

1.  Go to **IAM Console** -> **Roles** -> **Create role**.
2.  Select **AWS Service** -> **EC2**.
3.  Add Permissions:
    *   `AmazonS3FullAccess` (or scoped to your bucket).
    *   `AWSGlueConsoleFullAccess`.
4.  Name it `TrinoEC2Role`.
5.  **Attach to Instance**:
    *   Go back to EC2 Console -> Select Instance -> Actions -> Security -> Modify IAM Role.
    *   Select `TrinoEC2Role`.

> **Note**: If you use this method, you can leave `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` empty in the `.env` file on the server.

## Step 3: Install Docker on EC2

SSH into your instance:
```bash
chmod 400 trino-key.pem
ssh -i "trino-key.pem" ubuntu@<EC2-PUBLIC-IP>
```

Run these commands to install Docker and Docker Compose:

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install Docker packages:
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group (so you don't need sudo):
sudo usermod -aG docker $USER
newgrp docker
```

## Step 3.5: (Optional) Deploy Infrastructure with Terraform

If you have a `terraform` directory in your project for managing infrastructure (e.g., S3 buckets, Glue Catalog), you can deploy it now.

**How to use it:**
1.  Install Terraform.
2.  Navigate to the terraform directory:
    ```bash
    cd terraform
    ```
3.  Run `terraform init`.
4.  Run `terraform apply ...`.

## Step 4: Deploy Code

### Option A: Git (Recommended)
1.  Push your local code to GitHub.
2.  Clone it on the server:
    ```bash
    git clone https://github.com/your-user/your-repo.git trino-stack
    cd trino-stack
    ```

### Option B: SCP (Copy files directly)
From your *local machine*:
```bash
scp -i "trino-key.pem" -r ./sar_trino ubuntu@<EC2-PUBLIC-IP>:~/trino-stack
```

## Step 5: Configure and Run

1.  **Create .env file**:
    ```bash
    cd ~/trino-stack
    nano .env
    ```
    Paste your environment variables.
    *   If using IAM Role: Only set `AWS_REGION`.
    *   If NOT using IAM Role: Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION`.

2.  **Start the Stack**:
    ```bash
    docker compose up -d
    ```

## Step 6: Access Services

Open your browser and navigate to:

*   **Trino UI**: `http://<EC2-PUBLIC-IP>:8080`
*   **Superset**: `http://<EC2-PUBLIC-IP>:8088`
