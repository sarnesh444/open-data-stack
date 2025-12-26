#!/bin/bash
set -e

# Update and install dependencies
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

# Install Docker
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add ubuntu user to docker group
sudo usermod -aG docker ubuntu

# Clone the repository
# NOTE: You need to replace this with your actual repository URL.
# If it's private, you'll need to handle SSH keys or use a PAT (Personal Access Token).
cd /home/ubuntu
git clone ${repo_url} trino-stack
cd trino-stack

# Create .env file from Terraform variables
cat <<EOF > .env
AWS_REGION=${aws_region}
# AWS Keys are not needed if using IAM Role (which this Terraform setup does)
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
EOF

# Start the stack
# We use 'runuser' to run as ubuntu user so permissions are correct
runuser -l ubuntu -c "cd /home/ubuntu/trino-stack && docker compose up -d"
