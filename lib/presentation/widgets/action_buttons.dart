import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/domain/enums/player_action.dart';

class ActionButtons extends StatelessWidget {
  final bool canCheck;
  final int currentBet;
  final int playerStack;
  final int bigBlind;
  final Function(PlayerAction action, {int? raiseAmount}) onAction;

  const ActionButtons({
    super.key,
    required this.canCheck,
    required this.currentBet,
    required this.playerStack,
    required this.bigBlind,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _ActionButton(
              label: 'FOLD',
              color: AppColors.textDanger,
              onTap: () => onAction(PlayerAction.fold),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: canCheck ? 'CHECK' : 'CALL',
              color: AppColors.neonGreen,
              onTap: () => onAction(
                canCheck ? PlayerAction.check : PlayerAction.call,
              ),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'RAISE',
              color: AppColors.neonOrange,
              onTap: () => onAction(
                PlayerAction.raise,
                raiseAmount: currentBet + bigBlind * 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: () => onAction(PlayerAction.allIn),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.neonPink.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.neonPink),
              ),
            ),
            child: Text(
              'ALL-IN ($playerStack)',
              style: AppTypography.labelLarge.copyWith(color: AppColors.neonPink),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 48,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: color),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelLarge.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}
