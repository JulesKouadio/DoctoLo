// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppointmentModelAdapter extends TypeAdapter<AppointmentModel> {
  @override
  final int typeId = 2;

  @override
  AppointmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppointmentModel(
      id: fields[0] as String,
      patientId: fields[1] as String,
      doctorId: fields[2] as String,
      dateTime: fields[3] as DateTime,
      durationMinutes: fields[4] as int,
      type: fields[5] as String,
      status: fields[6] as String,
      reason: fields[7] as String?,
      notes: fields[8] as String?,
      fee: fields[9] as double,
      isPaid: fields[10] as bool,
      paymentId: fields[11] as String?,
      isTelemedicine: fields[12] as bool,
      videoCallId: fields[13] as String?,
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime?,
      cancellationReason: fields[16] as String?,
      reminderSent: fields[17] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppointmentModel obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patientId)
      ..writeByte(2)
      ..write(obj.doctorId)
      ..writeByte(3)
      ..write(obj.dateTime)
      ..writeByte(4)
      ..write(obj.durationMinutes)
      ..writeByte(5)
      ..write(obj.type)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.reason)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.fee)
      ..writeByte(10)
      ..write(obj.isPaid)
      ..writeByte(11)
      ..write(obj.paymentId)
      ..writeByte(12)
      ..write(obj.isTelemedicine)
      ..writeByte(13)
      ..write(obj.videoCallId)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.cancellationReason)
      ..writeByte(17)
      ..write(obj.reminderSent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
