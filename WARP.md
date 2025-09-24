# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This is **OpenHands for Apple Silicon** - a specialized setup repository that provides a battle-tested, zero-configuration solution for running OpenHands (AI coding assistant) on Apple Silicon Macs (M1/M2/M3/M4/M5+). The repository contains optimization scripts and configurations that solve common Docker/ARM64 compatibility issues when running OpenHands on macOS.

## Core Architecture

### Main Components

1. **`openhands-gui.sh`** - The central launcher script that handles all OpenHands operations
   - Manages Docker container lifecycle with Apple Silicon optimizations
   - Provides commands: start, start-browser, stop, restart, status, logs
   - Includes platform-specific fixes (AMD64 enforcement, runtime image selection)
   - Handles resource cleanup and container management

2. **Configuration System**
   - Environment loading from `~/.openhands_env` (user-specific overrides)
   - Docker platform enforcement (`DOCKER_DEFAULT_PLATFORM=linux/amd64`)
   - Specific runtime image targeting (`runtime:0.57.0-nikolaik`)
   - Browser actions disabled to prevent Playwright crashes

3. **Apple Silicon Optimizations**
   - Explicit AMD64 platform specification to avoid ARM64/AMD64 conflicts
   - Colima integration for optimal Docker performance on macOS
   - Memory and resource management tuned for M-series chips
   - Container cleanup strategies to prevent resource leaks

## Common Development Commands

### Core Operations
```bash
# Start OpenHands (background, no browser)
./openhands-gui.sh start

# Start with browser auto-open
./openhands-gui.sh start-browser

# Check status
./openhands-gui.sh status

# View logs
./openhands-gui.sh logs

# Stop and cleanup
./openhands-gui.sh stop

# Restart (full stop/start cycle)
./openhands-gui.sh restart
```

### Docker Management
```bash
# Check Docker status
docker info

# Verify runtime image availability
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik

# View OpenHands container logs in real-time
docker logs -f openhands-app

# Check disk usage
docker system df

# Clean Docker system (if needed)
docker system prune -af --volumes
```

### Colima Management
```bash
# Start Colima with optimized settings
colima start --cpu 2 --memory 4 --disk 30

# Increase resources if needed
colima stop
colima start --cpu 4 --memory 8 --disk 50

# Check Colima status
colima status

# Restart Colima
colima restart
```

## Development Setup

### Prerequisites Validation
- macOS with Apple Silicon (M1/M2/M3/M4/M5+)
- Colima and Docker installed via Homebrew
- Basic terminal access

### Environment Configuration
Create `~/.openhands_env` for custom settings:
```bash
# Custom runtime image
SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:custom-tag

# Logging level
LOG_ALL_EVENTS=false

# Add other OpenHands environment variables as needed
```

### Shell Aliases (Recommended)
```bash
# Add to ~/.zshrc or ~/.bashrc
alias oh-start="~/path/to/openhands-gui.sh start"
alias oh-stop="~/path/to/openhands-gui.sh stop"
alias oh-status="~/path/to/openhands-gui.sh status"
alias oh-logs="~/path/to/openhands-gui.sh logs"
```

## Technical Implementation Details

### Apple Silicon Compatibility Solutions
- **Platform Enforcement**: `DOCKER_DEFAULT_PLATFORM=linux/amd64` forces AMD64 containers on ARM64 hosts
- **Runtime Image**: Uses `runtime:0.57.0-nikolaik` specifically tested for M-series compatibility
- **Browser Actions**: Disabled (`BROWSER_ACTION_ENABLED=false`) to prevent Playwright crashes in containerized environments
- **Container Cleanup**: Automatic cleanup of runtime containers with random names using image ancestry filtering

### Container Configuration
The script runs OpenHands with these Docker parameters:
- Volume mounts for Docker socket and user data persistence
- Host networking integration (`host.docker.internal:host-gateway`)
- Port mapping (3000:3000) for web UI access
- Pull latest image policy for updates

### Data Persistence
**Preserved across restarts:**
- Conversation history (`~/.openhands/sessions/`)
- User settings (`~/.openhands/settings.json`)
- Authentication tokens (`~/.openhands/.jwt_secret`)
- Configuration files (`~/.openhands/config.toml`)

**Cleaned on stop:**
- Container processes and runtime state
- Temporary execution environments
- Container logs (accessible via `docker logs` while running)

## Repository Structure

```
openhands-apple-silicon/
├── openhands-gui.sh        # Main launcher script
├── README.md               # Comprehensive setup guide
├── LICENSE                 # MIT license
├── .gitignore             # Protects user data and logs
├── HERO_IMAGE_GUIDE.md    # Visual branding guidelines
├── IMAGE_CONCEPT.md       # Design concepts
└── images/                # Visual assets (if any)
```

## Testing and Validation

### System Verification
```bash
# Check Apple Silicon detection
uname -m  # Should show arm64

# Verify Colima setup
colima list
docker context show

# Test OpenHands accessibility
curl -s http://localhost:3000
```

### Troubleshooting Commands
```bash
# Debug Docker connectivity
docker info

# Check port conflicts
lsof -i :3000

# View container status
docker ps -a --filter "name=openhands"

# Check runtime containers
docker ps -a --filter "ancestor=docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik"
```

## Key Dependencies and Versions

- **OpenHands**: v0.57.0 (main application)
- **Runtime Image**: `runtime:0.57.0-nikolaik` (Apple Silicon compatible)
- **Colima**: Latest stable (Docker Desktop alternative)
- **Docker**: Compatible version via Colima
- **macOS**: Big Sur 11.0+ (Apple Silicon required)

## Project-Specific Guidelines

- Always test Docker connectivity before starting OpenHands
- Use Colima over Docker Desktop for better performance on Apple Silicon
- Monitor container cleanup to prevent resource leaks
- Preserve user data in `~/.openhands/` directory
- Never include sensitive information in environment files tracked by git
- Use explicit platform specification for cross-architecture compatibility
- Maintain backwards compatibility across M-series chip generations