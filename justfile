default:
	@just --list

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
