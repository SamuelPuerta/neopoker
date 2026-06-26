import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/constants/game_constants.dart';
import 'package:neopoker/core/router/app_router.dart';
import 'package:neopoker/domain/enums/game_mode.dart';
import 'package:neopoker/presentation/blocs/lobby/lobby_bloc.dart';
import 'package:neopoker/presentation/blocs/lobby/lobby_event.dart';
import 'package:neopoker/presentation/blocs/lobby/lobby_state.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LobbyBloc()..add(const LobbyStarted()),
      child: _LobbyView(),
    );
  }
}

class _LobbyView extends StatelessWidget {
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
              const SizedBox(height: 16),
              Text(
                'NUEVA PARTIDA',
                style: AppTypography.headingMedium.copyWith(
                  color: AppColors.neonCyan,
                ),
              ),
              const SizedBox(height: 32),
              BlocBuilder<LobbyBloc, LobbyState>(
                builder: (context, state) {
                  if (state is! LobbyReady) return const SizedBox();
                  return Expanded(
                    child: Column(
                      children: [
                        _ModeSelector(state: state),
                        const SizedBox(height: 24),
                        if (state.mode == GameMode.classic) ...[
                          _DifficultySelector(state: state),
                          const SizedBox(height: 24),
                        ],
                        const Spacer(),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: TextButton(
                            onPressed: () => _startGame(context, state),
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.neonCyan,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'COMENZAR PARTIDA',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.darkBackground,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context, LobbyReady state) {
    context.go(AppRouter.game, extra: {
      'mode': state.mode.name,
      'isRanked': state.isRanked,
      'botCount': GameConstants.maxPlayers - 1,
      'botDifficulty': state.botDifficulty,
    });
  }
}

class _ModeSelector extends StatelessWidget {
  final LobbyReady state;

  const _ModeSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODO DE JUEGO',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ModeCard(
                label: 'CLASSIC',
                subtitle: 'Póker puro',
                selected: state.mode == GameMode.classic,
                onTap: () => context
                    .read<LobbyBloc>()
                    .add(const GameModeSelected(mode: GameMode.classic, isRanked: false)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ModeCard(
                label: 'NEON',
                subtitle: 'Póker + Poderes',
                selected: state.mode == GameMode.neon,
                onTap: () => context
                    .read<LobbyBloc>()
                    .add(const GameModeSelected(mode: GameMode.neon, isRanked: false)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonCyan.withValues(alpha: 0.1) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.neonCyan : AppColors.textSecondary.withValues(alpha: 0.3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: selected ? AppColors.neonCyan : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  final LobbyReady state;

  const _DifficultySelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final difficulties = ['Novato', 'Operador', 'Elite'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DIFICULTAD DE BOTS',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(3, (i) {
            final selected = state.botDifficulty == i + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => context
                      .read<LobbyBloc>()
                      .add(BotDifficultyChanged(difficulty: i + 1)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.neonGreen.withValues(alpha: 0.1)
                          : AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.textSecondary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      difficulties[i],
                      textAlign: TextAlign.center,
                      style: AppTypography.bodySmall.copyWith(
                        color: selected ? AppColors.neonGreen : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
