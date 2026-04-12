# meetingguard

Flutter POC for Android / iOS alarm integration.

## Team setup

Install [just](https://github.com/casey/just) (`brew install just` on macOS). After cloning (or when native project files look wrong compared to your Flutter SDK), run:

```sh
just setup
```

That runs `flutter create . --platforms=android,ios` to keep only Android and iOS embedders in sync with the template, then `flutter pub get`. Run `just` with no arguments to list recipes.

### Android Configuration

The `android/local.properties` file is excluded from version control as it contains paths specific to your local machine. If you are missing this file, you can recreate it with the following template:

```properties
sdk.dir=/path/to/android/sdk
flutter.sdk=/path/to/flutter/sdk
```

Alternatively, running `flutter pub get` or opening the project in Android Studio/VS Code with the Flutter extension will usually regenerate this file for you.

## Run

```sh
just run-android
```

Uses the AVD named in `justfile` (`android_avd`, default `Pixel_7_Pro_API_35`). List ids with `flutter emulators`; pick another with `ANDROID_AVD=Medium_Phone_API_35 just run-android` or `just android_avd=Medium_Phone_API_35 run-android`.

```sh
flutter run -d android   # if an emulator is already booted
```

See [Flutter documentation](https://docs.flutter.dev/) for environment setup.
