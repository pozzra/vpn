#!/bin/bash
set -e

echo "=== Building VPN One iOS App Bundle ==="
flutter build ios --release --no-codesign

echo "=== Creating iOS Payload Structure ==="
rm -rf build/ios/ipa
mkdir -p build/ios/ipa/Payload

echo "=== Copying Runner.app into Payload/ ==="
cp -r build/ios/iphoneos/Runner.app build/ios/ipa/Payload/

echo "=== Packaging Payload into VPN_One.ipa ==="
cd build/ios/ipa
zip -r -q VPN_One.ipa Payload
cd ../../..

echo "=== IPA Build Complete! ==="
echo "Output: build/ios/ipa/VPN_One.ipa"
