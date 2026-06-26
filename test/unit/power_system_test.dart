import 'package:flutter_test/flutter_test.dart';
import 'package:neopoker/core/utils/hand_evaluator.dart';
import 'package:neopoker/domain/entities/card.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/entities/player.dart';
import 'package:neopoker/domain/enums/card_rank.dart';
import 'package:neopoker/domain/enums/game_mode.dart';
import 'package:neopoker/domain/enums/game_phase.dart';
import 'package:neopoker/domain/enums/power_type.dart';
import 'package:neopoker/domain/enums/suit.dart';
import 'package:neopoker/domain/enums/table_event_type.dart';
import 'package:neopoker/domain/usecases/apply_power.dart';

void main() {
  group('ApplyPower', () {
    late ApplyPower applyPower;
    late GameState baseState;
    late PlayerEntity humanPlayer;

    setUp(() {
      applyPower = ApplyPower(HandEvaluator());
      humanPlayer = PlayerEntity(
        id: 'human_1',
        name: 'Tester',
        stack: 1000,
        energy: 3,
        availablePowers: PowerType.values,
        holeCards: [
          CardEntity(rank: CardRank.ace, suit: Suit.hearts),
          CardEntity(rank: CardRank.king, suit: Suit.diamonds),
        ],
      );
      baseState = GameState(
        gameId: 'test',
        mode: GameMode.neon,
        phase: GamePhase.flop,
        players: [
          humanPlayer,
          PlayerEntity(id: 'bot_1', name: 'Bot', isBot: true, energy: 3),
        ],
        communityCards: [
          CardEntity(rank: CardRank.two, suit: Suit.clubs),
          CardEntity(rank: CardRank.three, suit: Suit.spades),
          CardEntity(rank: CardRank.four, suit: Suit.hearts),
        ],
      );
    });

    test('lanza PowerNotAvailableException si no tiene el poder', () {
      final player = humanPlayer.copyWith(availablePowers: [PowerType.scan]);
      final state = baseState.copyWith(players: [player, baseState.players[1]]);
      expect(
        () => applyPower(
          currentState: state,
          playerId: 'human_1',
          powerType: PowerType.firewall,
        ),
        throwsA(isA<PowerNotAvailableException>()),
      );
    });

    test('lanza InsufficientEnergyException si no tiene energía', () {
      final player = humanPlayer.copyWith(energy: 0);
      final state = baseState.copyWith(players: [player, baseState.players[1]]);
      expect(
        () => applyPower(
          currentState: state,
          playerId: 'human_1',
          powerType: PowerType.scan,
        ),
        throwsA(isA<InsufficientEnergyException>()),
      );
    });

    test('consume energía al usar un poder', () {
      final result = applyPower(
        currentState: baseState,
        playerId: 'human_1',
        powerType: PowerType.scan,
      );
      final updatedPlayer = result.players.first;
      expect(updatedPlayer.energy, 2);
    });

    test('Firewall cancela el upcomingEvent', () {
      final stateWithEvent = baseState.copyWith(
        upcomingEvent: const TableEvent(
          type: TableEventType.chipBlackout,
          displayName: 'Test',
          description: 'Test event',
        ),
      );
      final result = applyPower(
        currentState: stateWithEvent,
        playerId: 'human_1',
        powerType: PowerType.firewall,
      );
      expect(result.upcomingEvent, isNull);
      expect(result.players.first.energy, 2);
    });
  });
}
