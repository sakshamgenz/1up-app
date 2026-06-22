import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  late AudioPlayer _audioPlayer;

  factory AudioService() {
    return _instance;
  }

  AudioService._internal() {
    _audioPlayer = AudioPlayer();
  }

  Future<void> playAlarmSound(String soundName) async {
    try {
      // Map sound names to asset files
      final soundPath = _getSoundPath(soundName);
      await _audioPlayer.play(
        AssetSource(soundPath),
        volume: 1.0,
      );

      // Auto-stop after 30 seconds
      Future.delayed(const Duration(seconds: 30), () {
        stopAlarmSound();
      });
    } catch (e) {
      print('Error playing alarm sound: $e');
    }
  }

  Future<void> stopAlarmSound() async {
    await _audioPlayer.stop();
  }

  String _getSoundPath(String soundName) {
    switch (soundName) {
      case 'Soft Bell':
        return 'sounds/soft_bell.mp3';
      case 'Digital Beep':
        return 'sounds/digital_beep.mp3';
      case 'Chime':
        return 'sounds/chime.mp3';
      case 'Urgent Buzz':
        return 'sounds/urgent_buzz.mp3';
      case 'Nature - Birds':
        return 'sounds/nature_birds.mp3';
      default:
        return 'sounds/digital_beep.mp3';
    }
  }
}
