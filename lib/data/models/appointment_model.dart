import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'appointment_model.g.dart';

@HiveType(typeId: 2)
class AppointmentModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String patientId;

  @HiveField(2)
  final String doctorId;

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final int durationMinutes;

  @HiveField(5)
  final String type; // consultation, follow_up, emergency, teleconsultation

  @HiveField(6)
  final String status; // pending, confirmed, cancelled, completed, no_show

  @HiveField(7)
  final String? reason;

  @HiveField(8)
  final String? notes;

  @HiveField(9)
  final double fee;

  @HiveField(10)
  final bool isPaid;

  @HiveField(11)
  final String? paymentId;

  @HiveField(12)
  final bool isTelemedicine;

  @HiveField(13)
  final String? videoCallId;

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime? updatedAt;

  @HiveField(16)
  final String? cancellationReason;

  @HiveField(17)
  final bool reminderSent;

  const AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.dateTime,
    required this.durationMinutes,
    required this.type,
    required this.status,
    this.reason,
    this.notes,
    required this.fee,
    this.isPaid = false,
    this.paymentId,
    this.isTelemedicine = false,
    this.videoCallId,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    this.reminderSent = false,
  });

  DateTime get endTime => dateTime.add(Duration(minutes: durationMinutes));

  bool get isUpcoming =>
      dateTime.isAfter(DateTime.now()) &&
      (status == 'pending' || status == 'confirmed');

  bool get isPast => dateTime.isBefore(DateTime.now());

  bool get canCancel =>
      isUpcoming &&
      status != 'cancelled' &&
      dateTime.difference(DateTime.now()).inHours > 2;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'dateTime': dateTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'type': type,
      'status': status,
      'reason': reason,
      'notes': notes,
      'fee': fee,
      'isPaid': isPaid,
      'paymentId': paymentId,
      'isTelemedicine': isTelemedicine,
      'videoCallId': videoCallId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'reminderSent': reminderSent,
    };
  }

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      dateTime: json['dateTime'] != null
          ? DateTime.parse(json['dateTime'])
          : DateTime.now(),
      durationMinutes: json['durationMinutes'] ?? 30,
      type: json['type'] ?? 'consultation',
      status: json['status'] ?? 'pending',
      reason: json['reason'],
      notes: json['notes'],
      fee: (json['fee'] ?? 0.0).toDouble(),
      isPaid: json['isPaid'] ?? false,
      paymentId: json['paymentId'],
      isTelemedicine: json['isTelemedicine'] ?? false,
      videoCallId: json['videoCallId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      cancellationReason: json['cancellationReason'],
      reminderSent: json['reminderSent'] ?? false,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? dateTime,
    int? durationMinutes,
    String? type,
    String? status,
    String? reason,
    String? notes,
    double? fee,
    bool? isPaid,
    String? paymentId,
    bool? isTelemedicine,
    String? videoCallId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    bool? reminderSent,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      dateTime: dateTime ?? this.dateTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      type: type ?? this.type,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      fee: fee ?? this.fee,
      isPaid: isPaid ?? this.isPaid,
      paymentId: paymentId ?? this.paymentId,
      isTelemedicine: isTelemedicine ?? this.isTelemedicine,
      videoCallId: videoCallId ?? this.videoCallId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      reminderSent: reminderSent ?? this.reminderSent,
    );
  }

  @override
  List<Object?> get props => [
    id,
    patientId,
    doctorId,
    dateTime,
    durationMinutes,
    type,
    status,
    reason,
    notes,
    fee,
    isPaid,
    paymentId,
    isTelemedicine,
    videoCallId,
    createdAt,
    updatedAt,
    cancellationReason,
    reminderSent,
  ];
}
