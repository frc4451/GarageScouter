# Handles APK builds for Testing
android_build:
	flutter build apk

# Handles Android Bundles for Google Play Distribution
android_bundle:
	flutter build appbundle

# Handles iOS builds assuming you've assigned the correct settings in Xcode
ios_build:
	flutter build ios

# Opens iOS Runner in the event that we need to configure the build process
ios_runner:
	open ios/Runner.xcworkspace

# In the event that the ipa build fails, we can manually deploy it to TestFlight with Xcode
ios_distribute:
	open build/ios/archive/Runner.xcarchive

# CD's to iOS project folder and uses Fastlane to deploy to TestFlight
fastlane_testflight:
	cd ios/ && fastlane test_flight

# Builds Android app using Fastlane and automatically deploys to Firebase App Distribution
fastlane_firebase_android:
	cd android && fastlane android_firebase

# Test builds before we move forward with anything
test_builds: ios_build android_build

# Deploy to Dev environments (TestFlight for iOS, Firebase App Distribution for Android)
deploy_dev: test_builds fastlane_firebase_android fastlane_testflight

create_app_icon:
	flutter pub run flutter_launcher_icons