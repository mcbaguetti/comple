import 'package:hive_flutter/hive_flutter.dart';
import '../models/birthday.dart';
// import 'notification_service.dart';
import 'error_service.dart';

class StorageService {
  static const String _boxName = 'birthdaysBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BirthdayAdapter());
    await Hive.openBox<Birthday>(_boxName);
  }

  Box<Birthday> get _box => Hive.box<Birthday>(_boxName);

  List<Birthday> getBirthdays() {
    try {
      return _box.values.toList();
    } catch (e, st) {
      logError(e, st);
      return [];
    }
  }

  Future<void> addBirthday(Birthday birthday) async {
    try {
      await _box.put(birthday.id, birthday);
    } catch (e, st) {
      logError(e, st);
    }

    try {
      // await NotificationService().scheduleBirthdayNotification(birthday);
    } catch (e, st) {
      logError(e, st);
    }
  }

  Future<void> removeBirthday(String id) async {
    try {
      // await NotificationService().cancelBirthdayNotification(id);
    } catch (e, st) {
      logError(e, st);
    }

    try {
      await _box.delete(id);
    } catch (e, st) {
      logError(e, st);
    }
  }
}
