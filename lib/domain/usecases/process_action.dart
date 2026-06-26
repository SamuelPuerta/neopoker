import '../entities/game_state.dart';
import '../enums/player_action.dart';
import '../repositories/i_game_repository.dart';

class ProcessAction {
  final IGameRepository repository;

  ProcessAction(this.repository);

  Future<GameState> call({
    required String sessionId,
    required String playerId,
    required PlayerAction action,
    int? raiseAmount,
  }) {
    return repository.processAction(
      sessionId: sessionId,
      playerId: playerId,
      action: action,
      raiseAmount: raiseAmount,
    );
  }
}
