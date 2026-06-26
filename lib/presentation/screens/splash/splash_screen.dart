import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go(AppRouter.home);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NEOPOKER',
              style: AppTypography.headingLarge.copyWith(
                color: AppColors.neonCyan,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ciudad Nexo te espera',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: AppColors.neonCyan,
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
