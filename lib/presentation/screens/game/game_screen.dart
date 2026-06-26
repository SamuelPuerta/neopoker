import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/core/constants/app_typography.dart';
import 'package:neopoker/core/di/injection.dart';

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

class _GameView extends StatefulWidget {
  const _GameView();

  @override
  State<_GameView> createState() => _GameViewState();
}

class _GameViewState extends State<_GameView> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.cardBackground,
            title: const Text('Salir de la partida',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: const Text('¿Estás seguro de que quieres salir?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Salir',
                  style: TextStyle(color: AppColors.textDanger),
                ),
              ),
            ],
          ),
        );
        if (exit == true && mounted) context.go('/home');
      },
      child: Scaffold(
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
              return _GameTable(
                gameState: state.gameState,
                showdownInfo: state,
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
      ),
    );
  }
}

class _GameTable extends StatelessWidget {
  final GameState gameState;
  final gstate.GameShowdown? showdownInfo;

  const _GameTable({required this.gameState, this.showdownInfo});

  // Clockwise: Neón-X(1) → CipherBot(2) → Ghost_99(3) → Pulse_K(5) → Tú(0) → Vex_Machine(4)
  static const _clockOrder = [1, 2, 3, 5, 0, 4];

  int _clockIndex(int start, int offset) {
    final pos = _clockOrder.indexOf(start);
    if (pos == -1) return (start + offset) % _clockOrder.length;
    return _clockOrder[(pos + offset) % _clockOrder.length];
  }

  String _tagForIndex(GameState gs, int idx) {
    if (idx == gs.dealerIndex) return 'D';
    if (idx == _clockIndex(gs.dealerIndex, 1)) return 'SB';
    if (idx == _clockIndex(gs.dealerIndex, 2)) return 'BB';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final localPlayer = gameState.players.first;
    final botPlayers = gameState.players.skip(1).toList();

    final topBots = botPlayers.take(3).toList();
    final bottomBots = botPlayers.skip(3).toList();
    final isHumanTurn = gameState.currentPlayer.id == 'human_1';

    return Stack(
      children: [
        Column(
          children: [
            _EventBanner(event: gameState.activeEvent),
            _StatusBar(phase: gameState.phase, gameState: gameState),
            Expanded(
              flex: 2,
              child: _OpponentsRow(
                players: topBots, gameState: gameState,
                tagFn: (idx) => _tagForIndex(gameState, idx),
              ),
            ),
            Expanded(
              flex: 3,
              child: _CommunityCardsSection(
                phase: gameState.phase,
                communityCards: gameState.communityCards,
                pot: gameState.pot,
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bottomBots.isNotEmpty)
                      _CompactBotWidget(
                        player: bottomBots[0], gameState: gameState,
                        isTurn: gameState.currentPlayer.id == bottomBots[0].id,
                        tag: _tagForIndex(gameState, gameState.players.indexOf(bottomBots[0])),
                      ),
                    const SizedBox(width: 12),
                    _HumanRect(
                      player: localPlayer,
                      gameState: gameState,
                      isTurn: isHumanTurn,
                      tag: _tagForIndex(gameState, 0),
                    ),
                    const SizedBox(width: 12),
                    if (bottomBots.length > 1)
                      _CompactBotWidget(
                        player: bottomBots[1], gameState: gameState,
                        isTurn: gameState.currentPlayer.id == bottomBots[1].id,
                        tag: _tagForIndex(gameState, gameState.players.indexOf(bottomBots[1])),
                      ),
                  ],
                ),
              ),
            ),
            _PlayerCardsRow(localPlayer: localPlayer, gameState: gameState),
            _EnergyBar(
              energy: localPlayer.energy,
              canUsePower: localPlayer.canUsePower && gameState.mode == GameMode.neon,
              onPowerUsed: (power) {
                context.read<GameBloc>().add(PowerUsed(powerType: power));
              },
            ),
            if (isHumanTurn && gameState.phase != GamePhase.showdown)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ActionButtons(
                  canCheck: gameState.currentBet == 0 ||
                      gameState.currentBet == localPlayer.currentBet,
                  currentBet: gameState.currentBet,
                  playerCurrentBet: localPlayer.currentBet,
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
                      gameState.phase == GamePhase.showdown || gameState.phase == GamePhase.gameOver
                          ? 'MOSTRANDO CARTAS...'
                          : 'Esperando...',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.neonCyan,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        if (showdownInfo != null)
          _ShowdownOverlay(showdownInfo: showdownInfo!),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  final GamePhase phase;
  final GameState gameState;

  const _StatusBar({required this.phase, required this.gameState});

  String _phaseLabel(GamePhase p) {
    switch (p) {
      case GamePhase.preFlop:
        return 'PRE-FLOP';
      case GamePhase.flop:
        return 'FLOP';
      case GamePhase.turn:
        return 'TURN';
      case GamePhase.river:
        return 'RIVER';
      case GamePhase.showdown:
        return 'SHOWDOWN';
      case GamePhase.gameOver:
        return 'GAME OVER';
      case GamePhase.waiting:
        return 'ESPERANDO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final turnPlayer = gameState.currentPlayer;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.4)),
            ),
            child: Text(
              _phaseLabel(phase),
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neonCyan,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          if (!gameState.currentPlayer.isBot)
            Text(
              'TU TURNO',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neonGreen,
                fontWeight: FontWeight.bold,
              ),
            )
          else ...[
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonOrange,
              ),
            ),
            Text(
              '${turnPlayer.name} piensa...',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neonOrange,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OpponentsRow extends StatelessWidget {
  final List<dynamic> players;
  final GameState gameState;
  final String Function(int playerIndex) tagFn;

  const _OpponentsRow({
    required this.players,
    required this.gameState,
    required this.tagFn,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) return const SizedBox.shrink();
    return Center(
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: players.map((p) {
                final isTurn = gameState.currentPlayer.id == p.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _CompactBotWidget(
                    player: p,
                    gameState: gameState,
                    isTurn: isTurn,
                    tag: tagFn(gameState.players.indexOf(p)),
                    isHuman: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShowdownOverlay extends StatefulWidget {
  final gstate.GameShowdown showdownInfo;

  const _ShowdownOverlay({required this.showdownInfo});

  @override
  State<_ShowdownOverlay> createState() => _ShowdownOverlayState();
}

class _ShowdownOverlayState extends State<_ShowdownOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.showdownInfo;
    final gs = info.gameState;
    final players = gs.players;
    final winner = players.firstWhere((p) => p.id == info.winnerId, orElse: () => players.first);

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: Opacity(
                opacity: _fadeAnim.value,
                child: child,
              ),
            ),
            child: Container(
              width: 320,
              constraints: const BoxConstraints(maxHeight: 460),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.neonGreen, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.neonGreen.withValues(alpha: 0.3), blurRadius: 20),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: AppColors.neonGreen, size: 36),
                  const SizedBox(height: 4),
                  Text(
                    winner.name.toUpperCase(),
                    style: AppTypography.headingMedium.copyWith(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'GANADOR',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.neonGreen,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                    final hasCard = i < gs.communityCards.length;
                    if (!hasCard) {
                      return Container(
                        width: 28, height: 39,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2)),
                        ),
                      );
                    }
                    final winnerHand = info.results[info.winnerId]?.bestHand ?? [];
                    final isHighlighted = winnerHand.any((c) =>
                      c.rank == gs.communityCards[i].rank && c.suit == gs.communityCards[i].suit);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: CardWidget(
                        card: gs.communityCards[i],
                        small: true, width: 28, faceDown: false,
                        highlighted: isHighlighted,
                      ),
                    );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.neonCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'POT: ${gs.pot} créditos',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.neonCyan),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: players.where((p) => p.isActive).map((p) {
                        final isWinner = p.id == info.winnerId;
                        final handResult = info.results[p.id];
                        final bestHand = handResult?.bestHand ?? [];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: isWinner ? AppColors.neonGreen.withValues(alpha: 0.1) : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(6),
                            border: isWinner ? Border.all(color: AppColors.neonGreen, width: 1) : null,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.name,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: isWinner ? AppColors.neonGreen : AppColors.textPrimary,
                                        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    if (handResult != null)
                                      Text(
                                        handResult.rank.name,
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isWinner ? AppColors.neonGreen : AppColors.textSecondary,
                                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (p.holeCards.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CardWidget(
                                      card: p.holeCards[0], small: true, width: 28, faceDown: false,
                                      highlighted: bestHand.any((c) =>
                                        c.rank == p.holeCards[0].rank && c.suit == p.holeCards[0].suit),
                                    ),
                                    const SizedBox(width: 2),
                                    CardWidget(
                                      card: p.holeCards.length > 1 ? p.holeCards[1] : null,
                                      small: true, width: 28, faceDown: false,
                                      highlighted: p.holeCards.length > 1 && bestHand.any((c) =>
                                        c.rank == p.holeCards[1].rank && c.suit == p.holeCards[1].suit),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactBotWidget extends StatelessWidget {
  final dynamic player;
  final GameState gameState;
  final bool isTurn;
  final String tag;
  final bool isHuman;

  const _CompactBotWidget({
    required this.player,
    required this.gameState,
    required this.isTurn,
    required this.tag,
    this.isHuman = false,
  });

  @override
  Widget build(BuildContext context) {
    final faceDown = !isHuman && gameState.phase != GamePhase.showdown;

    return Container(
      width: 110,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isTurn
            ? AppColors.neonCyan.withValues(alpha: 0.15)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTurn ? AppColors.neonCyan : AppColors.neonCyan.withValues(alpha: 0.1),
          width: isTurn ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTurn
                      ? (isHuman ? AppColors.neonGreen.withValues(alpha: 0.3) : AppColors.neonCyan.withValues(alpha: 0.3))
                      : AppColors.neonCyan.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    isHuman ? Icons.person : (isTurn ? Icons.smart_toy : Icons.android),
                    size: 14,
                    color: isTurn
                        ? (isHuman ? AppColors.neonGreen : AppColors.neonCyan)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  player.name,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: isTurn ? (isHuman ? AppColors.neonGreen : AppColors.neonCyan) : AppColors.textPrimary,
                    fontSize: 11,
                    fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (tag.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: tag == 'D'
                        ? AppColors.neonPink.withValues(alpha: 0.3)
                        : (isHuman
                            ? AppColors.neonGreen.withValues(alpha: 0.2)
                            : AppColors.neonCyan.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: tag == 'D'
                          ? AppColors.neonPink
                          : (isHuman ? AppColors.neonGreen : AppColors.neonCyan),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.labelSmall.copyWith(
                      color: tag == 'D'
                          ? AppColors.neonPink
                          : (isHuman ? AppColors.neonGreen : AppColors.neonCyan),
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (isHuman)
                Container(
                  margin: const EdgeInsets.only(left: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.neonGreen, width: 0.5),
                  ),
                  child: Text(
                    'TU',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.neonGreen,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, size: 10, color: AppColors.neonCyan.withValues(alpha: 0.6)),
              const SizedBox(width: 2),
              Text(
                '${player.stack}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonCyan,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          if (player.currentBet > 0) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.neonOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${player.currentBet}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonOrange,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          if (player.holeCards is List && (player.holeCards as List).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CardWidget(card: player.holeCards[0], small: true, width: 32, faceDown: faceDown),
                  const SizedBox(width: 2),
                  CardWidget(
                    card: player.holeCards.length > 1 ? player.holeCards[1] : null,
                    small: true, width: 32, faceDown: faceDown,
                  ),
                ],
              ),
            ),
          if (!player.isActive && !player.isAllIn)
            Text(
              'FOLD',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textDanger,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (player.isAllIn)
            Text(
              'ALL-IN',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.neonOrange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _HumanRect extends StatelessWidget {
  final dynamic player;
  final GameState gameState;
  final bool isTurn;
  final String tag;

  const _HumanRect({
    required this.player,
    required this.gameState,
    required this.isTurn,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isTurn
            ? AppColors.neonGreen.withValues(alpha: 0.15)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isTurn ? AppColors.neonGreen : AppColors.neonGreen.withValues(alpha: 0.2),
          width: isTurn ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isTurn
                      ? AppColors.neonGreen.withValues(alpha: 0.3)
                      : AppColors.neonGreen.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.person, size: 14,
                  color: isTurn ? AppColors.neonGreen : AppColors.textSecondary),
              ),
              const SizedBox(width: 4),
              Text(
                player.name,
                style: AppTypography.bodySmall.copyWith(
                  color: isTurn ? AppColors.neonGreen : AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: isTurn ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monetization_on, size: 10, color: AppColors.neonCyan.withValues(alpha: 0.6)),
              const SizedBox(width: 2),
              Text(
                '${player.stack}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonCyan, fontSize: 11,
                ),
              ),
            ],
          ),
          if (player.currentBet > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: AppColors.neonOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Apuesta: ${player.currentBet}',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonOrange,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tag.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tag == 'D'
                        ? AppColors.neonPink.withValues(alpha: 0.3)
                        : AppColors.neonCyan.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: tag == 'D' ? AppColors.neonPink : AppColors.neonCyan,
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    tag,
                    style: AppTypography.labelSmall.copyWith(
                      color: tag == 'D' ? AppColors.neonPink : AppColors.neonCyan,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: AppColors.neonGreen, width: 0.5),
                ),
                child: Text(
                  'TU',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.neonGreen, fontSize: 9, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerCardsRow extends StatelessWidget {
  final dynamic localPlayer;
  final GameState gameState;

  const _PlayerCardsRow({required this.localPlayer, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final toCall = gameState.currentBet - localPlayer.currentBet;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (toCall > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Faltan +$toCall para igualar',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.neonGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CardWidget(
                card: localPlayer.holeCards.isNotEmpty ? localPlayer.holeCards[0] : null,
                width: 64, faceDown: false,
              ),
              const SizedBox(width: 10),
              CardWidget(
                card: localPlayer.holeCards.length > 1 ? localPlayer.holeCards[1] : null,
                width: 64, faceDown: false,
              ),
            ],
          ),
        ],
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
            final card = i < communityCards.length ? communityCards[i] : null;
            final showEmpty = phase == GamePhase.waiting;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: CardWidget(
                card: card,
                width: 54,
                small: true,
                faceDown: card == null && !showEmpty,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.neonCyan.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Row(
        children: [
          ...List.generate(3, (i) {
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 3),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
