import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/router/app_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.go(AppRouter.home),
              ),
              const SizedBox(height: 24),
              Text(
                'AJUSTES',
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 32),
              _SettingTile(label: 'Sonido', trailing: const Icon(Icons.volume_up, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              _SettingTile(label: 'Música', trailing: const Icon(Icons.music_note, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              _SettingTile(label: 'Efectos visuales', trailing: const Icon(Icons.visibility, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              _SettingTile(label: 'Versión', trailing: Text('0.1.0', style: TextStyle(color: AppColors.textSecondary))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingTile({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
          trailing,
        ],
      ),
    );
  }
}
