import 'package:hive_flutter/hive_flutter.dart';
import '../models/birthday.dart';

class StorageService {
  static const String _boxName = 'birthdaysBox';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(BirthdayAdapter());
    await Hive.openBox<Birthday>(_boxName);
  }

  Box<Birthday> get _box => Hive.box<Birthday>(_boxName);

  List<Birthday> getBirthdays() {
    return _box.values.toList();
  }

  Future<void> addBirthday(Birthday birthday) async {
    await _box.put(birthday.id, birthday);
  }

  Future<void> removeBirthday(String id) async {
    await _box.delete(id);
  }
}
