import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FaceService {
  static final String? _apiKey = dotenv.env['FACE_API_KEY'];
  static final String? _apiSecret = dotenv.env['FACE_API_SECRET'];

  static Future<String?> detectarRosto(File imageFile) async {
    final url = Uri.parse('https://api-us.faceplusplus.com/facepp/v3/detect');

    final request = http.MultipartRequest('POST', url)
      ..fields['api_key'] = _apiKey ?? ''
      ..fields['api_secret'] = _apiSecret ?? ''
      ..files.add(await http.MultipartFile.fromPath('image_file', imageFile.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    if (data['faces'] != null && data['faces'].isNotEmpty) {
      return data['faces'][0]['face_token'];
    } else {
      print('Nenhum rosto detectado.');
      return null;
    }
  }
}
