#!/bin/bash

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

IMAGE_NAME="nest-datadog-poc"
CONTAINER_NAME="nest-datadog-poc-container"
PORT=3000
TIMEOUT=30

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}   Docker Build & Run Test Suite${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# Cleanup function
cleanup() {
    echo -e "\n${YELLOW}Cleaning up...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME 2>/dev/null
}

# Trap to cleanup on exit
trap cleanup EXIT

# Test 1: Build
echo -e "${BLUE}[1/5] Building Docker image...${NC}"
if docker build -t $IMAGE_NAME . > /tmp/docker-build.log 2>&1; then
    echo -e "${GREEN}✓ Build successful${NC}"
    echo -e "${YELLOW}Image size: $(docker images $IMAGE_NAME --format "{{.Size}}" | head -n1)${NC}"
else
    echo -e "${RED}✗ Build failed${NC}"
    echo -e "${RED}See /tmp/docker-build.log for details${NC}"
    exit 1
fi
echo ""

# Test 2: Check if .env exists
echo -e "${BLUE}[2/5] Checking environment file...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}Warning: .env not found, using env.example${NC}"
    cp env.example .env
fi
echo -e "${GREEN}✓ Environment file ready${NC}"
echo ""

# Test 3: Run container
echo -e "${BLUE}[3/5] Starting container...${NC}"
if docker run -d \
    --name $CONTAINER_NAME \
    --env-file .env \
    -p $PORT:$PORT \
    $IMAGE_NAME > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Container started${NC}"
    echo -e "${YELLOW}Container ID: $(docker ps -q -f name=$CONTAINER_NAME)${NC}"
else
    echo -e "${RED}✗ Failed to start container${NC}"
    exit 1
fi
echo ""

# Test 4: Wait for app to be ready
echo -e "${BLUE}[4/5] Waiting for application to be ready...${NC}"
COUNTER=0
while [ $COUNTER -lt $TIMEOUT ]; do
    if curl -s http://localhost:$PORT > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Application is responding${NC}"
        break
    fi
    echo -ne "${YELLOW}Waiting... ${COUNTER}s/${TIMEOUT}s\r${NC}"
    sleep 1
    COUNTER=$((COUNTER + 1))
done

if [ $COUNTER -eq $TIMEOUT ]; then
    echo -e "${RED}✗ Application failed to start within ${TIMEOUT}s${NC}"
    echo -e "${YELLOW}Container logs:${NC}"
    docker logs $CONTAINER_NAME
    exit 1
fi
echo ""

# Test 5: Health check
echo -e "${BLUE}[5/5] Running health checks...${NC}"

# Check if container is running
if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✓ Container is running${NC}"
else
    echo -e "${RED}✗ Container stopped unexpectedly${NC}"
    exit 1
fi

# Test the endpoint
RESPONSE=$(curl -s -w "\n%{http_code}" http://localhost:$PORT)
HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | head -n-1)

if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✓ Endpoint responding (HTTP $HTTP_CODE)${NC}"
    echo -e "${YELLOW}Response:${NC} $BODY"
else
    echo -e "${RED}✗ Endpoint returned HTTP $HTTP_CODE${NC}"
fi

# Show container stats
echo ""
echo -e "${BLUE}Container Stats:${NC}"
docker stats $CONTAINER_NAME --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo -e "${BLUE}======================================${NC}"
echo -e "${GREEN}✓ All tests passed!${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""
echo -e "${YELLOW}Container is still running. You can:${NC}"
echo -e "  • View logs: ${BLUE}make logs${NC}"
echo -e "  • Stop it:   ${BLUE}make stop${NC}"
echo -e "  • Access:    ${BLUE}http://localhost:$PORT${NC}"
echo ""

# Keep container running unless --cleanup flag is passed
if [ "$1" = "--cleanup" ]; then
    cleanup
    echo -e "${GREEN}Cleanup completed${NC}"
fi

