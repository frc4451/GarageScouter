# Handles iOS builds assuming you've assigned the correct settings in Xcode
build_ios:
	flutter build ios
	# flutter build ipa

# Opens iOS Runner in the event that we need to configure the build process
ios_runner:
	open ios/Runner.xcworkspace

# In the event that the ipa build fails, we can manually deploy it to TestFlight with Xcode
ios_distribute:
	open build/ios/archive/Runner.xcarchive