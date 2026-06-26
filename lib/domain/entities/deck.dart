import 'dart:math';
import 'card.dart';
import '../enums/card_rank.dart';
import '../enums/suit.dart';

class Deck {
  final List<CardEntity> _cards = [];
  final Random _random = Random();
  int _drawIndex = 0;

  Deck() {
    _initialize();
  }

  void _initialize() {
    _cards.clear();
    for (final suit in Suit.values) {
      for (final rank in CardRank.values) {
        _cards.add(CardEntity(rank: rank, suit: suit));
      }
    }
    _drawIndex = 0;
  }

  void shuffle() {
    _cards.shuffle(_random);
    _drawIndex = 0;
  }

  CardEntity draw() {
    if (_drawIndex >= _cards.length) {
      throw StateError('No more cards in the deck');
    }
    return _cards[_drawIndex++];
  }

  void reset() {
    _initialize();
  }

  int get remaining => _cards.length - _drawIndex;
}
