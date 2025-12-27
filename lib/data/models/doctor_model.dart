import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'doctor_model.g.dart';

@HiveType(typeId: 1)
class DoctorModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String specialty;

  @HiveField(3)
  final String licenseNumber;

  @HiveField(4)
  final List<String> languages;

  @HiveField(5)
  final String? bio;

  @HiveField(6)
  final List<String> qualifications;

  @HiveField(7)
  final int yearsOfExperience;

  @HiveField(8)
  final double rating;

  @HiveField(9)
  final int reviewCount;

  @HiveField(10)
  final Map<String, dynamic>? address;

  @HiveField(11)
  final Map<String, List<Map<String, String>>>? availability; // {day: [{start, end}]}

  @HiveField(12)
  final double consultationFee;

  @HiveField(13)
  final double teleconsultationFee;

  @HiveField(14)
  final bool acceptsNewPatients;

  @HiveField(15)
  final bool offersTelemedicine;

  @HiveField(16)
  final List<String>? insuranceAccepted;

  @HiveField(17)
  final DateTime createdAt;

  const DoctorModel({
    required this.id,
    required this.userId,
    required this.specialty,
    required this.licenseNumber,
    required this.languages,
    this.bio,
    required this.qualifications,
    required this.yearsOfExperience,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.address,
    this.availability,
    required this.consultationFee,
    required this.teleconsultationFee,
    this.acceptsNewPatients = true,
    this.offersTelemedicine = true,
    this.insuranceAccepted,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'specialty': specialty,
      'licenseNumber': licenseNumber,
      'languages': languages,
      'bio': bio,
      'qualifications': qualifications,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'reviewCount': reviewCount,
      'address': address,
      'availability': availability,
      'consultationFee': consultationFee,
      'teleconsultationFee': teleconsultationFee,
      'acceptsNewPatients': acceptsNewPatients,
      'offersTelemedicine': offersTelemedicine,
      'insuranceAccepted': insuranceAccepted,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      specialty: json['specialty'] ?? '',
      licenseNumber: json['licenseNumber'] ?? '',
      languages: List<String>.from(json['languages'] ?? []),
      bio: json['bio'],
      qualifications: List<String>.from(json['qualifications'] ?? []),
      yearsOfExperience: json['yearsOfExperience'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      address: json['address'],
      availability: json['availability'] != null
          ? Map<String, List<Map<String, String>>>.from(json['availability'])
          : null,
      consultationFee: (json['consultationFee'] ?? 0.0).toDouble(),
      teleconsultationFee: (json['teleconsultationFee'] ?? 0.0).toDouble(),
      acceptsNewPatients: json['acceptsNewPatients'] ?? true,
      offersTelemedicine: json['offersTelemedicine'] ?? true,
      insuranceAccepted: json['insuranceAccepted'] != null
          ? List<String>.from(json['insuranceAccepted'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  DoctorModel copyWith({
    String? id,
    String? userId,
    String? specialty,
    String? licenseNumber,
    List<String>? languages,
    String? bio,
    List<String>? qualifications,
    int? yearsOfExperience,
    double? rating,
    int? reviewCount,
    Map<String, dynamic>? address,
    Map<String, List<Map<String, String>>>? availability,
    double? consultationFee,
    double? teleconsultationFee,
    bool? acceptsNewPatients,
    bool? offersTelemedicine,
    List<String>? insuranceAccepted,
    DateTime? createdAt,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      specialty: specialty ?? this.specialty,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      languages: languages ?? this.languages,
      bio: bio ?? this.bio,
      qualifications: qualifications ?? this.qualifications,
      yearsOfExperience: yearsOfExperience ?? this.yearsOfExperience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      address: address ?? this.address,
      availability: availability ?? this.availability,
      consultationFee: consultationFee ?? this.consultationFee,
      teleconsultationFee: teleconsultationFee ?? this.teleconsultationFee,
      acceptsNewPatients: acceptsNewPatients ?? this.acceptsNewPatients,
      offersTelemedicine: offersTelemedicine ?? this.offersTelemedicine,
      insuranceAccepted: insuranceAccepted ?? this.insuranceAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    specialty,
    licenseNumber,
    languages,
    bio,
    qualifications,
    yearsOfExperience,
    rating,
    reviewCount,
    address,
    availability,
    consultationFee,
    teleconsultationFee,
    acceptsNewPatients,
    offersTelemedicine,
    insuranceAccepted,
    createdAt,
  ];
}
