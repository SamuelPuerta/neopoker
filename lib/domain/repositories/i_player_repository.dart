import '../entities/player.dart';

abstract interface class IPlayerRepository {
  Future<PlayerEntity> getPlayer(String playerId);
  Future<void> savePlayer(PlayerEntity player);
  Future<List<PlayerEntity>> getBotPlayers(int count, int difficulty);
}
