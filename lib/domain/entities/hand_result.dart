import 'package:equatable/equatable.dart';
import 'card.dart';
import '../enums/hand_rank.dart';

class HandResult extends Equatable {
  final HandRank rank;
  final List<CardEntity> bestHand;
  final List<int> tiebreakers;

  const HandResult({
    required this.rank,
    required this.bestHand,
    required this.tiebreakers,
  });

  int compareTo(HandResult other) {
    if (rank.index != other.rank.index) {
      return rank.index - other.rank.index;
    }
    for (int i = 0; i < tiebreakers.length && i < other.tiebreakers.length; i++) {
      if (tiebreakers[i] != other.tiebreakers[i]) {
        return tiebreakers[i] - other.tiebreakers[i];
      }
    }
    return 0;
  }

  @override
  List<Object?> get props => [rank, tiebreakers];
}
