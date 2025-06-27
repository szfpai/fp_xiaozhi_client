import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

import '../config/app_config.dart';
import '../data/voice.dart';
import 'auth_service.dart';

class TtsService {
  final AuthService authService;
  final AudioPlayer _audioPlayer = AudioPlayer();

  TtsService({required this.authService});

  /// Fetches the list of available TTS voices from the backend.
  Future<List<Voice>> getVoices() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final url = Uri.parse('${AppConfig.baseUrl}/api/roles/tts-list');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(utf8.decode(response.bodyBytes));
      final List<dynamic> voicesJson = responseData['data']['ttsList'] ?? [];
      return voicesJson.map((json) => Voice.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load voices: ${response.body}');
    }
  }
}
