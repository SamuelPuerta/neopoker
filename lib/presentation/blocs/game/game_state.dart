import 'package:equatable/equatable.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/entities/hand_result.dart';

sealed class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameLoading extends GameBlocState {
  const GameLoading();
}

class GameInProgress extends GameBlocState {
  final GameState gameState;

  const GameInProgress({required this.gameState});

  @override
  List<Object?> get props => [gameState];
}

class GameShowdown extends GameBlocState {
  final GameState gameState;
  final Map<String, HandResult> results;
  final String winnerId;

  const GameShowdown({
    required this.gameState,
    required this.results,
    required this.winnerId,
  });

  @override
  List<Object?> get props => [gameState, results, winnerId];
}

class GameError extends GameBlocState {
  final String message;

  const GameError({required this.message});

  @override
  List<Object?> get props => [message];
}
