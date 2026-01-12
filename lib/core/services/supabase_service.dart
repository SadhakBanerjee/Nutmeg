import 'package:supabase_flutter/supabase_flutter.dart';

/// Singleton service to manage Supabase client
/// Singleton = Only one instance exists throughout app lifecycle
class SupabaseService {
  // Private constructor prevents external instantiation
  SupabaseService._();

  // Single instance of this class
  static final SupabaseService _instance = SupabaseService._();

  // Factory constructor returns the same instance every time
  factory SupabaseService() => _instance;

  // The Supabase client - used for all database operations
  SupabaseClient? _client;

  /// Getter to access Supabase client
  /// Throws error if not initialized (safety check)
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
          'SupabaseService not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Initialize Supabase with your project credentials
  /// Call this once when app starts (in main.dart)
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    try {
      // Initialize Supabase SDK
      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        // Optional: Add auth persistence for future features
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce, // Secure auth flow
        ),
      );

      // Store the client instance
      _client = Supabase.instance.client;

      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      rethrow; // Pass error up so app can handle it
    }
  }

  /// Check if Supabase is initialized
  bool get isInitialized => _client != null;

  /// Get current user (for future auth features)
  User? get currentUser => _client?.auth.currentUser;

  /// REMOVED THE INCORRECT 'db' GETTER
  /// Instead, use: supabaseService.client.from('table_name')
}

// Global instance for easy access throughout app
final supabaseService = SupabaseService();
