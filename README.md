# Clipboard History Manager

## Overview
A cross-platform mobile clipboard history manager built with Flutter, supporting both iOS and Android. 

## Features
- Real-time clipboard monitoring
- Local storage of clipboard history
- Search functionality
- Copy and delete individual clipboard entries
- Clear entire clipboard history
- Timestamp for each clipboard entry

## Project Structure
```
clipboard_manager/
├── lib/
│   ├── core/
│   │   ├── clipboard_service.dart
│   │   ├── history_manager.dart
│   │   └── shared_prefs_service.dart
│   ├── models/
│   │   └── clipboard_item.dart
│   ├── providers/
│   │   └── clipboard_provider.dart
│   └── ui/
│       ├── screens/
│       │   └── home_screen.dart
│       └── widgets/
│           └── clipboard_list_item.dart
└── pubspec.yaml
```

## Dependencies
- Flutter SDK
- `provider` for state management
- `clipboard` for clipboard interactions
- `shared_preferences` for local storage
- `uuid` for unique item identification
- `intl` for timestamp formatting

## Setup
1. Ensure Flutter SDK is installed
2. Clone the repository
3. Run `flutter pub get`
4. Connect a device or start an emulator
5. Run `flutter run`

## Usage
- App automatically tracks clipboard content
- Search through clipboard history
- Tap the copy icon to restore a previous clipboard entry
- Tap the delete icon to remove a specific entry
- Use the clear all button to reset clipboard history

## Limitations
- Background clipboard monitoring may have platform-specific restrictions
- Requires app to be open to capture clipboard changes

## Contributing
Contributions are welcome! Please submit pull requests or open issues on the repository.

## Future Improvements
- Enhanced error handling
- More advanced search functionality
- Customizable preferences
- Platform-specific background monitoring
- Comprehensive testing
