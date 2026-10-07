#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p artifacts
sw_vers | tee artifacts/environment.txt
xcodebuild -version | tee -a artifacts/environment.txt
xcrun simctl list devices available -j > artifacts/devices.json
SIMULATOR_ID=$(python3 - <<'PY'
import json
with open("artifacts/devices.json") as f:
    devices = json.load(f)["devices"]
for runtime, entries in sorted(devices.items(), reverse=True):
    if ".iOS-" not in runtime:
        continue
    for device in entries:
        if device["isAvailable"] and device["name"].startswith("iPhone"):
            print(device["udid"])
            raise SystemExit(0)
raise SystemExit("No available iPhone simulator runtime")
PY
)
printf 'Simulator ID: %s\n' "$SIMULATOR_ID" | tee -a artifacts/environment.txt
plutil -lint FreeIOSProbe.xcodeproj/project.pbxproj
xcodebuild -project FreeIOSProbe.xcodeproj -scheme FreeIOSProbe \
  -configuration Debug -sdk iphonesimulator \
  -destination "id=$SIMULATOR_ID" -derivedDataPath DerivedData/simulator \
  CODE_SIGNING_ALLOWED=NO build analyze | tee artifacts/simulator-build.log
xcrun simctl boot "$SIMULATOR_ID" || xcrun simctl bootstatus "$SIMULATOR_ID" -b
xcrun simctl bootstatus "$SIMULATOR_ID" -b
xcrun simctl install "$SIMULATOR_ID" DerivedData/simulator/Build/Products/Debug-iphonesimulator/FreeIOSProbe.app
xcrun simctl launch "$SIMULATOR_ID" org.example.FreeIOSProbe
sleep 3
xcrun simctl io "$SIMULATOR_ID" screenshot artifacts/simulator.png
xcodebuild -project FreeIOSProbe.xcodeproj -scheme FreeIOSProbe \
  -configuration Debug -destination "id=$SIMULATOR_ID" \
  -derivedDataPath DerivedData/simulator -resultBundlePath artifacts/UITests.xcresult \
  -parallel-testing-enabled NO CODE_SIGNING_ALLOWED=NO test | tee artifacts/ui-tests.log
xcodebuild -project FreeIOSProbe.xcodeproj -scheme FreeIOSProbe \
  -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' \
  -derivedDataPath DerivedData/device CODE_SIGNING_ALLOWED=NO build | tee artifacts/unsigned-device-build.log
ditto -c -k --keepParent DerivedData/simulator/Build/Products/Debug-iphonesimulator/FreeIOSProbe.app artifacts/simulator-app.zip
printf 'PASS: simulator build, analysis, launch, UI interaction, unsigned iOS device build\n' | tee artifacts/result.txt
