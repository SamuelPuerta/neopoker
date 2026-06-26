import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/domain/enums/player_action.dart';

class ActionButtons extends StatefulWidget {
  final bool canCheck;
  final int currentBet;
  final int playerCurrentBet;
  final int playerStack;
  final int bigBlind;
  final Function(PlayerAction action, {int? raiseAmount}) onAction;

  const ActionButtons({
    super.key,
    required this.canCheck,
    required this.currentBet,
    required this.playerCurrentBet,
    required this.playerStack,
    required this.bigBlind,
    required this.onAction,
  });

  @override
  State<ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<ActionButtons> {
  double _customRaise = 0;
  bool _showSlider = false;

  int get _minRaise => widget.currentBet + widget.bigBlind;
  int get _maxRaise => widget.playerStack;
  int get _raiseAmount => _customRaise.round();

  @override
  void initState() {
    super.initState();
    _customRaise = _minRaise.toDouble();
  }

  @override
  void didUpdateWidget(ActionButtons oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentBet != widget.currentBet ||
        oldWidget.playerStack != widget.playerStack) {
      _customRaise = _minRaise.toDouble();
      _showSlider = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final callAmount = widget.currentBet - widget.playerCurrentBet;
    return Column(
      children: [
        Row(
          children: [
            _ActionButton(
              label: 'FOLD',
              color: AppColors.textDanger,
              onTap: () => widget.onAction(PlayerAction.fold),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: widget.canCheck
                  ? 'CHECK'
                  : 'CALL +$callAmount',
              color: AppColors.neonGreen,
              onTap: () {
                _showSlider = false;
                widget.onAction(
                  widget.canCheck ? PlayerAction.check : PlayerAction.call,
                );
              },
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: _showSlider ? 'CONFIRMAR' : 'RAISE',
              color: AppColors.neonOrange,
              onTap: () {
                if (_showSlider) {
                  widget.onAction(
                    PlayerAction.raise,
                    raiseAmount: _raiseAmount,
                  );
                } else {
                  setState(() => _showSlider = true);
                }
              },
            ),
          ],
        ),
        if (_showSlider) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonOrange.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.neonOrange.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Cantidad:',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.neonOrange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$_raiseAmount',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.neonOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showSlider = false),
                      child: Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: AppColors.neonOrange,
                    inactiveTrackColor: AppColors.neonOrange.withValues(alpha: 0.2),
                    thumbColor: AppColors.neonOrange,
                    overlayColor: AppColors.neonOrange.withValues(alpha: 0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                  ),
                  child: Slider(
                    min: _minRaise.toDouble(),
                    max: _maxRaise.toDouble(),
                    value: _customRaise.clamp(
                      _minRaise.toDouble(),
                      _maxRaise.toDouble(),
                    ),
                    onChanged: (v) => setState(() => _customRaise = v),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: TextButton(
            onPressed: () => widget.onAction(PlayerAction.allIn),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.neonPink.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: AppColors.neonPink),
              ),
            ),
            child: Text(
              'ALL-IN (${widget.playerStack})',
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
