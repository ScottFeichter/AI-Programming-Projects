#!/bin/bash

##########################
# To use this script:

# 1. Save it as create-pern-app.sh

# 2. Make it executable: chmod +x create-pern-app.sh

# 3. Run it: ./create-pern-app.sh

###########################################
# After running the script, you'll need to:

# 1. Configure your PostgreSQL database credentials in the .env file

# 2. Install AWS CLI and configure your AWS credentials

# 3. Create an RDS instance for PostgreSQL in AWS

# 4. Update the production database configuration with RDS credentials


#######################
# To start development:

# ./start.sh


#######################
# To deploy to AWS:

# ./deploy.sh


#######################
# The script sets up:

# A Node/Express backend with Sequelize ORM

# A React frontend with Vite

# Security middleware (helmet, cors, rate-limiting)

# Basic project structure

# AWS Elastic Beanstalk configuration

# Development and deployment scripts


#######################
# Remember to:

# Keep sensitive information in environment variables

# Set up proper security groups in AWS

# Configure SSL/TLS for production

# Set up proper database backup strategies

# Implement proper authentication/authorization

# Add error handling and logging

# Set up CI/CD pipelines as needed

# This is a basic setup that you can build upon based on your specific requirements.



# THE SCRIPT:
#######################


# Create project directories
echo "Creating project structure..."
mkdir pern-stack-app
cd pern-stack-app

# Initialize main project
npm init -y

# Create frontend and backend directories
mkdir frontend backend
cd backend

# Initialize backend
echo "Setting up backend..."
npm init -y
npm install express pg pg-hstore sequelize cors dotenv helmet express-rate-limit

# Create backend structure
mkdir src src/models src/controllers src/routes src/config

# Create basic backend files
cat > src/config/database.js << EOL
require('dotenv').config();

module.exports = {
  development: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: 'postgres'
  },
  production: {
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    host: process.env.DB_HOST,
    dialect: 'postgres'
  }
};
EOL

# Create main server file
cat > src/index.js << EOL
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const { Sequelize } = require('sequelize');
const config = require('./config/database');

const app = express();

// Middleware
app.use(cors());
app.use(helmet());
app.use(express.json());

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});
app.use(limiter);

// Database connection
const sequelize = new Sequelize(config[process.env.NODE_ENV || 'development']);

// Test database connection
sequelize.authenticate()
  .then(() => console.log('Database connected successfully'))
  .catch(err => console.error('Unable to connect to the database:', err));

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(\`Server running on port \${PORT}\`));
EOL

# Create .env file
cat > .env << EOL
DB_USERNAME=postgres
DB_PASSWORD=your_password
DB_NAME=pern_db
DB_HOST=localhost
PORT=5000
NODE_ENV=development
EOL

# Initialize Sequelize
npx sequelize-cli init

# Move to frontend directory and setup React with Vite
cd ../frontend
npm create vite@latest . -- --template react
npm install
npm install axios @reduxjs/toolkit react-redux react-router-dom

# Create basic frontend structure
mkdir src/components src/pages src/services src/store

# Create AWS deployment files
cd ..
cat > deploy.sh << EOL


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
EOL

# Create start script
cat > start.sh << EOL


# Start development servers
echo "Starting development servers..."

# Start backend
cd backend
npm run dev &

# Start frontend
cd ../frontend
npm run dev
EOL

chmod +x start.sh
chmod +x deploy.sh

# Create README
cat > README.md << EOL
# PERN Stack Application

## Setup Instructions

1. Install dependencies:
   \`\`\`bash
   cd backend && npm install
   cd ../frontend && npm install
   \`\`\`

2. Configure environment variables in \`backend/.env\`

3. Start development servers:
   \`\`\`bash
   ./start.sh
   \`\`\`

## Deployment

1. Configure AWS credentials:
   \`\`\`bash
   aws configure
   \`\`\`

2. Deploy to AWS:
   \`\`\`bash
   ./deploy.sh
   \`\`\`
EOL

# Initialize git repository
git init
cat > .gitignore << EOL
node_modules
.env
.DS_Store
dist
build
.elasticbeanstalk/*
!.elasticbeanstalk/config.yml
EOL

echo "Project setup complete! Follow the instructions in README.md to get started."
