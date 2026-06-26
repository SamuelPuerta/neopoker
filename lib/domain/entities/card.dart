import 'package:equatable/equatable.dart';
import '../enums/card_rank.dart';
import '../enums/suit.dart';

class CardEntity extends Equatable {
  final CardRank rank;
  final Suit suit;

  const CardEntity({required this.rank, required this.suit});

  int get numericValue => rank.index + 2;

  @override
  List<Object?> get props => [rank, suit];
}
