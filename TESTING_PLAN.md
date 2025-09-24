


# Regression Testing Plan for Security Improvements

## 🎯 Testing Strategy

Given the significant security enhancements proposed in the security-improvements branch, we need thorough testing to ensure:
1. **Functionality Preservation**: All original features work as expected
2. **Security Improvements**: New security features work correctly
3. **Performance**: No performance degradation
4. **User Experience**: Changes don't break user workflows

## 🧪 Test Environment Setup

### Prerequisites
```bash
# Ensure clean test environment
docker system prune -af
colima stop && colima start --cpu 2 --memory 4 --disk 30

# Backup existing OpenHands data (if any)
cp -r ~/.openhands ~/.openhands.backup.$(date +%Y%m%d_%H%M%S)
```

### Test Configuration
```bash
# Clone the security branch
git clone https://github.com/dmisiuk/openhands-apple-silicon.git test-security
cd test-security
git checkout security-improvements
chmod +x openhands-gui.sh
```

## 📋 Core Functionality Tests

### Test 1: Basic Operations
```bash
# Test 1.1: Help and usage
./openhands-gui.sh
./openhands-gui.sh --help  # Should show usage

# Test 1.2: Status check (should show not running)
./openhands-gui.sh status

# Test 1.3: Start basic operation
./openhands-gui.sh start
sleep 10
./openhands-gui.sh status  # Should show running

# Test 1.4: Accessibility check
curl -s http://localhost:3000 | head -20

# Test 1.5: Stop operation
./openhands-gui.sh stop
./openhands-gui.sh status  # Should show not running
```

### Test 2: Browser Integration
```bash
# Test 2.1: Start with browser
./openhands-gui.sh start-browser
sleep 15
# Check if browser opened (macOS specific)
ps aux | grep -i "localhost:3000" | grep -v grep

# Test 2.2: Stop cleanup
./openhands-gui.sh stop
```

### Test 3: Restart Functionality
```bash
# Test 3.1: Start service
./openhands-gui.sh start
sleep 10

# Test 3.2: Restart service
./openhands-gui.sh restart
sleep 10

# Test 3.3: Verify still running
./openhands-gui.sh status

# Test 3.4: Final cleanup
./openhands-gui.sh stop
```

## 🔒 Security Feature Tests

### Test 4: Security Command
```bash
# Test 4.1: Security info when not running
./openhands-gui.sh security

# Test 4.2: Security info when running
./openhands-gui.sh start
sleep 10
./openhands-gui.sh security

# Test 4.3: Check security log creation
ls -la security.log
cat security.log

# Test 4.4: Verify security features in container
docker inspect openhands-app | grep -A 10 "SecurityOpt"
docker inspect openhands-app | grep -A 5 "CapAdd"
docker inspect openhands-app | grep -A 5 "CapDrop"
docker inspect openhands-app | grep "ReadonlyRootfs"

./openhands-gui.sh stop
```

### Test 5: Resource Limits
```bash
# Test 5.1: Start with custom limits
export OPENHANDS_MEMORY_LIMIT=2g
export OPENHANDS_CPU_LIMIT=1.0
./openhands-gui.sh start
sleep 10

# Test 5.2: Verify limits applied
docker inspect openhands-app | grep Memory
docker inspect openhands-app | grep NanoCpus

# Test 5.3: Test with different limits
./openhands-gui.sh stop
export OPENHANDS_MEMORY_LIMIT=6g
export OPENHANDS_CPU_LIMIT=3.0
./openhands-gui.sh start
sleep 10

# Verify new limits
docker inspect openhands-app | grep Memory
docker inspect openhands-app | grep NanoCpus

./openhands-gui.sh stop
```

### Test 6: Environment Variable Validation
```bash
# Test 6.1: Test with suspicious environment variables
export OPENHANDS_SECRET_PASSWORD="test123"
export SANDBOX_API_KEY="secret-key"
./openhands-gui.sh start
sleep 5

# Check for security warnings
cat security.log | grep -i "suspicious"
cat security.log | grep -i "warning"

./openhands-gui.sh stop

# Test 6.2: Clean environment
unset OPENHANDS_SECRET_PASSWORD
unset SANDBOX_API_KEY
./openhands-gui.sh start
sleep 5
./openhands-gui.sh stop
```

## 🐳 Docker Integration Tests

### Test 7: Docker Compatibility
```bash
# Test 7.1: Colima integration
colima stop
./openhands-gui.sh start  # Should start Colima automatically
sleep 15
./openhands-gui.sh status
./openhands-gui.sh stop

# Test 7.2: Docker Desktop compatibility (if available)
# Test with both Docker runtimes if possible

# Test 7.3: Platform compatibility
echo "Testing AMD64 platform enforcement..."
./openhands-gui.sh start
sleep 10
docker inspect openhands-app | grep Platform
./openhands-gui.sh stop
```

### Test 8: Container Cleanup
```bash
# Test 8.1: Start multiple containers
./openhands-gui.sh start
sleep 10

# Create some test containers
docker run -d --name test-container1 alpine sleep 3600
docker run -d --name test-container2 alpine sleep 3600

# Test 8.2: Stop OpenHands (should only clean OpenHands containers)
./openhands-gui.sh stop

# Test 8.3: Verify test containers still exist
docker ps -a | grep test-container

# Cleanup test containers
docker rm -f test-container1 test-container2
```

## 📊 Performance and Logging Tests

### Test 9: Logging and Monitoring
```bash
# Test 9.1: Log file creation
./openhands-gui.sh start
sleep 10

# Check log files
ls -la *.log
head -20 openhands.log
head -20 security.log

# Test 9.2: Log command
./openhands-gui.sh logs

# Test 9.3: Log rotation (simulate large log)
dd if=/dev/zero of=openhands.log bs=1M count=15
./openhands-gui.sh logs  # Should handle large logs

./openhands-gui.sh stop
```

### Test 10: Performance Impact
```bash
# Test 10.1: Startup time
time ./openhands-gui.sh start
sleep 10
./openhands-gui.sh stop

# Test 10.2: Memory usage
./openhands-gui.sh start
sleep 10
docker stats openhands-app --no-stream
./openhands-gui.sh stop

# Test 10.3: Multiple start/stop cycles
for i in {1..3}; do
    echo "Cycle $i:"
    time ./openhands-gui.sh start
    sleep 5
    time ./openhands-gui.sh stop
    echo "---"
done
```

## 🔄 Migration and Compatibility Tests

### Test 11: Data Migration
```bash
# Test 11.1: Preserve existing data
./openhands-gui.sh start
sleep 10

# Create some test data
echo "test data" > ~/.openhands/test_file.txt

./openhands-gui.sh stop
./openhands-gui.sh start
sleep 10

# Verify data preserved
cat ~/.openhands/test_file.txt

./openhands-gui.sh stop
```

### Test 12: Configuration Migration
```bash
# Test 12.1: Existing configuration
cat > ~/.openhands_env << EOF
SANDBOX_RUNTIME_CONTAINER_IMAGE=docker.all-hands.dev/all-hands-ai/runtime:0.57.0-nikolaik
LOG_ALL_EVENTS=true
EOF

./openhands-gui.sh start
sleep 10

# Verify configuration applied
docker logs openhands-app | grep -i "runtime image"

./openhands-gui.sh stop
```

## 🚨 Edge Case Tests

### Test 13: Error Handling
```bash
# Test 13.1: Invalid commands
./openhands-gui.sh invalid-command
./openhands-gui.sh --invalid-option

# Test 13.2: Docker not running
colima stop
./openhands-gui.sh start  # Should handle gracefully
colima start

# Test 13.3: Port conflicts
docker run -d --name conflict -p 3000:3000 nginx
./openhands-gui.sh start  # Should handle port conflict
docker rm -f conflict

# Test 13.4: Resource constraints
export OPENHANDS_MEMORY_LIMIT=100m  # Very low memory
./openhands-gui.sh start  # Should handle gracefully
unset OPENHANDS_MEMORY_LIMIT
```

### Test 14: File Permissions
```bash
# Test 14.1: Log file permissions
./openhands-gui.sh start
sleep 5
ls -la *.log
stat -c "%a" *.log  # Should be 600

# Test 14.2: Security log permissions
ls -la security.log
stat -c "%a" security.log

./openhands-gui.sh stop
```

## 📈 Test Automation

### Automated Test Script
```bash
#!/bin/bash
# automated_test.sh

echo "Starting automated regression test..."

# Test counter
PASSED=0
FAILED=0

# Test function
test_command() {
    local test_name="$1"
    local command="$2"
    local expected_exit_code="${3:-0}"
    
    echo "Running: $test_name"
    if eval "$command"; then
        if [ $? -eq $expected_exit_code ]; then
            echo "✅ PASSED: $test_name"
            ((PASSED++))
        else
            echo "❌ FAILED: $test_name (exit code $?, expected $expected_exit_code)"
            ((FAILED++))
        fi
    else
        if [ $expected_exit_code -ne 0 ]; then
            echo "✅ PASSED: $test_name (expected failure)"
            ((PASSED++))
        else
            echo "❌ FAILED: $test_name"
            ((FAILED++))
        fi
    fi
}

# Run tests
test_command "Help command" "./openhands-gui.sh" 1
test_command "Status when stopped" "./openhands-gui.sh status" 0
test_command "Start service" "./openhands-gui.sh start" 0
test_command "Status when running" "./openhands-gui.sh status" 0
test_command "Stop service" "./openhands-gui.sh stop" 0

# Results
echo ""
echo "Test Results:"
echo "✅ Passed: $PASSED"
echo "❌ Failed: $FAILED"
echo "Total: $((PASSED + FAILED))"

if [ $FAILED -eq 0 ]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "💥 Some tests failed!"
    exit 1
fi
```

## 📋 Test Checklist

### Pre-Deployment Checklist
- [ ] All core functionality tests pass
- [ ] Security features work as expected
- [ ] No performance degradation
- [ ] Error handling works correctly
- [ ] Log files are created with correct permissions
- [ ] Security events are logged properly
- [ ] Container cleanup works correctly
- [ ] Resource limits are applied
- [ ] Migration from old version works
- [ ] Documentation is accurate

### Post-Deployment Monitoring
- [ ] Monitor error rates
- [ ] Check performance metrics
- [ ] Review security logs
- [ ] Gather user feedback
- [ ] Monitor resource usage

## 🚀 Rollback Plan

If issues are discovered, rollback procedure:
```bash
# Rollback to main branch
git checkout main
git pull origin main

# Restore backup data
cp -r ~/.openhands.backup.* ~/.openhands/

# Restart with original version
./openhands-gui.sh start
```

## 🎯 Quick Test for Immediate Validation

For immediate validation of the security improvements branch, run this quick test suite:

```bash
# Quick smoke test (5 minutes)
cd /workspace/openhands-apple-silicon

# 1. Test basic functionality
./openhands-gui.sh
./openhands-gui.sh status

# 2. Test start/stop cycle
./openhands-gui.sh start
sleep 10
./openhands-gui.sh status
./openhands-gui.sh security

# 3. Test cleanup
./openhands-gui.sh stop
./openhands-gui.sh status

# 4. Verify no leftover containers
docker ps -a | grep openhands
```

## 🔍 Areas of Concern

Based on the security improvements, pay special attention to:

1. **Docker Socket Mounting**: The read-only change might affect OpenHands functionality
2. **Resource Limits**: New constraints might impact performance
3. **Capability Dropping**: Removed capabilities might break features
4. **Environment Validation**: New warnings might affect user experience

## 📊 Risk Assessment

The security improvements are considered **low risk** because:
- All changes are backward compatible
- New features are configurable via environment variables
- Core OpenHands functionality remains unchanged
- Using established Docker security best practices

---

This testing plan ensures comprehensive validation of both existing functionality and new security features.

**Last Updated**: $(date +%Y-%m-%d)

**Target Branch**: security-improvements

**Purpose**: Regression testing for security enhancements


