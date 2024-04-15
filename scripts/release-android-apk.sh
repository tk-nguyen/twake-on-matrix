#!/usr/bin/env sh

set -eux

flutter build apk --release \
                  --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                  --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                  --dart-define=PLATFORM="$PLATFORM" \
                  --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER"

version=$(git describe --tags --exact-match)
cp build/app/outputs/apk/release/app-release.apk twake-"$version"-android.apk
