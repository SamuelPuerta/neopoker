import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/domain/entities/player.dart';

class PlayerHud extends StatelessWidget {
  final PlayerEntity player;
  final bool isCurrentPlayer;
  final bool isLocal;

  const PlayerHud({
    super.key,
    required this.player,
    this.isCurrentPlayer = false,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? AppColors.neonCyan.withValues(alpha: 0.15)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: isCurrentPlayer
            ? Border.all(color: AppColors.neonCyan)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person,
            color: isLocal ? AppColors.neonCyan : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: AppTypography.bodySmall.copyWith(
                  color: isCurrentPlayer
                      ? AppColors.neonCyan
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                '${player.stack}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (player.activePower != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.neonPink.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.bolt, color: AppColors.neonPink, size: 12),
            ),
          ],
          if (!player.isActive && !player.isAllIn) ...[
            const SizedBox(width: 8),
            Text(
              'FOLD',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textDanger,
              ),
            ),
          ],
          if (player.isAllIn) ...[
            const SizedBox(width: 8),
            Text(
              'ALL-IN',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.neonOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
