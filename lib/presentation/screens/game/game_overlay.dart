import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neopoker/presentation/blocs/game/game_bloc.dart';
import 'package:neopoker/presentation/blocs/game/game_state.dart' as gstate;

class GameOverlay extends StatelessWidget {
  const GameOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, gstate.GameBlocState>(
      builder: (context, state) {
        return const SizedBox();
      },
    );
  }
}
