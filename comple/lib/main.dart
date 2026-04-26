import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';
import 'services/error_service.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    logError(details.exception, details.stack);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const Material(
      child: Center(
        child: Text('Something went wrong'),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    logError(error, stack);
    return true; // handled
  };

  runZonedGuarded(() async {
    final storageService = StorageService();

    try {
      await storageService.init();
    } catch (e, st) {
      logError(e, st);
    }

    try {
      // await NotificationService().init();
    } catch (e, st) {
      logError(e, st);
    }

    try {
      final birthdays = storageService.getBirthdays();
      for (final b in birthdays) {
        try {
          // await NotificationService().scheduleBirthdayNotification(b);
        } catch (e, st) {
          logError(e, st);
        }
      }
    } catch (e, st) {
      logError(e, st);
    }

    await initializeDateFormatting();
    runApp(BirthdayTrackerApp(storageService: storageService));
  }, (error, stack) {
    logError(error, stack);
  });
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

class BirthdayTrackerApp extends StatelessWidget {
  final StorageService storageService;

  const BirthdayTrackerApp({Key? key, required this.storageService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Comple',
          themeMode: currentMode,
          theme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF00A59B), // Brutalist Teal
            dialogBackgroundColor: const Color(0xFF00A59B),
            primaryColor: const Color(0xFFFFFF00), // Brutalist Yellow
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFFFF00), // Yellow
              onPrimary: Color(0xFF000000), // Black on yellow
              secondary: Color(0xFF000000), // Black
              onSecondary: Color(0xFFFFFFFF), // White on black
              surface: Color(0xFF00A59B),
              onSurface: Color(0xFF000000), // Text color
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF000000),
              foregroundColor: Color(0xFFFFFFFF), // White text on black app bar
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFFFFFF00), // Yellow background
              foregroundColor: Color(0xFF000000), // Black icon
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF1C1C1C), // Sumi ink black
            dialogBackgroundColor: const Color(0xFF1C1C1C),
            primaryColor: const Color(0xFF8A1C14), // Hanko stamp red
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8A1C14),
              onPrimary: Color(0xFFFFFFFF), // White text on red
              secondary: Color(0xFFF9F6F0), // Washi paper cream
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFF9F6F0), // Text color
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF8A1C14), // Red background
              foregroundColor: Color(0xFFFFFFFF), // White icon
            ),
            useMaterial3: true,
          ),
          home: HomeScreen(storageService: storageService),
        );
      },
    );
  }
}
