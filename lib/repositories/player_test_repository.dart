import '../core/services/supabase_service.dart';
import '../models/player_test_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for player test data
/// Handles all fitness test database operations
class PlayerTestRepository {
  final SupabaseService _supabaseService = supabaseService;

  /// Get all tests for a specific player
  /// Returns list sorted by date (newest first)
  Future<List<PlayerTest>> getTestsByPlayerId(String playerId) async {
    try {
      // SELECT * FROM player_tests WHERE player_id = playerId
      // ORDER BY test_date DESC
      final response = await _supabaseService.client
          .from('player_tests')
          .select()
          .eq('player_id', playerId)
          .order('test_date', ascending: false); // Newest first

      return (response as List)
          .map((json) => PlayerTest.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching tests for player $playerId: $e');
      throw Exception('Failed to fetch player tests: $e');
    }
  }

  /// Get latest test for a player
  /// Returns null if no tests exist
  Future<PlayerTest?> getLatestTest(String playerId) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .select()
          .eq('player_id', playerId)
          .order('test_date', ascending: false)
          .limit(1); // Only get 1 result

      if (response.isEmpty) return null;

      return PlayerTest.fromJson(response.first);
    } catch (e) {
      print('❌ Error fetching latest test: $e');
      return null;
    }
  }

  /// Get tests within a date range
  /// Useful for viewing progress over specific period
  Future<List<PlayerTest>> getTestsByDateRange({
    required String playerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .select()
          .eq('player_id', playerId)
          .gte('test_date', startDate.toIso8601String()) // >= startDate
          .lte('test_date', endDate.toIso8601String()) // <= endDate
          .order('test_date', ascending: false);

      return (response as List)
          .map((json) => PlayerTest.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching tests by date range: $e');
      throw Exception('Failed to fetch tests by date range: $e');
    }
  }

  /// Get a specific test by ID
  Future<PlayerTest?> getTestById(String testId) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .select()
          .eq('id', testId)
          .single();

      return PlayerTest.fromJson(response);
    } catch (e) {
      print('❌ Error fetching test $testId: $e');
      return null;
    }
  }

  /// Create a new test
  /// Returns created test with generated ID
  Future<PlayerTest> createTest(PlayerTest test) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .insert(test.toInsertJson())
          .select()
          .single();

      print('✅ Test created for player: ${test.playerId}');
      return PlayerTest.fromJson(response);
    } catch (e) {
      print('❌ Error creating test: $e');
      throw Exception('Failed to create test: $e');
    }
  }

  /// Update existing test
  Future<PlayerTest> updateTest(PlayerTest test) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .update(test.toJson())
          .eq('id', test.id)
          .select()
          .single();

      print('✅ Test updated: ${test.id}');
      return PlayerTest.fromJson(response);
    } catch (e) {
      print('❌ Error updating test: $e');
      throw Exception('Failed to update test: $e');
    }
  }

  /// Delete a test
  Future<void> deleteTest(String testId) async {
    try {
      await _supabaseService.client
          .from('player_tests')
          .delete()
          .eq('id', testId);

      print('✅ Test deleted: $testId');
    } catch (e) {
      print('❌ Error deleting test: $e');
      throw Exception('Failed to delete test: $e');
    }
  }

  /// Get test count for a player
  /// Useful for showing "X tests completed"
  Future<int> getTestCountForPlayer(String playerId) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .select('id')
          .eq('player_id', playerId)
          .count(CountOption.exact);

      return response.count ?? 0;
    } catch (e) {
      print('❌ Error counting tests: $e');
      return 0;
    }
  }

  /// Get recent tests across all players
  /// Useful for dashboard "Recent Activity" section
  Future<List<PlayerTest>> getRecentTests({int limit = 10}) async {
    try {
      final response = await _supabaseService.client
          .from('player_tests')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => PlayerTest.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ Error fetching recent tests: $e');
      throw Exception('Failed to fetch recent tests: $e');
    }
  }

  /// Fetch all tests across all players
  Future<List<PlayerTest>> getAllTests() async {
    try {
      print('🔍 Fetching all tests from database...'); // Debug log

      final response = await supabaseService.client
          .from('player_tests')
          .select()
          .order('test_date', ascending: false);

      final tests =
          (response as List).map((json) => PlayerTest.fromJson(json)).toList();

      print('✅ Repository fetched ${tests.length} tests'); // Debug log

      return tests;
    } catch (e) {
      print('❌ Error in getAllTests: $e');
      throw Exception('Failed to fetch all tests: $e');
    }
  }

  /// Compare two tests (useful for showing progress)
  /// Returns percentage change for each metric
  Map<String, double> compareTests(PlayerTest oldTest, PlayerTest newTest) {
    Map<String, double> changes = {};

    // Helper function to calculate percentage change
    double? percentChange(double? oldValue, double? newValue) {
      if (oldValue == null || newValue == null || oldValue == 0) return null;
      return ((newValue - oldValue) / oldValue) * 100;
    }

    // Calculate changes for each metric
    final speed20Change = percentChange(oldTest.speed20m, newTest.speed20m);
    if (speed20Change != null) changes['speed_20m'] = speed20Change;

    final enduranceChange =
        percentChange(oldTest.enduranceScore, newTest.enduranceScore);
    if (enduranceChange != null) changes['endurance'] = enduranceChange;

    final agilityChange =
        percentChange(oldTest.agilityScore, newTest.agilityScore);
    if (agilityChange != null) changes['agility'] = agilityChange;

    final jumpChange = percentChange(
        oldTest.jumpHeightCm?.toDouble(), newTest.jumpHeightCm?.toDouble());
    if (jumpChange != null) changes['jump_height'] = jumpChange;

    return changes;
  }
}
