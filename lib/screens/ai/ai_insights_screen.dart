import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/groq_service.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_test_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/player_test_model.dart';

/// AI-powered insights and recommendations screen
class AIInsightsScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  const AIInsightsScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  String? _performanceAnalysis;
  String? _trainingRecommendations;
  String? _injuryRisk;

  bool _isLoadingPerformance = false;
  bool _isLoadingTraining = false;
  bool _isLoadingInjury = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlayerTests();
  }

  Future<void> _loadPlayerTests() async {
    await context
        .read<PlayerTestProvider>()
        .fetchTestsForPlayer(widget.playerId);
  }

  Future<void> _generatePerformanceAnalysis() async {
    setState(() {
      _isLoadingPerformance = true;
      _error = null;
    });

    try {
      final testProvider = context.read<PlayerTestProvider>();
      final playerProvider = context.read<PlayerProvider>();

      if (!testProvider.hasTests) {
        setState(() {
          _error = 'No test data available for analysis';
          _isLoadingPerformance = false;
        });
        return;
      }

      final player =
          playerProvider.players.firstWhere((p) => p.id == widget.playerId);
      final latestTest = testProvider.tests.first;
      final previousTest =
          testProvider.tests.length > 1 ? testProvider.tests[1] : null;

      final latestMetrics = _extractMetrics(latestTest);
      final previousMetrics =
          previousTest != null ? _extractMetrics(previousTest) : null;

      final analysis = await groqService.analyzePlayerPerformance(
        playerName: player.name,
        age: player.age,
        position: player.position ?? 'Not specified',
        latestMetrics: latestMetrics,
        previousMetrics: previousMetrics,
      );

      setState(() {
        _performanceAnalysis = analysis;
        _isLoadingPerformance = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate analysis: $e';
        _isLoadingPerformance = false;
      });
    }
  }

  Future<void> _generateTrainingRecommendations() async {
    setState(() {
      _isLoadingTraining = true;
      _error = null;
    });

    try {
      final testProvider = context.read<PlayerTestProvider>();

      if (!testProvider.hasTests) {
        setState(() {
          _error = 'No test data available';
          _isLoadingTraining = false;
        });
        return;
      }

      final latestTest = testProvider.tests.first;
      final analysis = _analyzeStrengthsWeaknesses(latestTest);

      final recommendations = await groqService.getTrainingRecommendations(
        playerName: widget.playerName,
        strengths: analysis['strengths']!,
        weaknesses: analysis['weaknesses']!,
      );

      setState(() {
        _trainingRecommendations = recommendations;
        _isLoadingTraining = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate recommendations: $e';
        _isLoadingTraining = false;
      });
    }
  }

  Future<void> _generateInjuryRiskAssessment() async {
    setState(() {
      _isLoadingInjury = true;
      _error = null;
    });

    try {
      final testProvider = context.read<PlayerTestProvider>();
      final playerProvider = context.read<PlayerProvider>();

      if (!testProvider.hasTests) {
        setState(() {
          _error = 'No test data available';
          _isLoadingInjury = false;
        });
        return;
      }

      final player =
          playerProvider.players.firstWhere((p) => p.id == widget.playerId);
      final latestTest = testProvider.tests.first;

      final vitalMetrics = <String, dynamic>{};
      final performanceMetrics = <String, dynamic>{};

      if (latestTest.restingHeartRate != null) {
        vitalMetrics['Resting Heart Rate'] =
            '${latestTest.restingHeartRate} bpm';
      }
      if (latestTest.bloodPressureSystolic != null &&
          latestTest.bloodPressureDiastolic != null) {
        vitalMetrics['Blood Pressure'] =
            '${latestTest.bloodPressureSystolic}/${latestTest.bloodPressureDiastolic} mmHg';
      }

      if (latestTest.speed10m != null) {
        performanceMetrics['10m Sprint'] = '${latestTest.speed10m} sec';
      }
      if (latestTest.enduranceScore != null) {
        performanceMetrics['Endurance'] = '${latestTest.enduranceScore}';
      }
      if (latestTest.jumpHeightCm != null) {
        performanceMetrics['Vertical Jump'] = '${latestTest.jumpHeightCm} cm';
      }

      final assessment = await groqService.getInjuryRiskAssessment(
        playerName: player.name,
        age: player.age,
        vitalMetrics: vitalMetrics,
        performanceMetrics: performanceMetrics,
      );

      setState(() {
        _injuryRisk = assessment;
        _isLoadingInjury = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to generate assessment: $e';
        _isLoadingInjury = false;
      });
    }
  }

  Map<String, dynamic> _extractMetrics(PlayerTest test) {
    final metrics = <String, dynamic>{};

    if (test.speed10m != null) metrics['10m Sprint'] = '${test.speed10m} sec';
    if (test.speed20m != null) metrics['20m Sprint'] = '${test.speed20m} sec';
    if (test.enduranceScore != null) {
      metrics['Endurance Score'] = '${test.enduranceScore}';
    }
    if (test.agilityScore != null) {
      metrics['Agility Score'] = '${test.agilityScore} sec';
    }
    if (test.jumpHeightCm != null) {
      metrics['Vertical Jump'] = '${test.jumpHeightCm} cm';
    }
    if (test.pushupsCount != null) {
      metrics['Push-ups'] = '${test.pushupsCount} reps';
    }
    if (test.situpsCount != null) {
      metrics['Sit-ups'] = '${test.situpsCount} reps';
    }
    if (test.plankSeconds != null) {
      metrics['Plank Hold'] = '${test.plankSeconds} sec';
    }

    return metrics;
  }

  Map<String, Map<String, dynamic>> _analyzeStrengthsWeaknesses(
      PlayerTest test) {
    // Simple analysis - you can make this more sophisticated
    final strengths = <String, dynamic>{};
    final weaknesses = <String, dynamic>{};

    if (test.speed10m != null) {
      if (test.speed10m! < 2.0) {
        strengths['Speed'] = 'Excellent 10m sprint time';
      } else if (test.speed10m! > 2.5) {
        weaknesses['Speed'] = 'Needs improvement in sprint speed';
      }
    }

    if (test.enduranceScore != null) {
      if (test.enduranceScore! > 1500) {
        strengths['Endurance'] = 'Great cardiovascular fitness';
      } else if (test.enduranceScore! < 1000) {
        weaknesses['Endurance'] = 'Needs work on stamina';
      }
    }

    if (test.pushupsCount != null) {
      if (test.pushupsCount! > 40) {
        strengths['Upper Body Strength'] = 'Excellent push-up performance';
      } else if (test.pushupsCount! < 25) {
        weaknesses['Upper Body Strength'] = 'Could improve upper body strength';
      }
    }

    if (strengths.isEmpty) strengths['Overall'] = 'Consistent performance';
    if (weaknesses.isEmpty) {
      weaknesses['Overall'] = 'Balanced development needed';
    }

    return {'strengths': strengths, 'weaknesses': weaknesses};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'AI Insights',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Icon(
                    Icons.psychology_rounded,
                    size: 48,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Player header
                _buildPlayerHeader(),
                const SizedBox(height: AppConstants.spacingL),

                // Error message
                if (_error != null) _buildErrorCard(),
                if (_error != null)
                  const SizedBox(height: AppConstants.spacingM),

                // Performance Analysis Section
                _buildAnalysisSection(
                  title: '📊 Performance Analysis',
                  description: 'AI-powered analysis of latest test results',
                  content: _performanceAnalysis,
                  isLoading: _isLoadingPerformance,
                  onGenerate: _generatePerformanceAnalysis,
                  icon: Icons.analytics_rounded,
                ),
                const SizedBox(height: AppConstants.spacingM),

                // Training Recommendations Section
                _buildAnalysisSection(
                  title: '💪 Training Plan',
                  description: 'Personalized training recommendations',
                  content: _trainingRecommendations,
                  isLoading: _isLoadingTraining,
                  onGenerate: _generateTrainingRecommendations,
                  icon: Icons.fitness_center_rounded,
                ),
                const SizedBox(height: AppConstants.spacingM),

                // Injury Risk Assessment Section
                _buildAnalysisSection(
                  title: '🏥 Injury Risk Assessment',
                  description: 'Preventive health insights',
                  content: _injuryRisk,
                  isLoading: _isLoadingInjury,
                  onGenerate: _generateInjuryRiskAssessment,
                  icon: Icons.health_and_safety_rounded,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.2),
              child: Text(
                widget.playerName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryYellow,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.playerName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'AI-Powered Coaching Insights',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Card(
      color: AppColors.errorRed.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.errorRed),
            const SizedBox(width: AppConstants.spacingM),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.errorRed),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSection({
    required String title,
    required String description,
    required String? content,
    required bool isLoading,
    required VoidCallback onGenerate,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryYellow, size: 24),
                const SizedBox(width: AppConstants.spacingS),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.spacingL),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppConstants.spacingM),
                      Text('AI is analyzing...'),
                    ],
                  ),
                ),
              )
            else if (content == null)
              Center(
                child: ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Generate with AI'),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: SelectableText(
                      content,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                  TextButton.icon(
                    onPressed: onGenerate,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Regenerate'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
