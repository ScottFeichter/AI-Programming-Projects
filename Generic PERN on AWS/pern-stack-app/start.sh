#!/bin/bash

# Start development servers
echo "Starting development servers..."

# Start backend
cd backend
npm run dev &

# Start frontend
cd ../frontend
npm run dev
