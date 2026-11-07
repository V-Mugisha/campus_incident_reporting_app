import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Uploads incident photos and returns a public URL.
abstract class ImageUploadService {
  Future<String> upload(File file);
}

/// Cloudinary unsigned upload implementation.
class CloudinaryImageUploadService implements ImageUploadService {
  CloudinaryImageUploadService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const String _cloudName = 'victormugisha';
  static const String _uploadPreset = 'incident_report_app';

  @override
  Future<String> upload(File file) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload failed (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final url = body['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw Exception('Upload returned no URL');
    }
    return url;
  }
}
