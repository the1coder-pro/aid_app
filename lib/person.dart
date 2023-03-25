import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
class Person extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String idNumber;
  @HiveField(2)
  int phoneNumber;
  @HiveField(3)
  List<DateTime> aidDates;
  @HiveField(4)
  String aidType;
  @HiveField(5)
  int aidAmount;
  @HiveField(6)
  bool isContinuousAid;
  @HiveField(7)
  String notes;

  Person(
      {required this.name,
      required this.idNumber,
      required this.phoneNumber,
      required this.aidDates,
      required this.aidType,
      required this.aidAmount,
      required this.isContinuousAid,
      required this.notes});
}
