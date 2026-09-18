class Booking {
  final int id;
  final int roomId;
  final int hostelId;
  final int studentId;
  final int? hostelOwnerId;
  final String? hostelName;
  final String? roomType;
  final String? studentName;
  final double depositAmount;
  final String paymentStatus;
  final String? paymentMethod;
  final String bookingCode;
  final String status;
  final String ownerDecision; // pending | approved | denied
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.roomId,
    required this.hostelId,
    required this.studentId,
    this.hostelOwnerId,
    this.hostelName,
    this.roomType,
    this.studentName,
    required this.depositAmount,
    required this.paymentStatus,
    this.paymentMethod,
    required this.bookingCode,
    required this.status,
    required this.ownerDecision,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      roomId: json['room_id'],
      hostelId: json['hostel_id'],
      studentId: json['student_id'],
      hostelOwnerId: json['hostel_owner_id'],
      hostelName: json['hostel_name'],
      roomType: json['room_type'],
      studentName: json['student_name'],
      depositAmount: double.tryParse(json['deposit_amount'].toString()) ?? 0,
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      bookingCode: json['booking_code'],
      status: json['status'] ?? 'pending',
      ownerDecision: json['owner_decision'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}