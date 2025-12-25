#!/bin/bash
# Fix script for broken hookapp installation
# This script cleans up broken system Ruby installations and provides proper installation instructions

set -e

echo "=== Hookapp Installation Fix Script ==="
echo ""

# Check for broken system Ruby installation
BROKEN_WRAPPER="/usr/local/bin/hook"
BROKEN_GEM_PATH="/Library/Ruby/Gems/2.6.0/gems/hookapp-2.1.2"

if [ -f "$BROKEN_WRAPPER" ]; then
	echo "Found broken wrapper script at $BROKEN_WRAPPER"
	echo "Removing broken wrapper script..."
	sudo rm -f "$BROKEN_WRAPPER"
	echo "✓ Removed broken wrapper script"
else
	echo "✓ No broken wrapper script found"
fi

if [ -d "$BROKEN_GEM_PATH" ]; then
	echo "Found broken gem installation at $BROKEN_GEM_PATH"
	echo "Removing broken gem installation..."
	sudo rm -rf "$BROKEN_GEM_PATH"
	echo "✓ Removed broken gem installation"
else
	echo "✓ No broken gem installation found"
fi

# Check for system Ruby gem installation
if sudo gem list hookapp -i >/dev/null 2>&1; then
	echo ""
	echo "Found hookapp installed in system Ruby"
	echo "Uninstalling from system Ruby..."
	sudo gem uninstall hookapp -x
	echo "✓ Uninstalled from system Ruby"
else
	echo "✓ No system Ruby installation found"
fi

echo ""
echo "=== Installation Instructions ==="
echo ""
echo "To install hookapp properly, use one of these methods:"
echo ""
echo "1. Install without sudo (recommended):"
echo "   gem install hookapp"
echo ""
echo "2. If you must use sudo (not recommended):"
echo "   sudo gem install hookapp"
echo "   # Then verify installation:"
echo "   hook --version"
echo ""
echo "3. Install from local source:"
echo "   gem build hookapp.gemspec"
echo "   gem install pkg/hookapp-*.gem"
echo ""
echo "After installation, verify with: hook --version"
echo ""
