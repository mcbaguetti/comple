import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = StorageService();
  await storageService.init();
  
  initializeDateFormatting().then((_) => runApp(BirthdayTrackerApp(storageService: storageService)));
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
            scaffoldBackgroundColor: const Color(0xFFF9F6F0), // Washi paper cream
            dialogBackgroundColor: const Color(0xFFF9F6F0),
            primaryColor: const Color(0xFF8A1C14), // Hanko stamp red
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8A1C14),
              secondary: Color(0xFF1C1C1C), // Sumi ink black
              surface: Color(0xFFF9F6F0),
              onSurface: Color(0xFF1C1C1C), // Text color
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            scaffoldBackgroundColor: const Color(0xFF1C1C1C), // Sumi ink black
            dialogBackgroundColor: const Color(0xFF1C1C1C),
            primaryColor: const Color(0xFF8A1C14), // Hanko stamp red
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8A1C14),
              secondary: Color(0xFFF9F6F0), // Washi paper cream
              surface: Color(0xFF1C1C1C),
              onSurface: Color(0xFFF9F6F0), // Text color
            ),
            useMaterial3: true,
          ),
          home: HomeScreen(storageService: storageService),
        );
      },
    );
  }
}
