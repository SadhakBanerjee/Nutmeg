import 'package:groq/groq.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Singleton service for Groq AI integration
class GroqService {
  static final GroqService _instance = GroqService._internal();
  factory GroqService() => _instance;
  GroqService._internal();

  late final Groq _groq;
  bool _isInitialized = false;

  /// Initialize Groq with API key
  void initialize() {
    if (_isInitialized) return;

    final apiKey = dotenv.env['GROQ_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY not found in .env file');
    }

    final configuration = Configuration(
      model: 'llama-3.3-70b-versatile', // Fast and powerful model
      temperature: 0.7,
      maxCompletionTokens: 1024,
    );

    _groq = Groq(
      apiKey: apiKey,
      configuration: configuration,
    );

    _groq.startChat();
    _isInitialized = true;

    print('✅ Groq AI initialized successfully');
  }

  /// Get AI analysis for player performance
  Future<String> analyzePlayerPerformance({
    required String playerName,
    required int age,
    required String position,
    required Map<String, dynamic> latestMetrics,
    required Map<String, dynamic>? previousMetrics,
  }) async {
    if (!_isInitialized) {
      throw Exception('Groq service not initialized');
    }

    final prompt = _buildPerformancePrompt(
      playerName: playerName,
      age: age,
      position: position,
      latestMetrics: latestMetrics,
      previousMetrics: previousMetrics,
    );

    try {
      final response = await _groq.sendMessage(prompt);
      return response.choices.first.message.content;
    } catch (e) {
      print('❌ Error getting AI analysis: $e');
      throw Exception('Failed to get AI analysis: $e');
    }
  }

  /// Get simple AI response for any prompt
  Future<String> getSimpleResponse(String prompt) async {
    if (!_isInitialized) {
      throw Exception('Groq service not initialized');
    }

    try {
      final response = await _groq.sendMessage(prompt);
      return response.choices.first.message.content;
    } catch (e) {
      print('❌ Error getting AI response: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }

  /// Get training recommendations
  Future<String> getTrainingRecommendations({
    required String playerName,
    required Map<String, dynamic> strengths,
    required Map<String, dynamic> weaknesses,
  }) async {
    if (!_isInitialized) {
      throw Exception('Groq service not initialized');
    }

    final prompt = '''
You are an expert football/soccer coach. Analyze the player's performance data and provide specific training recommendations.

Player: $playerName

Strengths:
${strengths.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Areas for Improvement:
${weaknesses.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Provide:
1. 3-5 specific training exercises to improve weaknesses
2. How to maintain current strengths
3. Estimated timeline for improvements
4. Weekly training schedule suggestion

Keep it concise, actionable, and motivating. Use bullet points.
''';

    try {
      final response = await _groq.sendMessage(prompt);
      return response.choices.first.message.content;
    } catch (e) {
      print('❌ Error getting training recommendations: $e');
      throw Exception('Failed to get training recommendations: $e');
    }
  }

  /// Get injury risk assessment
  Future<String> getInjuryRiskAssessment({
    required String playerName,
    required int age,
    required Map<String, dynamic> vitalMetrics,
    required Map<String, dynamic> performanceMetrics,
  }) async {
    if (!_isInitialized) {
      throw Exception('Groq service not initialized');
    }

    final prompt = '''
You are a sports medicine expert. Assess injury risk based on player data.

Player: $playerName (Age: $age)

Vital Signs:
${vitalMetrics.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Performance Metrics:
${performanceMetrics.entries.map((e) => '- ${e.key}: ${e.value}').join('\n')}

Provide:
1. Overall injury risk level (Low/Medium/High)
2. Specific areas of concern
3. Preventive measures
4. Recovery recommendations

Be professional but clear. Use medical knowledge but explain in coach-friendly terms.
''';

    try {
      final response = await _groq.sendMessage(prompt);
      return response.choices.first.message.content;
    } catch (e) {
      print('❌ Error getting injury risk assessment: $e');
      throw Exception('Failed to get injury risk assessment: $e');
    }
  }

  /// Build performance analysis prompt
  String _buildPerformancePrompt({
    required String playerName,
    required int age,
    required String position,
    required Map<String, dynamic> latestMetrics,
    required Map<String, dynamic>? previousMetrics,
  }) {
    final buffer = StringBuffer();

    buffer.writeln(
        'You are an expert football/soccer coach analyzing player performance data.');
    buffer.writeln('');
    buffer.writeln('Player Profile:');
    buffer.writeln('- Name: $playerName');
    buffer.writeln('- Age: $age');
    buffer.writeln('- Position: $position');
    buffer.writeln('');
    buffer.writeln('Latest Test Results:');

    for (var entry in latestMetrics.entries) {
      buffer.writeln('- ${entry.key}: ${entry.value}');
    }

    if (previousMetrics != null) {
      buffer.writeln('');
      buffer.writeln('Previous Test Results (for comparison):');
      for (var entry in previousMetrics.entries) {
        buffer.writeln('- ${entry.key}: ${entry.value}');
      }
    }

    buffer.writeln('');
    buffer.writeln('Provide a comprehensive analysis including:');
    buffer.writeln(
        '1. Overall performance rating (Excellent/Good/Average/Needs Improvement)');
    buffer.writeln('2. Key strengths (2-3 points)');
    buffer.writeln('3. Areas for improvement (2-3 points)');
    buffer.writeln('4. Progress compared to previous test (if available)');
    buffer.writeln('5. Position-specific insights');
    buffer.writeln('6. Next steps and focus areas');
    buffer.writeln('');
    buffer.writeln(
        'Keep it motivating, specific, and actionable. Use bullet points and emojis.');

    return buffer.toString();
  }

  /// Clear chat history (for new analysis)
  void clearChat() {
    if (_isInitialized) {
      _groq.clearChat();
    }
  }
}

// Global instance
final groqService = GroqService();
