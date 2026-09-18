class Institution {
  final int id;
  final String name;
  final String shortCode;
  final String? city;

  Institution({required this.id, required this.name, required this.shortCode, this.city});

  factory Institution.fromJson(Map<String, dynamic> json) {
    return Institution(
      id: json['id'],
      name: json['name'],
      shortCode: json['short_code'],
      city: json['city'],
    );
  }
}