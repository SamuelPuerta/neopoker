import 'package:flame/components.dart';

class PlayerSeatComponent extends PositionComponent {
  final int seatIndex;

  PlayerSeatComponent({required this.seatIndex});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
  }
}
