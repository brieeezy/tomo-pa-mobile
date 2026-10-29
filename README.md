# Tomo Android app (Flutter)

Tomo is a native Flutter app prototype with an overview dashboard, matched jobs, employer application confirmations, notifications, and invoice/earnings analysis.

## Build an Android APK

The source is ready to build with Flutter. A Flutter SDK and Android SDK are not installed in this workspace, so an APK cannot be produced locally here.

On a computer with Flutter and Android development tools installed:

```sh
flutter create --platforms=android --org com.tomo --project-name tomo_mobile .
flutter build apk --release
```

The resulting APK is `build/app/outputs/flutter-apk/app-release.apk`. Copy it to an Android phone, open it, and allow your browser or file manager to install apps when prompted.

The GitHub Actions workflow at `.github/workflows/build-android.yml` can build the APK in the cloud on a push to `main` or when manually triggered. Download the `tomo-android-apk` artifact from the workflow run and install the APK on the phone. Building an APK from Flutter requires the Flutter SDK and Android build tools. [Flutter's Android setup guide](https://docs.flutter.dev/platform-integration/android/setup) and [APK build instructions](https://docs.flutter.dev/deployment/android#build-an-apk) have the current SDK setup and device-install steps.

The app currently uses representative sample data. Live job matching, employer updates, push notifications, and payment processing need a backend.
