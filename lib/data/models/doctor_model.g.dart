// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoctorModelAdapter extends TypeAdapter<DoctorModel> {
  @override
  final int typeId = 1;

  @override
  DoctorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoctorModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      specialty: fields[2] as String,
      licenseNumber: fields[3] as String,
      languages: (fields[4] as List).cast<String>(),
      bio: fields[5] as String?,
      qualifications: (fields[6] as List).cast<String>(),
      yearsOfExperience: fields[7] as int,
      rating: fields[8] as double,
      reviewCount: fields[9] as int,
      address: (fields[10] as Map?)?.cast<String, dynamic>(),
      availability: (fields[11] as Map?)?.map((dynamic k, dynamic v) =>
          MapEntry(
              k as String,
              (v as List)
                  .map((dynamic e) => (e as Map).cast<String, String>())
                  .toList())),
      consultationFee: fields[12] as double,
      teleconsultationFee: fields[13] as double,
      acceptsNewPatients: fields[14] as bool,
      offersTelemedicine: fields[15] as bool,
      insuranceAccepted: (fields[16] as List?)?.cast<String>(),
      createdAt: fields[17] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DoctorModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.specialty)
      ..writeByte(3)
      ..write(obj.licenseNumber)
      ..writeByte(4)
      ..write(obj.languages)
      ..writeByte(5)
      ..write(obj.bio)
      ..writeByte(6)
      ..write(obj.qualifications)
      ..writeByte(7)
      ..write(obj.yearsOfExperience)
      ..writeByte(8)
      ..write(obj.rating)
      ..writeByte(9)
      ..write(obj.reviewCount)
      ..writeByte(10)
      ..write(obj.address)
      ..writeByte(11)
      ..write(obj.availability)
      ..writeByte(12)
      ..write(obj.consultationFee)
      ..writeByte(13)
      ..write(obj.teleconsultationFee)
      ..writeByte(14)
      ..write(obj.acceptsNewPatients)
      ..writeByte(15)
      ..write(obj.offersTelemedicine)
      ..writeByte(16)
      ..write(obj.insuranceAccepted)
      ..writeByte(17)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
