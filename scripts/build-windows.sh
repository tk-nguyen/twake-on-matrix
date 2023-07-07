#!/bin/bash
echo "Building for Windows."
flutter config --enable-windows-desktop
flutter clean
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
flutter build windows --release -v

# Building libolm
echo "Building libolm."
git clone https://gitlab.matrix.org/matrix-org/olm.git
(cd olm; cmake . -Bbuild; cmake --build build)
