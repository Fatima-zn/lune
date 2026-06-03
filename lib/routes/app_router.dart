import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lune/features/explore/pages/genre_podcasts_page.dart';
import '../features/auth/pages/login_page.dart';
import '../features/auth/pages/signup_page.dart';
import '../features/auth/pages/forgot_password_page.dart';
import '../features/auth/pages/email_verification_page.dart';
import '../features/auth/pages/biometric_gate.dart';
import '../features/home/pages/home_page.dart';
import '../features/explore/pages/explore_page.dart';
import '../features/library/pages/library_page.dart';
import '../features/stats/pages/stats_page.dart';
import '../features/player/pages/player_screen.dart';
import '../features/player/providers/player_provider.dart';
import '../features/podcast/pages/podcast_detail_screen.dart';
import '../core/widgets/app_shell.dart';


final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BiometricGate(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.extra as String? ?? '';
        return EmailVerificationScreen(email: email);
      },
    ),
    
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    
    GoRoute(
      path: '/podcast/:podcastId',
      builder: (context, state) {
        final podcastId = state.pathParameters['podcastId']!;
        return PodcastDetailPage(podcastId: podcastId);
      },
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final container = ProviderScope.containerOf(context);
            container.read(playerStateProvider.notifier).play(
              url: extra['audio'] as String? ?? '',
              title: extra['title'] as String? ?? '',
              podcastTitle: extra['podcastTitle'] as String? ?? '',
              imageUrl: extra['image'] as String?,
            );
          });
        }
        return const PlayerScreen();
      },
    ),

    GoRoute(
      path: '/genre/:genreId',
      builder: (context, state) {
        final genreId = int.parse(state.pathParameters['genreId']!);
        final genreName = state.extra as String? ?? 'Podcasts';
        return GenrePodcastsPage(genreId: genreId, genreName: genreName);
      },
    ),
  ],
);