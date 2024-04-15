#!/bin/sh -ve
flutter config --enable-macos-desktop
flutter clean
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
cd macos
bundle exec fastlane sync_dev
pod install --repo-update
pod update
flutter build macos --profile -v \
                    --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                    --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                    --dart-define=PLATFORM="$PLATFORM" \
                    --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER"
