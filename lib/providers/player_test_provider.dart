import 'package:flutter/foundation.dart';
import '../models/player_test_model.dart';
import '../repositories/player_test_repository.dart';

/// Provider manages player test state
class PlayerTestProvider extends ChangeNotifier {
  final PlayerTestRepository _repository = PlayerTestRepository();

  // State
  List<PlayerTest> _tests = []; // Tests for current player
  Map<String, List<PlayerTest>> _testsByPlayer =
      {}; // NEW - All tests grouped by player
  PlayerTest? _selectedTest;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<PlayerTest> get tests => _tests;
  PlayerTest? get selectedTest => _selectedTest;
  PlayerTest? get latestTest => _tests.isNotEmpty ? _tests.first : null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasTests => _tests.isNotEmpty;
  int get testCount => _tests.length;

  // NEW GETTER - Get all tests across all players
  List<PlayerTest> get allTests {
    if (_testsByPlayer.isEmpty) {
      return _tests; // Return current player's tests if no grouped data
    }
    return _testsByPlayer.values.expand((tests) => tests).toList()
      ..sort((a, b) => b.testDate.compareTo(a.testDate));
  }

  /// Fetch all tests for a player
  Future<void> fetchTestsForPlayer(String playerId) async {
    _setLoading(true);
    _clearError();
    try {
      _tests = await _repository.getTestsByPlayerId(playerId);
      print('✅ Loaded ${_tests.length} tests for player $playerId');
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tests: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch all tests across all players
  Future<void> fetchAllTests() async {
    _setLoading(true);
    _clearError();
    try {
      final allTestsList = await _repository.getAllTests();

      print(
          '📊 Fetched ${allTestsList.length} tests from database'); // Debug log

      // Group tests by player
      _testsByPlayer.clear();
      for (var test in allTestsList) {
        if (!_testsByPlayer.containsKey(test.playerId)) {
          _testsByPlayer[test.playerId] = [];
        }
        _testsByPlayer[test.playerId]!.add(test);
      }

      // Sort each player's tests by date
      _testsByPlayer.forEach((key, tests) {
        tests.sort((a, b) => b.testDate.compareTo(a.testDate));
      });

      print(
          '✅ Loaded ${allTestsList.length} tests across ${_testsByPlayer.length} players');
      notifyListeners();
    } catch (e) {
      print('❌ Error fetching all tests: $e');
      _setError('Failed to load all tests: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Get tests within date range
  Future<void> fetchTestsByDateRange({
    required String playerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      _tests = await _repository.getTestsByDateRange(
        playerId: playerId,
        startDate: startDate,
        endDate: endDate,
      );
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tests by date: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create new test
  Future<bool> createTest(PlayerTest test) async {
    _setLoading(true);
    _clearError();
    try {
      final createdTest = await _repository.createTest(test);

      // Add to local list
      _tests.insert(0, createdTest);

      // Add to grouped tests
      if (!_testsByPlayer.containsKey(test.playerId)) {
        _testsByPlayer[test.playerId] = [];
      }
      _testsByPlayer[test.playerId]!.insert(0, createdTest);

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to create test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update existing test
  Future<bool> updateTest(PlayerTest test) async {
    _setLoading(true);
    _clearError();
    try {
      final updatedTest = await _repository.updateTest(test);

      // Update in local list
      final index = _tests.indexWhere((t) => t.id == updatedTest.id);
      if (index != -1) {
        _tests[index] = updatedTest;
      }

      // Update selected test if same
      if (_selectedTest?.id == updatedTest.id) {
        _selectedTest = updatedTest;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete test
  Future<bool> deleteTest(String testId) async {
    _setLoading(true);
    _clearError();
    try {
      await _repository.deleteTest(testId);

      // Remove from local list
      _tests.removeWhere((t) => t.id == testId);

      // Remove from grouped tests
      _testsByPlayer.forEach((key, tests) {
        tests.removeWhere((t) => t.id == testId);
      });

      // Clear selected if deleted
      if (_selectedTest?.id == testId) {
        _selectedTest = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to delete test: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Select a test for viewing/editing
  void selectTest(PlayerTest test) {
    _selectedTest = test;
    notifyListeners();
  }

  /// Clear selected test
  void clearSelection() {
    _selectedTest = null;
    notifyListeners();
  }

  /// Clear all tests (when switching players)
  void clearTests() {
    _tests = [];
    _selectedTest = null;
    notifyListeners();
  }

  /// Get comparison between two most recent tests
  Map<String, double>? getRecentProgress() {
    if (_tests.length < 2) return null;
    final latest = _tests[0];
    final previous = _tests[1];
    return _repository.compareTests(previous, latest);
  }

  /// Get metric trend over last N tests
  List<double?> getMetricTrend(String metricName, {int lastN = 5}) {
    final recentTests = _tests.take(lastN).toList();
    return recentTests.map((test) {
      switch (metricName) {
        case 'speed_20m':
          return test.speed20m;
        case 'endurance':
          return test.enduranceScore;
        case 'agility':
          return test.agilityScore;
        case 'jump_height':
          return test.jumpHeightCm?.toDouble();
        default:
          return null;
      }
    }).toList();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
