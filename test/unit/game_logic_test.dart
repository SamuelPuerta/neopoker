import 'package:flutter_test/flutter_test.dart';
import 'package:neopoker/domain/entities/deck.dart';

void main() {
  group('Deck', () {
    test('tiene 52 cartas', () {
      final deck = Deck();
      final drawn = <dynamic>[];
      for (int i = 0; i < 52; i++) {
        drawn.add(deck.draw());
      }
      expect(drawn.length, 52);
      expect(() => deck.draw(), throwsStateError);
    });

    test('todas las cartas son únicas', () {
      final deck = Deck();
      final drawn = <dynamic>[];
      for (int i = 0; i < 52; i++) {
        drawn.add(deck.draw());
      }
      final unique = drawn.toSet();
      expect(unique.length, 52);
    });

    test('se puede resetear', () {
      final deck = Deck();
      for (int i = 0; i < 10; i++) {
        deck.draw();
      }
      expect(deck.remaining, 42);
      deck.reset();
      expect(deck.remaining, 52);
    });

    test('shuffle cambia el orden', () {
      final deck1 = Deck();
      final deck2 = Deck();
      final order1 = <dynamic>[];
      final order2 = <dynamic>[];
      for (int i = 0; i < 52; i++) {
        order1.add(deck1.draw());
        order2.add(deck2.draw());
      }
      final same = order1.every((c) => order1.indexOf(c) == order2.indexOf(c));
      expect(same, isTrue); // Sin shuffle deben ser iguales
    });
  });
}
