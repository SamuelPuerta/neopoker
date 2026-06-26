import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

enum SoundType { check, call, fold, raise, allIn, winner }

class SoundService {
  static final SoundService instance = SoundService._();

  SoundService._();

  final AudioPlayer _player = AudioPlayer();
  final Map<SoundType, String> _files = {};
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final dir = Directory.systemTemp;
    final soundsDir = Directory('${dir.path}${Platform.pathSeparator}neopoker_sounds');
    if (!await soundsDir.exists()) {
      await soundsDir.create(recursive: true);
    }

    for (final type in SoundType.values) {
      final path = '${soundsDir.path}/${type.name}.wav';
      final file = File(path);
      if (!await file.exists()) {
        await file.writeAsBytes(_generateWav(type));
      }
      _files[type] = path;
    }
  }

  Future<void> play(SoundType type) async {
    if (!_initialized) return;
    final path = _files[type];
    if (path == null) return;
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}

Uint8List _generateWav(SoundType type) {
  final sampleRate = 22050;
  final durationMs = _duration(type);
  final freq = _frequency(type);
  final numSamples = (sampleRate * durationMs / 1000).round();
  final samples = Int16List(numSamples);

  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final envelope = _envelope(i, numSamples);
    double value = sin(2 * pi * freq * t) * envelope * 0.6;

    if (type == SoundType.allIn) {
      final freq2 = freq * 1.5;
      value += sin(2 * pi * freq2 * t) * envelope * 0.3;
    }

    samples[i] = (value * 32767).round().clamp(-32768, 32767);
  }

  return _encodeWav(samples, sampleRate);
}

int _duration(SoundType type) {
  switch (type) {
    case SoundType.check: return 80;
    case SoundType.call: return 100;
    case SoundType.fold: return 60;
    case SoundType.raise: return 150;
    case SoundType.allIn: return 200;
    case SoundType.winner: return 300;
  }
}

double _frequency(SoundType type) {
  switch (type) {
    case SoundType.check: return 880;
    case SoundType.call: return 660;
    case SoundType.fold: return 330;
    case SoundType.raise: return 1100;
    case SoundType.allIn: return 440;
    case SoundType.winner: return 1320;
  }
}

double _envelope(int i, int total) {
  final attack = 0.05;
  final release = 0.15;
  final pos = i / total;
  if (pos < attack) return pos / attack;
  if (pos > 1 - release) return (1 - pos) / release;
  return 1.0;
}

Uint8List _encodeWav(Int16List samples, int sampleRate) {
  final dataSize = samples.length * 2;
  final fileSize = 44 + dataSize;
  final bytes = ByteData(fileSize);

  bytes.setUint8(0, 0x52); // R
  bytes.setUint8(1, 0x49); // I
  bytes.setUint8(2, 0x46); // F
  bytes.setUint8(3, 0x46); // F
  bytes.setUint32(4, fileSize - 8, Endian.little);
  bytes.setUint8(8, 0x57); // W
  bytes.setUint8(9, 0x41); // A
  bytes.setUint8(10, 0x56); // V
  bytes.setUint8(11, 0x45); // E
  bytes.setUint8(12, 0x66); // f
  bytes.setUint8(13, 0x6D); // m
  bytes.setUint8(14, 0x74); // t
  bytes.setUint8(15, 0x20); // (space)
  bytes.setUint32(16, 16, Endian.little); // chunk size
  bytes.setUint16(20, 1, Endian.little); // PCM
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little); // byte rate
  bytes.setUint16(32, 2, Endian.little); // block align
  bytes.setUint16(34, 16, Endian.little); // bits per sample
  bytes.setUint8(36, 0x64); // d
  bytes.setUint8(37, 0x61); // a
  bytes.setUint8(38, 0x74); // t
  bytes.setUint8(39, 0x61); // a
  bytes.setUint32(40, dataSize, Endian.little);

  for (int i = 0; i < samples.length; i++) {
    bytes.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  return bytes.buffer.asUint8List();
}
