class Booking {
  final int id;
  final int roomId;
  final int hostelId;
  final String? hostelName;
  final String? roomType;
  final double depositAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String bookingCode;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.roomId,
    required this.hostelId,
    this.hostelName,
    this.roomType,
    required this.depositAmount,
    required this.paymentStatus,
    this.paymentMethod,
    required this.bookingCode,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      roomId: json['room_id'],
      hostelId: json['hostel_id'],
      hostelName: json['hostel_name'],
      roomType: json['room_type'],
      depositAmount: double.tryParse(json['deposit_amount'].toString()) ?? 0,
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      bookingCode: json['booking_code'],
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}