#!/bin/bash

# OpenHands GUI Background Launcher for Apple Silicon Macs (M1/M2/M3/M4/M5+)
# Tested on M1 MacBook running macOS Sequoia 15.7
# Based on proven working solution from GitHub issue #7618

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
OPENHANDS_URL="http://localhost:3000"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/openhands.log"
PID_FILE="$SCRIPT_DIR/openhands.pid"

# Load environment variables if available
if [ -f "$HOME/.openhands_env" ]; then
    source "$HOME/.openhands_env"
fi

function show_usage() {
    echo -e "${BLUE}OpenHands GUI Background Launcher${NC}"
    echo ""
    echo "Usage: $0 [start|start-browser|stop|restart|status|logs]"
    echo ""
    echo "Commands:"
    echo "  start         - Start OpenHands in background (no browser)"
    echo "  start-browser - Start OpenHands in background and open browser"
    echo "  stop          - Stop OpenHands"
    echo "  restart       - Restart OpenHands"
    echo "  status        - Check if OpenHands is running"
    echo "  logs          - Show recent logs"
    echo ""
}

function check_docker() {
    if ! docker info >/dev/null 2>&1; then
        echo -e "${RED}❌ Docker is not running. Starting Colima...${NC}"
        colima start --cpu 2 --memory 4 --disk 30
        sleep 5
    fi
}

function wait_for_openhands() {
    echo -e "${YELLOW}⏳ Waiting for OpenHands to start...${NC}"
    
    for i in {1..30}; do
        if curl -s "$OPENHANDS_URL" >/dev/null 2>&1; then
            echo -e "${GREEN}✅ OpenHands is ready!${NC}"
            return 0
        fi
        sleep 2
        echo -n "."
    done
    
    echo -e "${RED}❌ OpenHands failed to start within 60 seconds${NC}"
    return 1
}

function start_openhands() {
    local open_browser=${1:-false}
    
    if is_running; then
        echo -e "${YELLOW}⚠️  OpenHands is already running at $OPENHANDS_URL${NC}"
        if [ "$open_browser" = "true" ]; then
            open "$OPENHANDS_URL"
        fi
        return 0
    fi
    
    echo -e "${BLUE}🚀 Starting OpenHands GUI with Apple Silicon optimizations...${NC}"
    
    check_docker
    
    # Clean up any orphaned containers
    docker container prune -f >/dev/null 2>&1 || true
    
    # Set platform for Apple Silicon (ARM64) compatibility
    export DOCKER_DEFAULT_PLATFORM=linux/amd64
    
    # Start OpenHands in background
    docker run -d --pull=always \
        -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik \
        -e LOG_ALL_EVENTS=true \
        -e BROWSER_ACTION_ENABLED=false \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$HOME/.openhands:/.openhands" \
        -p 3000:3000 \
        --add-host host.docker.internal:host-gateway \
        --name openhands-app \
        docker.all-hands.dev/all-hands-ai/openhands:0.57.0
    
    # Container ID is returned by docker run -d, no need for PID file
    # echo $! > "$PID_FILE"
    
    if wait_for_openhands; then
        if [ "$open_browser" = "true" ]; then
            echo -e "${GREEN}🌐 Opening browser...${NC}"
            open "$OPENHANDS_URL"
        fi
        echo -e "${GREEN}✅ OpenHands is running in background${NC}"
        echo -e "${BLUE}🌐 UI available at: $OPENHANDS_URL${NC}"
        echo -e "${BLUE}📝 Logs: docker logs -f openhands-app${NC}"
        echo -e "${BLUE}🛑 Stop: $0 stop${NC}"
    else
        stop_openhands
        exit 1
    fi
}

function stop_openhands() {
    echo -e "${YELLOW}🛑 Stopping OpenHands...${NC}"
    
    # Stop main OpenHands container
    docker stop openhands-app 2>/dev/null || true
    docker rm openhands-app 2>/dev/null || true
    
    # Clean up OpenHands runtime containers (they have random names but use the runtime image)
    echo -e "${YELLOW}🧩 Cleaning up runtime containers...${NC}"
    RUNTIME_CONTAINERS=$(docker ps -a --filter "ancestor=docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik" --format "{{.ID}}" 2>/dev/null || true)
    if [ -n "$RUNTIME_CONTAINERS" ]; then
        echo "$RUNTIME_CONTAINERS" | xargs -r docker rm -f 2>/dev/null || true
    fi
    
    # Clean up any stopped containers (safe - only removes stopped ones)
    docker container prune -f >/dev/null 2>&1 || true
    
    # Clean up PID file
    if [ -f "$PID_FILE" ]; then
        rm "$PID_FILE"
    fi
    
    echo -e "${GREEN}✅ OpenHands fully cleaned up${NC}"
}

function restart_openhands() {
    stop_openhands
    sleep 2
    start_openhands false
}

function is_running() {
    docker ps --format "table {{.Names}}" | grep -q "openhands-app" 2>/dev/null
}

function show_status() {
    if is_running; then
        echo -e "${GREEN}✅ OpenHands is running${NC}"
        echo -e "${BLUE}🌐 URL: $OPENHANDS_URL${NC}"
        echo -e "${BLUE}📊 Container info:${NC}"
        docker ps --filter "name=openhands-app" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    else
        echo -e "${RED}❌ OpenHands is not running${NC}"
    fi
}

function show_logs() {
    if is_running; then
        echo -e "${BLUE}📝 OpenHands container logs:${NC}"
        docker logs --tail 50 openhands-app
    else
        echo -e "${YELLOW}⚠️  OpenHands is not running${NC}"
    fi
}

# Main command handling
case "${1:-start}" in
    start)
        start_openhands false
        ;;
    start-browser)
        start_openhands true
        ;;
    stop)
        stop_openhands
        ;;
    restart)
        restart_openhands
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    *)
        show_usage
        exit 1
        ;;
esac
