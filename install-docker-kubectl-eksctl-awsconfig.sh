#!/bin/bash

# Step 1: Uninstall old versions of Docker (if any)
sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine

# Step 2: Install required packages
sudo yum install -y yum-utils

# Step 3: Set up the Docker repository
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Step 4: Install Docker Engine
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Step 5: Start Docker service
sudo systemctl start docker

# Step 6: Enable Docker to start on boot
sudo systemctl enable docker

# Step 7: Verify Docker is running
#sudo systemctl status docker

# Step 8: Add your user to the Docker group (optional, so you can run Docker commands without sudo)
sudo usermod -aG docker $USER

# Step 9: Print Docker version to verify installation
docker --version

echo "Docker has been installed and started successfully."
echo "Please log out and log back in for group changes to take effect."

# Step 2: Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --output=yaml
echo "kubectl installed successfully."

# Step 3: Install eksctl
echo "Installing eksctl..."
curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/$(curl -s https://api.github.com/repos/weaveworks/eksctl/releases/latest | grep tag_name | cut -d '"' -f 4)/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version
echo "eksctl installed successfully."

# Step 4: Install AWS CLI
echo "Installing AWS CLI..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
echo "AWS CLI installed successfully."

# Step 5: AWS Configure using CLI input
echo "Configuring AWS CLI..."
AWS_ACCESS_KEY=$1
AWS_SECRET_KEY=$2
AWS_REGION=$3

if [ -z "$AWS_ACCESS_KEY" ] || [ -z "$AWS_SECRET_KEY" ] || [ -z "$AWS_REGION" ]; then
  echo "Usage: $0 <AWS_ACCESS_KEY> <AWS_SECRET_KEY> <AWS_REGION>"
  exit 1
fi

# Pass AWS credentials via AWS CLI configuration
aws configure set aws_access_key_id "$AWS_ACCESS_KEY"
aws configure set aws_secret_access_key "$AWS_SECRET_KEY"
aws configure set region "$AWS_REGION"
aws configure set output json

echo "AWS CLI configured successfully."

# End of Script
echo "Setup Complete: Docker, kubectl, eksctl, and AWS CLI are ready to use."
