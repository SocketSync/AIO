import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'providers/transaction_provider.dart';
import 'providers/savings_goal_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/receipt_scanner_screen.dart';
import 'screens/profile_screen.dart';

/// Application entry point (AIO-67, AIO-79).
///
/// Bootstraps Flutter widget bindings, initializes the Supabase client via
/// [SupabaseService.initialize] when compile-time `--dart-define` credentials
/// are configured (without hardcoding secrets), restores any persisted auth
/// session, and mounts [FinWiseApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase only when public client credentials are provided.
  if (SupabaseService.isConfigured) {
    try {
      await SupabaseService().initialize();
    } catch (e) {
      debugPrint("Notice: Supabase initialization deferred ($e)");
    }
  }

  await AuthService().initializeSession();

  runApp(const FinWiseApp());
}

/// Root widget for the FinWise application configuring providers, theme,
/// and route guards (AIO-67).
class FinWiseApp extends StatefulWidget {
  final String initialRoute;
  final AuthService? authService;
  final TransactionProvider? transactionProvider;
  final SavingsGoalProvider? savingsGoalProvider;

  const FinWiseApp({
    super.key,
    this.initialRoute = '/',
    this.authService,
    this.transactionProvider,
    this.savingsGoalProvider,
  });

  /// Named routes that require an authenticated user session.
  ///
  /// Public routes (`/`, `/login`, `/register`, `/forgot-password`) remain
  /// accessible without an active session, whereas protected routes
  /// (`/dashboard`, `/budgets`, `/goals`, `/insights`, `/simulator`,
  /// `/profile`, `/add-transaction`, `/receipt-scanner`, `/scanner`) are
  /// guarded in [_FinWiseAppState._onGenerateRoute].
  static const Set<String> protectedRoutes = {
    '/dashboard',
    '/budgets',
    '/goals',
    '/insights',
    '/simulator',
    '/profile',
    '/add-transaction',
    '/receipt-scanner',
    '/scanner',
  };

  @override
  State<FinWiseApp> createState() => _FinWiseAppState();
}

class _AppRouteObserver extends NavigatorObserver {
  final List<Route<dynamic>> _stack = <Route<dynamic>>[];

  String? get currentRouteName =>
      _stack.isEmpty ? null : _stack.last.settings.name;

  int get stackDepth => _stack.length;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _stack.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _stack.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _stack.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final int index = oldRoute != null ? _stack.indexOf(oldRoute) : -1;
    if (index != -1) {
      if (newRoute != null) {
        _stack[index] = newRoute;
      } else {
        _stack.removeAt(index);
      }
    } else if (newRoute != null) {
      _stack.add(newRoute);
    }
  }
}

class _FinWiseAppState extends State<FinWiseApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final _AppRouteObserver _routeObserver = _AppRouteObserver();

  late final AuthService _authService;
  late final TransactionProvider _transactionProvider;
  late final SavingsGoalProvider _savingsGoalProvider;
  late final ThemeProvider _themeProvider;
  late final bool _ownsTransactionProvider;
  late final bool _ownsSavingsGoalProvider;
  StreamSubscription<AuthSessionEvent>? _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _ownsTransactionProvider = widget.transactionProvider == null;
    _transactionProvider = widget.transactionProvider ?? TransactionProvider();
    _ownsSavingsGoalProvider = widget.savingsGoalProvider == null;
    _savingsGoalProvider = widget.savingsGoalProvider ?? SavingsGoalProvider();
    _themeProvider = ThemeProvider();
    _themeProvider.load();

    _authService.registerSessionResetCallback(_resetProviderCaches);
    _sessionSubscription =
        _authService.sessionEvents.listen(_handleSessionEvent);
  }

  @override
  void dispose() {
    _sessionSubscription?.cancel();
    _authService.unregisterSessionResetCallback(_resetProviderCaches);
    if (_ownsTransactionProvider) {
      _transactionProvider.dispose();
    }
    if (_ownsSavingsGoalProvider) {
      _savingsGoalProvider.dispose();
    }
    _themeProvider.dispose();
    super.dispose();
  }

  void _resetProviderCaches() {
    _transactionProvider.clear();
    _savingsGoalProvider.clear();
  }

  void _handleSessionEvent(AuthSessionEvent event) {
    if (!mounted) return;
    switch (event) {
      case AuthSessionEvent.signedOut:
      case AuthSessionEvent.sessionExpired:
        _resetProviderCaches();
        final bool isAlreadyAtLogin =
            _routeObserver.currentRouteName == '/login' &&
                _routeObserver.stackDepth == 1;
        if (!isAlreadyAtLogin) {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }
      case AuthSessionEvent.signedIn:
        final String? currentRoute = _routeObserver.currentRouteName;
        if (currentRoute == '/' || currentRoute == '/login') {
          _navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/dashboard',
            (route) => false,
          );
        }
    }
  }

  /// Central named-route generator with authentication route guarding.
  ///
  /// Redirects unauthenticated requests targeting [FinWiseApp.protectedRoutes]
  /// to `/login`, resolves authenticated tab and modal destinations, and falls
  /// back to `/dashboard` (when authenticated) or `/login` for unknown routes.
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? '/';
    final bool isAuthenticated = _authService.isAuthenticated;

    if (FinWiseApp.protectedRoutes.contains(routeName) && !isAuthenticated) {
      return MaterialPageRoute<void>(
        settings: const RouteSettings(name: '/login'),
        builder: (_) => const LoginScreen(),
      );
    }

    switch (routeName) {
      case '/':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AuthGate(),
        );
      case '/login':
        if (isAuthenticated) {
          return MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/dashboard'),
            builder: (_) => const MainNavigationShell(initialTab: 0),
          );
        }
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
      case '/register':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );
      case '/forgot-password':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );
      case '/dashboard':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialTab: 0),
        );
      case '/budgets':
      case '/goals':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialTab: 1),
        );
      case '/insights':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialTab: 2),
        );
      case '/simulator':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const MainNavigationShell(initialTab: 3),
        );
      case '/profile':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case '/add-transaction':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const AddTransactionScreen(),
        );
      case '/receipt-scanner':
      case '/scanner':
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const ReceiptScannerScreen(),
        );
      default:
        return MaterialPageRoute<void>(
          settings:
              RouteSettings(name: isAuthenticated ? '/dashboard' : '/login'),
          builder: (_) => isAuthenticated
              ? const MainNavigationShell(initialTab: 0)
              : const LoginScreen(),
        );
    }
  }

  /// Builds the root [MultiProvider] state container and [MaterialApp]
  /// navigation tree (AIO-28: Flutter App Architecture & Global State).
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authService),
        ChangeNotifierProvider.value(value: _transactionProvider),
        ChangeNotifierProvider.value(value: _savingsGoalProvider),
      ],
      child: ChangeNotifierProvider.value(
        value: _themeProvider,
        child: Consumer<ThemeProvider>(
          builder: (context, theme, _) => MaterialApp(
            title: 'FinWise',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            navigatorKey: _navigatorKey,
            navigatorObservers: [_routeObserver],
            initialRoute: widget.initialRoute,
            onGenerateInitialRoutes: (String initialRouteName) => [
              _onGenerateRoute(RouteSettings(name: initialRouteName)),
            ],
            onGenerateRoute: _onGenerateRoute,
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isCheckingSession = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthService>();
    if (!auth.isSessionInitialized && SupabaseService.isConfigured) {
      _isCheckingSession = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        auth.initializeSession().whenComplete(() {
          if (!mounted) return;
          setState(() => _isCheckingSession = false);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (_isCheckingSession) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const MainNavigationShell(initialTab: 0);
    }

    return const LoginScreen();
  }
}
