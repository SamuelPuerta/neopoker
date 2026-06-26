class GameResult {
  final String gameId;
  final String winnerId;
  final int pot;
  final int duration;
  final bool isRanked;

  const GameResult({
    required this.gameId,
    required this.winnerId,
    required this.pot,
    required this.duration,
    required this.isRanked,
  });
}

class PlayerStats {
  final String playerId;
  final int totalGames;
  final int totalWins;
  final int totalXp;
  final int credits;
  final int level;

  const PlayerStats({
    required this.playerId,
    this.totalGames = 0,
    this.totalWins = 0,
    this.totalXp = 0,
    this.credits = 0,
    this.level = 1,
  });
}

abstract interface class IStatsRepository {
  Future<void> saveGameResult(GameResult result);
  Future<PlayerStats> getStats(String playerId);
  Future<void> updateXp(String playerId, int delta);
  Future<void> updateCredits(String playerId, int delta);
}
