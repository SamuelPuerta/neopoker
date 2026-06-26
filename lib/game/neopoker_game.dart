import 'package:flame/game.dart';
import 'package:neopoker/domain/entities/card.dart';
import 'package:neopoker/domain/entities/game_state.dart';
import 'package:neopoker/domain/entities/player.dart';

class NeoPokerGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
  }

  void updateGameState(GameState state) {
    _updateCommunityCards(state.communityCards);
    _updatePlayerSeats(state.players);
    _updatePot(state.pot);
    if (state.activeEvent != null) {
      _triggerEventEffect(state.activeEvent!);
    }
  }

  void _updateCommunityCards(List<CardEntity> cards) {}

  void _updatePlayerSeats(List<PlayerEntity> players) {}

  void _updatePot(int pot) {}

  void _triggerEventEffect(TableEvent event) {}
}
