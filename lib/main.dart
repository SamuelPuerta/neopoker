import 'package:flutter/material.dart';
import 'package:neopoker/app.dart';
import 'package:neopoker/core/di/injection_offline.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupOfflineDependencies();
  runApp(const NeoPokerApp());
}
