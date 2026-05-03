import 'package:hive/hive.dart';

part 'birthday.g.dart';

@HiveType(typeId: 0)
class Birthday extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  List<String> gifts;

  Birthday({
    required this.id,
    required this.name,
    required this.date,
    List<String>? gifts,
  }) : gifts = gifts ?? [];
}
