# Data Persistence Implementation

## Overview
The app now uses **persistent storage** to save all expenses and settings. Data will survive:
- ✅ App restarts
- ✅ Phone reboots
- ✅ App updates
- ✅ Background app termination

## Storage Architecture

### 1. SQLite Database (sqflite)
**File**: `lib/services/database_service.dart`

Stores all expenses with:
- Automatic save on add/edit/delete
- Month-based queries for efficient loading
- CRUD operations (Create, Read, Update, Delete)

**Database Schema**:
```sql
expenses (
  id TEXT PRIMARY KEY,
  categoryId TEXT,
  date TEXT (ISO8601 format),
  description TEXT,
  amount REAL
)
```

### 2. Shared Preferences
**File**: `lib/services/settings_service.dart`

Stores app settings:
- Default monthly budget
- Monthly budget overrides (for special months)
- Language preference

## Platform Support

### ✅ Android / iOS
- **Fully supported** - All data persists correctly
- SQLite database stored in app's private storage
- SharedPreferences stored securely

### ⚠️ Web (Chrome during development)
- **Limited support** - May not persist between sessions
- Uses browser storage (IndexedDB for sqflite_common_ffi_web)
- For development/testing only

## How It Works

### Expense Operations
1. **Add Expense**: Saved immediately to SQLite
2. **Edit Expense**: Updates database, reloads UI
3. **Delete Expense**: Removes from database, reloads UI
4. **View Expenses**: Loads from database by month

### Budget Settings
- **Default budget**: Saved in SharedPreferences (default: 2000 CHF)
- **Monthly override**: Optional per-month budget adjustment
- **Language**: Automatically saved when toggled

## Future Enhancements

Ready to implement:
1. **Settings Screen**: UI to change default budget
2. **Budget Override**: Button to adjust current month's budget
3. **Data Export**: Backup expenses to CSV/JSON
4. **Cloud Sync**: Optional backup to cloud storage

## Testing on Chrome

**Note**: While developing on Chrome, persistence may be limited. The app is designed primarily for Android deployment where all persistence features work correctly.

To test full persistence:
1. Build an APK: `flutter build apk`
2. Install on Android device
3. Add expenses and restart app - they will persist!
