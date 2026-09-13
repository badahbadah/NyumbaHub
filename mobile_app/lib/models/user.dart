class AppUser {
  final int id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String role;

  AppUser({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      role: json['role'],
    );
  }
}