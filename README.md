# 🚀 OpenHands for Apple Silicon (M1/M2/M3/M4/M5) - Easy Setup

```
  ╔══════════════════════════════════════════════════════════════╗
  ║                                                              ║
  ║    🍎 OPENHANDS FOR APPLE SILICON 🤖                         ║
  ║                                                              ║
  ║    ✨ Zero-config setup for M1/M2/M3 Macs                    ║
  ║    🚀 Solves Docker + Runtime compatibility issues           ║
  ║    🔧 One command to rule them all                           ║
  ║                                                              ║
  ║         [MacBook M1] ──❤️── [OpenHands AI]                   ║
  ║                                                              ║
  ║    📦 Ready to use  •  🧹 Auto cleanup  •  📊 Battle tested   ║
  ║                                                              ║
  ╚══════════════════════════════════════════════════════════════╝
```

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-success)](https://support.apple.com/en-us/HT211814)
[![Docker](https://img.shields.io/badge/Docker-Colima-blue)](https://github.com/abiosoft/colima)
[![OpenHands](https://img.shields.io/badge/OpenHands-0.57.0-orange)](https://github.com/All-Hands-AI/OpenHands)

> **One-command solution for running OpenHands on Apple Silicon Macs (M1/M2/M3/M4/M5+)** 🍎

Get [OpenHands](https://github.com/All-Hands-AI/OpenHands) (formerly OpenDevin) running smoothly on your Apple Silicon Mac with zero configuration headaches. This repository provides a battle-tested setup that solves all the common ARM64/Docker compatibility issues across the entire M-series chip lineup - from M1 to the latest M4 and future M5 processors.

## ✨ Features

- 🔧 **Zero-config setup** - Works out of the box on Apple Silicon
- ⚡ **Fast startup** - Optimized container management
- 🧹 **Smart cleanup** - Automatically manages Docker resources
- 🔒 **Data persistence** - Your conversations survive restarts
- 🎯 **M-series optimized** - Handles ARM64/AMD64 platform issues
- 📱 **Browser control** - Start with or without auto-opening browser

## 🚨 The Problem This Solves

OpenHands users on Apple Silicon Macs commonly face:

```
RemoteProtocolError: Server disconnected without sending a response
TargetClosedError: Target page, context or browser has been closed
Runtime container failed to start
```

**Root causes:**
- Playwright browser crashes in ARM64 containers
- Platform architecture mismatches (ARM64 host ↔ AMD64 containers)
- Insufficient Docker VM resources
- Runtime image version conflicts

## 🎯 The Solution

Our setup provides:
- ✅ **Explicit AMD64 platform specification** for M-series compatibility
- ✅ **Proper runtime image versioning** (`0.57.0-nikolaik`)
- ✅ **Browser actions disabled** to prevent Playwright crashes
- ✅ **Optimized Docker resource allocation**
- ✅ **Enhanced container cleanup** for better resource management

## 🚀 Quick Start

### Prerequisites

1. **macOS with Apple Silicon** - Any M-series chip (M1, M2, M3, M4, M5, or newer)
2. **Colima + Docker** (recommended over Docker Desktop for performance)
3. **Basic terminal knowledge**

### Installation

```bash
# 1. Clone this repository
git clone https://github.com/dmisiuk/openhands-apple-silicon.git
cd openhands-apple-silicon

# 2. Make scripts executable
chmod +x *.sh

# 3. Set up Colima (if not already installed)
brew install colima docker
colima start --cpu 2 --memory 4 --disk 30

# 4. Add aliases to your shell (optional but recommended)
echo 'alias oh-start=\"~/path/to/openhands-gui.sh start\"' >> ~/.zshrc
echo 'alias oh-stop=\"~/path/to/openhands-gui.sh stop\"' >> ~/.zshrc
echo 'alias oh-status=\"~/path/to/openhands-gui.sh status\"' >> ~/.zshrc
source ~/.zshrc
```

## 🎮 Usage

### Basic Commands

```bash
# Start OpenHands (no browser auto-open)
./openhands-gui.sh start
# OR with alias: oh-start

# Start OpenHands + open browser automatically
./openhands-gui.sh start-browser

# Check status
./openhands-gui.sh status
# OR: oh-status

# View logs
./openhands-gui.sh logs

# Stop and cleanup
./openhands-gui.sh stop
# OR: oh-stop

# Restart
./openhands-gui.sh restart
```

### Daily Workflow

**Morning:**
```bash
oh-start  # Starts in background, no browser popup
```
Then manually open http://localhost:3000 when ready to work.

> Works seamlessly on all Apple Silicon Macs - M1, M2, M3, M4, M5, and future processors

**Evening:**
```bash
oh-stop   # Stops containers, cleans up resources
```

### Advanced Usage

**Environment Configuration:**
Create `~/.openhands_env` for custom settings:
```bash
# Example environment overrides
SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:custom-tag
LOG_ALL_EVENTS=false
# Add other OpenHands environment variables
```

**Resource Management:**
```bash
# Increase Colima resources if needed
colima stop
colima start --cpu 4 --memory 8 --disk 50

# Check Docker resources
docker system df
```

**Colima Management:**
```bash
# The script does NOT stop Colima automatically (by design)
# This allows other Docker projects to keep running

# To manually stop Colima (saves battery):
colima stop

# To restart Colima:
colima start --cpu 2 --memory 4 --disk 30
```

## 🔧 Configuration Details

### Key Technical Solutions

1. **Platform Specification:**
   ```bash
   export DOCKER_DEFAULT_PLATFORM=linux/amd64
   ```
   Forces AMD64 containers even on ARM64 hosts.

2. **Runtime Image Version:**
   ```bash
   -e SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik
   ```
   Uses the M1-compatible runtime image variant.

3. **Browser Actions Disabled:**
   ```bash
   -e BROWSER_ACTION_ENABLED=false
   ```
   Prevents Playwright crashes in containerized environments.

4. **Enhanced Cleanup:**
   - Removes main OpenHands container
   - Cleans up runtime containers automatically
   - Prunes stopped containers safely
   - Preserves user data in `~/.openhands/`

### File Structure

```
openhands-apple-silicon/
├── openhands-gui.sh     # Main launcher script
├── README.md            # This file
├── .gitignore          # Protects private data
└── LICENSE             # MIT license
```

## 🧪 System Tested

**Actually tested and confirmed working:**
- ✅ **M1 MacBook** running **macOS Sequoia 15.7**
- ✅ **Docker via Colima** (recommended setup)
- ✅ **OpenHands version 0.57.0** with runtime:0.57.0-nikolaik

**Expected to work (same architecture):**
- 🔄 M2, M3, M4, M5 Macs (same ARM64 architecture, same Docker compatibility issues)
- 🔄 macOS Big Sur 11.0+ through latest versions
- 🔄 Docker Desktop (though Colima recommended for performance)

*Community testing and feedback welcome for other configurations!*

## 📊 What Gets Persisted?

**✅ Saved (survives restarts):**
- All conversation history (`~/.openhands/sessions/`)
- User settings and preferences (`~/.openhands/settings.json`)
- Authentication tokens (`~/.openhands/.jwt_secret`)
- Configuration files (`~/.openhands/config.toml`)

**❌ Temporary (cleaned on stop):**
- Container processes and runtime state
- Temporary execution environments
- Container logs (use `docker logs` while running)

## 🐛 Troubleshooting

### Common Issues

**"Container failed to start"**
```bash
# Check Docker is running
docker info

# Restart Colima if needed
colima restart

# Check resources
docker system df
```

**"Runtime image not found"**
```bash
# Verify the runtime image exists
docker pull docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik
```

**"Port 3000 already in use"**
```bash
# Find what's using port 3000
lsof -i :3000

# Stop previous OpenHands instance
./openhands-gui.sh stop
```

**"Out of disk space"**
```bash
# Clean Docker system
docker system prune -af --volumes

# Increase Colima disk size
colima stop
colima start --cpu 2 --memory 4 --disk 50
```

### Debug Mode

Run with verbose logging:
```bash
LOG_ALL_EVENTS=true ./openhands-gui.sh start
```

## 🙏 Contributing

Contributions welcome! This setup has been battle-tested but we're always improving.

### Areas for Contribution:
- 🧪 Testing on newer OpenHands versions
- 📚 Documentation improvements
- 🔧 Additional M-series optimizations
- 🐛 Bug fixes and edge cases
- 🌟 Feature enhancements

### How to Contribute:
1. Fork this repository
2. Create a feature branch
3. Test on your M-series Mac
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- **OpenHands Team** - For the amazing AI coding assistant
- **GitHub Issue #7618** - Community solution that inspired this setup
- **Apple Silicon Community** - For documenting Docker compatibility issues
- **Colima Project** - For the excellent Docker Desktop alternative

## 🔗 Related Links

- [OpenHands Official Repo](https://github.com/All-Hands-AI/OpenHands)
- [Colima Documentation](https://github.com/abiosoft/colima)
- [Docker on Apple Silicon](https://docs.docker.com/desktop/mac/apple-silicon/)
- [Original GitHub Issue #7618](https://github.com/All-Hands-AI/OpenHands/issues/7618)

---

**⭐ Star this repo if it helped you get OpenHands running on your Mac!**

**🐛 Found an issue?** [Open an issue](../../issues) and we'll help you out.

**💬 Questions?** [Start a discussion](../../discussions) with the community.

---

*Made with ❤️ for the Apple Silicon community*
