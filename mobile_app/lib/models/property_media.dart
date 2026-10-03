import '../services/api_service.dart';

class PropertyMedia {
  final int id;
  final String mediaUrl;
  final String mediaType;

  PropertyMedia({required this.id, required this.mediaUrl, required this.mediaType});

  factory PropertyMedia.fromJson(Map<String, dynamic> json) {
    return PropertyMedia(
      id: json['id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
    );
  }

  String get fullUrl => '${ApiService.serverUrl}$mediaUrl';
}