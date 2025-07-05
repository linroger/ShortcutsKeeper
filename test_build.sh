#!/bin/bash
cd "/Users/rogerlin/XCode-Projects/ShortcutsKeeper"
echo "Building ShortcutsKeeper..."
xcodebuild -scheme ShortcutsKeeper clean build 2>&1
echo "Build completed."