import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/services/supabase_service.dart';
import 'theme/app_theme.dart';
import 'providers/player_provider.dart';
import 'providers/player_test_provider.dart';
import 'screens/home/home_screen.dart';
import 'core/services/groq_service.dart';
import 'providers/theme_provider.dart';

void main() async {
  // Ensure Flutter is initialized before async operations
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load environment variables from .env file
    await dotenv.load(fileName: ".env");

    // Initialize Supabase with credentials from .env
    await supabaseService.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );

    // Initialize Groq AI
    groqService.initialize();

    // Run the app
    runApp(const NutmegApp());
  } catch (e) {
    // Show error if initialization fails
    print('Failed to initialize app: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class NutmegApp extends StatelessWidget {
  const NutmegApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Register all providers here
    return MultiProvider(
      providers: [
        // Player provider - manages player state
        ChangeNotifierProvider(create: (_) => PlayerProvider()),

        // PlayerTest provider - manages test state
        ChangeNotifierProvider(create: (_) => PlayerTestProvider()),

        // Theme provider - manages theme state
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(  // ← Wrap MaterialApp with Consumer
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Nutmeg',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,      // ← Light theme
            darkTheme: AppTheme.darkTheme,   // ← Dark theme
            themeMode: themeProvider.themeMode,  // ← Now accessible!
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}


/// Error screen shown if app fails to initialize
class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to Initialize App',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate to HomeScreen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your custom logo
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            Text(
              'NUTMEG',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Train Smarter. Play Faster',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            // Loading indicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
