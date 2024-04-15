#!/usr/bin/env bash
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
flutter build appbundle --release \
                        --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                        --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                        --dart-define=PLATFORM="$PLATFORM" \
                        --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER"

cd android
bundle exec fastlane deploy_internal_test
