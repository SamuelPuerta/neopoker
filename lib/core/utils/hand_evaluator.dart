import 'dart:math';
import '../../domain/entities/card.dart';
import '../../domain/entities/hand_result.dart';
import '../../domain/enums/card_rank.dart';
import '../../domain/enums/hand_rank.dart';
import '../../domain/enums/suit.dart';

class HandEvaluator {
  HandResult evaluate(List<CardEntity> holeCards, List<CardEntity> communityCards) {
    final allCards = [...holeCards, ...communityCards];
    final combinations = _getCombinations(allCards, 5);
    return combinations
        .map(_evaluateFiveCards)
        .reduce((best, current) => current.compareTo(best) > 0 ? current : best);
  }

  List<List<CardEntity>> _getCombinations(List<CardEntity> cards, int k) {
    final result = <List<CardEntity>>[];
    _combine(cards, k, 0, [], result);
    return result;
  }

  void _combine(
    List<CardEntity> cards,
    int k,
    int start,
    List<CardEntity> current,
    List<List<CardEntity>> result,
  ) {
    if (current.length == k) {
      result.add(List.from(current));
      return;
    }
    for (int i = start; i < cards.length; i++) {
      current.add(cards[i]);
      _combine(cards, k, i + 1, current, result);
      current.removeLast();
    }
  }

  HandResult _evaluateFiveCards(List<CardEntity> cards) {
    final sorted = List<CardEntity>.from(cards)
      ..sort((a, b) => b.numericValue.compareTo(a.numericValue));
    final values = sorted.map((c) => c.numericValue).toList();
    final suits = sorted.map((c) => c.suit).toList();

    final isFlush = _isFlush(suits);
    final isStraight = _isStraight(values);
    final valueCounts = _getValueCounts(values);

    if (isFlush && isStraight) {
      final isRoyal = values.first == 14 && values.last == 10;
      return HandResult(
        rank: isRoyal ? HandRank.royalFlush : HandRank.straightFlush,
        bestHand: sorted,
        tiebreakers: [values.first],
      );
    }

    if (_hasCount(valueCounts, 4)) {
      final quadValue = _valueWithCount(valueCounts, 4);
      final kicker = values.firstWhere((v) => v != quadValue);
      return HandResult(
        rank: HandRank.fourOfAKind,
        bestHand: sorted,
        tiebreakers: [quadValue, kicker],
      );
    }

    if (_hasCount(valueCounts, 3) && _hasCount(valueCounts, 2)) {
      final tripValue = _valueWithCount(valueCounts, 3);
      final pairValue = _valueWithCount(valueCounts, 2);
      return HandResult(
        rank: HandRank.fullHouse,
        bestHand: sorted,
        tiebreakers: [tripValue, pairValue],
      );
    }

    if (isFlush) {
      return HandResult(
        rank: HandRank.flush,
        bestHand: sorted,
        tiebreakers: values,
      );
    }

    if (isStraight) {
      return HandResult(
        rank: HandRank.straight,
        bestHand: sorted,
        tiebreakers: [values.first],
      );
    }

    if (_hasCount(valueCounts, 3)) {
      final tripValue = _valueWithCount(valueCounts, 3);
      final kickers = values.where((v) => v != tripValue).toList();
      return HandResult(
        rank: HandRank.threeOfAKind,
        bestHand: sorted,
        tiebreakers: [tripValue, ...kickers],
      );
    }

    final pairs = _getPairs(valueCounts);
    if (pairs.length == 2) {
      final highPair = pairs[0];
      final lowPair = pairs[1];
      final kicker = values.firstWhere((v) => v != highPair && v != lowPair);
      return HandResult(
        rank: HandRank.twoPair,
        bestHand: sorted,
        tiebreakers: [highPair, lowPair, kicker],
      );
    }

    if (pairs.length == 1) {
      final pairValue = pairs[0];
      final kickers = values.where((v) => v != pairValue).toList();
      return HandResult(
        rank: HandRank.onePair,
        bestHand: sorted,
        tiebreakers: [pairValue, ...kickers],
      );
    }

    return HandResult(
      rank: HandRank.highCard,
      bestHand: sorted,
      tiebreakers: values,
    );
  }

  bool _isFlush(List<Suit> suits) {
    return suits.every((s) => s == suits.first);
  }

  bool _isStraight(List<int> values) {
    var unique = values.toSet().toList()..sort((a, b) => b.compareTo(a));
    if (unique.length < 5) return false;

    if (unique.first - unique.last == 4 && unique.length == 5) return true;

    if (unique.first == 14 &&
        unique[1] == 5 &&
        unique[2] == 4 &&
        unique[3] == 3 &&
        unique[4] == 2) {
      return true;
    }

    return false;
  }

  Map<int, int> _getValueCounts(List<int> values) {
    final counts = <int, int>{};
    for (final v in values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }
    return counts;
  }

  bool _hasCount(Map<int, int> counts, int n) {
    return counts.values.any((c) => c == n);
  }

  int _valueWithCount(Map<int, int> counts, int n) {
    return counts.entries.firstWhere((e) => e.value == n).key;
  }

  List<int> _getPairs(Map<int, int> counts) {
    final pairs = <int>[];
    for (final entry in counts.entries) {
      if (entry.value == 2) pairs.add(entry.key);
    }
    pairs.sort((a, b) => b.compareTo(a));
    return pairs;
  }

  double calculateWinProbability(
    List<CardEntity> holeCards,
    List<CardEntity> communityCards,
    int opponents,
  ) {
    final ownResult = evaluate(holeCards, communityCards);
    final deck = _buildDeckWithout(holeCards, communityCards);
    final unknownCount = communityCards.length;
    final cardsToDraw = 5 - unknownCount;

    if (cardsToDraw <= 0) {
      return _monteCarloResult(ownResult, opponents, deck);
    }

    return _monteCarloSimulation(holeCards, communityCards, opponents,
        cardsToDraw, deck);
  }

  double _monteCarloSimulation(
    List<CardEntity> holeCards,
    List<CardEntity> communityCards,
    int opponents,
    int cardsToDraw,
    List<CardEntity> deck,
  ) {
    const int simulations = 5000;
    int wins = 0;
    final rng = Random();

    for (int i = 0; i < simulations; i++) {
      final simDeck = List<CardEntity>.from(deck)..shuffle(rng);
      final drawn = simDeck.take(cardsToDraw).toList();
      final fullCommunity = [...communityCards, ...drawn];

      final ownResult = evaluate(holeCards, fullCommunity);
      bool win = true;

      for (int o = 0; o < opponents; o++) {
        final oppCards = [simDeck[cardsToDraw + o * 2], simDeck[cardsToDraw + o * 2 + 1]];
        final oppResult = evaluate(oppCards, fullCommunity);
        if (oppResult.compareTo(ownResult) > 0) {
          win = false;
          break;
        }
      }

      if (win) wins++;
    }

    return wins / simulations;
  }

  double _monteCarloResult(
    HandResult ownResult,
    int opponents,
    List<CardEntity> deck,
  ) {
    const int simulations = 2000;
    int wins = 0;
    final rng = Random();

    for (int i = 0; i < simulations; i++) {
      final simDeck = List<CardEntity>.from(deck)..shuffle(rng);
      bool win = true;

      for (int o = 0; o < opponents; o++) {
        final oppCards = [simDeck[o * 2], simDeck[o * 2 + 1]];
        final community = simDeck.sublist(opponents * 2, opponents * 2 + 5);
        final oppResult = evaluate(oppCards, community);
        if (oppResult.compareTo(ownResult) > 0) {
          win = false;
          break;
        }
      }

      if (win) wins++;
    }

    return wins / simulations;
  }

  List<CardEntity> _buildDeckWithout(
    List<CardEntity> holeCards,
    List<CardEntity> communityCards,
  ) {
    final used = <String>{};
    for (final c in [...holeCards, ...communityCards]) {
      used.add('${c.rank.index}_${c.suit.index}');
    }

    final deck = <CardEntity>[];
    for (final suit in Suit.values) {
      for (final rank in CardRank.values) {
        final key = '${rank.index}_${suit.index}';
        if (!used.contains(key)) {
          deck.add(CardEntity(rank: rank, suit: suit));
        }
      }
    }
    return deck;
  }
}
