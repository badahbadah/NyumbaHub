class Review {
  final int id;
  final int waterRating;
  final int electricityRating;
  final int safetyRating;
  final int responsivenessRating;
  final String? comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.waterRating,
    required this.electricityRating,
    required this.safetyRating,
    required this.responsivenessRating,
    this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      waterRating: json['water_rating'],
      electricityRating: json['electricity_rating'],
      safetyRating: json['safety_rating'],
      responsivenessRating: json['responsiveness_rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ReviewAverages {
  final double? avgWater;
  final double? avgElectricity;
  final double? avgSafety;
  final double? avgResponsiveness;
  final int reviewCount;

  ReviewAverages({
    this.avgWater,
    this.avgElectricity,
    this.avgSafety,
    this.avgResponsiveness,
    required this.reviewCount,
  });

  factory ReviewAverages.fromJson(Map<String, dynamic> json) {
    return ReviewAverages(
      avgWater: json['avg_water'] != null ? double.tryParse(json['avg_water'].toString()) : null,
      avgElectricity: json['avg_electricity'] != null ? double.tryParse(json['avg_electricity'].toString()) : null,
      avgSafety: json['avg_safety'] != null ? double.tryParse(json['avg_safety'].toString()) : null,
      avgResponsiveness: json['avg_responsiveness'] != null ? double.tryParse(json['avg_responsiveness'].toString()) : null,
      reviewCount: int.tryParse(json['review_count'].toString()) ?? 0,
    );
  }
}