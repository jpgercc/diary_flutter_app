# diary | branch: google-drive-data

<img width="701" height="698" alt="Image" src="https://github.com/user-attachments/assets/6cbc9941-9f5a-4fae-9e38-01a475f00854" />

<img width="1634" height="857" alt="Image" src="https://github.com/user-attachments/assets/e5bcbe28-72c2-44a3-8063-044eae44baa7" />

## Purpose
Personal journaling app that showcases a dark, typewriter-inspired UI (see `lib/screens/home_screen_new.dart`, `entry_screen.dart`, `search_screen.dart` and `entries_by_year_screen.dart`). Users can write, edit, delete, search, and browse entries by year while the provider (`lib/providers/diary_provider.dart`) keeps the UI in sync with the JSON-backed storage and Google Drive sync service.

## Requirements
- Flutter SDK `>=3.0.0 <4.0.0` with the packages listed in `pubspec.yaml` (Material Flutter, `provider`, `google_sign_in`, `googleapis`, `http`, `path_provider`, `intl`, `google_fonts`, `shared_preferences`, `cupertino_icons`).
- A Google account to authenticate `google_sign_in` and allow the app to reach Drive’s `appDataFolder`.

## Install
1. Clone the repo and cd into the project root.
2. Run `flutter pub get` to install dependencies declared in `pubspec.yaml`.
3. Connect a device or simulator/emulator that supports the targeted Flutter platform.

## Run
- Use `flutter run -d <device>` to build and launch the app. `main.dart` wires the `DiaryProvider` into the widget tree before showing `HomeScreenNew`.
- Hot reload works as usual; new entries are persisted immediately via `DiaryService.saveEntries` into `diary.json`, which lives under `getApplicationDocumentsDirectory()`.

## Real-world usage
- Track daily thoughts with the full-screen `EntryScreen`, which validates non-empty content and injects titles like “Sem título” when the user leaves the field blank.
- Monitor entry totals and cumulative word count on the home tab, jump to a year-specific view with `EntriesByYearScreen`, and run substring searches through `SearchScreen`.
- Floating action button always opens a fresh entry screen while tapping any existing tile lets the user edit or delete entries with confirmation.
- Background sync keeps a local `diary.json` mirrored with Google Drive’s `appDataFolder` via `DriveService.upload`/`download`.

## Architecture
- `main.dart` bootstraps Flutter bindings, wraps `MyApp` in `ChangeNotifierProvider`, and selects `HomeScreenNew` as the root widget.
- `DiaryProvider` manages an in-memory list of `Entry` (see `lib/models/entry.dart`), exposes CRUD and sync helpers, and delegates persistence to `DiaryService` plus Drive uploads/downloads via `DriveService`.
- Services follow a layered approach: `DiaryService` handles JSON serialization, file access, and uses `path_provider` to find `diary.json`; `DriveService` obtains a Google Drive API client with `GoogleSignIn`, queries/creates the stored file, and transfers bytes.
- Screens are stateless/stateful widgets that consume the provider and navigate via `Navigator.push` to reusable entry screens (`EntryScreen`, `EntriesByYearScreen`, `SearchScreen`), keeping the visual theme consistent with `google_fonts`.

## Environment configuration
1. Enable Google Sign-In and Drive API in the Google Cloud Console for the package/application identifiers you target.
2. Download and place `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) into their platform-specific directories so `google_sign_in` can locate your OAuth client.
3. Ensure `DriveService` uses the `driveAppdataScope`; no user-facing Drive permissions dialog should appear beyond signing in.
4. For desktop/web targets, configure the relevant OAuth client IDs and follow the platform instructions in the `google_sign_in` package documentation so `_getDriveApi` can successfully authenticate.

## Testing
- Run `flutter test`. (No tests currently exist, but this ensures the default test runner succeeds once you add suites.)

## Limitations
- Data is stored in plaintext `diary.json`; no encryption or multi-user separation is implemented.
- Sync is tied to the signed-in Google user and Drive’s `appDataFolder`, so it only works when the same account is authenticated on each device.
- There is no backend; the app cannot be shared between users or devices without manually reusing the same Google credentials and Drive file.
