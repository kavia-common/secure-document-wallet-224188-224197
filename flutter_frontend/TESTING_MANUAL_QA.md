# Secure Document Wallet - Manual QA Checklist

This document guides a full manual verification on the running preview (Appetize or device).

Environment:
- Container: flutter_frontend
- Preview URL (from runner): https://appetize.io/embed/m7wc6r35jhcphze6sfq6vyn3be

Device Permissions:
- Files/Media Access (for file picker)
- Biometrics (if available)
- Local storage (DB persistence)

Record for each step:
- Expected Result
- Actual Result
- Errors/Prompts
- Notes

Sections:
1. App Launch & Lock Setup
2. Unlock (PIN & Biometric)
3. Folder Management
4. Import Documents via File Picker
5. Open/Preview Documents
6. Share a Document
7. Delete a Document
8. Persistence Across Restarts
9. General Observations

---

1) App Launch & Lock Setup
Steps:
- Launch the app in Appetize.
- On first run, you should see a lock setup flow (PIN entry). If biometrics are supported, an option should appear.
- Create a 4-6 digit PIN, confirm it.

Expected:
- App accepts a valid PIN and stores it securely (no crash).
- If biometric is available, toggle/enable it after PIN creation (optional).

Record:
- Any permission prompts (biometric prompt).
- Errors in lock service.

2) Unlock (PIN & Biometric)
Steps:
- Lock screen should be shown after app relaunch.
- Try unlocking with PIN.
- If biometric enabled, attempt biometric unlock.

Expected:
- PIN unlock succeeds with correct PIN; fails with incorrect PIN with friendly error.
- Biometric prompt appears and succeeds/fails cleanly.

Record:
- Messages on wrong PIN.
- Biometric availability prompt status.

3) Folder Management
Steps:
- From Home, create a folder (“Personal”).
- Create another folder (“Work”).
- Rename a folder (if supported).
- Open a folder to view its empty state.

Expected:
- New folders appear in list.
- Empty folder shows an empty state UI without errors.

Record:
- Any validation messages (duplicate name, empty name).
- UI refresh behavior.

4) Import Documents via File Picker
Steps:
- Enter “Personal” folder.
- Use “Add/Upload” or Floating Action Button to open File Picker.
- Select a small PDF or image (use Appetize demo files if available).
- Confirm import.

Expected:
- Permission prompt for storage may appear; grant it.
- Document entry appears with name, type, and modified date.

Record:
- Permission prompts.
- Any errors from file_service or repository.

5) Open/Preview Documents
Steps:
- Tap on the imported document.
- Preview should open (PDF viewer or image viewer).
- Navigate back.

Expected:
- Document previews without crash.
- Proper back navigation to folder list.

Record:
- Viewer performance, rendering errors.

6) Share a Document
Steps:
- From document tile overflow or detail, select Share.
- System share sheet should appear.

Expected:
- Share intent opens; canceling returns to app gracefully.

Record:
- Any errors from share_service.

7) Delete a Document
Steps:
- From document tile options or detail, select Delete.
- Confirm deletion.

Expected:
- Document removed from list.
- No orphaned previews.

Record:
- Confirmation prompts and any errors.

8) Persistence Across Restarts
Steps:
- Close the app session (restart Appetize).
- Unlock with PIN or biometric.
- Verify folders and documents still present.
- Open a previously imported document to ensure it persists.

Expected:
- Data persists (folders/docs).
- No re-import needed.

Record:
- Any missing items or DB issues.

9) General Observations
- Performance: scrolling, navigation latency.
- UI consistency with style guide (light, modern, blue/cyan accents).
- Error handling: friendly messages, no stack traces.
- Security: no sensitive data in logs or UI.

---

Runtime Error & Permission Prompt Log Template

- Timestamp:
- Step:
- Component (lock_service, secure_storage_service, file_service, share_service, repositories):
- Error message / prompt text:
- Repro steps:
- Screenshots (if possible):
- Notes:

---

Known Limitations to Validate
- File picker availability in Appetize may be limited; if not usable, test on device/emulator.
- Biometric prompt may not be supported in Appetize; validate PIN unlock as primary.
- Large files: out-of-scope; test small PDFs/images.

Pass/Fail Criteria
- All critical flows (setup/unlock, create folder, import small doc, view, share, delete, persistence) complete without crashes or blocking errors.
- Permissions requested as needed and handled gracefully.
