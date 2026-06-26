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
  final bool highlighted;

  const CardWidget({
    super.key,
    this.card,
    this.faceDown = false,
    this.width = 60,
    this.small = false,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final h = width * 1.4;
    if (faceDown) {
      return _CardBack(width: width, height: h, small: small);
    }
    if (card == null) return _CardBack(width: width, height: h, small: small);
    final borderColor = highlighted
        ? AppColors.neonGreen
        : AppColors.textSecondary.withValues(alpha: 0.5);
    final borderWidth = highlighted ? 2.5 : 1.5;
    return Container(
      width: width,
      height: h,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.neonGreen.withValues(alpha: 0.08)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: _CardFace(card: card!, small: small),
    );
  }
}

class _CardBack extends StatelessWidget {
  final double width;
  final double height;
  final bool small;

  const _CardBack({required this.width, required this.height, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonCyan.withValues(alpha: 0.5),
            AppColors.neonPink.withValues(alpha: 0.3),
            AppColors.neonCyan.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: AppColors.neonCyan.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_awesome,
          color: AppColors.neonCyan.withValues(alpha: 0.6),
          size: small ? 14 : 22,
        ),
      ),
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
    final rankStr = _rankSymbol(card.rank);

    final fs = small ? 1.0 : null;
    return Padding(
      padding: EdgeInsets.all(small ? 2 : 4),
      child: ClipRect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rankStr,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: small ? 10 : 14,
                fontWeight: FontWeight.bold,
                height: fs,
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                suitIcon,
                maxLines: 1,
                style: TextStyle(fontSize: small ? 12 : 20, height: fs),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                rankStr,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: small ? 10 : 14,
                  fontWeight: FontWeight.bold,
                  height: fs,
                ),
              ),
            ),
          ],
        ),
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
