# Clipboard History Manager

## Overview
A cross-platform mobile clipboard history manager built with Flutter, supporting both iOS and Android with advanced background monitoring, robust logging, and error handling capabilities.

## Features
- Real-time clipboard monitoring
- Background clipboard tracking on both Android and iOS
- Comprehensive logging system
- Detailed error handling and reporting
- Local storage of clipboard history
- Search functionality
- Copy and delete individual clipboard entries
- Clear entire clipboard history
- Timestamp for each clipboard entry

## Logging System
### Log Levels
- `debug`: Detailed information for troubleshooting
- `info`: General operational events
- `warning`: Potential issues that don't prevent functionality
- `error`: Recoverable errors
- `critical`: Severe errors that may impact application stability

### Log Storage
- Logs are stored in the application's documents directory
- Log files are rotated when they exceed 5MB
- Supports console and file-based logging
- Configurable log levels

### Log Retrieval
Logs can be retrieved programmatically for debugging or user support.

## Error Handling
- Comprehensive try/catch blocks
- Graceful error recovery
- Detailed error logging with stack traces
- User-friendly error notifications

## Background Monitoring
### Android
- Uses foreground service for persistent clipboard monitoring
- Leverages `ClipboardManager` to detect clipboard changes
- Runs as a foreground service to improve reliability

### iOS
- Utilizes background fetch and periodic checking
- Checks clipboard content at regular intervals
- Respects iOS background task limitations

## Project Structure
```
clipboard_manager/
├── lib/
│   ├── core/
│   │   ├── clipboard_service.dart
│   │   ├── history_manager.dart
│   │   ├── logger.dart
│   │   ├── platform_channel_service.dart
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
- `path_provider` for log file management
- `permission_handler` for runtime permissions

## Setup
1. Ensure Flutter SDK is installed
2. Clone the repository
3. Run `flutter pub get`
4. Connect a device or start an emulator
5. Run `flutter run`

## Usage
- App automatically tracks clipboard content in the background
- Search through clipboard history
- Tap the copy icon to restore a previous clipboard entry
- Tap the delete icon to remove a specific entry
- Use the clear all button to reset clipboard history

## Logging and Debugging
### Accessing Logs
```dart
final logger = Logger();
final logs = await logger.getLogs(); // Retrieve logs
await logger.clearLogs(); // Clear log file
```

## Limitations
- Background clipboard monitoring has platform-specific restrictions
- iOS background monitoring is less consistent due to system limitations
- Battery and performance impact may vary

## Contributing
Contributions are welcome! Please submit pull requests or open issues on the repository.

## Future Improvements
- Enhanced error handling
- More advanced search functionality
- Customizable background monitoring preferences
- Comprehensive testing
- Improved platform-specific background task management
- Advanced log filtering and export
