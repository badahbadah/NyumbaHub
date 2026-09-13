class Room {
  final int id;
  final int hostelId;
  final String roomType;
  final double priceAmount;
  final String pricePeriod;
  final int totalBeds;
  final int availableBeds;
  final bool isSelfContained;

  Room({
    required this.id,
    required this.hostelId,
    required this.roomType,
    required this.priceAmount,
    required this.pricePeriod,
    required this.totalBeds,
    required this.availableBeds,
    required this.isSelfContained,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      hostelId: json['hostel_id'],
      roomType: json['room_type'],
      priceAmount: double.tryParse(json['price_amount'].toString()) ?? 0,
      pricePeriod: json['price_period'] ?? 'month',
      totalBeds: json['total_beds'] ?? 0,
      availableBeds: json['available_beds'] ?? 0,
      isSelfContained: json['is_self_contained'] ?? false,
    );
  }
}