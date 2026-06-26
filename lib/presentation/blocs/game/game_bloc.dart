import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/enums/game_phase.dart';
import 'package:neopoker/domain/enums/player_action.dart';
import 'package:neopoker/domain/repositories/i_game_repository.dart';
import 'package:neopoker/domain/usecases/apply_power.dart';
import 'package:neopoker/domain/usecases/deal_cards.dart';
import 'package:neopoker/domain/usecases/evaluate_hand.dart';
import 'package:neopoker/domain/usecases/process_action.dart';
import 'package:neopoker/domain/usecases/trigger_event.dart';
import 'game_event.dart' as events;
import 'game_state.dart' as states;

class GameBloc extends Bloc<events.GameBlocEvent, states.GameBlocState> {
  final IGameRepository _gameRepository;
  final ProcessAction _processAction;
  final EvaluateHand _evaluateHand;
  final ApplyPower _applyPower;

  String? _sessionId;
  StreamSubscription? _gameSubscription;

  GameBloc({
    required IGameRepository gameRepository,
    required DealCards dealCards,
    required ProcessAction processAction,
    required EvaluateHand evaluateHand,
    required ApplyPower applyPower,
    required TriggerEvent triggerEvent,
  })  : _gameRepository = gameRepository,
        _processAction = processAction,
        _evaluateHand = evaluateHand,
        _applyPower = applyPower,
        super(const states.GameInitial()) {
    on<events.GameStarted>(_onGameStarted);
    on<events.PlayerActed>(_onPlayerActed);
    on<events.PowerUsed>(_onPowerUsed);
    on<events.BotActionRequested>(_onBotActionRequested);
    on<events.GameStateUpdated>(_onGameStateUpdated);
    on<events.GameEnded>(_onGameEnded);
  }

  Future<void> _onGameStarted(
    events.GameStarted event,
    Emitter<states.GameBlocState> emit,
  ) async {
    emit(const states.GameLoading());

    try {
      final allIds = <String>[
        'human_1',
        ...List.generate(
          event.botCount,
          (i) => 'bot_${DateTime.now().microsecondsSinceEpoch + i}',
        ),
      ];

      _sessionId = await _gameRepository.createSession(
        mode: event.mode,
        isRanked: event.isRanked,
        playerIds: allIds,
      );

      await _gameRepository.dealCards(_sessionId!);
      await _gameRepository.postBlinds(_sessionId!);

      _gameSubscription?.cancel();
      _gameSubscription = _gameRepository
          .watchGameState(_sessionId!)
          .listen((gameState) {
        if (!isClosed) {
          add(events.GameStateUpdated(gameState: gameState));
        }
      });

      final currentState = await _getCurrentState();
      if (currentState != null) {
        emit(states.GameInProgress(gameState: currentState));
        _triggerBotActionsIfNeeded(currentState);
      }
    } catch (e) {
      emit(states.GameError(message: 'Error al iniciar partida: $e'));
    }
  }

  Future<void> _onPlayerActed(
    events.PlayerActed event,
    Emitter<states.GameBlocState> emit,
  ) async {
    if (_sessionId == null) return;

    try {
      final newState = await _processAction.call(
        sessionId: _sessionId!,
        playerId: 'human_1',
        action: event.action,
        raiseAmount: event.raiseAmount,
      );

      if (newState.phase == GamePhase.showdown ||
          newState.phase == GamePhase.gameOver) {
        final result = await _gameRepository.resolveShowdown(_sessionId!);
        emit(states.GameShowdown(
          gameState: newState,
          results: result.results,
          winnerId: result.winnerId,
        ));
      } else {
        emit(states.GameInProgress(gameState: newState));
        _triggerBotActionsIfNeeded(newState);
      }
    } catch (e) {
      emit(states.GameError(message: 'Error al procesar acción: $e'));
    }
  }

  Future<void> _onPowerUsed(
    events.PowerUsed event,
    Emitter<states.GameBlocState> emit,
  ) async {
    if (_sessionId == null) return;

    final currentState = await _getCurrentState();
    if (currentState == null) return;

    try {
      _applyPower.call(
        currentState: currentState,
        playerId: 'human_1',
        powerType: event.powerType,
      );

      final updatedState = await _getCurrentState();
      if (updatedState != null && state is states.GameInProgress) {
        emit(states.GameInProgress(gameState: updatedState));
      }
    } catch (e) {
      emit(states.GameError(message: 'Error al usar poder: $e'));
    }
  }

  Future<void> _onBotActionRequested(
    events.BotActionRequested event,
    Emitter<states.GameBlocState> emit,
  ) async {
    final currentState = await _getCurrentState();
    if (currentState == null) return;

    if (currentState.currentPlayer.isBot) {
      final action = _getBotAction(currentState);
      final newState = await _processAction.call(
        sessionId: _sessionId!,
        playerId: currentState.currentPlayer.id,
        action: action,
      );

      if (newState.phase == GamePhase.showdown ||
          newState.phase == GamePhase.gameOver) {
        final result = await _gameRepository.resolveShowdown(_sessionId!);
        emit(states.GameShowdown(
          gameState: newState,
          results: result.results,
          winnerId: result.winnerId,
        ));
      } else {
        emit(states.GameInProgress(gameState: newState));
        _triggerBotActionsIfNeeded(newState);
      }
    }
  }

  void _onGameStateUpdated(
    events.GameStateUpdated event,
    Emitter<states.GameBlocState> emit,
  ) {
    final gameState = event.gameState as GameState;
    if (state is states.GameInProgress) {
      emit(states.GameInProgress(gameState: gameState));
    }
  }

  void _onGameEnded(
    events.GameEnded event,
    Emitter<states.GameBlocState> emit,
  ) async {
    _gameSubscription?.cancel();
    if (_sessionId != null) {
      await _gameRepository.endSession(_sessionId!);
    }
    emit(const states.GameInitial());
  }

  void _triggerBotActionsIfNeeded(GameState gameState) {
    if (gameState.currentPlayer.isBot) {
      final delay = Duration(
        milliseconds:
            gameState.currentPlayer.botDifficulty == 1
                ? 800
                : gameState.currentPlayer.botDifficulty == 2
                    ? 600
                    : 400,
      );
      Future.delayed(delay, () {
        if (!isClosed) {
          add(events.BotActionRequested(sessionId: _sessionId!));
        }
      });
    }
  }

  PlayerAction _getBotAction(GameState state) {
    final player = state.currentPlayer;
    final difficulty = player.botDifficulty;

    if (difficulty == 1) {
      if (state.currentBet == 0) return PlayerAction.check;
      if (player.stack < state.currentBet * 3) return PlayerAction.fold;
      return PlayerAction.call;
    }

    if (difficulty == 2) {
      if (state.currentBet == 0) return PlayerAction.check;
      if (player.stack < state.currentBet) return PlayerAction.fold;
      final hasGoodHand = player.holeCards.any((c) => c.numericValue >= 12);
      if (hasGoodHand && state.currentBet <= state.bigBlind * 2) {
        return PlayerAction.raise;
      }
      if (state.currentBet > state.bigBlind * 4) return PlayerAction.fold;
      return PlayerAction.call;
    }

    if (difficulty == 3) {
      final winProb = _evaluateHand.calculateWinProbability(
        player.holeCards,
        state.communityCards,
        state.players.where((p) => p.isActive && p.id != player.id).length,
      );

      if (winProb > 0.7) {
        if (state.currentBet == 0) return PlayerAction.raise;
        return PlayerAction.raise;
      }
      if (winProb > 0.5) return PlayerAction.call;
      if (winProb > 0.3 && state.currentBet < state.bigBlind * 2) {
        return PlayerAction.call;
      }
      return PlayerAction.fold;
    }

    return PlayerAction.check;
  }

  Future<GameState?> _getCurrentState() async {
    if (_sessionId == null) return null;
    return _gameRepository.watchGameState(_sessionId!).first;
  }

  @override
  Future<void> close() {
    _gameSubscription?.cancel();
    return super.close();
  }
}
