import 'package:flutter/material.dart';
import 'package:neopoker/core/constants/app_colors.dart';
import 'package:neopoker/domain/entities/card.dart';
import 'package:neopoker/domain/enums/card_rank.dart';
import 'package:neopoker/domain/enums/suit.dart';

class CardWidget extends StatelessWidget {
  final CardEntity? card;
  final bool faceDown;
  final double width;
  final bool small;

  const CardWidget({
    super.key,
    this.card,
    this.faceDown = false,
    this.width = 60,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = width * 1.4;
    return Container(
      width: width,
      height: h,
      decoration: BoxDecoration(
        color: faceDown ? AppColors.neonPink.withValues(alpha: 0.3) : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: faceDown ? AppColors.neonPink : AppColors.textSecondary.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: faceDown
          ? const Center(
              child: Icon(Icons.question_mark, color: AppColors.neonPink, size: 20),
            )
          : card != null
              ? _CardFace(card: card!, small: small)
              : const SizedBox(),
    );
  }
}

class _CardFace extends StatelessWidget {
  final CardEntity card;
  final bool small;

  const _CardFace({required this.card, this.small = false});

  @override
  Widget build(BuildContext context) {
    final isRed = card.suit == Suit.hearts || card.suit == Suit.diamonds;
    final color = isRed ? AppColors.textDanger : AppColors.textPrimary;
    final suitIcon = _suitIcon(card.suit);

    return Padding(
      padding: EdgeInsets.all(small ? 2 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _rankSymbol(card.rank),
            style: TextStyle(
              color: color,
              fontSize: small ? 10 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Center(
            child: Text(
              suitIcon,
              style: TextStyle(fontSize: small ? 14 : 20),
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              _rankSymbol(card.rank),
              style: TextStyle(
                color: color,
                fontSize: small ? 10 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _rankSymbol(CardRank rank) {
    switch (rank) {
      case CardRank.ace:
        return 'A';
      case CardRank.king:
        return 'K';
      case CardRank.queen:
        return 'Q';
      case CardRank.jack:
        return 'J';
      case CardRank.ten:
        return '10';
      default:
        return '${rank.index + 2}';
    }
  }

  String _suitIcon(Suit suit) {
    switch (suit) {
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
      case Suit.spades:
        return '♠';
    }
  }
}
