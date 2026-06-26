import 'package:flutter_bloc/flutter_bloc.dart';
import 'lobby_event.dart';
import 'lobby_state.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  LobbyBloc() : super(const LobbyInitial()) {
    on<LobbyStarted>(_onLobbyStarted);
    on<GameModeSelected>(_onGameModeSelected);
    on<BotDifficultyChanged>(_onBotDifficultyChanged);
  }

  void _onLobbyStarted(
    LobbyStarted event,
    Emitter<LobbyState> emit,
  ) {
    emit(const LobbyReady());
  }

  void _onGameModeSelected(
    GameModeSelected event,
    Emitter<LobbyState> emit,
  ) {
    final current = state;
    if (current is LobbyReady) {
      emit(LobbyReady(
        mode: event.mode,
        isRanked: event.isRanked,
        botDifficulty: current.botDifficulty,
      ));
    }
  }

  void _onBotDifficultyChanged(
    BotDifficultyChanged event,
    Emitter<LobbyState> emit,
  ) {
    final current = state;
    if (current is LobbyReady) {
      emit(LobbyReady(
        mode: current.mode,
        isRanked: current.isRanked,
        botDifficulty: event.difficulty,
      ));
    }
  }
}
