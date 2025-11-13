# Secure Document Wallet — Flutter Frontend

## Overview

This mobile app is an offline-first document wallet. It lets you:
- Create folders and organize documents
- Import files from the device (via system picker/SAF)
- View lightweight inline previews for certain formats
- Share documents using the native share sheet
- Protect access with a PIN and optionally biometrics

All data is stored locally on the device using a SQLite database. Sensitive secrets (like the PIN hash and salt) are kept in platform keystores via secure storage. The architecture is designed to support optional cloud sync in the future, but no network/cloud backend is required to run the app today.

## Getting Started

### Prerequisites

- Flutter SDK installed (stable channel recommended)
- Android Studio or VS Code with Flutter/Dart extensions
- Android emulator or physical device
- Java/Gradle toolchain (configured by Flutter/Android Studio)

### Install dependencies

From the flutter_frontend directory:

```bash
flutter pub get
```

### Run the app

- Using CLI:
  - Debug: `flutter run`
  - Specify device: `flutter devices` then `flutter run -d <deviceId>`
- Using IDE:
  - Open the `flutter_frontend` folder in Android Studio or VS Code
  - Select a device/emulator and press Run/Debug

The app initializes its local database on first launch and presents the lock/setup screen flow.

## Project Structure

- lib/main.dart: application entry point and initialization
- lib/core/services:
  - local_auth_service.dart: wraps local_auth for biometric/device authentication
  - lock_service.dart: manages lock state, PIN verification, biometric preference, auto-lock
  - secure_storage_service.dart: encrypted key-value storage via flutter_secure_storage
- lib/services/files:
  - file_service.dart: file import via system picker/SAF, saves into app documents directory
  - share_service.dart: native share sheet integration via share_plus
- lib/data:
  - db/app_database.dart: SQLite database (sqflite) bootstrap and schema
  - models/: Document and Folder models
- lib/features:
  - folders/repository/: folder repository (CRUD)
  - documents/repository/: document repository (CRUD)
- lib/ui/screens:
  - lock/lock_screen.dart: PIN setup and unlock flows
  - home/home_screen.dart: folder grid and quick actions
  - folder/folder_detail_screen.dart: documents list within a folder
  - document/document_view_screen.dart: inline preview and actions
- lib/routes/app_router.dart: route definitions and parsing
- lib/core: app_constants, theme, and validators
- android/app/src/main/AndroidManifest.xml: Android permissions and setup

## Permissions and Platform Behavior

The app follows a privacy-first, sandboxed storage approach:

- Biometrics/device credentials: local_auth
  - Android Manifest declares:
    - android.permission.USE_BIOMETRIC
    - android.permission.USE_FINGERPRINT (legacy)
  - No additional runtime permission prompts are needed for biometrics; the OS dialog is presented by the local_auth plugin.

- File access: Storage Access Framework (SAF)
  - Files are selected using a system picker (file_picker) and then copied into the app’s documents directory (path_provider).
  - No broad storage permissions (READ/WRITE_EXTERNAL_STORAGE) are requested.
  - On older Android versions, the system picker still provides access without broad storage permissions.

- Sharing: share_plus
  - Uses OS-level share sheets. No additional permissions are required.

- Internet (debug/profile only)
  - android/app/src/debug/AndroidManifest.xml and profile manifest include INTERNET permission for Flutter tooling (hot reload, etc.). The release app does not need network access to function.

References:
- android/app/src/main/AndroidManifest.xml
- lib/core/services/local_auth_service.dart
- lib/services/files/file_service.dart

## Security: PIN Setup and Unlock Flow

- First launch:
  - If no PIN is configured, the app prompts to create a PIN and confirm it.
  - The PIN is validated locally (minimum length enforced in UI; see lock_screen.dart), then saved using secure storage as a salted HMAC-SHA256 hash. The raw PIN is never stored.
- Unlock:
  - If a PIN exists, enter the PIN to unlock. A retry counter limits brute-force attempts in a session.
  - If biometrics are enabled and available, you can unlock using biometrics/device credentials.
- Biometric preference:
  - Users can toggle biometric unlock. The preference is stored in SharedPreferences; the biometric capability is validated at runtime using local_auth.
- Auto-lock:
  - The LockService supports auto-lock on app pause/resume based on a configured duration (set to immediate lock by default in code paths that pass Duration.zero).

Relevant files:
- lib/core/services/lock_service.dart
- lib/core/services/secure_storage_service.dart
- lib/core/services/local_auth_service.dart
- lib/ui/screens/lock/lock_screen.dart

## Where Files Are Stored Locally

- On import, a selected file is copied into the application documents directory:
  - path_provider.getApplicationDocumentsDirectory()
  - A unique filename is generated if a name collision occurs.
  - The document record stores the absolute path in the database.
- Only files under the application documents directory are created or deleted by FileService safeguards. Deleting a document removes both the DB row and the stored file.

Relevant files:
- lib/services/files/file_service.dart
- lib/data/db/app_database.dart
- lib/data/models/document.dart

## Feature Overview

- Folders
  - Create, rename, and describe folders
  - View folders in a grid on the home screen
- Documents
  - Import from device (system file picker/SAF)
  - Store metadata (name, path, mime type, notes/tags)
  - Delete documents (removes DB row and locally stored file)
  - Edit name/notes
- Viewing
  - Inline previews for images and plain text formats (txt, md, csv, log)
  - Generic preview for unsupported types
  - “Open externally” action to open with a 3rd-party app if available
- Sharing
  - Share a document via native share sheet (share_plus)

UI entry points:
- Home: lib/ui/screens/home/home_screen.dart
- Folder detail: lib/ui/screens/folder/folder_detail_screen.dart
- Document view: lib/ui/screens/document/document_view_screen.dart

## Known Limitations

- Inline previews:
  - PDFs and many office formats (docx, xlsx, pptx) are not rendered inline. Use Open externally or Share.
  - Large text files are read in full; for huge files, performance may degrade.
- MIME/type detection:
  - Best-effort using file name/extension and the mime package. Some edge cases may be misidentified.
- No cloud sync:
  - The app is offline-first. There is no network backend or sync service at this time.
- No cross-device migration:
  - Moving data between devices is not built-in.

## Future Sync Notes

The data and service layers are designed for a local-first approach with possible future sync:
- Repositories (folders/documents) and AppDatabase provide clean separation for introducing a remote source and conflict resolution.
- Secure secrets (PIN hash/salt) are device-bound; remote sync should never include raw secrets.
- Consider background sync workers with explicit user consent and end-to-end encryption for any remote storage.

## Usage Guide

1. Launch the app
2. Set a PIN when prompted
3. (Optional) Enable biometric unlock
4. Create a folder from the Home screen
5. Open the folder and add documents using the Upload/Add button (system picker)
6. Tap a document to view; use Share or Open to send/open with other apps
7. Use the lock icon (if present in top bar) or background/foreground to test auto-lock

## Troubleshooting

Android permissions and biometrics:

- Biometric prompt not showing:
  - Ensure the emulator has a configured fingerprint/biometric:
    - Android Studio Emulator: Extended controls > Settings > Fingerprint. Add a fingerprint and use “Touch sensor” to simulate.
  - Some emulators may report no biometric hardware. Try “isDeviceSupported()” fallback via local_auth, which can present device credential.
  - On physical devices, ensure screen lock and biometrics are configured in device settings.

- SAF picker issues:
  - If the system picker returns no file path (content URI only), file_service persists bytes/readStream into app documents directory. Ensure you are selecting files from accessible providers.
  - On very old Android versions or uncommon providers, some URIs may not expose streams. Try a different file source or copy the file locally first.

- “No app found to open this file”:
  - Not all file types have associated handlers on the device/emulator. Use Share to transfer to an app that can open it or install a suitable viewer.

- Emulator storage visibility:
  - Imported files are copied into the app sandbox. They are not visible in general external storage nor visible to other apps unless shared.

- Build or dependency errors:
  - Run `flutter pub get` to ensure dependencies are resolved.
  - Ensure local_auth, flutter_secure_storage, file_picker, path_provider, sqflite, share_plus, open_filex, and mime are included in pubspec.yaml (this repo’s pubspec already includes required packages).
  - Clean and rebuild: `flutter clean && flutter pub get && flutter run`.

## Compliance and Privacy Notes

- The app does not log sensitive data such as PINs or file contents.
- The PIN is never stored in plaintext; only a salted HMAC-SHA256 hash and salt are stored in secure storage.
- File deletions are restricted to the application documents directory by defensive checks.
- No network transmissions are performed by the app for core functionality.

## References in Code

- Lock and authentication:
  - lib/core/services/lock_service.dart
  - lib/core/services/local_auth_service.dart
  - lib/core/services/secure_storage_service.dart
  - lib/ui/screens/lock/lock_screen.dart
- Files and sharing:
  - lib/services/files/file_service.dart
  - lib/services/files/share_service.dart
- Database and models:
  - lib/data/db/app_database.dart
  - lib/data/models/document.dart
  - lib/data/models/folder.dart
- UI and navigation:
  - lib/ui/screens/home/home_screen.dart
  - lib/ui/screens/folder/folder_detail_screen.dart
  - lib/ui/screens/document/document_view_screen.dart
  - lib/routes/app_router.dart
- Permissions/Manifest:
  - android/app/src/main/AndroidManifest.xml
  - android/app/src/debug/AndroidManifest.xml
  - android/app/src/profile/AndroidManifest.xml
