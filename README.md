# diary_flutter_app | branch: main (json-data)
<img width="1552" height="841" alt="Image" src="https://github.com/user-attachments/assets/058bbed4-b30a-40b0-80ae-fb5e09d56c64" />

<img width="1563" height="828" alt="Image" src="https://github.com/user-attachments/assets/191a2dfc-73a5-49bf-9b59-47708a71c65c" />


## Purpose
A lightweight Flutter journal that surfaces the user’s thoughts, memories, and word count statistics via a Courier Prime theme while keeping everything on-device. The root widget wires a `ChangeNotifierProvider` so the diary entries load once at startup and feed the multi-tab `HomeScreenNew` that exposes a summary, year view, and search interface.

## Requirements
- Flutter SDK 3.x (pubspec bounds `>=3.0.0 <4.0.0`).  
- Dependencies: `provider` for simple state management, `google_fonts` for typography, `path_provider` for locating the documents directory, `intl` for localized date strings, plus shared defaults such as `cupertino_icons`.

## Installation
1. Install Flutter from flutter.dev and ensure `flutter doctor` reports no blocking issues.
2. Run `flutter pub get` from the project root to fetch the declared dependencies (`pubspec.yaml` lines 9-24).

## Running
1. Connect a device or start an emulator.
2. Launch `flutter run` (add `-d <device-id>` when targeting a specific platform).
3. The app boots `MyApp` (`lib/main.dart:7-35`), applies a dark Material3 theme, and shows `HomeScreenNew` with floating-action navigation to `EntryScreen`.

## Real-world Usage
- Track entries grouped by year, view word/entry counts on the welcome card, and toggle between “Início”, “Anos”, and “Pesquisar” tabs (`lib/screens/home_screen_new.dart:36-184`).  
- Drill down into a specific year to browse monthly sections and tap a card to edit entries (`lib/screens/entries_by_year_screen.dart:26-164`).  
- Use the search tab with indexed filtering and inline previews before opening the full entry editor (`lib/screens/search_screen.dart:28-151`).

## Architecture
- `DiaryProvider` handles the in-memory list of `Entry` models, exposes CRUD helpers, and persists changes through `DiaryService` (`lib/providers/diary_provider.dart:5-32`).  
- `DiaryService` reads/writes a local `diary.json` at `getApplicationDocumentsDirectory()` to survive restarts (`lib/services/diary_service.dart:6-30`).  
- `Entry` serializes/deserializes to JSON with an ISO timestamp so the service can round-trip without losing metadata (`lib/models/entry.dart:3-29`).

## Storage behavior
- This branch keeps every entry in the host device’s Documents directory inside `diary.json`; the `DiaryService` serializes the in-memory list to JSON when saving and decodes it back during startup, so nothing ever leaves the local filesystem.  
- The alternate branch that syncs via GitHub Gists is tracked separately—update the link below once you decide where to host it:

  [gist-based storage branch](<gist-branch-link>)

## Environment Config
- Dart SDK constraint: `>=3.0.0 <4.0.0` (pubspec lines 6-7).  
- No external API keys or platform-critical env vars; the journal relies solely on device storage.

## Testing
Run `flutter test` to execute whatever tests exist or to confirm the default Flutter setup (`pubspec.yaml:19-22`).

## Limitations
- Entries live only in the device’s documents directory; there is no cloud sync or backup capability.  
- Editing/deleting requires manual confirmation in the modal dialog, and there is no conflict resolution if multiple instances run simultaneously.  
- Shared preferences is declared but unused, so persistent settings would require additional wiring.
