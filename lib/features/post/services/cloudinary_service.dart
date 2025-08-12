import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  final String cloudName;
  final String uploadPreset;

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
  });

  Future<String> uploadImage(File file) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/dt3ojv1nj/image/upload');
    print('📤 Cloudinary → $url | preset=$uploadPreset | file=${file.path}');

    final req = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await req.send();
    final body = await res.stream.bytesToString();
    print('📦 Cloudinary resp [${res.statusCode}]: $body');

    if (res.statusCode != 200) {
      throw Exception('Cloudinary upload failed (${res.statusCode}): $body');
    }

    final match = RegExp(r'"secure_url"\s*:\s*"([^"]+)"').firstMatch(body);
    final secureUrl = match?.group(1);
    if (secureUrl == null) {
      throw Exception('secure_url not found in response');
    }
    print('✅ Cloudinary URL: $secureUrl');
    return secureUrl;
  }
}
