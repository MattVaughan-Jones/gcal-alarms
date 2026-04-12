# AVD id from `flutter emulators` (Android Studio). Override: `ANDROID_AVD=… just run-android` or `just android_avd=… run-android`.
android_avd := env_var_or_default("ANDROID_AVD", "Pixel_7_Pro_API_35")

default:
	@just --list

# Boot the Android emulator (if not already running), then run the app on it.
# Uses a real device id (e.g. emulator-5554); `flutter run -d android` does not match all setups.
run-android:
	ANDROID_AVD="{{android_avd}}" ./scripts/run-android.sh

# Repair/sync native runners (Android + iOS only) and fetch packages.
setup:
	flutter create . --platforms=android,ios
	flutter pub get

pub-get:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test
