import 'package:flame/components.dart';

class ChipComponent extends PositionComponent {
  final int amount;

  ChipComponent({this.amount = 0});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
  }
}
