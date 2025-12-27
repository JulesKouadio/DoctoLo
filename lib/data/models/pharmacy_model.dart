import 'dart:math' show cos, sqrt, asin;

class PharmacyModel {
  final String id;
  final String name;
  final String commune;
  final String doctorName;
  final String phone;
  final double? latitude;
  final double? longitude;
  final String? address;

  PharmacyModel({
    required this.id,
    required this.name,
    required this.commune,
    required this.doctorName,
    required this.phone,
    this.latitude,
    this.longitude,
    this.address,
  });

  factory PharmacyModel.fromJson(Map<String, dynamic> json) {
    return PharmacyModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      commune: json['commune'] ?? '',
      doctorName: json['doctorName'] ?? '',
      phone: json['phone'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'commune': commune,
      'doctorName': doctorName,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  // Calculer la distance par rapport à une position donnée (en km)
  // Formule de Haversine
  double? distanceFrom(double userLat, double userLon) {
    if (latitude == null || longitude == null) return null;

    const double p = 0.017453292519943295; // Math.PI / 180
    final double a =
        0.5 -
        cos((latitude! - userLat) * p) / 2 +
        cos(userLat * p) *
            cos(latitude! * p) *
            (1 - cos((longitude! - userLon) * p)) /
            2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
