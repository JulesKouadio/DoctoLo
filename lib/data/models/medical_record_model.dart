import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle pour un dossier médical de patient
class MedicalRecordModel {
  final String id;
  final String patientId;
  final String doctorId;
  final DateTime consultationDate;
  final String reason; // Raison de la consultation
  final String diagnosis; // Diagnostic du médecin
  final String prescription; // Ordonnance
  final String consultationType; // 'physical' ou 'telemedicine'
  final String? notes; // Notes supplémentaires
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.consultationDate,
    required this.reason,
    required this.diagnosis,
    required this.prescription,
    required this.consultationType,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'consultationDate': Timestamp.fromDate(consultationDate),
      'reason': reason,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'consultationType': consultationType,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json, String id) {
    return MedicalRecordModel(
      id: id,
      patientId: json['patientId'] ?? '',
      doctorId: json['doctorId'] ?? '',
      consultationDate: (json['consultationDate'] as Timestamp).toDate(),
      reason: json['reason'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      prescription: json['prescription'] ?? '',
      consultationType: json['consultationType'] ?? 'physical',
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  MedicalRecordModel copyWith({
    String? id,
    String? patientId,
    String? doctorId,
    DateTime? consultationDate,
    String? reason,
    String? diagnosis,
    String? prescription,
    String? consultationType,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      doctorId: doctorId ?? this.doctorId,
      consultationDate: consultationDate ?? this.consultationDate,
      reason: reason ?? this.reason,
      diagnosis: diagnosis ?? this.diagnosis,
      prescription: prescription ?? this.prescription,
      consultationType: consultationType ?? this.consultationType,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Modèle pour les informations médicales d'un patient
class PatientMedicalInfo {
  final String patientId;
  final String bloodGroup; // Groupe sanguin (A+, B+, O-, etc.)
  final double? height; // Taille en cm
  final double? weight; // Poids en kg
  final List<String> allergies; // Liste des allergies
  final List<String> chronicDiseases; // Maladies chroniques
  final String? emergencyContact; // Contact d'urgence
  final DateTime? lastUpdated;

  const PatientMedicalInfo({
    required this.patientId,
    required this.bloodGroup,
    this.height,
    this.weight,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.emergencyContact,
    this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'patientId': patientId,
      'bloodGroup': bloodGroup,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'emergencyContact': emergencyContact,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }

  factory PatientMedicalInfo.fromJson(
    Map<String, dynamic> json,
    String patientId,
  ) {
    return PatientMedicalInfo(
      patientId: patientId,
      bloodGroup: json['bloodGroup'] ?? 'Non renseigné',
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      allergies: List<String>.from(json['allergies'] ?? []),
      chronicDiseases: List<String>.from(json['chronicDiseases'] ?? []),
      emergencyContact: json['emergencyContact'],
      lastUpdated: json['lastUpdated'] != null
          ? (json['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  PatientMedicalInfo copyWith({
    String? patientId,
    String? bloodGroup,
    double? height,
    double? weight,
    List<String>? allergies,
    List<String>? chronicDiseases,
    String? emergencyContact,
    DateTime? lastUpdated,
  }) {
    return PatientMedicalInfo(
      patientId: patientId ?? this.patientId,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
