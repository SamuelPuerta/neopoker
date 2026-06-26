import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/router/app_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Text(
                'NEOPOKER',
                style: AppTypography.headingLarge.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'El juego de cartas del futuro',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              _MenuButton(
                label: 'JUGAR',
                onTap: () => context.go(AppRouter.lobby),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'PERFIL',
                onTap: () => context.go(AppRouter.profile),
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'AJUSTES',
                onTap: () => context.go(AppRouter.settings),
              ),
              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _MenuButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.neonCyan, width: 1),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelLarge.copyWith(color: AppColors.neonCyan),
        ),
      ),
    );
  }
}
