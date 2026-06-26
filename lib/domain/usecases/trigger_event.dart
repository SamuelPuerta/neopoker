import 'dart:math';
import '../entities/game_state.dart';
import '../enums/game_mode.dart';
import '../enums/table_event_type.dart';

class TriggerEvent {
  final Random _random = Random();

  static const _neonCasualProbability = 0.40;
  static const _neonRankedProbability = 0.20;

  TableEvent? roll(GameMode mode, bool isRanked) {
    final probability = isRanked ? _neonRankedProbability : _neonCasualProbability;

    if (_random.nextDouble() > probability) return null;

    final pool = _getEventPool(mode, isRanked);
    if (pool.isEmpty) return null;
    return pool[_random.nextInt(pool.length)];
  }

  List<TableEvent> _getEventPool(GameMode mode, bool isRanked) {
    if (mode == GameMode.classic) return [];
    return [..._baseEvents, if (!isRanked) ..._rareEvents];
  }

  static const _baseEvents = [
    TableEvent(
      type: TableEventType.glitchCasino,
      displayName: 'Glitch de Casino',
      description: 'La interfaz cambia de paleta brevemente',
      isVisualOnly: true,
    ),
    TableEvent(
      type: TableEventType.neonFlicker,
      displayName: 'Parpadeo Neón',
      description: 'Las luces de la mesa fallan',
      isVisualOnly: true,
    ),
    TableEvent(
      type: TableEventType.liveTransmission,
      displayName: 'Transmisión en Vivo',
      description: 'Viewcount ficticio en la mesa',
      isVisualOnly: true,
    ),
    TableEvent(
      type: TableEventType.signalInterference,
      displayName: 'Interferencia de Señal',
      description: 'Distorsión sobre los avatares',
      isVisualOnly: true,
    ),
    TableEvent(
      type: TableEventType.overclockGlobal,
      displayName: 'Overclock Global',
      description: 'Tiempo de decisión baja 10 segundos',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.highLatency,
      displayName: 'Latencia Alta',
      description: 'Tiempo de decisión sube 5 segundos',
      durationRounds: 2,
    ),
    TableEvent(
      type: TableEventType.neonCountdown,
      displayName: 'Cuenta Regresiva Neón',
      description: 'Contador visual urgente',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.chipBlackout,
      displayName: 'Blackout de Fichas',
      description: 'Apuesta mínima sube 20%',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.neonPot,
      displayName: 'Pot Neón',
      description: 'Bote multiplicado x1.2',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.silentTurn,
      displayName: 'Turno Silencioso',
      description: 'Solo call o fold, no raise',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.doubleBlinds,
      displayName: 'Ciegas Dobles',
      description: 'Ciegas duplicadas esta mano',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.visualSwap,
      displayName: 'Swap Visual',
      description: 'Cartas comunitarias en orden inverso',
      durationRounds: 1,
    ),
  ];

  static const _rareEvents = [
    TableEvent(
      type: TableEventType.tableReset,
      displayName: 'Reinicio de Mesa',
      description: 'Posiciones de ciega redistribuidas',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.ghostPot,
      displayName: 'Bote Fantasma',
      description: '5% del bote va a bote acumulado',
      durationRounds: 1,
    ),
    TableEvent(
      type: TableEventType.darkHand,
      displayName: 'Mano Oscura',
      description: 'No se ven comunitarias hasta showdown',
      durationRounds: 1,
    ),
  ];
}
