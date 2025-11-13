# Manual QA - Flutter Offline-first Document Wallet

This checklist guides a manual preview verification run on the Appetize or local emulator build. It focuses on critical user flows: lock security, folder/document management, file import/preview/share/delete, and offline persistence behavior.

Run target:
- Environment: Appetize embed or Android/iOS emulator
- Build: flutter_frontend (current workspace)

Preconditions:
- Fresh install scenario: App may not have lock configured.
- Storage permission will be requested on first file import/share where applicable.

Test Data:
- Use any 2–3 small PDF/PNG/JPEG/TXT files from device/emulator storage (e.g., Downloads).

1) App Launch and First-run
- Action: Launch the app.
- Expected:
  - Shows Lock screen on first launch with options to set up biometric/PIN (per app design).
  - If biometric available: Prompt from OS. If not: fallback PIN setup.
  - No crash or red-screen errors.
- Capture:
  - Note any permission/OS prompts.
  - Errors in console logs (if running locally: flutter run).

2) Lock Setup (Biometric or PIN)
- Action:
  - If biometric available, enable biometric unlock.
  - Otherwise set a PIN (record a test PIN for verification).
- Expected:
  - Setup completes and user is navigated to Home screen.
  - Subsequent app open requires unlock (biometric/PIN).
- Capture:
  - Any errors from local_auth_service or secure_storage_service.
  - Any repeated prompts or failures to enroll.

3) Unlock Flow Verification
- Action:
  - Lock the app (send to background) and reopen.
  - Provide biometric/PIN.
- Expected:
  - Successful unlock returns to Home screen without resetting state.
- Negative:
  - Enter wrong PIN once.
- Expected:
  - Friendly error message, no crash.
- Capture:
  - Errors, unexpected retries, or session resets.

4) Folder Creation
- Action:
  - Create folders: "Personal", "Work".
- Expected:
  - Folders appear in Home list with correct names.
  - No duplicates unless explicitly created.
- Capture:
  - Errors from folder_repository or app_database writes.

5) Document Import via File Picker
- Action:
  - Open "Personal" folder.
  - Import files using Floating Action Button or upload action.
  - Choose 2 files with different types (e.g., PDF and PNG).
- Expected:
  - OS file picker permission prompt may appear (Android READ/WRITE or scoped storage).
  - On acceptance, documents are added and listed with filenames and metadata.
- Capture:
  - Permission prompts and outcomes.
  - Errors from file_service or document_repository.
  - Thumbnails/icon rendering behavior.

6) Document Preview
- Action:
  - Tap each imported document to open its preview screen.
- Expected:
  - Document content or a default preview placeholder loads without crash.
  - Back navigation returns to folder list.
- Capture:
  - Preview errors (e.g., unsupported type), timeouts, or blank view.

7) Share a Document
- Action:
  - From document tile or document view screen, use Share action.
- Expected:
  - OS share sheet opens with available share targets.
  - No crash; canceling returns to the app.
- Capture:
  - Share permission prompts, errors from share_service/share_utils.

8) Delete a Document
- Action:
  - Delete one imported document from the folder.
- Expected:
  - Confirmation (if implemented), then document disappears from list.
  - No orphaned UI tiles or errors.
- Capture:
  - Errors from document_repository or app_database delete operations.

9) Persistence Across App Restart (Offline-first)
- Action:
  - Fully close and relaunch the app.
  - Unlock via biometric/PIN.
- Expected:
  - Folders and remaining documents persist and display correctly.
  - No re-import required; offline storage backed by app_database is intact.
- Capture:
  - Any data loss, ordering changes, or reindexing delay anomalies.

10) Edge Permissions
- Action:
  - Deny file picker permission once; retry import.
- Expected:
  - App shows a rationale/toast and allows retry or directs to Settings.
- Capture:
  - Behavior on denial and recovery path.

11) General UX/Performance Notes
- Observe:
  - Animation smoothness, load times, freezes.
  - Error messages clarity, empty states (ui/widgets/empty_state.dart).
- Capture:
  - Suggestions for improvement.

Known Functional Areas in Codebase for Debugging:
- Lock & Auth:
  - lib/core/services/local_auth_service.dart
  - lib/core/services/lock_service.dart
  - lib/core/services/secure_storage_service.dart
- Data & Repos:
  - lib/data/db/app_database.dart
  - lib/features/folders/repository/folder_repository.dart
  - lib/features/documents/repository/document_repository.dart
- Files & Sharing:
  - lib/services/files/file_service.dart
  - lib/services/files/share_service.dart
  - lib/shared/utils/file_utils.dart
  - lib/shared/utils/share_utils.dart
- UI:
  - lib/ui/screens/ (home, lock, folder detail, document view)
  - lib/ui/widgets/ (document_tile, folder_tile, empty_state)

Runtime Issues Log Template:
- Timestamp:
- Device/Emulator:
- OS Version:
- Scenario (Step number):
- What happened:
- Expected behavior:
- Repro steps:
- Screenshots/Logs:

Pass/Fail Criteria:
- All steps complete without unhandled exceptions or crashes.
- Lock setup/unlock works reliably.
- Folders/documents persist across restart.
- File import/preview/share/delete behave per expectations.
- Permissions handled gracefully with clear messaging.

Retest Guidance:
- If a step fails due to permissions, reset app permissions and retry.
- If document previews fail for specific types, note the MIME/type and attach sample file.
- If data persistence fails, collect logs for app_database operations and repro after clean reinstall.

Notes:
- This document is intended for repeated manual verification and to capture findings during preview runs.
