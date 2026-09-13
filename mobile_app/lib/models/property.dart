class Property {
  final int id;
  final String listingType; // rent | sale
  final String propertyType; // house | apartment | shop | land
  final String city;
  final String? area;
  final int? bedrooms;
  final int? bathrooms;
  final double priceAmount;
  final String? pricePeriod;
  final String? description;
  final bool isFenced;
  final bool hasWaterTank;
  final bool isPaved;
  final String status; // available | taken

  Property({
    required this.id,
    required this.listingType,
    required this.propertyType,
    required this.city,
    this.area,
    this.bedrooms,
    this.bathrooms,
    required this.priceAmount,
    this.pricePeriod,
    this.description,
    required this.isFenced,
    required this.hasWaterTank,
    required this.isPaved,
    required this.status,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      listingType: json['listing_type'],
      propertyType: json['property_type'],
      city: json['city'],
      area: json['area'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      priceAmount: double.tryParse(json['price_amount'].toString()) ?? 0,
      pricePeriod: json['price_period'],
      description: json['description'],
      isFenced: json['is_fenced'] ?? false,
      hasWaterTank: json['has_water_tank'] ?? false,
      isPaved: json['is_paved'] ?? false,
      status: json['status'] ?? 'available',
    );
  }
}