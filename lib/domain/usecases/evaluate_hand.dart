import 'package:neopoker/core/utils/hand_evaluator.dart';
import '../entities/card.dart';
import '../entities/hand_result.dart';

class EvaluateHand {
  final HandEvaluator evaluator;

  EvaluateHand(this.evaluator);

  HandResult call(List<CardEntity> holeCards, List<CardEntity> communityCards) {
    return evaluator.evaluate(holeCards, communityCards);
  }

  double calculateWinProbability(
    List<CardEntity> holeCards,
    List<CardEntity> communityCards,
    int opponents,
  ) {
    return evaluator.calculateWinProbability(holeCards, communityCards, opponents);
  }
}
