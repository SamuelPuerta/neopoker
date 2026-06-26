# NeoPoker — Estado de implementación

## Etapa 1 — Offline MVP ✓ Completada

### Implementado:
- [x] `CardEntity`, `Deck`, `PlayerEntity`, `GameState`, `HandResult` definidos y testeados
- [x] `HandEvaluator` con 17 tests (todas las combinaciones de mano, desempates, As bajo)
- [x] `IGameRepository`, `IPlayerRepository`, `IStatsRepository` definidos como interfaces abstractas
- [x] `LocalGameRepository`, `LocalPlayerRepository`, `LocalStatsRepository` implementados
- [x] Casos de uso: `DealCards`, `EvaluateHand`, `ProcessAction`, `ApplyPower`, `TriggerEvent`
- [x] `GameBloc` completo (preFlop → showdown en Classic Mode)
- [x] UI básica: Splash, Home, Lobby, Game, Profile, Settings
- [x] Widgets: `CardWidget`, `ChipWidget`, `PlayerHud`, `ActionButtons`
- [x] Bots Novato, Operador y Elite tomando decisiones
- [x] Sistema de pods: `PowerType`, `ApplyPower` con validación y consumo de energía
- [x] Sistema de eventos: `TableEvent`, `TriggerEvent` con 15 tipos, frecuencia por modo
- [x] DI: `injection.dart` + `injection_offline.dart` con `get_it`
- [x] Router: `go_router` con todas las rutas
- [x] Capa Flame: `NeoPokerGame`, `TableComponent`, `CardComponent`, `PlayerSeat`
- [x] 21 tests unitarios pasando
- [x] `flutter analyze` sin errores

## Mejoras post-MVP

### Interfaz de juego
- [x] Cartas de los bots siempre visibles: boca abajo durante el juego, se voltean en showdown
- [x] Cartas del humano grandes (64px) debajo del rectángulo, no dentro de la cuadrícula
- [x] `_HumanRect` rectangular (130px) centrado entre 2 bots inferiores con avatar, stack, apuesta actual y tags D/SB/BB/TU
- [x] Fondo degradado cian→rosa en el dorso de las cartas (reemplaza interrogantes rosas)
- [x] Tarjeta comunitaria muestra borde vacío delgado para cartas no repartidas (no dorso)
- [x] Destacado verde (borde + tinte) en cartas ganadoras en overlay de showdown

### Showdown
- [x] Showdown como overlay sobre la mesa (no pantalla separada) con animación scale+fade
- [x] Muestra ganador con trofeo, cartas comunitarias, cartas de jugadores y total del pozo
- [x] Cartas ganadoras destacadas con borde verde
- [x] `_awaitingShowdown` guard: colocado DENTRO del bloque `if (phase == showdown/gameOver)` para permitir updates de `startNewHand`

### Lógica de juego
- [x] All-in preflop: si todos van all-in preflop, se reparten las 5 comunitarias antes del showdown
- [x] Rotación de turnos en sentido HORARIO: Neón-X → CipherBot → Ghost_99 → Pulse_K → Tú → Vex_Machine → Neón-X
- [x] Tags D/SB/BB rotan a la izquierda cada mano (mismo orden circular)
- [x] Dealer aleatorio en la primera mano (`Random().nextInt(n)`)
- [x] Foldear no afecta la posición de los tags
- [x] Bots con nombre fijo por posición: Neón-X, CipherBot, Ghost_99, Vex_Machine, Pulse_K

### Sonido
- [x] `SoundService` con generación de WAV sine wave en tiempo real
- [x] Sonidos: check=880Hz, call=660Hz, fold=330Hz, raise=1100Hz, allIn=440Hz dual, winner=1320Hz
- [x] Integrado en BLoC: `_onPlayerActed`, `_onBotActionRequested`, `_resolveAndShowShowdown`
- [x] Caché en temp dir, instancia única de `AudioPlayer`

### UX
- [x] `ActionButtons` muestra "CALL +X" con la diferencia a pagar
- [x] `_PlayerCardsRow` muestra banner "Faltan +X para igualar"
- [x] Apuesta actual del jugador visible en el rectángulo humano
- [x] Delay de 800ms antes de la acción de cada bot
- [x] Home screen: doble pulsación de atrás para salir de la app (SnackBar + `SystemNavigator.pop()`)
- [x] Game screen: PopScope con diálogo "¿Estás seguro?" → navega a `/home`

### Bugs conocidos / Pendiente
- [ ] Las acciones de gestos (PopScope) no funcionan correctamente en Android — el gesto de atrás cierra la app en lugar de mostrar el diálogo
- [ ] Sistema de poderes completo (6 pods con efectos reales)
- [ ] Bot Elite con lógica de pods
- [ ] Neon Casual end-to-end
- [ ] Persistencia Hive para progresión
- [ ] Animaciones Flame para pods y eventos
- [ ] Test de integración: partida completa offline

### Pendiente (Etapa 3):
- [ ] Firebase Auth
- [ ] FirebaseGameRepository
- [ ] Cloud Functions
- [ ] Online lobby y matchmaking
- [ ] MMR y ligas Ranked
