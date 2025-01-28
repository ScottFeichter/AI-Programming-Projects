#!/bin/bash

# This needs to be vetted.

# - It uses pip for elb cli and various things and therefore needs to use virtual environment.
# - After running the script, the EB CLI will be available within the virtual environment.
# - When you need to use the EB CLI in the future, you'll need to activate the virtual environment first:
#      source eb-venv/bin/activate

############################################################################################

# After deploying with Elastic Beanstalk, you can access your application in several ways:

# - Through the AWS Management Console:
#   1. Go to the Elastic Beanstalk service
#   2. Find your application "pern-stack-app"
#   3. Click on the environment "pern-stack-app-env"
#   4. You'll see a URL at the top of the page that looks like: pern-stack-app-env.xxxxxx.region.elasticbeanstalk.com

# - Through the EB CLI: Run these commands in your terminal:
#   1. eb status    # Shows environment info including the URL
#   2. eb open      # Opens the application in your default browser


############################################################################################

# To see deployment status and logs:

# eb health    # Shows environment health
# eb logs      # Shows application logs


############################################################################################

# If you need to make changes to your application:

# - Make your changes locally
# - Commit your changes if using git
# - Deploy the updates using:
#   - eb deploy

# Copy

# Remember that your application needs to be properly configured to listen on port 8080 (Elastic Beanstalk's default port) or the port specified by process.env.PORT.


############################################################################################
####################################### THE SCRIPT #########################################


# AWS Elastic Beanstalk deployment script
echo "Preparing for AWS deployment..."


# First, ensure Python 3 is installed and accessible
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi


# Create and activate a virtual environment to avoid system-wide package conflicts
echo "Setting up Python virtual environment..."
python3 -m venv eb-venv


# Source the virtual environment based on the shell
if [[ "$SHELL" == */zsh ]]; then
    source eb-venv/bin/activate
else
    . eb-venv/bin/activate
fi


# Upgrade pip within the virtual environment
echo "Upgrading pip..."
python3 -m pip install --upgrade pip


# Install EB CLI in the virtual environment
echo "Installing EB CLI..."
python3 -m pip install awsebcli


# Verify EB CLI installation
if ! command -v eb &> /dev/null; then
    echo "Adding eb-venv/bin to PATH..."
    export PATH="$PWD/eb-venv/bin:$PATH"
fi


# Test EB CLI installation
if ! command -v eb &> /dev/null; then
    echo "EB CLI installation failed. Please install manually."
    exit 1
fi


# Initialize Elastic Beanstalk (only proceed if eb command is available)
if command -v eb &> /dev/null; then
    # Initialize Elastic Beanstalk with specific Node.js platform branch
    echo "Initializing Elastic Beanstalk..."
    eb init pern-stack-app --platform "node.js-18" --region us-east-1

    # Create Elastic Beanstalk configuration
    mkdir -p .elasticbeanstalk
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

    # Create Profile
    echo "web: node backend/src/index.js" > Procfile

    # Create .ebignore
    cat > .ebignore << EOF
.git
.gitignore
.env
node_modules
frontend/node_modules
EOF

    # Create the Elastic Beanstalk environment
    echo "Creating Elastic Beanstalk environment..."
    eb create pern-stack-app-env \
        --instance-type t2.micro \
        --platform "node.js-18" \
        --region us-east-1

    # Wait for environment to be ready
    echo "Waiting for environment to be ready..."
    eb status

    # Display the application URL
    echo "Opening application in default browser..."
    eb open

else
    echo "EB CLI is not available in PATH. Installation may have failed."
    exit 1
fi

echo "Setup complete!"

# Deactivate the virtual environment
deactivate
