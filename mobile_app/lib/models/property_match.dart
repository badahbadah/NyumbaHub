class PropertyMatch {
  final int id;
  final int requestId;
  final int propertyId;
  final int agentId;
  final int? hunterId;
  final String status; // pending | accepted | declined
  final DateTime createdAt;

  // Populated when viewed from the request side (hunter's "offers received")
  final String? propertyCity;
  final String? propertyArea;
  final double? propertyPriceFromRequestView;
  final String? propertyDescription;

  // Populated when viewed from the agent's "my matches" side
  final String? requestCity;
  final String? requestPropertyType;
  final double? budgetAmount;
  final double? propertyPrice;

  PropertyMatch({
    required this.id,
    required this.requestId,
    required this.propertyId,
    required this.agentId,
    this.hunterId,
    required this.status,
    required this.createdAt,
    this.propertyCity,
    this.propertyArea,
    this.propertyPriceFromRequestView,
    this.propertyDescription,
    this.requestCity,
    this.requestPropertyType,
    this.budgetAmount,
    this.propertyPrice,
  });

  factory PropertyMatch.fromJson(Map<String, dynamic> json) {
    return PropertyMatch(
      id: json['id'],
      requestId: json['request_id'],
      propertyId: json['property_id'],
      agentId: json['agent_id'],
      hunterId: json['hunter_id'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      propertyCity: json['city'],
      propertyArea: json['area'],
      propertyPriceFromRequestView: json['price_amount'] != null ? double.tryParse(json['price_amount'].toString()) : null,
      propertyDescription: json['description'],
      requestCity: json['request_city'],
      requestPropertyType: json['request_property_type'],
      budgetAmount: json['budget_amount'] != null ? double.tryParse(json['budget_amount'].toString()) : null,
      propertyPrice: json['property_price'] != null ? double.tryParse(json['property_price'].toString()) : null,
    );
  }
}