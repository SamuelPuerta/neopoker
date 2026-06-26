import '../entities/card.dart';
import '../repositories/i_game_repository.dart';

class DealCards {
  final IGameRepository repository;

  DealCards(this.repository);

  Future<Map<String, List<CardEntity>>> call(String sessionId) {
    return repository.dealCards(sessionId);
  }
}
