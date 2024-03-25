import 'package:hive/hive.dart';
import 'package:intl/intl.dart' as intl;

part 'person.g.dart';

@HiveType(typeId: 2)
class Person extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  String idNumber;
  @HiveField(11)
  String phoneNumber;
  @HiveField(3)
  List<DateTime> aidDates;
  @HiveField(4)
  String aidType;
  @HiveField(10)
  double aidAmount;
  @HiveField(13)
  String? aidTypeDetails;
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
      this.aidTypeDetails,
      required this.isContinuousAid,
      required this.notes});

  String toJson() {
    return """
{
        "helpTypeDetails": "$aidTypeDetails"
        "helpAmount": ${aidType != 'عينية' && aidType != 'رمضانية' ? aidAmount : ''},
        "helpDate": "${aidDates.length > 1 ? intl.DateFormat('yyyy/MM/dd').format(aidDates[0]) : '-'} - ${aidDates.length > 1 ? intl.DateFormat('yyyy/MM/dd').format(aidDates[1]) : '-'}",
        "helpDuration": "${isContinuousAid ? 'مستمرة' : 'منقطعة'}",
        "helpType": "$aidType",
        "name": "$name",
        "nationalId": "$idNumber",
        "notes": "$notes",
        "phoneNumber": "$phoneNumber"
    }
""";
  }
}
