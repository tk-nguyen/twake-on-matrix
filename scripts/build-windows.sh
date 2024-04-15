#!/bin/bash
echo "Building for Windows."
flutter config --enable-windows-desktop
flutter clean
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
flutter build windows --release -v \
                      --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                      --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                      --dart-define=PLATFORM="$PLATFORM" \
                      --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER"

# Building libolm
echo "Building libolm."
LIBOLM_VERSION=3.2.15
git clone https://gitlab.matrix.org/matrix-org/olm.git -b "$LIBOLM_VERSION"
(cd olm; cmake . -Bbuild; cmake --build build)
