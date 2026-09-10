import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'language_controller.dart';

class AudioService {
  static final AudioService instance = AudioService._internal();
  factory AudioService() => instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  String _resolveAudioLanguageFolder() {
    final code = LanguageController.instance.currentLanguageCode;
    // Map supported codes to available audio folders
    switch (code) {
      case 'hi':
        return 'hindi';
      case 'mr':
        return 'marathi';
      case 'ta':
        return 'tamil';
      case 'te':
        return 'telugu';
      case 'sa':
        return 'sanskrit';
      case 'bn':
        return 'bengali';
      default:
        return 'english';
    }
  }

  Future<void> playVoiceHelp(String fileName) async {
    final folder = _resolveAudioLanguageFolder();
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('audio/$folder/$fileName'));
    } catch (e) {
      debugPrint('[AudioService] Error playing audio: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
