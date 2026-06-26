import 'package:equatable/equatable.dart';
import 'card.dart';
import 'player.dart';
import 'hand_result.dart';
import '../enums/game_phase.dart';
import '../enums/game_mode.dart';
import '../enums/table_event_type.dart';

class TableEvent extends Equatable {
  final TableEventType type;
  final String displayName;
  final String description;
  final int durationRounds;
  final bool affectsAllPlayers;
  final bool isVisualOnly;
  final int roundsUntilActive;

  const TableEvent({
    required this.type,
    this.displayName = '',
    this.description = '',
    this.durationRounds = 1,
    this.affectsAllPlayers = true,
    this.isVisualOnly = false,
    this.roundsUntilActive = 0,
  });

  TableEvent copyWith({
    TableEventType? type,
    String? displayName,
    String? description,
    int? durationRounds,
    bool? affectsAllPlayers,
    bool? isVisualOnly,
    int? roundsUntilActive,
  }) {
    return TableEvent(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      durationRounds: durationRounds ?? this.durationRounds,
      affectsAllPlayers: affectsAllPlayers ?? this.affectsAllPlayers,
      isVisualOnly: isVisualOnly ?? this.isVisualOnly,
      roundsUntilActive: roundsUntilActive ?? this.roundsUntilActive,
    );
  }

  @override
  List<Object?> get props => [
        type,
        displayName,
        description,
        durationRounds,
        affectsAllPlayers,
        isVisualOnly,
        roundsUntilActive,
      ];
}

class ShowdownResult extends Equatable {
  final String winnerId;
  final int pot;
  final Map<String, HandResult> results;
  final List<String> handDescriptions;

  const ShowdownResult({
    required this.winnerId,
    required this.pot,
    required this.results,
    this.handDescriptions = const [],
  });

  @override
  List<Object?> get props => [winnerId, pot, results, handDescriptions];
}

class GameState extends Equatable {
  final String gameId;
  final GameMode mode;
  final GamePhase phase;
  final List<PlayerEntity> players;
  final List<CardEntity> communityCards;
  final int pot;
  final int currentBet;
  final int currentPlayerIndex;
  final int dealerIndex;
  final TableEvent? activeEvent;
  final TableEvent? upcomingEvent;
  final bool isRanked;
  final int roundCount;
  final int smallBlind;
  final int bigBlind;
  final Map<String, int> playerTimeBank;

  const GameState({
    required this.gameId,
    required this.mode,
    required this.phase,
    required this.players,
    this.communityCards = const [],
    this.pot = 0,
    this.currentBet = 0,
    this.currentPlayerIndex = 0,
    this.dealerIndex = 0,
    this.activeEvent,
    this.upcomingEvent,
    this.isRanked = false,
    this.roundCount = 0,
    this.smallBlind = 10,
    this.bigBlind = 20,
    this.playerTimeBank = const {},
  });

  PlayerEntity get currentPlayer => players[currentPlayerIndex];
  PlayerEntity get dealer => players[dealerIndex];

  GameState copyWith({
    String? gameId,
    GameMode? mode,
    GamePhase? phase,
    List<PlayerEntity>? players,
    List<CardEntity>? communityCards,
    int? pot,
    int? currentBet,
    int? currentPlayerIndex,
    int? dealerIndex,
    TableEvent? activeEvent,
    TableEvent? upcomingEvent,
    bool? isRanked,
    int? roundCount,
    int? smallBlind,
    int? bigBlind,
    Map<String, int>? playerTimeBank,
    bool clearActiveEvent = false,
    bool clearUpcomingEvent = false,
  }) {
    return GameState(
      gameId: gameId ?? this.gameId,
      mode: mode ?? this.mode,
      phase: phase ?? this.phase,
      players: players ?? this.players,
      communityCards: communityCards ?? this.communityCards,
      pot: pot ?? this.pot,
      currentBet: currentBet ?? this.currentBet,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      dealerIndex: dealerIndex ?? this.dealerIndex,
      activeEvent:
          clearActiveEvent ? null : (activeEvent ?? this.activeEvent),
      upcomingEvent: clearUpcomingEvent
          ? null
          : (upcomingEvent ?? this.upcomingEvent),
      isRanked: isRanked ?? this.isRanked,
      roundCount: roundCount ?? this.roundCount,
      smallBlind: smallBlind ?? this.smallBlind,
      bigBlind: bigBlind ?? this.bigBlind,
      playerTimeBank: playerTimeBank ?? this.playerTimeBank,
    );
  }

  @override
  List<Object?> get props => [
        gameId,
        mode,
        phase,
        players,
        communityCards,
        pot,
        currentBet,
        currentPlayerIndex,
        dealerIndex,
        activeEvent,
        upcomingEvent,
        isRanked,
        roundCount,
        smallBlind,
        bigBlind,
        playerTimeBank,
      ];
}
