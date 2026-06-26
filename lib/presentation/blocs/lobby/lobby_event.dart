import 'package:equatable/equatable.dart';
import 'package:neopoker/domain/enums/game_mode.dart';

sealed class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object?> get props => [];
}

class LobbyStarted extends LobbyEvent {
  const LobbyStarted();
}

class GameModeSelected extends LobbyEvent {
  final GameMode mode;
  final bool isRanked;

  const GameModeSelected({required this.mode, required this.isRanked});

  @override
  List<Object?> get props => [mode, isRanked];
}

class BotDifficultyChanged extends LobbyEvent {
  final int difficulty;

  const BotDifficultyChanged({required this.difficulty});

  @override
  List<Object?> get props => [difficulty];
}
