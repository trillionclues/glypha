import 'package:flutter/cupertino.dart';
import 'package:glypha/app/routes/route_paths.dart';
import 'package:glypha/features/auth/presentation/pages/onboarding_page.dart';
import 'package:glypha/features/auth/presentation/pages/login_page.dart';
import 'package:glypha/features/home/presentation/pages/home_page.dart';
import 'package:glypha/features/home/presentation/pages/shell_scaffold.dart';
import 'package:glypha/features/leaderboard/presentation/leaderboard_page.dart';
import 'package:glypha/features/practice/presentation/practice_page.dart';
import 'package:glypha/features/profile/presentation/profile_page.dart';
import 'package:glypha/features/splash/presentation/pages/splash_page.dart';
import 'package:glypha/features/game/presentation/game_page.dart';
import 'package:go_router/go_router.dart';

final RouteObserver<ModalRoute> routeObserver = RouteObserver<ModalRoute>();

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: SplashPage.route,
          name: AppRoute.splash.name,
          builder: (context, state) => const SplashPage(),
        ),
        GoRoute(
          path: LoginPage.route,
          name: AppRoute.login.name,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: OnboardingPage.route,
          name: AppRoute.onboarding.name,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: GamePage.route,
          name: AppRoute.game.name,
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const GamePage(),
        ),
        StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ShellScaffold(
                  currentIndex: navigationShell.currentIndex,
                  onNavTap: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                  child: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _shellNavigatorKey,
                routes: [
                  GoRoute(
                    path: HomePage.route,
                    name: AppRoute.home.name,
                    builder: (context, state) => const HomePage(),
                    // Then navigate with:
                    //   context.goNamed(AppRoute.game.name, pathParameters: {'levelId': '1'});
                    // routes: [
                    //   GoRoute(
                    //     path: 'game/:levelId',
                    //     name: AppRoute.game.name,
                    //     parentNavigatorKey: _rootNavigatorKey, // Uses root navigator
                    //     builder: (context, state) {
                    //       final levelId = state.pathParameters['levelId']!;
                    //       return GamePage(levelId: levelId);
                    //     },
                    //   ),
                    // ]
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: PracticePage.route,
                    name: AppRoute.practice.name,
                    builder: (context, state) => const PracticePage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: LeaderboardPage.route,
                    name: AppRoute.leaderboard.name,
                    builder: (context, state) => const LeaderboardPage(),
                  ),
                ],
              ),
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: ProfilePage.route,
                    name: AppRoute.profile.name,
                    builder: (context, state) => const ProfilePage(),
                  ),
                ],
              ),
            ])
      ],
      observers: [
        routeObserver
      ]);
}
