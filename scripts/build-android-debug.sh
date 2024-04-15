#!/usr/bin/env bash
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --debug \
                  --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                  --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                  --dart-define=PLATFORM="$PLATFORM" \
                  --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER"

cp build/app/outputs/apk/debug/app-debug.apk twake-on-matrix-debug.apk
