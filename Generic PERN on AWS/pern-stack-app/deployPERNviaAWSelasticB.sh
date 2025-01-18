#!/bin/bash

# This needs to be vetted and may be incomplete. Is there an Elastic Beanstalk cli?

# AWS Elastic Beanstalk deployment script
echo "Preparing for AWS deployment..."

# Install AWS CLI if not installed
if ! command -v aws &> /dev/null; then
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
fi

# Install Elastic Beanstalk CLI
if ! command -v eb &> /dev/null; then
    echo "Installing EB CLI..."
    pip install awsebcli
fi

# Initialize Elastic Beanstalk
eb init pern-stack-app --platform node.js --region us-east-1

# Create Elastic Beanstalk configuration
mkdir .elasticbeanstalk
cat > .elasticbeanstalk/config.yml << EOF
branch-defaults:
  main:
    environment: pern-stack-app-env
global:
  application_name: pern-stack-app
  default_region: us-east-1
  profile: null
  sc: git
EOF

# Create Procfile
echo "web: node backend/src/index.js" > Procfile

# Create .ebignore
cat > .ebignore << EOF
.git
.gitignore
.env
node_modules
frontend/node_modules
EOF
