class HouseRequest {
  final int id;
  final int hunterId;
  final String propertyType;
  final String? targetArea;
  final String city;
  final double budgetAmount;
  final String? budgetPeriod;
  final String? notes;
  final String status;
  final DateTime createdAt;

  HouseRequest({
    required this.id,
    required this.hunterId,
    required this.propertyType,
    this.targetArea,
    required this.city,
    required this.budgetAmount,
    this.budgetPeriod,
    this.notes,
    required this.status,
    required this.createdAt,
  });

  factory HouseRequest.fromJson(Map<String, dynamic> json) {
    return HouseRequest(
      id: json['id'],
      hunterId: json['hunter_id'],
      propertyType: json['property_type'],
      targetArea: json['target_area'],
      city: json['city'],
      budgetAmount: double.tryParse(json['budget_amount'].toString()) ?? 0,
      budgetPeriod: json['budget_period'],
      notes: json['notes'],
      status: json['status'] ?? 'open',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}