import 'package:uuid/uuid.dart';
import 'package:neopoker/domain/entities/player.dart';
import 'package:neopoker/domain/enums/power_type.dart';
import 'package:neopoker/domain/repositories/i_player_repository.dart';

class LocalPlayerRepository implements IPlayerRepository {
  final _uuid = const Uuid();

  final _botNames = [
    'Neón-X',
    'CipherBot',
    'Ghost_99',
    'Vex_Machine',
    'Pulse_K',
    'Kronos_AI',
  ];

  @override
  Future<PlayerEntity> getPlayer(String playerId) async {
    return PlayerEntity(
      id: playerId,
      name: playerId == 'human_1' ? 'Tú' : _botNames[_uuid.hashCode % _botNames.length],
      operatorId: 'vex',
      energy: 3,
      availablePowers: PowerType.values,
    );
  }

  @override
  Future<void> savePlayer(PlayerEntity player) async {}

  @override
  Future<List<PlayerEntity>> getBotPlayers(int count, int difficulty) async {
    return List.generate(count, (i) {
      return PlayerEntity(
        id: 'bot_${_uuid.v4().substring(0, 8)}',
        name: _botNames[i % _botNames.length],
        operatorId: ['vex', 'cipher', 'ghost', 'nyx', 'kronos', 'pulse'][i],
        stack: 1000,
        energy: 3,
        isBot: true,
        botDifficulty: difficulty,
        availablePowers: PowerType.values,
      );
    });
  }
}
