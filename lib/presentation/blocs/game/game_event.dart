import 'package:equatable/equatable.dart';
import 'package:neopoker/domain/enums/game_mode.dart';
import 'package:neopoker/domain/enums/player_action.dart';
import 'package:neopoker/domain/enums/power_type.dart';

sealed class GameBlocEvent extends Equatable {
  const GameBlocEvent();

  @override
  List<Object?> get props => [];
}

class GameStarted extends GameBlocEvent {
  final GameMode mode;
  final bool isRanked;
  final List<String> playerIds;
  final int botCount;
  final int botDifficulty;

  const GameStarted({
    required this.mode,
    this.isRanked = false,
    this.playerIds = const ['human_1'],
    this.botCount = 3,
    this.botDifficulty = 1,
  });

  @override
  List<Object?> get props => [mode, isRanked, playerIds, botCount, botDifficulty];
}

class PlayerActed extends GameBlocEvent {
  final PlayerAction action;
  final int? raiseAmount;

  const PlayerActed({required this.action, this.raiseAmount});

  @override
  List<Object?> get props => [action, raiseAmount];
}

class PowerUsed extends GameBlocEvent {
  final PowerType powerType;

  const PowerUsed({required this.powerType});

  @override
  List<Object?> get props => [powerType];
}

class BotActionRequested extends GameBlocEvent {
  final String sessionId;

  const BotActionRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class EventResolved extends GameBlocEvent {
  const EventResolved();
}

class NextPhaseRequested extends GameBlocEvent {
  const NextPhaseRequested();
}

class GameEnded extends GameBlocEvent {
  const GameEnded();
}

class GameStateUpdated extends GameBlocEvent {
  final dynamic gameState;

  const GameStateUpdated({required this.gameState});

  @override
  List<Object?> get props => [gameState];
}
