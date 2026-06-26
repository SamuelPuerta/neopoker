import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/router/app_router.dart';

class NeoPokerApp extends StatelessWidget {
  const NeoPokerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NeoPoker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.neonCyan,
          secondary: AppColors.neonPink,
        ),
      ),
      routerConfig: AppRouter.router,
    );
  }
}
