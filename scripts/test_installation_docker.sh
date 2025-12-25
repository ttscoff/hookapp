#!/bin/bash
# Test hookapp installation in a Docker container with Ruby 2.6
# This simulates a clean system Ruby installation

set -e

echo "=== Testing hookapp installation in Docker (Ruby 2.6) ==="
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    echo "Please install Docker: https://www.docker.com/get-started"
    exit 1
fi

# Build the gem first to ensure it's ready
echo "Building gem..."
gem build hookapp.gemspec
echo "✓ Gem built successfully"

# Ensure pkg directory exists and gem is there
mkdir -p pkg
# Move gem to pkg if it's in the root
if ls hookapp-*.gem 1> /dev/null 2>&1; then
    mv hookapp-*.gem pkg/
    echo "✓ Gem moved to pkg/ directory"
else
    echo "✓ Gem already in pkg/ directory"
fi
echo ""

# Build Docker image
echo "Building Docker image with Ruby 2.6..."
docker build -f Dockerfile.test -t hookapp-test:ruby2.6 .
echo "✓ Docker image built"
echo ""

# Run the container to test installation
echo "Testing installation in container..."
echo "---"
docker run --rm hookapp-test:ruby2.6
echo "---"
echo ""

# Test with sudo simulation (install as root in container)
echo "Testing installation as root (simulating sudo)..."
echo "---"
docker run --rm hookapp-test:ruby2.6 sh -c "gem install hookapp-*.gem && hook --version && hook help"
echo "---"
echo ""

echo "✓ All tests completed!"
echo ""
echo "To manually inspect the container:"
echo "  docker run -it --rm hookapp-test:ruby2.6 /bin/bash"

