# Stage 1: Builder - Install dependencies
FROM node:25-alpine AS builder

# Install git (required for npm to install dependencies from GitHub)
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker cache
COPY package.json ./
COPY package-lock.json* ./

# Install production dependencies and ignore prepare scripts like husky
RUN npm install --omit=dev --ignore-scripts

# Stage 2: Runner - Copy application code and run
FROM node:25-alpine

# Set working directory
WORKDIR /app

# Copy production dependencies from the builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy application source code and default config
COPY src/ ./src/
COPY config.default.ts ./config.default.ts
COPY package.json ./package.json

# Default environment variables
# Note: Railway automatically overrides PORT dynamically at runtime
ENV NODELINK_SERVER_HOST=0.0.0.0 \
    NODELINK_CLUSTER_ENABLED=true

# Command to run the application
CMD ["npm", "start"]
