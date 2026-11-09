import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';
import 'services/supabase_service.dart';
import 'providers/transaction_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/main_navigation_shell.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/receipt_scanner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables if available
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Notice: .env file not loaded or not found ($e)");
  }

  // Initialize Supabase if backend credentials are configured in .env
  if (SupabaseService.isConfigured) {
    try {
      await SupabaseService().initialize();
    } catch (e) {
      debugPrint("Notice: Supabase initialization deferred ($e)");
    }
  }

  runApp(const FinWiseApp());
}

class FinWiseApp extends StatelessWidget {
  const FinWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthService()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'FinWise',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/dashboard': (context) => const MainNavigationShell(initialTab: 0),
          '/budgets': (context) => const MainNavigationShell(initialTab: 1),
          '/insights': (context) => const MainNavigationShell(initialTab: 2),
          '/simulator': (context) => const MainNavigationShell(initialTab: 3),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/scanner': (context) => const ReceiptScannerScreen(),
        },
      ),
    );
  }
}
