# NeoPoker — Agent Development Guide

**Documento para:** Agente de desarrollo IA  
**Stack:** Flutter + Flame  
**Referencia base:** `proyecto.md` (GDD completo de NeoPoker)  
**Versión agente:** 1.1 (Offline-first → Multiplayer)

---

## 1. Rol del agente

Eres el agente de desarrollo de **NeoPoker**, un juego de póker móvil cyberpunk construido en **Flutter** con el motor de juego **Flame**. Tu misión es implementar el juego de forma incremental, modular y bien documentada, siguiendo estrictamente el Game Design Document (`proyecto.md`).

**Estrategia de desarrollo: Offline-first**  
El juego se construye primero como experiencia 100% local (sin red, sin servidor). Una vez validado el motor de juego con bots, se integra la capa de red sin tocar el núcleo. Esto acelera el testing, elimina dependencias de backend en las etapas tempranas y reduce el riesgo arquitectónico.

```
ETAPA 1 — Offline   : Motor + UI + Bots   → validar que el juego es divertido
ETAPA 2 — Puente    : Repositorios + DI   → preparar la arquitectura para red
ETAPA 3 — Online    : Firebase + WebSocket → multiplayer real sin rewrite
```

**Tus responsabilidades:**
- Implementar el motor de póker (lógica de juego pura, sin dependencias de red)
- Construir la UI/UX con Flutter Widgets + Flame Components
- Integrar sistemas de estado, poderes y eventos
- Diseñar cada capa con interfaces que soporten tanto implementación local como remota
- Escribir código limpio, comentado en español, con arquitectura escalable
- Reportar blockers, ambigüedades del GDD y sugerencias de mejora técnica

---

## 2. Stack tecnológico

### 2.1 Estrategia de dependencias por etapa

Las dependencias se agregan progresivamente. **No instalar Firebase hasta la Etapa 2.**

### 2.2 Etapa 1 — Offline (MVP jugable)

```yaml
# pubspec.yaml — ETAPA 1
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.18.0              # Motor de juego 2D
  flame_audio: ^2.1.1         # Audio y efectos de sonido
  flutter_bloc: ^8.1.5        # Gestión de estado
  equatable: ^2.0.5           # Comparación de objetos
  go_router: ^13.0.0          # Navegación
  shared_preferences: ^2.2.2  # Persistencia local (stats, prefs)
  get_it: ^7.6.7              # Inyección de dependencias
  json_annotation: ^4.8.1     # Serialización
  uuid: ^4.3.3                # IDs únicos locales

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  mocktail: ^1.0.3
  bloc_test: ^9.1.6
```

### 2.3 Etapa 2 — Puente (preparar para red, aún sin servidor)

```yaml
# Agregar en Etapa 2
  hive: ^2.2.3                # Base de datos local más robusta
  hive_flutter: ^1.1.0        # Para persistir progreso local
```

### 2.4 Etapa 3 — Online (multiplayer)

```yaml
# Agregar en Etapa 3 — NO antes
  firebase_core: ^2.27.0
  firebase_auth: ^4.17.0
  cloud_firestore: ^4.15.0
  firebase_analytics: ^10.8.0
  # Opción A — WebSocket directo (menor latencia):
  web_socket_channel: ^2.4.0
  # Opción B — Firebase Realtime Database (más simple):
  firebase_database: ^10.4.9
  # Elegir una sola opción según decisión en la Etapa 2
```

### 2.5 Estructura de carpetas

La clave de la arquitectura offline-first está en la capa `data/`: los repositorios son **interfaces abstractas**. En la Etapa 1 se conectan a implementaciones locales; en la Etapa 3 se reemplazan por implementaciones remotas sin tocar el `domain/` ni los BLoCs.

```
neopoker/
├── lib/
│   ├── main.dart
│   ├── app.dart                        # MaterialApp + GoRouter
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart         # Paleta cyberpunk
│   │   │   ├── app_typography.dart     # Fuentes neón
│   │   │   └── game_constants.dart     # Reglas numéricas del GDD
│   │   ├── di/
│   │   │   ├── injection.dart          # get_it setup
│   │   │   ├── injection_offline.dart  # Etapa 1: inyecta repos locales
│   │   │   └── injection_online.dart   # Etapa 3: inyecta repos remotos
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   └── utils/
│   │       ├── card_utils.dart
│   │       └── hand_evaluator.dart     # Núcleo — sin dependencias externas
│   │
│   ├── domain/
│   │   ├── entities/                   # Clases puras — nunca importan Flutter
│   │   │   ├── card.dart
│   │   │   ├── deck.dart
│   │   │   ├── player.dart
│   │   │   ├── game_state.dart
│   │   │   ├── hand_result.dart
│   │   │   ├── power.dart
│   │   │   └── table_event.dart
│   │   ├── enums/
│   │   │   ├── suit.dart
│   │   │   ├── card_rank.dart
│   │   │   ├── hand_rank.dart
│   │   │   ├── game_phase.dart
│   │   │   ├── game_mode.dart
│   │   │   ├── player_action.dart
│   │   │   └── power_type.dart
│   │   ├── repositories/               # INTERFACES — sin implementación
│   │   │   ├── i_game_repository.dart  # Contrato de partida
│   │   │   ├── i_player_repository.dart# Contrato de jugador/perfil
│   │   │   └── i_stats_repository.dart # Contrato de estadísticas
│   │   └── usecases/                   # Solo dependen de interfaces
│   │       ├── deal_cards.dart
│   │       ├── evaluate_hand.dart
│   │       ├── process_action.dart
│   │       ├── apply_power.dart
│   │       └── trigger_event.dart
│   │
│   ├── data/
│   │   ├── models/                     # DTOs con serialización
│   │   │   ├── player_model.dart
│   │   │   ├── game_session_model.dart
│   │   │   └── stats_model.dart
│   │   │
│   │   ├── local/                      # ETAPA 1 — implementaciones offline
│   │   │   ├── local_game_repository.dart    # Implementa i_game_repository
│   │   │   ├── local_player_repository.dart  # Implementa i_player_repository
│   │   │   ├── local_stats_repository.dart   # Implementa i_stats_repository
│   │   │   └── local_db.dart                 # shared_preferences / hive
│   │   │
│   │   └── remote/                     # ETAPA 3 — implementaciones online
│   │       ├── firebase_game_repository.dart
│   │       ├── firebase_player_repository.dart
│   │       ├── firebase_stats_repository.dart
│   │       └── websocket_game_repository.dart # Alternativa si se usa WS
│   │
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   ├── home/
│   │   │   ├── lobby/
│   │   │   │   ├── lobby_screen.dart         # Etapa 1: "Jugar vs bots"
│   │   │   │   └── online_lobby_screen.dart  # Etapa 3: matchmaking real
│   │   │   ├── game/
│   │   │   │   ├── game_screen.dart
│   │   │   │   └── game_overlay.dart         # HUD Flutter sobre Flame
│   │   │   ├── profile/
│   │   │   └── settings/
│   │   ├── widgets/
│   │   │   ├── card_widget.dart
│   │   │   ├── chip_widget.dart
│   │   │   ├── player_hud.dart
│   │   │   ├── action_buttons.dart
│   │   │   ├── power_bar.dart
│   │   │   └── event_banner.dart
│   │   └── blocs/
│   │       ├── game/
│   │       │   ├── game_bloc.dart       # Nunca sabe si es offline u online
│   │       │   ├── game_event.dart
│   │       │   └── game_state.dart
│   │       └── lobby/
│   │           ├── lobby_bloc.dart
│   │           ├── lobby_event.dart
│   │           └── lobby_state.dart
│   │
│   └── game/                            # Capa Flame — solo visual
│       ├── neopoker_game.dart
│       ├── components/
│       │   ├── table_component.dart
│       │   ├── card_component.dart
│       │   ├── chip_component.dart
│       │   ├── player_seat.dart
│       │   ├── event_effect.dart
│       │   └── power_effect.dart
│       ├── scenes/
│       │   ├── underground_scene.dart
│       │   ├── neon_district_scene.dart
│       │   └── the_grid_scene.dart
│       └── fx/
│           ├── glitch_effect.dart
│           ├── neon_glow.dart
│           └── particle_system.dart
│
├── assets/
│   ├── images/
│   │   ├── cards/
│   │   ├── avatars/
│   │   ├── tables/
│   │   ├── ui/
│   │   └── fx/
│   ├── audio/
│   │   ├── sfx/
│   │   └── music/
│   └── fonts/
│       ├── Orbitron-Regular.ttf
│       └── Rajdhani-Regular.ttf
│
└── test/
    ├── unit/
    │   ├── hand_evaluator_test.dart
    │   ├── game_logic_test.dart
    │   ├── power_system_test.dart
    │   └── bot_player_test.dart
    ├── widget/
    │   └── game_screen_test.dart
    └── integration/
        └── full_game_flow_test.dart    # Partida completa offline → resultado
```

---

## 3. Motor de póker — Implementación del núcleo

### 3.1 Entidades base

```dart
// domain/enums/suit.dart
enum Suit { hearts, diamonds, clubs, spades }

// domain/enums/card_rank.dart
enum CardRank {
  two, three, four, five, six, seven, eight,
  nine, ten, jack, queen, king, ace
}

// domain/entities/card.dart
class CardEntity extends Equatable {
  final CardRank rank;
  final Suit suit;
  
  const CardEntity({required this.rank, required this.suit});
  
  int get numericValue => rank.index + 2; // 2-14
  
  @override
  List<Object?> get props => [rank, suit];
}
```

### 3.2 Evaluador de manos

El evaluador es el componente más crítico. Debe cubrir exactamente el orden del GDD (Sección 11).

```dart
// core/utils/hand_evaluator.dart

enum HandRank {
  highCard,
  onePair,
  twoPair,
  threeOfAKind,
  straight,
  flush,
  fullHouse,
  fourOfAKind,
  straightFlush,
  royalFlush,
}

class HandResult extends Equatable {
  final HandRank rank;
  final List<CardEntity> bestHand; // Las 5 mejores cartas
  final List<int> tiebreakers;     // Para desempate
  
  const HandResult({
    required this.rank,
    required this.bestHand,
    required this.tiebreakers,
  });
  
  // Compara dos manos. Retorna positivo si this gana, negativo si pierde, 0 si empate
  int compareTo(HandResult other) { ... }
  
  @override
  List<Object?> get props => [rank, tiebreakers];
}

class HandEvaluator {
  // Evalúa las 7 cartas disponibles y retorna la mejor mano de 5
  HandResult evaluate(List<CardEntity> holeCards, List<CardEntity> communityCards) {
    assert(holeCards.length == 2);
    assert(communityCards.length >= 3 && communityCards.length <= 5);
    
    final allCards = [...holeCards, ...communityCards];
    // Generar todas las combinaciones de 5 cartas
    final combinations = _getCombinations(allCards, 5);
    // Evaluar cada combinación y retornar la mejor
    return combinations
        .map(_evaluateFiveCards)
        .reduce((best, current) => current.compareTo(best) > 0 ? current : best);
  }
  
  List<List<CardEntity>> _getCombinations(List<CardEntity> cards, int k) { ... }
  HandResult _evaluateFiveCards(List<CardEntity> cards) { ... }
  bool _isFlush(List<CardEntity> cards) { ... }
  bool _isStraight(List<CardEntity> cards) { ... }
  bool _isRoyalFlush(List<CardEntity> cards) { ... }
}
```

### 3.3 Estado del juego

```dart
// domain/enums/game_phase.dart
enum GamePhase {
  waiting,      // Esperando jugadores
  preFlop,      // Cartas repartidas, antes del flop
  flop,         // 3 cartas comunitarias
  turn,         // 4 cartas comunitarias
  river,        // 5 cartas comunitarias
  showdown,     // Revelación final
  gameOver,     // Fin de partida
}

// domain/entities/game_state.dart
class GameState extends Equatable {
  final String gameId;
  final GameMode mode;           // classic / neon
  final GamePhase phase;
  final List<PlayerEntity> players;
  final List<CardEntity> communityCards;
  final int pot;
  final int currentBet;
  final int currentPlayerIndex;
  final int dealerIndex;
  final TableEvent? activeEvent;        // null si no hay evento activo
  final TableEvent? upcomingEvent;      // Evento anunciado para la próxima ronda
  final bool isRanked;
  
  const GameState({ ... });
  
  PlayerEntity get currentPlayer => players[currentPlayerIndex];
  PlayerEntity get dealer => players[dealerIndex];
  
  @override
  List<Object?> get props => [gameId, phase, players, communityCards, pot, ...];
}
```

### 3.4 BLoC del juego

```dart
// presentation/blocs/game/game_bloc.dart

// EVENTOS del BLoC
abstract class GameEvent extends Equatable {}

class GameStarted extends GameEvent {
  final GameMode mode;
  final bool isRanked;
  final List<String> playerIds;
}

class PlayerActed extends GameEvent {
  final PlayerAction action;
  final int? raiseAmount; // null si no es raise
}

class PowerUsed extends GameEvent {
  final PowerType powerType;
}

class EventResolved extends GameEvent {}
class NextPhaseRequested extends GameEvent {}
class GameEnded extends GameEvent {}

// ESTADOS del BLoC
abstract class GameBlocState extends Equatable {}

class GameInitial extends GameBlocState {}
class GameLoading extends GameBlocState {}
class GameInProgress extends GameBlocState {
  final GameState gameState;
}
class GameShowdown extends GameBlocState {
  final GameState gameState;
  final Map<String, HandResult> results;
  final String winnerId;
}
class GameError extends GameBlocState {
  final String message;
}
```

---

## 4. Arquitectura offline → online (la clave del salto)

El principio central es que **el BLoC nunca sabe si está hablando con una implementación local o remota**. Solo conoce interfaces.

### 4.1 Interfaces de repositorio (dominio puro)

```dart
// domain/repositories/i_game_repository.dart
abstract interface class IGameRepository {
  /// Crea una sesión nueva. En offline: objeto local. En online: documento Firestore.
  Future<String> createSession({
    required GameMode mode,
    required bool isRanked,
    required List<String> playerIds,
  });
  
  /// Reparte cartas. En offline: barajado local. En online: Cloud Function.
  Future<Map<String, List<CardEntity>>> dealCards(String sessionId);
  
  /// Registra una acción. En offline: actualiza estado local. En online: envía a servidor.
  Future<GameState> processAction({
    required String sessionId,
    required String playerId,
    required PlayerAction action,
    int? raiseAmount,
  });
  
  /// Stream del estado del juego. En offline: StreamController local.
  /// En online: Firestore onSnapshot o WebSocket stream.
  Stream<GameState> watchGameState(String sessionId);
  
  /// Resuelve el showdown. En offline: HandEvaluator local. En online: Cloud Function.
  Future<ShowdownResult> resolveShowdown(String sessionId);
}

// domain/repositories/i_stats_repository.dart
abstract interface class IStatsRepository {
  Future<void> saveGameResult(GameResult result);
  Future<PlayerStats> getStats(String playerId);
  Future<void> updateMmr(String playerId, int delta); // solo Etapa 3
}
```

### 4.2 Implementación offline (Etapa 1)

```dart
// data/local/local_game_repository.dart
class LocalGameRepository implements IGameRepository {
  final HandEvaluator _evaluator = HandEvaluator();
  final Map<String, GameState> _sessions = {}; // estado en memoria
  final Map<String, StreamController<GameState>> _controllers = {};
  
  @override
  Future<String> createSession({...}) async {
    final id = const Uuid().v4();
    final initialState = GameState.initial(
      gameId: id,
      mode: mode,
      isRanked: isRanked,
      players: playerIds.map((id) => PlayerEntity.fromId(id)).toList(),
    );
    _sessions[id] = initialState;
    _controllers[id] = StreamController<GameState>.broadcast();
    return id;
  }
  
  @override
  Future<Map<String, List<CardEntity>>> dealCards(String sessionId) async {
    // Barajado completamente local — mismo algoritmo que luego usará el servidor
    final deck = Deck()..shuffle();
    final players = _sessions[sessionId]!.players;
    final distribution = <String, List<CardEntity>>{};
    for (final player in players) {
      distribution[player.id] = [deck.draw(), deck.draw()];
    }
    return distribution;
  }
  
  @override
  Stream<GameState> watchGameState(String sessionId) {
    return _controllers[sessionId]!.stream;
  }
  
  void _emit(String sessionId, GameState state) {
    _sessions[sessionId] = state;
    _controllers[sessionId]?.add(state);
  }
  
  // ... resto de métodos
}
```

### 4.3 Inyección de dependencias por etapa

```dart
// core/di/injection_offline.dart  — Etapa 1
void setupOfflineDependencies() {
  final getIt = GetIt.instance;
  
  // Repositorios locales
  getIt.registerLazySingleton<IGameRepository>(() => LocalGameRepository());
  getIt.registerLazySingleton<IPlayerRepository>(() => LocalPlayerRepository());
  getIt.registerLazySingleton<IStatsRepository>(() => LocalStatsRepository());
  
  // Casos de uso — no cambian entre etapas
  getIt.registerLazySingleton(() => DealCards(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => ProcessAction(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => ApplyPower(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => TriggerEvent());
}

// core/di/injection_online.dart  — Etapa 3 (reemplaza el de arriba)
void setupOnlineDependencies() {
  final getIt = GetIt.instance;
  
  // Solo se cambian las implementaciones — los casos de uso no se tocan
  getIt.registerLazySingleton<IGameRepository>(() => FirebaseGameRepository());
  getIt.registerLazySingleton<IPlayerRepository>(() => FirebasePlayerRepository());
  getIt.registerLazySingleton<IStatsRepository>(() => FirebaseStatsRepository());
  
  // Casos de uso — literalmente el mismo registro
  getIt.registerLazySingleton(() => DealCards(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => ProcessAction(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => ApplyPower(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => TriggerEvent());
}

// main.dart — elegir cuál usar
void main() {
  setupOfflineDependencies(); // cambiar a setupOnlineDependencies() en Etapa 3
  runApp(const NeoPokerApp());
}
```

### 4.4 El BLoC no cambia entre etapas

```dart
// presentation/blocs/game/game_bloc.dart
// Este archivo NO se modifica al pasar de offline a online
class GameBloc extends Bloc<GameBlocEvent, GameBlocState> {
  final DealCards _dealCards;
  final ProcessAction _processAction;
  final ApplyPower _applyPower;
  
  GameBloc({
    required DealCards dealCards,
    required ProcessAction processAction,
    required ApplyPower applyPower,
  })  : _dealCards = dealCards,
        _processAction = processAction,
        _applyPower = applyPower,
        super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<PlayerActed>(_onPlayerActed);
    on<PowerUsed>(_onPowerUsed);
  }
  
  Future<void> _onGameStarted(GameStarted event, Emitter emit) async {
    emit(GameLoading());
    // Llama al caso de uso — no sabe si es local o Firebase
    final sessionId = await _dealCards(event.config);
    emit(GameInProgress(sessionId: sessionId));
  }
}
```

---

### 4.1 Entidad de poder

```dart
// domain/entities/power.dart
class Power extends Equatable {
  final PowerType type;
  final int energyCost;
  final bool isUsedThisGame;
  
  const Power({
    required this.type,
    required this.energyCost,
    this.isUsedThisGame = false,
  });
}

// domain/entities/player.dart
class PlayerEntity extends Equatable {
  final String id;
  final String name;
  final String operatorId;     // Avatar seleccionado
  final List<CardEntity> holeCards;
  final int stack;             // Fichas actuales
  final int currentBet;
  final bool isActive;         // ¿Sigue en la mano?
  final bool isAllIn;
  final int energy;            // ⚡ actual (0-3, solo Neon Mode)
  final List<Power> availablePowers; // Solo en Neon Mode
  final Power? activePower;    // Poder activado esta mano
  
  const PlayerEntity({ ... });
  
  bool get canUsePower => energy > 0 && activePower == null;
}
```

### 4.2 Caso de uso: aplicar poder

```dart
// domain/usecases/apply_power.dart
class ApplyPower {
  final GameRepository repository;
  
  ApplyPower(this.repository);
  
  Future<GameState> call({
    required GameState currentState,
    required String playerId,
    required PowerType powerType,
  }) async {
    final player = currentState.players.firstWhere((p) => p.id == playerId);
    
    // Validar que puede usar el poder
    if (!player.canUsePower) throw PowerNotAvailableException();
    
    final power = player.availablePowers.firstWhere((p) => p.type == powerType);
    if (player.energy < power.energyCost) throw InsufficientEnergyException();
    
    // Aplicar efecto según tipo
    return switch (powerType) {
      PowerType.scan => _applyScan(currentState, player),
      PowerType.firewall => _applyFirewall(currentState, player),
      PowerType.overclock => _applyOverclock(currentState, player),
      PowerType.reboot => _applyReboot(currentState, player),
      PowerType.decrypt => _applyDecrypt(currentState, player),
      PowerType.ghostHand => _applyGhostHand(currentState, player),
    };
  }
  
  GameState _applyScan(GameState state, PlayerEntity player) {
    // SCAN: calcula win probability y la expone al jugador
    // No modifica el estado del juego, solo expone información estadística
    ...
  }
  
  GameState _applyFirewall(GameState state, PlayerEntity player) {
    // FIREWALL: cancela el upcomingEvent si existe
    return state.copyWith(
      upcomingEvent: null,
      players: state.players.map((p) =>
        p.id == player.id
          ? p.copyWith(energy: p.energy - 1, activePower: const Power(type: PowerType.firewall, energyCost: 1))
          : p
      ).toList(),
    );
  }
}
```

---

## 5. Sistema de eventos — Implementación

### 5.1 Entidad de evento

```dart
// domain/entities/table_event.dart
class TableEvent extends Equatable {
  final TableEventType type;
  final String displayName;
  final String description;
  final int durationRounds;    // Cuántas rondas dura
  final bool affectsAllPlayers;
  final bool isVisualOnly;     // Si no tiene efecto mecánico
  
  const TableEvent({ ... });
}

// domain/enums/table_event_type.dart
enum TableEventType {
  // Visuales
  glitchCasino,
  neonFlicker,
  liveTransmission,
  signalInterference,
  // Tiempo
  overclockGlobal,
  highLatency,
  neonCountdown,
  // Mesa
  chipBlackout,
  neonPot,
  silentTurn,
  doubleBlinds,
  visualSwap,
  // Raros (solo Neon Casual)
  tableReset,
  ghostPot,
  darkHand,
}
```

### 5.2 Controlador de eventos

```dart
// domain/usecases/trigger_event.dart
class TriggerEvent {
  final Random _random = Random();
  
  // Probabilidades según modo (GDD Sección 5.2)
  static const _neonCasualProbability = 0.40;
  static const _neonRankedProbability = 0.20;
  
  TableEvent? roll(GameMode mode, bool isRanked) {
    final probability = isRanked ? _neonRankedProbability : _neonCasualProbability;
    
    if (_random.nextDouble() > probability) return null;
    
    final pool = _getEventPool(mode, isRanked);
    return pool[_random.nextInt(pool.length)];
  }
  
  List<TableEvent> _getEventPool(GameMode mode, bool isRanked) {
    if (mode == GameMode.classic) return [];
    
    final baseEvents = [..._visualEvents, ..._timeEvents, ..._tableEvents];
    if (!isRanked) return [...baseEvents, ..._rareEvents]; // Raros solo en casual
    return baseEvents;
  }
}
```

---

## 6. Capa visual Flame

### 6.1 Arquitectura Flutter + Flame

La integración usa `GameWidget` de Flame embebido dentro de un `Stack` de Flutter, con el HUD de Flutter superpuesto.

```dart
// presentation/screens/game/game_screen.dart
class GameScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc()..add(GameStarted(...)),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Capa Flame — física del juego y animaciones
            GameWidget<NeoPokerGame>(
              game: NeoPokerGame(),
            ),
            // Capa Flutter — HUD, botones, información
            const GameOverlay(),
          ],
        ),
      ),
    );
  }
}
```

### 6.2 NeoPokerGame (FlameGame)

```dart
// game/neopoker_game.dart
class NeoPokerGame extends FlameGame with TapCallbacks, HasCollisionDetection {
  late TableComponent _table;
  late List<PlayerSeatComponent> _seats;
  late List<CardComponent> _communityCards;
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await _loadAssets();
    await _initializeScene();
  }
  
  Future<void> _loadAssets() async {
    await images.loadAll([
      'cards/card_back.png',
      'tables/underground.png',
      // ... todos los assets
    ]);
  }
  
  Future<void> _initializeScene() async {
    _table = TableComponent()..position = size / 2;
    _seats = List.generate(6, (i) => PlayerSeatComponent(seatIndex: i));
    add(_table);
    _seats.forEach(add);
  }
  
  // Llamado desde el BLoC cuando el estado cambia
  void updateGameState(GameState state) {
    _updateCommunityCards(state.communityCards);
    _updatePlayerSeats(state.players);
    _updatePot(state.pot);
    if (state.activeEvent != null) {
      _triggerEventEffect(state.activeEvent!);
    }
  }
  
  void _triggerEventEffect(TableEvent event) {
    switch (event.type) {
      case TableEventType.glitchCasino:
        add(GlitchEffect()..duration = 2.0);
      case TableEventType.neonFlicker:
        add(NeonFlickerEffect());
      default:
        break;
    }
  }
}
```

### 6.3 Paleta de colores cyberpunk

```dart
// core/constants/app_colors.dart
class AppColors {
  // Colores primarios
  static const neonCyan = Color(0xFF00FFFF);
  static const neonPink = Color(0xFFFF00FF);
  static const neonGreen = Color(0xFF00FF41);
  static const neonOrange = Color(0xFFFF6B00);
  
  // Fondos
  static const darkBackground = Color(0xFF0A0A0F);
  static const cardBackground = Color(0xFF12121A);
  static const tableGreen = Color(0xFF0D1F12);
  
  // Estados
  static const energyFull = Color(0xFF00FFFF);
  static const energyLow = Color(0xFFFF6B00);
  static const energyEmpty = Color(0xFF333344);
  
  // Ligas
  static const leagueCircuito = Color(0xFF888899);
  static const leagueOperador = Color(0xFF4488FF);
  static const leagueHacker = Color(0xFF44FF88);
  static const leagueFantasma = Color(0xFFAA44FF);
  static const leagueNexo = Color(0xFFFFAA00);
  
  // Texto
  static const textPrimary = Color(0xFFE0E0F0);
  static const textSecondary = Color(0xFF888899);
  static const textNeon = Color(0xFF00FFFF);
  static const textWarning = Color(0xFFFF6B00);
  static const textDanger = Color(0xFFFF0044);
}
```

---

## 7. Persistencia y backend

### 7.1 Firebase Firestore — Colecciones

```
firestore/
├── users/{userId}
│   ├── displayName: string
│   ├── operatorId: string
│   ├── level: int
│   ├── xp: int
│   ├── credits: int
│   ├── neonTokens: int
│   ├── classicMmr: int
│   ├── neonMmr: int
│   └── stats: {
│       ├── totalGames: int
│       ├── totalWins: int
│       ├── bestHand: string
│       └── favoritePower: string
│     }
│
├── game_sessions/{sessionId}
│   ├── mode: 'classic' | 'neon'
│   ├── isRanked: bool
│   ├── players: [userId]
│   ├── status: 'waiting' | 'active' | 'finished'
│   ├── createdAt: timestamp
│   └── result: {winnerId, pot, duration}
│
└── leaderboards/
    ├── classic_ranked/{userId}
    │   └── mmr, displayName, operatorId, rank
    └── neon_ranked/{userId}
        └── mmr, displayName, operatorId, rank
```

### 7.2 Lógica crítica — Solo en servidor

Las siguientes operaciones **nunca deben ejecutarse en el cliente:**
- Barajado y reparto de cartas (seed encriptado)
- Evaluación final de manos en showdown
- Actualización de MMR
- Validación de poderes y energía

Usar **Cloud Functions** para toda lógica de juego crítica.

```typescript
// functions/src/game/dealCards.ts
export const dealCards = onCall(async (request) => {
  const { sessionId } = request.data;
  
  // Generar seed encriptado y verificable
  const seed = crypto.randomBytes(32).toString('hex');
  const deck = shuffleDeck(createDeck(), seed);
  
  // Guardar seed hasheado (para fairness transparente)
  await db.collection('game_sessions').doc(sessionId).update({
    deckSeedHash: sha256(seed),
  });
  
  // Repartir cartas (nunca exponer al cliente antes de tiempo)
  return distributeCards(deck, playerCount);
});
```

---

## 8. Migración a multiplayer (Etapa 3)

### 8.1 Cuándo hacer el salto

Condiciones para iniciar la Etapa 3:
- El motor de juego completo funciona offline sin bugs conocidos
- Los 3 niveles de bots están implementados y probados
- Classic Casual y Neon Casual son jugables end-to-end
- El HandEvaluator tiene cobertura de tests al 100%

### 8.2 Qué cambia y qué no cambia

| Capa | ¿Cambia en Etapa 3? | Razón |
|---|---|---|
| `domain/entities/` | ❌ No | Clases puras, sin dependencias |
| `domain/usecases/` | ❌ No | Dependen de interfaces, no implementaciones |
| `presentation/blocs/` | ❌ No | Solo conocen interfaces vía DI |
| `game/` (Flame) | ❌ No | Solo visual |
| `core/di/injection.dart` | ✅ Sí | Se apunta a `injection_online.dart` |
| `data/local/` | ➕ Se mantiene | Para modo offline y fallback |
| `data/remote/` | ✅ Se implementa | FirebaseGameRepository, etc. |

**Cambio en `main.dart`:** una línea.  
**Cambio en el resto del juego:** cero líneas.

### 8.3 Arquitectura de multiplayer en tiempo real

Para el turno-a-turno del póker, **Firebase Realtime Database** es mejor opción que Firestore para estados que cambian rápido (cada acción del jugador):

```dart
// data/remote/firebase_game_repository.dart
class FirebaseGameRepository implements IGameRepository {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  
  @override
  Future<String> createSession({...}) async {
    // Cloud Function crea la sesión, baraja y guarda el estado
    final result = await _functions
        .httpsCallable('createGameSession')
        .call({'mode': mode.name, 'isRanked': isRanked, 'playerIds': playerIds});
    return result.data['sessionId'] as String;
  }
  
  @override
  Stream<GameState> watchGameState(String sessionId) {
    // Realtime Database: actualización en <100ms entre jugadores
    return _db
        .ref('sessions/$sessionId/state')
        .onValue
        .map((event) => GameStateModel.fromJson(
              Map<String, dynamic>.from(event.snapshot.value as Map),
            ).toEntity());
  }
  
  @override
  Future<GameState> processAction({...}) async {
    // La acción se valida en el servidor antes de aplicarse
    final result = await _functions
        .httpsCallable('processPlayerAction')
        .call({'sessionId': sessionId, 'playerId': playerId, 'action': action.name});
    return GameStateModel.fromJson(result.data).toEntity();
  }
}
```

### 8.4 Lobby y matchmaking

```dart
// presentation/screens/lobby/online_lobby_screen.dart
// Nuevas pantallas solo para Etapa 3 — no afectan las offline
class OnlineLobbyScreen extends StatelessWidget {
  // Pantalla de matchmaking: buscar partida, crear sala privada, invitar amigos
}
```

El `lobby_screen.dart` original (vs bots) se mantiene intacto y accesible.

### 8.5 Cloud Functions requeridas (Etapa 3)

```typescript
// Las siguientes funciones deben implementarse antes de lanzar online:

createGameSession(mode, isRanked, playerIds)
  → Crea sesión, baraja deck con seed verificable, registra hash

dealHoleCards(sessionId)
  → Distribuye cartas privadas (nunca expuestas al cliente hasta showdown)

processPlayerAction(sessionId, playerId, action, raiseAmount?)
  → Valida acción, actualiza estado, avanza turno

resolveShowdown(sessionId)
  → HandEvaluator en servidor, determina ganador, distribuye pot

updateMmr(sessionId, winnerId)
  → Calcula delta de MMR usando ELO adaptado al póker
```

### 8.6 Seguridad en Firebase (Etapa 3)

```
// firestore.rules — reglas críticas
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Los usuarios solo pueden leer su propia sesión
    match /sessions/{sessionId} {
      allow read: if request.auth.uid in resource.data.playerIds;
      // NUNCA permitir escritura directa del cliente — solo Cloud Functions
      allow write: if false;
    }
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId 
                   && !request.resource.data.keys().hasAny(['mmr', 'credits']);
    }
  }
}
```

---

### 8.1 Interfaz de bot

```dart
// domain/ai/bot_player.dart
abstract class BotPlayer {
  final String id;
  final BotDifficulty difficulty;
  
  Future<PlayerAction> decideAction({
    required GameState gameState,
    required PlayerEntity self,
  });
  
  // Solo en Neon Mode
  PowerType? decidePower({
    required GameState gameState,
    required PlayerEntity self,
  }) => null; // Bots básicos no usan poderes
}
```

### 8.2 Implementaciones

```dart
// Novato — llama casi siempre, nunca blufea
class NovatoBotPlayer extends BotPlayer {
  @override
  Future<PlayerAction> decideAction({...}) async {
    if (gameState.currentBet == 0) return PlayerAction.check;
    if (self.stack < gameState.currentBet * 3) return PlayerAction.fold;
    return PlayerAction.call; // Casi siempre llama
  }
}

// Elite — usa pot odds, lee el bote, blufea estratégicamente
class EliteBotPlayer extends BotPlayer {
  final HandEvaluator _evaluator = HandEvaluator();
  
  @override
  Future<PlayerAction> decideAction({...}) async {
    final winProbability = _calculateWinProbability(gameState, self);
    final potOdds = _calculatePotOdds(gameState);
    
    if (winProbability > 0.7) return _aggressiveAction(gameState, self);
    if (winProbability > potOdds) return PlayerAction.call;
    if (_shouldBluff(gameState, self)) return _aggressiveAction(gameState, self);
    return PlayerAction.fold;
  }
  
  @override
  PowerType? decidePower({...}) {
    // Elite usa poderes de forma contextual
    if (self.energy >= 2 && gameState.phase == GamePhase.turn) {
      return PowerType.scan; // Analiza al llegar al turn
    }
    if (gameState.upcomingEvent?.type == TableEventType.chipBlackout) {
      return PowerType.firewall; // Bloquea eventos negativos
    }
    return null;
  }
}
```

---

## 10. Flujo de una partida completa

### 10.1 Flujo offline (Etapa 1 y 2)

```
INICIO
  ↓
[LobbyScreen] Seleccionar modo + dificultad de bots
  ↓
[GameBloc] GameStarted → IGameRepository.createSession() → LocalGameRepository
  ↓
[Local] DealCards → barajar localmente, repartir hole cards en memoria
  ↓
[PHASE: preFlop]
  → Publicar ciegas
  → Turno humano: action_buttons → GameBloc.PlayerActed → ProcessAction
  → Turno bots: BotPlayer.decideAction() → GameBloc.PlayerActed → ProcessAction
  → [Neon] TriggerEvent → mostrar EventBanner si corresponde
  ↓
[PHASE: flop / turn / river]
  → IGameRepository.processAction() — actualiza estado local en memoria
  → Stream<GameState> emite → GameBloc recibe → UI se reconstruye
  ↓
[PHASE: showdown]
  → IGameRepository.resolveShowdown() → HandEvaluator.evaluate() local
  → Animar revelación de cartas en Flame
  → Distribuir pot
  ↓
[POST-GAME]
  → IStatsRepository.saveGameResult() → LocalStatsRepository → shared_preferences
  → Mostrar pantalla de resultados
  ↓
[LOBBY] → Nueva partida
```

### 10.2 Flujo online (Etapa 3) — el BLoC es idéntico

```
INICIO
  ↓
[OnlineLobbyScreen] Buscar partida / crear sala
  ↓
[GameBloc] GameStarted → IGameRepository.createSession() → FirebaseGameRepository
  ↓
[Cloud Function] createGameSession → baraja con seed encriptado → escribe en Realtime DB
  ↓
[GameBloc] watchGameState() → Stream desde Realtime DB (100ms latencia)
  ↓
[PHASE: preFlop / flop / turn / river]
  → Acción del jugador local → Cloud Function processPlayerAction
  → Otros jugadores reciben actualización por Stream automáticamente
  → Bots reemplazados por jugadores reales — misma interfaz IGameRepository
  ↓
[PHASE: showdown]
  → Cloud Function resolveShowdown → HandEvaluator en servidor → resultado firmado
  → Todos los clientes reciben resultado por Stream
  ↓
[POST-GAME]
  → Cloud Function updateMmr si es Ranked
  → Firestore actualiza stats del usuario
```

---

## 10. Testing

### 10.1 Cobertura obligatoria

| Componente | Tipo de test | Cobertura mínima |
|---|---|---|
| HandEvaluator | Unit | 100% — cada combinación de mano |
| GameBloc | BLoC test | 90% — todos los eventos |
| ApplyPower usecase | Unit | 100% — cada poder |
| TriggerEvent | Unit | 80% |
| BotPlayer (Elite) | Unit | 70% |

### 10.2 Tests críticos del evaluador

```dart
// test/unit/hand_evaluator_test.dart
void main() {
  final evaluator = HandEvaluator();
  
  group('HandEvaluator', () {
    test('detecta Royal Flush correctamente', () {
      final hole = [CardEntity(rank: CardRank.ace, suit: Suit.hearts),
                    CardEntity(rank: CardRank.king, suit: Suit.hearts)];
      final community = [CardEntity(rank: CardRank.queen, suit: Suit.hearts),
                         CardEntity(rank: CardRank.jack, suit: Suit.hearts),
                         CardEntity(rank: CardRank.ten, suit: Suit.hearts)];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.royalFlush);
    });
    
    test('Royal Flush gana a Straight Flush', () { ... });
    test('desempata correctamente con kicker', () { ... });
    test('maneja As como carta baja en A-2-3-4-5', () { ... });
  });
}
```

---

## 12. Reglas para el agente

### 12.1 Prioridades de implementación

**ETAPA 1 — Offline (implementar en este orden estricto):**
1. Entidades base (`CardEntity`, `Deck`, `PlayerEntity`, `GameState`)
2. `HandEvaluator` con tests al 100%
3. Interfaces de repositorio (`IGameRepository`, `IStatsRepository`)
4. `LocalGameRepository` implementando las interfaces
5. Casos de uso (`DealCards`, `ProcessAction`, `EvaluateHand`)
6. `GameBloc` completo Classic Mode
7. UI básica Flutter (mesa, cartas, botones — sin Flame aún)
8. Bots Novato y Operador
9. Integración Flame (animaciones, efectos)
10. Classic Casual end-to-end jugable

**ETAPA 2 — Puente:**
11. Sistema de poderes (`Power`, `ApplyPower`) — Neon Mode
12. Sistema de eventos (`TableEvent`, `TriggerEvent`)
13. Bots Elite con lógica de poderes
14. Neon Casual end-to-end
15. Persistencia local con Hive (stats, prefs, progresión)

**ETAPA 3 — Online:**
16. Firebase Auth
17. `FirebaseGameRepository` implementando `IGameRepository`
18. Cloud Functions (createSession, dealCards, processAction, resolveShowdown)
19. Online lobby y matchmaking
20. MMR y ligas Ranked
21. Anti-trampa básico

### 12.2 Restricciones de diseño

- **Nunca revelar cartas privadas del rival en el cliente** — solo en showdown
- **Ningún poder modifica las cartas** — información o tiempo, nunca azar
- **Todo evento afecta a todos** — simétrico siempre
- **Los eventos se anuncian 1 ronda antes** en Neon Ranked
- **La energía es global por partida**, no se recupera entre manos
- **Los poderes de Ranked se declaran al inicio**
- **Nunca escribir lógica de negocio en Widgets** — solo en usecases y BLoC
- **Nunca llamar a Firebase directamente desde el BLoC** — solo a través de interfaces

### 12.3 Convenciones de código

- Código y comentarios en **español**
- Nombres de variables y métodos en **inglés** (Dart convención)
- Todo `GameState` es **inmutable** — usar `copyWith` para cambios
- Toda lógica de negocio en `domain/` — nunca en widgets
- Toda comunicación con Firebase en `data/remote/` — nunca en BLoC directamente
- Usar `sealed class` para eventos y estados del BLoC
- Usar `abstract interface class` para repositorios (Dart 3+)

### 12.4 Qué reportar al desarrollador humano

- Ambigüedades del GDD (ej: ¿qué pasa si dos jugadores usan Firewall al mismo tiempo?)
- Mecánicas técnicamente inviables o que requieran cambio de arquitectura
- Si una API de Firebase o Flame cambió respecto a las versiones especificadas
- Si algún poder puede crear un estado inválido (energía negativa, etc.)
- Cuando se complete cada etapa, con un resumen de lo que funciona y qué falta

---

## 13. Checklist de entrega por etapa

### Etapa 1 — Offline MVP
- [ ] `CardEntity`, `Deck`, `PlayerEntity`, `GameState` definidos y testeados
- [ ] `HandEvaluator` con tests al 100% (todas las combinaciones de mano)
- [ ] `IGameRepository` e `IStatsRepository` definidos como interfaces
- [ ] `LocalGameRepository` implementado
- [ ] `GameBloc` completo (preFlop → showdown en Classic Mode)
- [ ] UI básica de mesa en Flutter funcionando
- [ ] Bots Novato y Operador tomando decisiones correctas
- [ ] Partida Classic Casual completa jugable offline
- [ ] Stats locales guardándose entre sesiones

### Etapa 2 — Puente + Neon
- [ ] Sistema de poderes completo (6 poderes, energía, contrajuego)
- [ ] Sistema de eventos (21 eventos, frecuencias por modo)
- [ ] Bots Elite con lógica de poderes
- [ ] Neon Casual end-to-end
- [ ] Persistencia Hive para progresión
- [ ] Animaciones Flame para poderes y eventos
- [ ] Test de integración: partida completa offline → resultado correcto

### Etapa 3 — Online
- [ ] Firebase Auth configurado
- [ ] `FirebaseGameRepository` implementando `IGameRepository` exactamente
- [ ] Cloud Functions: createSession, dealCards, processAction, resolveShowdown
- [ ] `main.dart` apunta a `setupOnlineDependencies()` — resto del juego sin tocar
- [ ] Online lobby con matchmaking básico
- [ ] Classic Ranked online funcionando
- [ ] MMR actualizable desde Cloud Functions
- [ ] Reglas de seguridad Firestore implementadas
- [ ] Test: partida online 2 jugadores reales completa
