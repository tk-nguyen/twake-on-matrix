#!/bin/bash

# Install appdmg for packaging
echo "Installing appdmg."
npm install -g appdmg

echo "Packaging."
flutter pub global run flutter_distributor:main.dart package --platform macos --target dmg --skip-clean --flutter-build-args="profile"
