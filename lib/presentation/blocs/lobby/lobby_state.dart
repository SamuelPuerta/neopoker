import 'package:equatable/equatable.dart';
import 'package:neopoker/domain/enums/game_mode.dart';

sealed class LobbyState extends Equatable {
  const LobbyState();

  @override
  List<Object?> get props => [];
}

class LobbyInitial extends LobbyState {
  const LobbyInitial();
}

class LobbyReady extends LobbyState {
  final GameMode mode;
  final bool isRanked;
  final int botDifficulty;

  const LobbyReady({
    this.mode = GameMode.classic,
    this.isRanked = false,
    this.botDifficulty = 1,
  });

  @override
  List<Object?> get props => [mode, isRanked, botDifficulty];
}
