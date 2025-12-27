import '../models/medicine_model.dart';

class MedicineData {
  static final List<MedicineModel> medicines = [
    MedicineModel(
      number: 1,
      code: '8108772',
      commercialName: '5 FLUORO URACILE INJ FLACON DETAIL',
      therapeuticGroup: 'CANCEROLOGIE, ANTINEOPLASIQUE',
      price: 13780,
    ),
    MedicineModel(
      number: 2,
      code: '7112216',
      commercialName: 'A CERUMEN SOLUTION DOUCE D4HYGIENE AURICULAIRE B/10X2ML',
      therapeuticGroup: 'ORL, BOUCHON DE CERUMEN',
      price: 1065,
    ),
    MedicineModel(
      number: 3,
      code: '3352892',
      commercialName: 'ABUFENE CP 400 MG B/30',
      therapeuticGroup: 'GYNECOLOGIE,TRAITEMENTS DE LA MENOPAUSE',
      price: 3805,
    ),
    MedicineModel(
      number: 4,
      code: '3258453',
      commercialName: 'ABZ SUSP BUVFL/10ML',
      therapeuticGroup: 'PARASITOLOGIE, ANTHELMINTIQUE',
      price: 705,
    ),
    MedicineModel(
      number: 5,
      code: '5015703',
      commercialName: 'ACARILBIAL SOL P APPL LOC FL/200 ML',
      therapeuticGroup: 'DERMATOLOGIE, ANTIPARASITAIRE EXTERNE',
      price: 2875,
    ),
    MedicineModel(
      number: 6,
      code: '8003794',
      commercialName: 'ACCULOL CY 0,5% FL/5 ML',
      therapeuticGroup: 'OPHTALMOLOGIE, ANTIGLAUCOMATEUX',
      price: 3755,
    ),
    MedicineModel(
      number: 7,
      code: '3240410',
      commercialName: 'ACEFYL SIROP FL/120ML',
      therapeuticGroup: 'PNEUMOLOGIE, ANTITUSSIF',
      price: 1185,
    ),
    MedicineModel(
      number: 8,
      code: '2473652',
      commercialName: 'ACELODON CP PELL 100MG B/10',
      therapeuticGroup: 'ANTI-INFLAMMATOIRE NON STEROÏDIEN (AINS)',
      price: 2785,
    ),
    MedicineModel(
      number: 9,
      code: '2473651',
      commercialName: 'ACELODON-P COMP PELL 100MG/500MG B/10',
      therapeuticGroup: 'ANTALGIQUE/ANTIPYRETIQUE + AINS',
      price: 2245,
    ),
    MedicineModel(
      number: 10,
      code: '8096749',
      commercialName: 'ACEM CP 500 MG B/10',
      therapeuticGroup: 'ANTIBIOTIQUE, MACROLIDE',
      price: 6020,
    ),
  ];

  // Rechercher les médicaments par nom commercial
  static List<MedicineModel> searchByName(String name) {
    if (name.isEmpty) return medicines;
    return medicines
        .where(
          (m) => m.commercialName.toLowerCase().contains(name.toLowerCase()),
        )
        .toList();
  }

  // Rechercher les médicaments par groupe thérapeutique
  static List<MedicineModel> searchByTherapeuticGroup(String group) {
    if (group.isEmpty) return medicines;
    return medicines
        .where(
          (m) => m.therapeuticGroup.toLowerCase().contains(group.toLowerCase()),
        )
        .toList();
  }

  // Rechercher les médicaments par code
  static MedicineModel? searchByCode(String code) {
    try {
      return medicines.firstWhere((m) => m.code == code);
    } catch (e) {
      return null;
    }
  }
}
