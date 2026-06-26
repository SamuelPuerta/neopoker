import 'package:neopoker/domain/repositories/i_stats_repository.dart';

class LocalStatsRepository implements IStatsRepository {
  int _totalGames = 0;
  int _totalWins = 0;
  int _totalXp = 0;
  int _credits = 0;
  final int _level = 1;

  @override
  Future<void> saveGameResult(GameResult result) async {
    _totalGames++;
    if (result.winnerId == 'human_1') _totalWins++;
    _totalXp += result.winnerId == 'human_1' ? 100 : 40;
  }

  @override
  Future<PlayerStats> getStats(String playerId) async {
    return PlayerStats(
      playerId: playerId,
      totalGames: _totalGames,
      totalWins: _totalWins,
      totalXp: _totalXp,
      credits: _credits,
      level: _level,
    );
  }

  @override
  Future<void> updateXp(String playerId, int delta) async {
    _totalXp += delta;
  }

  @override
  Future<void> updateCredits(String playerId, int delta) async {
    _credits += delta;
  }
}
