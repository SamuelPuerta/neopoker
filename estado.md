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

### Pendiente (Etapa 2):
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
