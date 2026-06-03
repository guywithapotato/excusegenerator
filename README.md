# bahane üretici 3000

offline-first flutter android app for generating funny excuses in türkçe and english.

## build

```bash
flutter pub get
flutter build apk --release
```

the release apk will be created under:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## ios

ios builds must be made on macos with xcode installed.

```bash
flutter pub get
flutter build ios --release
```

to run in the ios simulator on macos:

```bash
open -a Simulator
flutter run
```

## notes

- no login, ads, tracking, subscriptions, or internet access are required.
- language and theme can be selected during onboarding and changed instantly in settings.
- all app data is stored locally with shared preferences.
