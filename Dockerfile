# Multi-stage build for optimized image size

# Stage 1: Install NVM and Node.js
FROM ubuntu:22.04 AS nvm-setup

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_VERSION=v0.39.7
ENV NODE_VERSION=20

# Install prerequisites
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

# Load NVM and install Node.js
SHELL ["/bin/bash", "-c"]
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default ${NODE_VERSION}

# Set NVM environment variables
ENV NVM_DIR=/root/.nvm
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH"

# Stage 2: Build application
FROM nvm-setup AS build

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm use ${NODE_VERSION} && \
    npm ci

# Copy source code
COPY . .

# Build application
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm use ${NODE_VERSION} && \
    npm run build

# Stage 3: Production image
FROM nvm-setup AS production

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && \
    nvm use ${NODE_VERSION} && \
    npm ci --only=production

# Copy built application from build stage
COPY --from=build /usr/src/app/dist ./dist

# Expose port
EXPOSE 3000

# NVM environment already set from nvm-setup stage
# PATH is already configured to include Node.js binary

# Start application with Datadog tracing
CMD ["node", "-r", "dd-trace/init", "dist/main"]
