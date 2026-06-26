import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/di/injection.dart';
import 'package:neopoker/core/router/app_router.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/enums/game_mode.dart';
import 'package:neopoker/domain/enums/game_phase.dart';
import 'package:neopoker/domain/enums/power_type.dart';
import 'package:neopoker/domain/repositories/i_game_repository.dart';
import 'package:neopoker/domain/usecases/apply_power.dart';
import 'package:neopoker/domain/usecases/deal_cards.dart';
import 'package:neopoker/domain/usecases/evaluate_hand.dart';
import 'package:neopoker/domain/usecases/process_action.dart';
import 'package:neopoker/domain/usecases/trigger_event.dart';
import 'package:neopoker/presentation/blocs/game/game_bloc.dart';
import 'package:neopoker/presentation/blocs/game/game_event.dart';
import 'package:neopoker/presentation/blocs/game/game_state.dart' as gstate;
import 'package:neopoker/presentation/widgets/action_buttons.dart';
import 'package:neopoker/presentation/widgets/card_widget.dart';
import 'package:neopoker/presentation/widgets/player_hud.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra as Map?;
    final mode = extra?['mode'] as String? ?? 'classic';
    final isRanked = extra?['isRanked'] as bool? ?? false;
    final botCount = extra?['botCount'] as int? ?? 3;
    final botDifficulty = extra?['botDifficulty'] as int? ?? 1;

    return BlocProvider(
      create: (_) => GameBloc(
        gameRepository: getIt<IGameRepository>(),
        dealCards: getIt<DealCards>(),
        processAction: getIt<ProcessAction>(),
        evaluateHand: getIt<EvaluateHand>(),
        applyPower: getIt<ApplyPower>(),
        triggerEvent: getIt<TriggerEvent>(),
      )..add(GameStarted(
          mode:
              mode == 'neon' ? GameMode.neon : GameMode.classic,
          isRanked: isRanked,
          botCount: botCount,
          botDifficulty: botDifficulty,
        )),
      child: const _GameView(),
    );
  }
}

class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: BlocConsumer<GameBloc, gstate.GameBlocState>(
          listener: (context, state) {
            if (state is gstate.GameError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is gstate.GameLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.neonCyan),
              );
            }
            if (state is gstate.GameInProgress) {
              return _GameTable(gameState: state.gameState);
            }
            if (state is gstate.GameShowdown) {
              return _ShowdownView(
                state: state,
              );
            }
            return const Center(
              child: Text(
                'Preparando partida...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GameTable extends StatelessWidget {
  final GameState gameState;

  const _GameTable({required this.gameState});

  @override
  Widget build(BuildContext context) {
    final localPlayer = gameState.players.first;
    final botPlayers = gameState.players.skip(1).toList();
    final isLocalTurn = gameState.currentPlayer.id == 'human_1';

    return Column(
      children: [
        _EventBanner(event: gameState.activeEvent),
        Expanded(
          flex: 3,
          child: _OpponentsSection(players: botPlayers, gameState: gameState),
        ),
        Expanded(
          flex: 4,
          child: _CommunityCardsSection(
            phase: gameState.phase,
            communityCards: gameState.communityCards,
            pot: gameState.pot,
          ),
        ),
        _EnergyBar(
          energy: localPlayer.energy,
          canUsePower: localPlayer.canUsePower && gameState.mode == GameMode.neon,
          onPowerUsed: (power) {
            if (isLocalTurn) {
              context.read<GameBloc>().add(PowerUsed(powerType: power));
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              CardWidget(card: localPlayer.holeCards.isNotEmpty ? localPlayer.holeCards[0] : null),
              const SizedBox(width: 8),
              CardWidget(card: localPlayer.holeCards.length > 1 ? localPlayer.holeCards[1] : null),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localPlayer.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: isLocalTurn ? AppColors.neonCyan : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${localPlayer.stack} créditos',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isLocalTurn && gameState.phase != GamePhase.showdown)
          Padding(
            padding: const EdgeInsets.all(16),
            child: ActionButtons(
              canCheck: gameState.currentBet == 0 ||
                  gameState.currentBet == localPlayer.currentBet,
              currentBet: gameState.currentBet,
              playerStack: localPlayer.stack,
              bigBlind: gameState.bigBlind,
              onAction: (action, {int? raiseAmount}) {
                context.read<GameBloc>().add(PlayerActed(
                  action: action,
                  raiseAmount: raiseAmount,
                ));
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: Center(
                child: Text(
                  gameState.phase == GamePhase.showdown
                      ? 'SHOWDOWN'
                      : 'Esperando...',
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.neonCyan,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OpponentsSection extends StatelessWidget {
  final List<dynamic> players;
  final GameState gameState;

  const _OpponentsSection({required this.players, required this.gameState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: players.map((p) {
            final isTurn = gameState.currentPlayer.id == p.id;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  PlayerHud(
                    player: p,
                    isCurrentPlayer: isTurn,
                  ),
                  if (p.holeCards.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          CardWidget(
                            card: p.holeCards[0],
                            faceDown: gameState.phase != GamePhase.showdown,
                            width: 36,
                            small: true,
                          ),
                          const SizedBox(width: 4),
                          CardWidget(
                            card: p.holeCards.length > 1 ? p.holeCards[1] : null,
                            faceDown: gameState.phase != GamePhase.showdown,
                            width: 36,
                            small: true,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CommunityCardsSection extends StatelessWidget {
  final GamePhase phase;
  final List<dynamic> communityCards;
  final int pot;

  const _CommunityCardsSection({
    required this.phase,
    required this.communityCards,
    required this.pot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final card = i < communityCards.length ? communityCards[i] as dynamic : null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardWidget(
                card: card,
                width: 48,
                small: true,
                faceDown: card == null,
              ),
            );
          }),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          ),
          child: Text(
            'POT: $pot',
            style: AppTypography.labelLarge.copyWith(color: AppColors.neonCyan),
          ),
        ),
      ],
    );
  }
}

class _EnergyBar extends StatelessWidget {
  final int energy;
  final bool canUsePower;
  final Function(PowerType) onPowerUsed;

  const _EnergyBar({
    required this.energy,
    required this.canUsePower,
    required this.onPowerUsed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          ...List.generate(3, (i) {
            return Container(
              width: 16,
              height: 16,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < energy
                    ? (energy <= 1 ? AppColors.energyLow : AppColors.energyFull)
                    : AppColors.energyEmpty,
              ),
            );
          }),
          const Spacer(),
          if (canUsePower)
            PopupMenuButton<PowerType>(
              onSelected: onPowerUsed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonPink.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.neonPink),
                ),
                child: Text(
                  'PODERES',
                  style: AppTypography.labelSmall.copyWith(color: AppColors.neonPink),
                ),
              ),
              itemBuilder: (context) => PowerType.values.map((power) {
                return PopupMenuItem(
                  value: power,
                  child: Text(power.name),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _EventBanner extends StatelessWidget {
  final TableEvent? event;

  const _EventBanner({this.event});

  @override
  Widget build(BuildContext context) {
    if (event == null) return const SizedBox(height: 4);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      color: AppColors.neonOrange.withValues(alpha: 0.2),
      child: Text(
        '⚡ ${event!.displayName}: ${event!.description}',
        textAlign: TextAlign.center,
        style: AppTypography.bodySmall.copyWith(color: AppColors.neonOrange),
      ),
    );
  }
}

class _ShowdownView extends StatelessWidget {
  final gstate.GameShowdown state;

  const _ShowdownView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'SHOWDOWN',
            style: AppTypography.headingLarge.copyWith(color: AppColors.neonPink),
          ),
          const SizedBox(height: 16),
          Text(
            'Ganador: ${state.winnerId}',
            style: AppTypography.headingMedium.copyWith(color: AppColors.neonGreen),
          ),
          const SizedBox(height: 16),
          Text(
            'Pot: ${state.gameState.pot}',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.neonCyan),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go(AppRouter.lobby),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.neonCyan,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'VOLVER AL LOBBY',
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.darkBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
