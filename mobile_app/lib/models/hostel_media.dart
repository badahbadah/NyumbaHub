import '../services/api_service.dart';

class HostelMedia {
  final int id;
  final String mediaUrl;
  final String mediaType;

  HostelMedia({required this.id, required this.mediaUrl, required this.mediaType});

  factory HostelMedia.fromJson(Map<String, dynamic> json) {
    return HostelMedia(
      id: json['id'],
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
    );
  }

  String get fullUrl => '${ApiService.serverUrl}$mediaUrl';
}