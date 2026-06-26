import 'package:flame/components.dart';

class TableComponent extends PositionComponent {
  @override
  Future<void> onLoad() async {
    super.onLoad();
    anchor = Anchor.center;
  }
}
