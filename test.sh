#!/bin/sh

# Code Signing Identity
CODE_SIGN_IDENTITY="iPhone Developer: ilich.vin@gmail.com"

# provision profile
PROVISION="$PWD/provision/arm1.ru.mobileprovision"

# имя схемы
SCHEME="FacebookTests"
WORKSPACE="$PWD/FacebookTests.xcworkspace"
BUNDLEID="com.grapes-studio.FacebookTests"
#PRODUCT_BUNDLE_IDENTIFIER="${BUNDLEID}"

xcodebuild -workspace "${WORKSPACE}" \
-scheme "${SCHEME}" \
-configuration Debug \
-destination 'platform=iOS Simulator,name=iPhone 5s,OS=10.3' \
-sdk iphonesimulator \
test-without-building

if [ $? != 0 ]; then
echo "Testing failed."
exit 1
fi

echo "Testing succeeded."  
