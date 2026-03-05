import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_repository.dart';
import '../../features/auth/login_screen.dart';
import '../../features/protocols/protocols_screen.dart';
import '../../features/contacts/contacts_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Router provider that rebuilds when auth state changes.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/protocols',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isOnLogin = state.uri.path == '/login';

      if (!isLoggedIn && !isOnLogin) return '/login';
      if (isLoggedIn && isOnLogin) return '/protocols';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/protocols',
            builder: (context, state) => const ProtocolsScreen(),
          ),
          GoRoute(
            path: '/contacts',
            builder: (context, state) => const ContactsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
