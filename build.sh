
#!/bin/sh

# Code Signing Identity
CODE_SIGN_IDENTITY="iPhone Developer: ilich.vin@gmail.com"

# provision profile
PROVISION="$PWD/provision/arm1.ru.mobileprovision"

# project
SCHEME="FacebookTests"
WORKSPACE="$PWD/FacebookTests.xcworkspace"
BUNDLEID="com.grapes-studio.FacebookTests"

#install/update cocoapods
if [ -e "Pods" ]
then
pod update
else
pod install
fi

#PRODUCT_BUNDLE_IDENTIFIER="${BUNDLEID}"
xcodebuild -workspace "${WORKSPACE}" \
-scheme "${SCHEME}" \
-configuration Debug \
-destination 'platform=iOS Simulator,name=iPhone 5s,OS=10.3' \
-sdk iphonesimulator \
clean \
build-for-testing \

if [ $? != 0 ]; then
echo "Build failed."
exit 1
fi

echo "Build succeeded."  
