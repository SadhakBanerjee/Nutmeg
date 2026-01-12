import 'package:flutter/material.dart';
import '../../models/player_model.dart';
import '../../models/player_test_model.dart';
import 'groq_service.dart';

class AnalyticsService {
  final GroqService _groqService = groqService;

  /// Calculate team average for a specific metric
  double calculateTeamAverage(List<PlayerTest> tests, String metric) {
    if (tests.isEmpty) return 0;

    final values = tests
        .map((test) {
          switch (metric) {
            case 'speed20m':
              return test.speed20m;
            case 'endurance':
              return test.enduranceScore;
            case 'agility':
              return test.agilityScore;
            case 'verticalJump':
              return test.jumpHeightCm?.toDouble();
            default:
              return null;
          }
        })
        .where((v) => v != null)
        .cast<double>()
        .toList();

    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Find best performer
  Map<String, dynamic> findBestPerformer(
    List<Player> players,
    List<PlayerTest> allTests,
  ) {
    if (players.isEmpty || allTests.isEmpty) {
      return {'player': null, 'score': 0.0};
    }

    double bestScore = 0;
    Player? bestPlayer;

    for (var player in players) {
      final playerTests =
          allTests.where((t) => t.playerId == player.id).toList();
      if (playerTests.isEmpty) continue;

      // Calculate overall score (lower is better for speed/agility, higher for others)
      final latestTest = playerTests.first;
      double score = 0;
      int count = 0;

      if (latestTest.speed20m != null) {
        score += (10 - latestTest.speed20m!) * 10; // Lower is better
        count++;
      }
      if (latestTest.enduranceScore != null) {
        score += latestTest.enduranceScore! / 100;
        count++;
      }
      if (latestTest.agilityScore != null) {
        score += (20 - latestTest.agilityScore!) * 5; // Lower is better
        count++;
      }
      if (latestTest.jumpHeightCm != null) {
        score += latestTest.jumpHeightCm! / 10;
        count++;
      }

      if (count > 0) {
        score = score / count;
        if (score > bestScore) {
          bestScore = score;
          bestPlayer = player;
        }
      }
    }

    return {'player': bestPlayer, 'score': bestScore};
  }

  /// Get performance trend (improving/declining)
  String getPerformanceTrend(List<PlayerTest> tests) {
    if (tests.length < 2) return 'neutral';

    final recent = tests.take(3).toList();
    final older = tests.skip(3).take(3).toList();

    if (older.isEmpty) return 'neutral';

    // Compare average scores
    double recentAvg = _calculateTestScore(recent);
    double olderAvg = _calculateTestScore(older);

    if (recentAvg > olderAvg * 1.1) return 'improving';
    if (recentAvg < olderAvg * 0.9) return 'declining';
    return 'stable';
  }

  double _calculateTestScore(List<PlayerTest> tests) {
    if (tests.isEmpty) return 0;

    double total = 0;
    int count = 0;

    for (var test in tests) {
      if (test.speed20m != null) {
        total += (10 - test.speed20m!) * 10;
        count++;
      }
      if (test.enduranceScore != null) {
        total += test.enduranceScore! / 100;
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }

  Future<String> getAIInsights({
    required int totalPlayers,
    required int totalTests,
    required double avgSpeed,
    required double avgEndurance,
    required String bestPerformerName,
    required String trend,
  }) async {
    try {
      final prompt = '''
You are an expert football coach AI. Analyze this team's performance and provide EXACTLY 3 brief insights.

Team Data:
• Total Players: $totalPlayers
• Tests Completed: $totalTests
• Avg 20m Sprint: ${avgSpeed > 0 ? '${avgSpeed.toStringAsFixed(2)}s' : 'No data'}
• Avg Endurance: ${avgEndurance > 0 ? '${avgEndurance.toStringAsFixed(0)}' : 'No data'}
• Top Performer: $bestPerformerName
• Recent Trend: $trend

Provide EXACTLY 3 bullet points (max 15 words each):
1. One positive observation
2. One area needing improvement
3. One motivational suggestion

Format: Start each with • and keep under 15 words.
''';

      final response = await _groqService.getSimpleResponse(prompt);
      return response;
    } catch (e) {
      print('❌ Error getting AI insights: $e');
      return '''
• Your team is making progress! Keep up consistent training.
• Focus on improving endurance and stamina through targeted drills.
• Celebrate small wins - consistency builds champions! 🏆
''';
    }
  }

  /// Get detailed team analytics using Groq AI
  Future<String> getTeamAnalyticsReport({
    required List<Player> players,
    required List<PlayerTest> allTests,
  }) async {
    if (players.isEmpty) {
      return 'Add players to your team to generate analytics reports.';
    }

    try {
      // Calculate metrics
      final avgAge =
          (players.map((p) => p.age).reduce((a, b) => a + b) / players.length)
              .round();
      final avgSpeed = calculateTeamAverage(allTests, 'speed20m');
      final avgEndurance = calculateTeamAverage(allTests, 'endurance');
      final bestPerformer = findBestPerformer(players, allTests);

      // Build metrics map for Groq
      final latestMetrics = {
        'Total Players': players.length,
        'Average Age': '$avgAge years',
        'Total Tests': allTests.length,
        'Average 20m Sprint':
            avgSpeed > 0 ? '${avgSpeed.toStringAsFixed(2)}s' : 'No data',
        'Average Endurance':
            avgEndurance > 0 ? '${avgEndurance.toStringAsFixed(0)}' : 'No data',
        'Best Performer': bestPerformer['player']?.name ?? 'N/A',
      };

      // Use the existing analyzePlayerPerformance method but for team
      final analysis = await _groqService.analyzePlayerPerformance(
        playerName: 'Team Analysis',
        age: avgAge,
        position: 'Full Squad',
        latestMetrics: latestMetrics,
        previousMetrics: null,
      );

      return analysis;
    } catch (e) {
      print('❌ Error generating team report: $e');

      // Return manual analysis as fallback
      final avgAge =
          (players.map((p) => p.age).reduce((a, b) => a + b) / players.length)
              .round();

      return '''
📊 Team Performance Report

Overall Assessment:
Your team of ${players.length} players (avg age: $avgAge) is progressing well. ${allTests.length} tests have been completed, providing valuable performance data.

Key Strengths:
• Consistent test participation showing team commitment
• Diverse player roster enabling tactical flexibility
• Data-driven approach to performance tracking

Areas for Improvement:
• Increase test frequency for better progress tracking
• Focus on balanced training across all performance metrics
• Ensure all players complete baseline assessments

Training Focus:
• Schedule regular testing sessions (weekly/bi-weekly)
• Target specific weaknesses identified in test results
• Celebrate improvements to boost team morale

Keep up the great work! 🏆
''';
    }
  }

  /// Get position-specific insights
  Map<String, int> getPositionDistribution(List<Player> players) {
    final distribution = <String, int>{};

    for (var player in players) {
      final position = player.position ?? 'Unassigned';
      distribution[position] = (distribution[position] ?? 0) + 1;
    }

    return distribution;
  }

  /// Calculate test completion rate
  double getTestCompletionRate(
      List<Player> players, List<PlayerTest> allTests) {
    if (players.isEmpty) return 0;

    final playersWithTests = allTests.map((t) => t.playerId).toSet().length;
    return (playersWithTests / players.length) * 100;
  }

  /// Get recent activity count (last 7 days)
  int getRecentActivityCount(List<PlayerTest> allTests) {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return allTests.where((test) => test.testDate.isAfter(weekAgo)).length;
  }
}

final analyticsService = AnalyticsService();
