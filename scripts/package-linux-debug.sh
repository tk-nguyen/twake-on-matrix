#!/bin/bash

echo "Packaging."
flutter pub global run flutter_distributor:main.dart package --platform linux --targets zip --skip-clean --flutter-build-args="profile"
