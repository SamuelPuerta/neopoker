import 'package:shared_preferences/shared_preferences.dart';
import 'package:neopoker/core/utils/hand_evaluator.dart';
import 'package:neopoker/data/local/local_db.dart';
import 'package:neopoker/data/local/local_game_repository.dart';
import 'package:neopoker/data/local/local_player_repository.dart';
import 'package:neopoker/data/local/local_stats_repository.dart';
import 'package:neopoker/domain/repositories/i_game_repository.dart';
import 'package:neopoker/domain/repositories/i_player_repository.dart';
import 'package:neopoker/domain/repositories/i_stats_repository.dart';
import 'package:neopoker/domain/usecases/apply_power.dart';
import 'package:neopoker/domain/usecases/deal_cards.dart';
import 'package:neopoker/domain/usecases/evaluate_hand.dart';
import 'package:neopoker/domain/usecases/process_action.dart';
import 'package:neopoker/domain/usecases/trigger_event.dart';
import 'injection.dart';

Future<void> setupOfflineDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<LocalDb>(() => LocalDb(prefs));
  getIt.registerLazySingleton<HandEvaluator>(() => HandEvaluator());
  getIt.registerLazySingleton<LocalPlayerRepository>(
      () => LocalPlayerRepository());
  getIt.registerLazySingleton<LocalGameRepository>(
      () => LocalGameRepository(getIt<LocalPlayerRepository>()));

  getIt.registerLazySingleton<IGameRepository>(
      () => getIt<LocalGameRepository>());
  getIt.registerLazySingleton<IPlayerRepository>(
      () => getIt<LocalPlayerRepository>());
  getIt.registerLazySingleton<IStatsRepository>(
      () => LocalStatsRepository());

  getIt.registerLazySingleton(() => DealCards(getIt<IGameRepository>()));
  getIt.registerLazySingleton(() => ProcessAction(getIt<IGameRepository>()));
  getIt.registerLazySingleton(
      () => EvaluateHand(getIt<HandEvaluator>()));
  getIt.registerLazySingleton(() => ApplyPower(getIt<HandEvaluator>()));
  getIt.registerLazySingleton(() => TriggerEvent());
}
