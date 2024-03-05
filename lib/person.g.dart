// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PersonAdapter extends TypeAdapter<Person> {
  @override
  final int typeId = 1;

  @override
  Person read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Person(
      name: fields[0] as String,
      idNumber: fields[1] as String,
      phoneNumber: fields[11] as String,
      aidDates: (fields[3] as List).cast<DateTime>(),
      aidType: fields[4] as String,
      aidAmount: fields[10] as double,
      isContinuousAid: fields[6] as bool,
      notes: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Person obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.idNumber)
      ..writeByte(11)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.aidDates)
      ..writeByte(4)
      ..write(obj.aidType)
      ..writeByte(10)
      ..write(obj.aidAmount)
      ..writeByte(6)
      ..write(obj.isContinuousAid)
      ..writeByte(7)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
