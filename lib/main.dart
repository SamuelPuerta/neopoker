import 'package:flutter/material.dart';
import 'package:neopoker/app.dart';
import 'package:neopoker/core/di/injection_offline.dart';
import 'package:neopoker/core/utils/sound_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupOfflineDependencies();
  await SoundService.instance.init();
  runApp(const NeoPokerApp());
}
