class Hostel {
  final int id;
  final int ownerId;
  final String name;
  final String? description;
  final int? institutionId;
  final double? latitude;
  final double? longitude;
  final bool hasWaterBackup;
  final bool hasElectricityBackup;
  final bool hasSecurity;
  final bool hasWifi;
  final bool hasStudyArea;
  final String status;

  Hostel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.institutionId,
    this.latitude,
    this.longitude,
    required this.hasWaterBackup,
    required this.hasElectricityBackup,
    required this.hasSecurity,
    required this.hasWifi,
    required this.hasStudyArea,
    required this.status,
  });

  factory Hostel.fromJson(Map<String, dynamic> json) {
    return Hostel(
      id: json['id'],
      ownerId: json['owner_id'],
      name: json['name'],
      description: json['description'],
      institutionId: json['institution_id'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      hasWaterBackup: json['has_water_backup'] ?? false,
      hasElectricityBackup: json['has_electricity_backup'] ?? false,
      hasSecurity: json['has_security'] ?? false,
      hasWifi: json['has_wifi'] ?? false,
      hasStudyArea: json['has_study_area'] ?? false,
      status: json['status'] ?? 'active',
    );
  }
}