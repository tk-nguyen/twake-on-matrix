#!/usr/bin/env bash
flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
flutter build apk --debug
cp build/app/outputs/apk/debug/app-debug.apk twake-on-matrix-debug.apk
