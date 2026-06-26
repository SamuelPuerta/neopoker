import 'dart:async';
import '../entities/card.dart';
import '../entities/game_state.dart';
import '../enums/game_mode.dart';
import '../enums/player_action.dart';

abstract interface class IGameRepository {
  Future<String> createSession({
    required GameMode mode,
    required bool isRanked,
    required List<String> playerIds,
  });

  Future<Map<String, List<CardEntity>>> dealCards(String sessionId);

  Future<void> postBlinds(String sessionId);

  Future<GameState> processAction({
    required String sessionId,
    required String playerId,
    required PlayerAction action,
    int? raiseAmount,
  });

  Future<GameState> dealCommunityCards(String sessionId, int count);

  Future<ShowdownResult> resolveShowdown(String sessionId);

  Future<void> startNewHand(String sessionId);

  Stream<GameState> watchGameState(String sessionId);

  Future<void> endSession(String sessionId);
}
