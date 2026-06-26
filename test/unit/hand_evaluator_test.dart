import 'package:flutter_test/flutter_test.dart';
import 'package:neopoker/core/utils/hand_evaluator.dart';
import 'package:neopoker/domain/entities/card.dart';
import 'package:neopoker/domain/enums/card_rank.dart';
import 'package:neopoker/domain/enums/hand_rank.dart';
import 'package:neopoker/domain/enums/suit.dart';

void main() {
  final evaluator = HandEvaluator();

  group('HandEvaluator', () {
    test('detecta Royal Flush correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
        CardEntity(rank: CardRank.king, suit: Suit.hearts),
      ];
      final community = [
        CardEntity(rank: CardRank.queen, suit: Suit.hearts),
        CardEntity(rank: CardRank.jack, suit: Suit.hearts),
        CardEntity(rank: CardRank.ten, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.royalFlush);
    });

    test('detecta Straight Flush correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.five, suit: Suit.clubs),
        CardEntity(rank: CardRank.six, suit: Suit.clubs),
      ];
      final community = [
        CardEntity(rank: CardRank.seven, suit: Suit.clubs),
        CardEntity(rank: CardRank.eight, suit: Suit.clubs),
        CardEntity(rank: CardRank.nine, suit: Suit.clubs),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.straightFlush);
    });

    test('detecta Four of a Kind correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
        CardEntity(rank: CardRank.ace, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.ace, suit: Suit.clubs),
        CardEntity(rank: CardRank.ace, suit: Suit.spades),
        CardEntity(rank: CardRank.king, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.fourOfAKind);
    });

    test('detecta Full House correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.king, suit: Suit.hearts),
        CardEntity(rank: CardRank.king, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.king, suit: Suit.clubs),
        CardEntity(rank: CardRank.two, suit: Suit.spades),
        CardEntity(rank: CardRank.two, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.fullHouse);
    });

    test('detecta Flush correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.two, suit: Suit.spades),
        CardEntity(rank: CardRank.five, suit: Suit.spades),
      ];
      final community = [
        CardEntity(rank: CardRank.seven, suit: Suit.spades),
        CardEntity(rank: CardRank.nine, suit: Suit.spades),
        CardEntity(rank: CardRank.queen, suit: Suit.spades),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.flush);
    });

    test('detecta Straight correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.nine, suit: Suit.hearts),
        CardEntity(rank: CardRank.ten, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.jack, suit: Suit.clubs),
        CardEntity(rank: CardRank.queen, suit: Suit.spades),
        CardEntity(rank: CardRank.king, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.straight);
    });

    test('detecta Three of a Kind correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.seven, suit: Suit.hearts),
        CardEntity(rank: CardRank.seven, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.seven, suit: Suit.clubs),
        CardEntity(rank: CardRank.two, suit: Suit.spades),
        CardEntity(rank: CardRank.king, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.threeOfAKind);
    });

    test('detecta Two Pair correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.jack, suit: Suit.hearts),
        CardEntity(rank: CardRank.jack, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.four, suit: Suit.clubs),
        CardEntity(rank: CardRank.four, suit: Suit.spades),
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.twoPair);
    });

    test('detecta One Pair correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.queen, suit: Suit.hearts),
        CardEntity(rank: CardRank.queen, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.three, suit: Suit.clubs),
        CardEntity(rank: CardRank.seven, suit: Suit.spades),
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.onePair);
    });

    test('detecta High Card correctamente', () {
      final hole = [
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
        CardEntity(rank: CardRank.king, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.two, suit: Suit.clubs),
        CardEntity(rank: CardRank.five, suit: Suit.spades),
        CardEntity(rank: CardRank.nine, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.highCard);
    });

    test('A-2-3-4-5 es Straight (As bajo)', () {
      final hole = [
        CardEntity(rank: CardRank.ace, suit: Suit.hearts),
        CardEntity(rank: CardRank.two, suit: Suit.diamonds),
      ];
      final community = [
        CardEntity(rank: CardRank.three, suit: Suit.clubs),
        CardEntity(rank: CardRank.four, suit: Suit.spades),
        CardEntity(rank: CardRank.five, suit: Suit.hearts),
      ];
      final result = evaluator.evaluate(hole, community);
      expect(result.rank, HandRank.straight);
    });

    test('Royal Flush gana a Straight Flush', () {
      final royal = evaluator.evaluate(
        [
          CardEntity(rank: CardRank.ace, suit: Suit.hearts),
          CardEntity(rank: CardRank.king, suit: Suit.hearts),
        ],
        [
          CardEntity(rank: CardRank.queen, suit: Suit.hearts),
          CardEntity(rank: CardRank.jack, suit: Suit.hearts),
          CardEntity(rank: CardRank.ten, suit: Suit.hearts),
        ],
      );
      final straightFlush = evaluator.evaluate(
        [
          CardEntity(rank: CardRank.five, suit: Suit.clubs),
          CardEntity(rank: CardRank.six, suit: Suit.clubs),
        ],
        [
          CardEntity(rank: CardRank.seven, suit: Suit.clubs),
          CardEntity(rank: CardRank.eight, suit: Suit.clubs),
          CardEntity(rank: CardRank.nine, suit: Suit.clubs),
        ],
      );
      expect(royal.compareTo(straightFlush), greaterThan(0));
    });

    test('desempata correctamente con kicker', () {
      final hand1 = evaluator.evaluate(
        [
          CardEntity(rank: CardRank.ace, suit: Suit.hearts),
          CardEntity(rank: CardRank.king, suit: Suit.diamonds),
        ],
        [
          CardEntity(rank: CardRank.two, suit: Suit.clubs),
          CardEntity(rank: CardRank.three, suit: Suit.spades),
          CardEntity(rank: CardRank.four, suit: Suit.hearts),
        ],
      );
      final hand2 = evaluator.evaluate(
        [
          CardEntity(rank: CardRank.queen, suit: Suit.spades),
          CardEntity(rank: CardRank.jack, suit: Suit.clubs),
        ],
        [
          CardEntity(rank: CardRank.two, suit: Suit.clubs),
          CardEntity(rank: CardRank.three, suit: Suit.spades),
          CardEntity(rank: CardRank.four, suit: Suit.hearts),
        ],
      );
      expect(hand1.compareTo(hand2), greaterThan(0));
    });
  });
}
