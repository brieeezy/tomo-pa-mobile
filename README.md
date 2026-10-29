# Tomo for Android

Tomo is a Flutter client for the Tomo backend. It provides a new-job alert inbox, a searchable job list with detail and apply links, and a chat assistant backed by Tomo's `/rag/messages` endpoint.

## Connect to Tomo

The app opens directly into the Tomo tabs and currently signs in with the development defaults `superadmin` / `password`, matching the Tomo web app. The credentials can be overridden at build time with `--dart-define=TOMO_USERNAME=...` and `--dart-define=TOMO_PASSWORD=...`. Use the account icon to open the connection screen and enter another backend URL or account.

For quick UI testing without an Android emulator, run `flutter run -d chrome`. The web build uses `http://localhost:8080` by default, so start the Tomo backend on the same computer first to load live data.

These defaults are for local development only. The app uses HTTP Basic authentication, so use HTTPS for any real account or deployment and remove the shared defaults before distributing a production build.

- Android emulator: use `http://10.0.2.2:8080` when the backend is running on the development computer.
- Physical phone: use the computer's LAN address and ensure the phone can reach the backend port. A production server should use HTTPS because Basic authentication sends credentials on every request.

The app refreshes notifications every 30 seconds while open. Background push when Android has closed the app is not configured; that needs Firebase Cloud Messaging and device tokens.

## Backend notifications

The desktop backend creates a `NEW_JOBS` notification for each Tomo user after a JSearch scrape inserts new jobs. The notification stores related job IDs, creation time and read time. The API provides `GET /notifications`, `GET /notifications/unread-count`, `PUT /notifications/{id}/read`, and `PUT /notifications/read-all`.

Apply the backend migration `schema/migrations/V20261029_01__tomo_notifications.sql` to an existing database. Fresh database setups also get the table from `schema/schema.sql`.

## Build and install

Open this folder in VS Code with the Flutter and Android SDK extensions configured, then connect an Android phone with USB debugging enabled or start an Android emulator. Select the device and run the app. For an installable APK, run:

```sh
flutter pub get
flutter build apk --release
```

The APK will be at `build/app/outputs/flutter-apk/app-release.apk`. The GitHub Actions workflow also builds an APK on pushes to `main` or a manual run and publishes it as the `tomo-android-apk` artifact.
