# diary | branch: gist-data

<img width="701" height="698" alt="Image" src="https://github.com/user-attachments/assets/6cbc9941-9f5a-4fae-9e38-01a475f00854" />

<img width="1634" height="857" alt="Image" src="https://github.com/user-attachments/assets/e5bcbe28-72c2-44a3-8063-044eae44baa7" />

  ## Purpose

  A Flutter-based private diary that keeps local archives, exposes yearly/keyword views, and displays entry
  counts and word totals through the HomeScreen/tabbed UI, keeping the UI minimal and mono-spaced for
  compatibility with mobile and desktop devices lib/screens/home_screen.dart:1. The app boots through
  main.dart, loading .env credentials before wiring the DiaryProvider that orchestrates sync/data readiness
  lib/main.dart:1.

  ## Requirements

  - Flutter / Dart 3.x SDK (per environment in pubspec.yaml and Material 3 UI) pubspec.yaml:6
  - Access to GitHub (for optional cloud backups) via a token lib/services/gist_service.dart:7
  - The flutter dependencies listed in pubspec.yaml (http, shared_preferences, provider, google_fonts,
    path_provider, intl, flutter_dotenv, Cupertino icons) pubspec.yaml:9

  ## Install

  1. Clone the repo (if not already).
  2. Run flutter pub get to install dependencies listed in pubspec.yaml.
  3. Ensure the .env asset (wired through pubspec.yaml assets) exists alongside the project root for dot-env
     loading pubspec.yaml:26.

  ## Run

  - Use flutter run (specify a device/emulator) to start the app; main.dart ensures the provider is created
    and the splash wrapper waits for initialization before presenting HomeScreen lib/main.dart:1.
  - Hot reload/hot restart behave normally once DiaryProvider has warmed the cache lib/providers/
    diary_provider.dart:1.

  ## Real-world Usage

  - Write, edit, and delete diary entries via EntryScreen, which enforces non-empty content, supports titles,
    and reuses Entry IDs/dates to keep edits consistent lib/screens/entry_screen.dart:1.
  - Track entries by year with EntriesByYearScreen, which groups entries by month, shows dates, and opens
    entries for editing lib/screens/entries_by_year_screen.dart:1.
  - Quickly search titles and contents through SearchScreen, which updates results as the query changes and
    leads back to the editor lib/screens/search_screen.dart:1.
  - Offline-first behavior shows stats immediately while background sync updates the cache, making it
    resilient on the go lib/providers/diary_provider.dart:1.

  ## Architecture

  - main.dart sets up MultiProvider, MaterialApp, and a splash wrapper that blocks until
    DiaryProvider.isInitialized is true lib/main.dart:1.
  - DiaryProvider handles loading/saving, syncing, sort/stats updates, and exposes entry lists, year buckets,
    and status flags to the UI; it only syncs after local cache initialization and can force-cloud sync when
    needed lib/providers/diary_provider.dart:1.
  - DiaryService reads/writes a shared-preferences cache and triggers cloud sync without blocking the initial
    load; saving tries the cloud only when configured lib/services/diary_service.dart:1.
  - CloudService talks to GitHub Gist, resolves the Gist ID via .env, shared preferences, or by discovering an
    existing file, and creates/patches a private Gist named meu_diario_backup.json lib/services/
    gist_service.dart:7.
  - Entries are normalized via the Entry model, which safely parses/serializes IDs and dates to JSON strings
    for storage/backups lib/models/entry.dart:1.

![UML Class Diagram](https://cdn-0.plantuml.com/plantuml/png/PP71QiCm38RlVGeVDqhw2ANGTOTTDXXx01Efm-18Gr82OUpTjqPnPjnJyl_6toVaareK6uUysuNGvwWQBcGoX--_7C8-WNyjMKR_xPaCoJn0jBKsVb6cXqTFL-5Xop__yASKPNuJdXAWh99kATzHfjIZDqWc2TM3pjIVCu-mmhi8y2eVNpTtgG0pUcfj1Lna2wcMxJD7kBYmZAznmb8rpFh-jYKzCrtJvoW81I4OOV4_fumrjowTt6obwuwXMKaTb_DwYZl0uN3qLxonJqWm3laN)

<details>
  <summary>UML CLASS DIAGRAM</summary>
  @startuml

  class Entry {
    +id
    +title
    +content
    +date
    +toJson()
    +fromJson()
  }

  class DiaryProvider {
    -DiaryService
    -entries
    -syncCloud()
    -addOrUpdate()
    -delete()
  }

  class DiaryService {
    -CloudService
    +loadEntries()
    +saveEntries()
  }

  class CloudService {
    +isConfigured()
    +readDiaryFile()
    +saveDiaryFile()
  }

  DiaryProvider --> DiaryService
  DiaryService --> CloudService
  DiaryProvider ..> Entry

  @enduml
</details>

  ## Environment Configuration

  - Create a .env file (included in Flutter assets) with at least:

    GITHUB_TOKEN=ghp_...
    to allow cloud sync; the provider checks dotenv for GITHUB_TOKEN before using GitHub APIs lib/services/
    gist_service.dart:7.
  - Optionally set GIST_ID in .env when you already have a backup Gist; otherwise the app searches via the
    GitHub API and caches the discovered ID in shared preferences lib/services/gist_service.dart:51.
  - Keep the .env file outside version control since it contains personal tokens.

  ## Testing

  - No automated tests are defined (test/ is empty). Manual verification via flutter run is the current
    validation path.

  ## Limitations

  1. Cloud sync relies entirely on a GitHub personal access token and the single Gist file
     meu_diario_backup.json; no alternative cloud providers are supported lib/services/gist_service.dart:7.
  2. There is no encryption beyond the private Gist flag, so the token and pasted content must be guarded
     manually lib/services/gist_service.dart:7.
  3. Offline cache is stored in SharedPreferences, which may not scale beyond light diary use cases lib/
     services/diary_service.dart:1.
  4. No automated tests or CI gatekeepers exist yet, so regressions must be prevented through careful manual
     testing before shipping.
