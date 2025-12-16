#!/bin/bash
# Install Ansible requirements

echo "Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

echo "Installing Python dependencies..."
pip install kubernetes boto3 botocore --break-system-packages

echo "✅ Ansible setup complete!"