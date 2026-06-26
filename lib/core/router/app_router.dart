import 'package:go_router/go_router.dart';
import 'package:neopoker/presentation/screens/splash/splash_screen.dart';
import 'package:neopoker/presentation/screens/home/home_screen.dart';
import 'package:neopoker/presentation/screens/lobby/lobby_screen.dart';
import 'package:neopoker/presentation/screens/game/game_screen.dart';
import 'package:neopoker/presentation/screens/profile/profile_screen.dart';
import 'package:neopoker/presentation/screens/settings/settings_screen.dart';

class AppRouter {
  static const String splash = '/';
  static const String home = '/home';
  static const String lobby = '/lobby';
  static const String game = '/game';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: home, builder: (_, _) => const HomeScreen()),
      GoRoute(path: lobby, builder: (_, _) => const LobbyScreen()),
      GoRoute(path: game, builder: (_, _) => const GameScreen()),
      GoRoute(path: profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: settings, builder: (_, _) => const SettingsScreen()),
    ],
  );
}
