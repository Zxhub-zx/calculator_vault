# Calculator Vault v1.1

## Database
No online database is required.

The app is intentionally local-only:
- PIN hash: SharedPreferences
- selected app package names: SharedPreferences
- calculator data: memory only

This means there is no Firebase/Supabase account, server, API key, or paid backend.

## Build
flutter pub get
flutter build apk --release

GitHub Actions workflow can build the APK without a local Android build machine.
