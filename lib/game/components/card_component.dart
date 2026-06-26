import 'package:flame/components.dart';
import 'package:neopoker/domain/entities/card.dart';

class CardComponent extends PositionComponent {
  final CardEntity? card;
  final bool faceDown;

  CardComponent({this.card, this.faceDown = false});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
  }
}
