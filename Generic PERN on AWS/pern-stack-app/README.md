# PERN Stack Application

## Setup Instructions

1. Install dependencies:
   ```bash
   cd backend && npm install
   cd ../frontend && npm install
   ```

2. Configure environment variables in `backend/.env`

3. Start development servers:
   ```bash
   ./start.sh
   ```

## Deployment

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Deploy to AWS:
   ```bash
   ./deploy.sh
   ```
