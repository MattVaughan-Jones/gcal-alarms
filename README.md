# meetingguard

Flutter POC for Android / iOS alarm integration.

## Team setup

Install [just](https://github.com/casey/just) (`brew install just` on macOS). After cloning (or when native project files look wrong compared to your Flutter SDK), run:

```sh
just setup
```

That runs `flutter create . --platforms=android,ios` to keep only Android and iOS embedders in sync with the template, then `flutter pub get`. Run `just` with no arguments to list recipes.

Without `just`, run the same two commands from the repo root.

## Run

```sh
flutter run -d android   # or an iOS simulator / device
```

See [Flutter documentation](https://docs.flutter.dev/) for environment setup.
