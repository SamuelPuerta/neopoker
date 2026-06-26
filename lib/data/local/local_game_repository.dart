import 'dart:async';
import 'package:uuid/uuid.dart';
import 'package:neopoker/core/utils/hand_evaluator.dart';
import 'package:neopoker/domain/entities/card.dart';
import 'package:neopoker/domain/entities/deck.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/entities/player.dart';
import 'package:neopoker/domain/enums/game_mode.dart';
import 'package:neopoker/domain/enums/game_phase.dart';
import 'package:neopoker/domain/enums/player_action.dart';
import 'package:neopoker/domain/entities/hand_result.dart';
import 'package:neopoker/domain/repositories/i_game_repository.dart';
import 'package:neopoker/domain/usecases/trigger_event.dart';
import 'local_player_repository.dart';

class LocalGameRepository implements IGameRepository {
  final HandEvaluator _evaluator = HandEvaluator();
  final LocalPlayerRepository _playerRepo;
  final TriggerEvent _triggerEvent = TriggerEvent();
  final Map<String, GameState> _sessions = {};
  final Map<String, StreamController<GameState>> _controllers = {};
  final Map<String, Deck> _decks = {};
  final Map<String, Map<String, List<CardEntity>>> _holeCards = {};
  final _uuid = const Uuid();

  LocalGameRepository(this._playerRepo);

  @override
  Future<String> createSession({
    required GameMode mode,
    required bool isRanked,
    required List<String> playerIds,
  }) async {
    final id = _uuid.v4();
    final players = <PlayerEntity>[];

    for (int i = 0; i < playerIds.length; i++) {
      final isHuman = i == 0;
      final player = await _playerRepo.getPlayer(playerIds[i]);
      players.add(player.copyWith(
        id: playerIds[i],
        isBot: !isHuman,
        botDifficulty: isHuman ? 0 : (i % 3 + 1),
        stack: mode == GameMode.neon ? 2000 : 1000,
        energy: mode == GameMode.neon ? 3 : 0,
        availablePowers:
            mode == GameMode.neon ? [/* poderes por defecto */] : [],
      ));
    }

    final state = GameState(
      gameId: id,
      mode: mode,
      phase: GamePhase.waiting,
      players: players,
      smallBlind: mode == GameMode.neon ? 20 : 10,
      bigBlind: mode == GameMode.neon ? 40 : 20,
      isRanked: isRanked,
    );

    _sessions[id] = state;
    _controllers[id] = StreamController<GameState>.broadcast();
    _decks[id] = Deck();
    _holeCards[id] = {};

    return id;
  }

  @override
  Future<Map<String, List<CardEntity>>> dealCards(String sessionId) async {
    final deck = _decks[sessionId]!;
    deck.shuffle();

    final state = _sessions[sessionId]!;
    final distribution = <String, List<CardEntity>>{};

    for (final player in state.players) {
      final cards = [deck.draw(), deck.draw()];
      distribution[player.id] = cards;
    }

    _holeCards[sessionId] = distribution;

    final updatedState = state.copyWith(
      phase: GamePhase.preFlop,
      players: state.players.map((p) {
        final cards = distribution[p.id]!;
        return p.copyWith(holeCards: cards);
      }).toList(),
    );

    _emit(sessionId, updatedState);
    return distribution;
  }

  @override
  Future<void> postBlinds(String sessionId) async {
    var state = _sessions[sessionId]!;
    final sbPlayer = state.players[(state.dealerIndex + 1) % state.players.length];
    final bbPlayer = state.players[(state.dealerIndex + 2) % state.players.length];

    final updatedPlayers = state.players.map((p) {
      if (p.id == sbPlayer.id) {
        return p.copyWith(
          stack: p.stack - state.smallBlind,
          currentBet: state.smallBlind,
          totalBetThisHand: state.smallBlind,
        );
      }
      if (p.id == bbPlayer.id) {
        return p.copyWith(
          stack: p.stack - state.bigBlind,
          currentBet: state.bigBlind,
          totalBetThisHand: state.bigBlind,
        );
      }
      return p.copyWith(currentBet: 0);
    }).toList();

    state = state.copyWith(
      pot: state.smallBlind + state.bigBlind,
      currentBet: state.bigBlind,
      players: updatedPlayers,
      currentPlayerIndex: (state.dealerIndex + 3) % state.players.length,
    );

    _emit(sessionId, state);
  }

  @override
  Future<GameState> processAction({
    required String sessionId,
    required String playerId,
    required PlayerAction action,
    int? raiseAmount,
  }) async {
    var state = _sessions[sessionId]!;
    final playerIndex = state.players.indexWhere((p) => p.id == playerId);

    if (playerIndex == -1) throw StateError('Player not found');

    final player = state.players[playerIndex];
    late List<PlayerEntity> updatedPlayers;
    int pot = state.pot;
    int currentBet = state.currentBet;

    switch (action) {
      case PlayerAction.fold:
        updatedPlayers = state.players.map((p) {
          if (p.id == playerId) return p.copyWith(isActive: false);
          return p;
        }).toList();
        break;
      case PlayerAction.check:
        updatedPlayers = List.from(state.players);
        break;
      case PlayerAction.call:
        final callAmount = state.currentBet - player.currentBet;
        final actualCall = callAmount > player.stack ? player.stack : callAmount;
        updatedPlayers = state.players.map((p) {
          if (p.id != playerId) return p;
          return p.copyWith(
            stack: p.stack - actualCall,
            currentBet: p.currentBet + actualCall,
            totalBetThisHand: p.totalBetThisHand + actualCall,
            isAllIn: p.stack - actualCall == 0,
          );
        }).toList();
        pot += actualCall;
        break;
      case PlayerAction.raise:
        final totalRaise = raiseAmount ?? state.bigBlind * 2;
        final actualRaise =
            totalRaise > player.stack ? player.stack : totalRaise;
        updatedPlayers = state.players.map((p) {
          if (p.id != playerId) return p;
          return p.copyWith(
            stack: p.stack - actualRaise,
            currentBet: p.currentBet + actualRaise,
            totalBetThisHand: p.totalBetThisHand + actualRaise,
            isAllIn: p.stack - actualRaise == 0,
          );
        }).toList();
        pot += actualRaise;
        currentBet = player.currentBet + actualRaise;
        break;
      case PlayerAction.allIn:
        final allInAmount = player.stack;
        updatedPlayers = state.players.map((p) {
          if (p.id != playerId) return p;
          return p.copyWith(
            stack: 0,
            currentBet: p.currentBet + allInAmount,
            totalBetThisHand: p.totalBetThisHand + allInAmount,
            isAllIn: true,
          );
        }).toList();
        pot += allInAmount;
        currentBet =
            player.currentBet + allInAmount > currentBet
                ? player.currentBet + allInAmount
                : currentBet;
        break;
    }

    final activePlayers = updatedPlayers.where((p) => p.isActive && !p.isAllIn).length;
    final nextPhase = _shouldAdvancePhase(state, updatedPlayers, activePlayers);

    final nextIndex = _nextActivePlayerIndex(
      updatedPlayers,
      state.currentPlayerIndex,
    );

    GamePhase? newPhase;
    if (activePlayers <= 1) {
      newPhase = GamePhase.gameOver;
    } else if (nextPhase && state.phase == GamePhase.preFlop) {
      newPhase = GamePhase.flop;
    } else if (nextPhase && state.phase == GamePhase.flop) {
      newPhase = GamePhase.turn;
    } else if (nextPhase && state.phase == GamePhase.turn) {
      newPhase = GamePhase.river;
    } else if (nextPhase && state.phase == GamePhase.river) {
      newPhase = GamePhase.showdown;
    }

    if (newPhase == GamePhase.showdown) {
      await resolveShowdown(sessionId);
      return _sessions[sessionId]!;
    }

    state = state.copyWith(
      players: updatedPlayers,
      pot: pot,
      currentBet: currentBet,
      currentPlayerIndex: nextPhase ? state.dealerIndex : nextIndex,
      phase: newPhase ?? state.phase,
      roundCount: newPhase != null ? state.roundCount + 1 : state.roundCount,
    ).let((s) {
      if (newPhase != null && s.mode == GameMode.neon) {
        final event = _triggerEvent.roll(s.mode, s.isRanked);
        if (event != null) {
          return s.copyWith(
            upcomingEvent: event,
          );
        }
      }
      return s;
    });

    _emit(sessionId, state);
    return state;
  }

  bool _shouldAdvancePhase(
    GameState state,
    List<PlayerEntity> players,
    int activePlayers,
  ) {
    if (activePlayers <= 1) return true;

    final allActed = players.every((p) {
      if (!p.isActive || p.isAllIn) return true;
      return p.totalBetThisHand == state.currentBet || p.stack == 0;
    });

    final allBetsEqual = players
        .where((p) => p.isActive && !p.isAllIn)
        .every((p) => p.currentBet == state.currentBet || p.stack == 0);

    final fullRoundCompleted = _hasCompletedFullRound(state, players);

    return allActed && allBetsEqual && fullRoundCompleted;
  }

  bool _hasCompletedFullRound(
    GameState state,
    List<PlayerEntity> players,
  ) {
    final activeCount = players.where((p) => p.isActive && !p.isAllIn).length;
    if (activeCount <= 1) return true;

    final actingPlayers =
        players.where((p) => p.isActive && !p.isAllIn).toList();
    final firstBettorIndex = actingPlayers
        .indexWhere((p) => p.currentBet == state.currentBet);

    return firstBettorIndex != -1;
  }

  int _nextActivePlayerIndex(List<PlayerEntity> players, int currentIndex) {
    final count = players.length;
    for (int i = 1; i <= count; i++) {
      final idx = (currentIndex + i) % count;
      if (players[idx].isActive && !players[idx].isAllIn) return idx;
    }
    return currentIndex;
  }

  @override
  Future<GameState> dealCommunityCards(String sessionId, int count) async {
    var state = _sessions[sessionId]!;
    final deck = _decks[sessionId]!;
    final newCards = List.generate(count, (_) => deck.draw());
    final updatedCommunity = [...state.communityCards, ...newCards];

    state = state.copyWith(communityCards: updatedCommunity);
    _emit(sessionId, state);
    return state;
  }

  @override
  Future<ShowdownResult> resolveShowdown(String sessionId) async {
    var state = _sessions[sessionId]!;
    final activePlayers = state.players.where((p) => p.isActive).toList();

    final results = <String, HandResult>{};
    for (final player in activePlayers) {
      final result = _evaluator.evaluate(player.holeCards, state.communityCards);
      results[player.id] = result;
    }

    var bestId = activePlayers.first.id;
    var bestResult = results[bestId]!;

    for (final entry in results.entries) {
      if (entry.value.compareTo(bestResult) > 0) {
        bestId = entry.key;
        bestResult = entry.value;
      }
    }

    final updatedPlayers = state.players.map((p) {
      if (p.id == bestId) {
        return p.copyWith(stack: p.stack + state.pot);
      }
      return p;
    }).toList();

    final descriptions = results.entries.map((e) {
      final playerName = state.players.firstWhere((p) => p.id == e.key).name;
      return '$playerName: ${e.value.rank.name}';
    }).toList();

    state = state.copyWith(
      phase: GamePhase.showdown,
      players: updatedPlayers,
    );
    _emit(sessionId, state);

    return ShowdownResult(
      winnerId: bestId,
      pot: state.pot,
      results: results,
      handDescriptions: descriptions,
    );
  }

  @override
  Stream<GameState> watchGameState(String sessionId) {
    return _controllers[sessionId]!.stream;
  }

  @override
  Future<void> endSession(String sessionId) async {
    _controllers[sessionId]?.close();
    _sessions.remove(sessionId);
    _controllers.remove(sessionId);
    _decks.remove(sessionId);
    _holeCards.remove(sessionId);
  }

  void _emit(String sessionId, GameState state) {
    _sessions[sessionId] = state;
    _controllers[sessionId]?.add(state);
  }
}

extension _LetExtension<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
