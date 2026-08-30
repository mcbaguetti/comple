# Comple

A simple, brutalist-themed birthday tracking app built with Flutter. Add birthdays, view them on an interactive calendar, and keep notes of gift ideas for the people you care about.

## Features

- Track birthdays with names and dates
- Month / two-week calendar views of upcoming birthdays
- Add gift ideas per person
- Persistent local storage (Hive)
- Light and dark themes (system-aware)
- Local notification support for birthday reminders (in progress)

## Requirements

- Flutter SDK (>=3.1.2) with Dart >=3.1.2
- A platform toolchain for your target (Android, iOS, Web, etc.)

## Getting Started

### Run the app

```sh
flutter run -d <device_id>   # physical or emulated device
flutter run -d web           # web browser
```

### Build the app

```sh
flutter build apk --debug    # Android
flutter build ios --debug    # iOS
flutter build web --debug    # Web
```

## Project Structure

The Flutter app lives in the `comple/` subdirectory.

```
comple/lib/
├── main.dart                       # App entry point, theme setup
├── models/
│   └── birthday.dart               # Birthday model (Hive)
├── screens/
│   └── home_screen.dart            # Main screen with calendar
├── services/
│   ├── error_service.dart          # Global error logging
│   ├── notification_service.dart   # Birthday reminders
│   └── storage_service.dart        # Hive persistence
└── widgets/
    ├── add_birthday_dialog.dart    # Add/edit birthday dialog
    └── gift_ideas_sheet.dart       # Gift ideas bottom sheet
```

## Tech Stack

- [Flutter](https://flutter.dev) — UI framework
- [Hive](https://pub.dev/packages/hive) / [hive_flutter](https://pub.dev/packages/hive_flutter) — local storage
- [table_calendar](https://pub.dev/packages/table_calendar) — calendar widget
- [intl](https://pub.dev/packages/intl) — date formatting
- [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) — reminder notifications

## License

[MIT](LICENSE)
