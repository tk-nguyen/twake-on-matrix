#!/bin/bash

# Have to run this first for dart-define
flutter build ios --dart-define=REGISTRATION_URL="$REGISTRATION_URL" \
                  --dart-define=TWAKE_WORKPLACE_HOMESERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                  --dart-define=PLATFORM="$PLATFORM" \
                  --dart-define=HOME_SERVER="$TWAKE_WORKPLACE_HOMESERVER" \
                  --no-codesign --debug

bundle exec fastlane dev
cp Runner.ipa ../Runner.ipa
