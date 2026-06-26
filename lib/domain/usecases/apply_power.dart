import 'package:neopoker/core/utils/hand_evaluator.dart';
import '../entities/game_state.dart';
import '../entities/player.dart';
import '../enums/power_type.dart';

class PowerNotAvailableException implements Exception {}
class InsufficientEnergyException implements Exception {}

class ApplyPower {
  final HandEvaluator _evaluator;

  ApplyPower(this._evaluator);

  GameState call({
    required GameState currentState,
    required String playerId,
    required PowerType powerType,
  }) {
    final playerIndex = currentState.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) throw StateError('Player not found');

    final player = currentState.players[playerIndex];

    if (!player.availablePowers.contains(powerType)) {
      throw PowerNotAvailableException();
    }
    if (player.energy < 1) throw InsufficientEnergyException();
    if (!player.canUsePower) throw PowerNotAvailableException();

    return switch (powerType) {
      PowerType.scan => _applyScan(currentState, player, playerIndex),
      PowerType.firewall => _applyFirewall(currentState, player, playerIndex),
      PowerType.overclock => _applyOverclock(currentState, player, playerIndex),
      PowerType.reboot => _applyReboot(currentState, player, playerIndex),
      PowerType.decrypt => _applyDecrypt(currentState, player, playerIndex),
      PowerType.ghostHand => _applyGhostHand(currentState, player, playerIndex),
    };
  }

  GameState _applyScan(GameState state, PlayerEntity player, int index) {
    if (state.communityCards.length >= 3 && player.holeCards.length >= 2) {
      _evaluator.calculateWinProbability(
        player.holeCards,
        state.communityCards,
        state.players.where((p) => p.isActive && p.id != player.id).length,
      );
    }
    return _consumeEnergy(state, index);
  }

  GameState _applyFirewall(GameState state, PlayerEntity player, int index) {
    final players = List<PlayerEntity>.generate(state.players.length, (i) {
      if (i != index) return state.players[i];
      return state.players[i].copyWith(energy: player.energy - 1);
    });
    return state.copyWith(
      clearUpcomingEvent: true,
      players: players,
    );
  }

  GameState _applyOverclock(GameState state, PlayerEntity player, int index) {
    return _consumeEnergy(state, index);
  }

  GameState _applyReboot(GameState state, PlayerEntity player, int index) {
    return _consumeEnergy(state, index);
  }

  GameState _applyDecrypt(GameState state, PlayerEntity player, int index) {
    return _consumeEnergy(state, index);
  }

  GameState _applyGhostHand(GameState state, PlayerEntity player, int index) {
    return _consumeEnergy(state, index);
  }

  GameState _consumeEnergy(GameState state, int playerIndex) {
    final player = state.players[playerIndex];
    final players = List<PlayerEntity>.generate(state.players.length, (i) {
      if (i != playerIndex) return state.players[i];
      return state.players[i].copyWith(energy: player.energy - 1);
    });
    return state.copyWith(players: players);
  }
}
