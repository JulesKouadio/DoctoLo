import '../models/pharmacy_model.dart';

class PharmacyData {
  // Liste des pharmacies de garde d'Abidjan
  static final List<PharmacyModel> onDutyPharmacies = [
    PharmacyModel(
      id: 'ph_001',
      name: 'PHARMACIE MAGNIFICAT',
      commune: 'ABOBO',
      doctorName: 'M. LOBA MARTIN',
      phone: '25 24 00 42 36',
      latitude: 5.4196,
      longitude: -4.0219,
    ),
    PharmacyModel(
      id: 'ph_002',
      name: 'PHARMACIE ABOBO GRAND MARCHE',
      commune: 'ABOBO',
      doctorName: 'M. DJAHA KONAN FRANCIS',
      phone: '05 44 96 91 01',
      latitude: 5.4301,
      longitude: -4.0182,
    ),
    PharmacyModel(
      id: 'ph_003',
      name: 'PHARMACIE DE LA MAIRIE ABOBO',
      commune: 'ABOBO',
      doctorName: 'M. EBY EHOUNOUD',
      phone: '27 24 39 32 48',
      latitude: 5.4347,
      longitude: -4.0203,
    ),
    PharmacyModel(
      id: 'ph_004',
      name: 'PHARMACIE AL-FATIH',
      commune: 'ABOBO',
      doctorName: 'M. COULIBALY ABDOULAYE DONASSIHI',
      phone: '01 52 12 12 21',
      latitude: 5.4278,
      longitude: -4.0245,
    ),
    PharmacyModel(
      id: 'ph_005',
      name: 'PHARMACIE STE CROIX',
      commune: 'ABOBO',
      doctorName: 'M. OPELI AGNES THIERRY',
      phone: '07 78 13 75 03',
      latitude: 5.4312,
      longitude: -4.0198,
    ),
    PharmacyModel(
      id: 'ph_006',
      name: 'PHARMACIE YARAPHA',
      commune: 'ABOBO',
      doctorName: 'M. ACKRA NOEL',
      phone: '27 24 49 12 63',
      latitude: 5.4289,
      longitude: -4.0213,
    ),
    PharmacyModel(
      id: 'ph_007',
      name: 'PHARMACIE FADYL',
      commune: 'ABOBO',
      doctorName: 'M TOE OUMAR AIME',
      phone: '07 88 89 90 76',
      latitude: 5.4325,
      longitude: -4.0176,
    ),
    PharmacyModel(
      id: 'ph_008',
      name: 'PHARMACIE NOURAM',
      commune: 'ABOBO',
      doctorName: 'M. BAMBA ZOUMANA',
      phone: '07 57 96 41 62',
      latitude: 5.4265,
      longitude: -4.0228,
    ),
    PharmacyModel(
      id: 'ph_009',
      name: 'PHARMACIE STE ODILE',
      commune: 'ABOBO',
      doctorName: 'M. NIAMKE OLIVIER JOCELYN AMON',
      phone: '27 22 42 16 73',
      latitude: 5.4338,
      longitude: -4.0189,
    ),
    PharmacyModel(
      id: 'ph_010',
      name: 'PHARMACIE ACTUELLE',
      commune: 'ABOBO',
      doctorName: 'M. KONE LASSINA',
      phone: '25 22 00 41 87',
      latitude: 5.4294,
      longitude: -4.0207,
    ),
  ];

  // Rechercher les pharmacies par commune
  static List<PharmacyModel> searchByCommune(String commune) {
    if (commune.isEmpty) return onDutyPharmacies;
    return onDutyPharmacies
        .where((p) => p.commune.toLowerCase().contains(commune.toLowerCase()))
        .toList();
  }

  // Rechercher les pharmacies par nom
  static List<PharmacyModel> searchByName(String name) {
    if (name.isEmpty) return onDutyPharmacies;
    return onDutyPharmacies
        .where((p) => p.name.toLowerCase().contains(name.toLowerCase()))
        .toList();
  }

  // Obtenir les pharmacies les plus proches
  static List<PharmacyModel> getNearestPharmacies(
    double userLat,
    double userLon, {
    int limit = 5,
  }) {
    final pharmaciesWithDistance = onDutyPharmacies
        .map((p) => MapEntry(p, p.distanceFrom(userLat, userLon)))
        .where((entry) => entry.value != null)
        .toList();

    pharmaciesWithDistance.sort((a, b) => a.value!.compareTo(b.value!));

    return pharmaciesWithDistance
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }
}
