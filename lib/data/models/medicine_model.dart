class MedicineModel {
  final int number;
  final String code;
  final String commercialName;
  final String therapeuticGroup;
  final int price;

  MedicineModel({
    required this.number,
    required this.code,
    required this.commercialName,
    required this.therapeuticGroup,
    required this.price,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) {
    return MedicineModel(
      number: json['number'] ?? 0,
      code: json['code'] ?? '',
      commercialName: json['commercialName'] ?? '',
      therapeuticGroup: json['therapeuticGroup'] ?? '',
      price: json['price'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'code': code,
      'commercialName': commercialName,
      'therapeuticGroup': therapeuticGroup,
      'price': price,
    };
  }
}
