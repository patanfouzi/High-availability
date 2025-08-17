#!/bin/bash

echo "🔄 Updating packages..."
sudo apt update -y && sudo apt upgrade -y

echo "📦 Installing essential dependencies..."
sudo apt install -y curl unzip gnupg software-properties-common openjdk-17-jdk

# -------------------------------
# 🔧 Install Terraform
# -------------------------------
echo "📦 Installing Terraform..."
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt update && sudo apt install terraform -y

# -------------------------------
# 🔧 Install Jenkins
# -------------------------------
echo "📦 Installing Jenkins..."
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
  sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update && sudo apt install jenkins -y

echo "🚀 Starting Jenkins..."
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "✅ Terraform and Jenkins installation complete!"
