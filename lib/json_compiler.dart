class JsonRecord {
  // int? id;
  String? name;
  String? idNumber;
  double? aidAmount;
  String? phoneNumber;
  String? notes;
  String? aidType;
  bool? isContinuousAid;
  String? aidDates;
  String? aidTypeDetails;

  JsonRecord(
      {this.name,
      this.idNumber,
      this.aidAmount,
      this.aidDates,
      this.aidType,
      this.aidTypeDetails,
      this.isContinuousAid,
      this.phoneNumber,
      this.notes});

  factory JsonRecord.fromJson(Map<String, dynamic> json) {
    return JsonRecord(
        name: json['name'],
        idNumber: json['nationalId'],
        aidAmount: double.parse(json['helpAmount'].toString()),
        isContinuousAid: json['helpDuration'] == 'مستمرة' ? true : false,
        aidDates: json['helpDate'],
        aidType: json['helpType'],
        aidTypeDetails: json['helpTypeDetails'],
        notes: json['notes'],
        phoneNumber: json['phoneNumber']);
  }
}

// "helpAmount": 500,
//         "helpDate": "14/05/2022 - 24/05/2022",
//         "helpDuration": "منقطعة",
//         "helpType": "مؤونة",

//         "name": "نجوى أمير السلمان",
//         "nationalId": "1888754646",
//         "notes": "السكن الهفوف الضمان ٣٠٠٠ المواطن ١١٠٠ غير مستحقه ",
//         "phoneNumber": "0876764644"