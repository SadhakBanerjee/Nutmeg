import 'package:flutter/material.dart';
import 'package:nutmeg/screens/tests/edit_test_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/player_test_model.dart';
import '../../providers/player_test_provider.dart';
import '../../theme/app_colors.dart';

/// Screen showing detailed test results
class TestDetailScreen extends StatefulWidget {
  final String testId;
  final String playerId;

  const TestDetailScreen({
    super.key,
    required this.testId,
    required this.playerId,
  });

  @override
  State<TestDetailScreen> createState() => _TestDetailScreenState();
}

class _TestDetailScreenState extends State<TestDetailScreen> {
  PlayerTest? _currentTest;
  PlayerTest? _previousTest;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    setState(() => _isLoading = true);

    final testProvider = context.read<PlayerTestProvider>();
    
    // Fetch all tests for this player
    await testProvider.fetchTestsForPlayer(widget.playerId);
    
    // Find current test
    _currentTest = testProvider.tests.firstWhere(
      (test) => test.id == widget.testId,
    );

    // Find previous test (the one before current test date)
    final allTests = testProvider.tests
        .where((test) => test.testDate.isBefore(_currentTest!.testDate))
        .toList()
      ..sort((a, b) => b.testDate.compareTo(a.testDate));

    if (allTests.isNotEmpty) {
      _previousTest = allTests.first;
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Results')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentTest == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Test Results')),
        body: const Center(child: Text('Test not found')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with gradient
          _buildAppBar(context),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Date and comparison info
                _buildHeaderCard(context),
                const SizedBox(height: AppConstants.spacingM),

                // Vitals Section
                if (_hasVitals())
                  _buildVitalsSection(context),
                if (_hasVitals())
                  const SizedBox(height: AppConstants.spacingM),

                // Speed Section
                if (_hasSpeed())
                  _buildSpeedSection(context),
                if (_hasSpeed())
                  const SizedBox(height: AppConstants.spacingM),

                // Endurance Section
                if (_currentTest!.enduranceScore != null)
                  _buildEnduranceSection(context),
                if (_currentTest!.enduranceScore != null)
                  const SizedBox(height: AppConstants.spacingM),

                // Agility Section
                if (_currentTest!.agilityScore != null)
                  _buildAgilitySection(context),
                if (_currentTest!.agilityScore != null)
                  const SizedBox(height: AppConstants.spacingM),

                // Power Section
                if (_hasPower())
                  _buildPowerSection(context),
                if (_hasPower())
                  const SizedBox(height: AppConstants.spacingM),

                // Strength Section
                if (_hasStrength())
                  _buildStrengthSection(context),
                if (_hasStrength())
                  const SizedBox(height: AppConstants.spacingM),

                // Flexibility Section
                if (_currentTest!.flexibilityCm != null)
                  _buildFlexibilitySection(context),
                if (_currentTest!.flexibilityCm != null)
                  const SizedBox(height: AppConstants.spacingM),

                // Notes Section
                if (_currentTest!.notes != null)
                  _buildNotesSection(context),
                
                const SizedBox(height: AppConstants.spacingXL),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// App Bar with gradient
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Test Results',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
  IconButton(
    icon: const Icon(Icons.edit_rounded, color: Colors.black),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditTestScreen(
            test: _currentTest!,
            playerName: 'Player', // You can get this from provider if needed
          ),
        ),
      ).then((_) {
        _loadTestData(); // Reload after edit
      });
    },
  ),
  IconButton(
    icon: const Icon(Icons.delete_rounded, color: Colors.black),
    onPressed: () => _showDeleteDialog(context),
  ),
],

    );
  }

  /// Header card with date and comparison info
  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  _currentTest!.formattedDate,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingS),
            if (_previousTest != null)
              Text(
                'Compared to previous test on ${_previousTest!.formattedDate}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              )
            else
              Text(
                'First test recorded',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
          ],
        ),
      ),
    );
  }

  /// Vitals Section
  Widget _buildVitalsSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Vitals',
      icon: Icons.favorite_rounded,
      color: AppColors.errorRed,
      metrics: [
        if (_currentTest!.restingHeartRate != null)
          _MetricData(
            label: 'Resting Heart Rate',
            current: _currentTest!.restingHeartRate!.toDouble(),
            previous: _previousTest?.restingHeartRate?.toDouble(),
            unit: 'bpm',
            lowerIsBetter: true,
          ),
        if (_currentTest!.bloodPressureSystolic != null)
          _MetricData(
            label: 'BP Systolic',
            current: _currentTest!.bloodPressureSystolic!.toDouble(),
            previous: _previousTest?.bloodPressureSystolic?.toDouble(),
            unit: 'mmHg',
            lowerIsBetter: true,
          ),
        if (_currentTest!.bloodPressureDiastolic != null)
          _MetricData(
            label: 'BP Diastolic',
            current: _currentTest!.bloodPressureDiastolic!.toDouble(),
            previous: _previousTest?.bloodPressureDiastolic?.toDouble(),
            unit: 'mmHg',
            lowerIsBetter: true,
          ),
      ],
    );
  }

  /// Speed Section
  Widget _buildSpeedSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Speed',
      icon: Icons.speed_rounded,
      color: AppColors.speedColor,
      metrics: [
        if (_currentTest!.speed10m != null)
          _MetricData(
            label: '10m Sprint',
            current: _currentTest!.speed10m!,
            previous: _previousTest?.speed10m,
            unit: 'sec',
            lowerIsBetter: true,
          ),
        if (_currentTest!.speed20m != null)
          _MetricData(
            label: '20m Sprint',
            current: _currentTest!.speed20m!,
            previous: _previousTest?.speed20m,
            unit: 'sec',
            lowerIsBetter: true,
          ),
      ],
    );
  }

  /// Endurance Section
  Widget _buildEnduranceSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Endurance',
      icon: Icons.directions_run_rounded,
      color: AppColors.enduranceColor,
      metrics: [
        _MetricData(
          label: 'Endurance Score',
          current: _currentTest!.enduranceScore!,
          previous: _previousTest?.enduranceScore,
          unit: 'score',
          lowerIsBetter: false,
        ),
      ],
    );
  }

  /// Agility Section
  Widget _buildAgilitySection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Agility',
      icon: Icons.alt_route_rounded,
      color: AppColors.agilityColor,
      metrics: [
        _MetricData(
          label: 'Agility Score',
          current: _currentTest!.agilityScore!,
          previous: _previousTest?.agilityScore,
          unit: 'sec',
          lowerIsBetter: true,
        ),
      ],
    );
  }

  /// Power Section
  Widget _buildPowerSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Power',
      icon: Icons.fitness_center_rounded,
      color: AppColors.strengthColor,
      metrics: [
        if (_currentTest!.jumpHeightCm != null)
          _MetricData(
            label: 'Vertical Jump',
            current: _currentTest!.jumpHeightCm!.toDouble(),
            previous: _previousTest?.jumpHeightCm?.toDouble(),
            unit: 'cm',
            lowerIsBetter: false,
          ),
        if (_currentTest!.longJumpCm != null)
          _MetricData(
            label: 'Long Jump',
            current: _currentTest!.longJumpCm!.toDouble(),
            previous: _previousTest?.longJumpCm?.toDouble(),
            unit: 'cm',
            lowerIsBetter: false,
          ),
      ],
    );
  }

  /// Strength Section
  Widget _buildStrengthSection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Strength',
      icon: Icons.sports_kabaddi_rounded,
      color: AppColors.strengthColor,
      metrics: [
        if (_currentTest!.pushupsCount != null)
          _MetricData(
            label: 'Push-ups',
            current: _currentTest!.pushupsCount!.toDouble(),
            previous: _previousTest?.pushupsCount?.toDouble(),
            unit: 'reps',
            lowerIsBetter: false,
          ),
        if (_currentTest!.situpsCount != null)
          _MetricData(
            label: 'Sit-ups',
            current: _currentTest!.situpsCount!.toDouble(),
            previous: _previousTest?.situpsCount?.toDouble(),
            unit: 'reps',
            lowerIsBetter: false,
          ),
        if (_currentTest!.plankSeconds != null)
          _MetricData(
            label: 'Plank Hold',
            current: _currentTest!.plankSeconds!.toDouble(),
            previous: _previousTest?.plankSeconds?.toDouble(),
            unit: 'sec',
            lowerIsBetter: false,
          ),
      ],
    );
  }

  /// Flexibility Section
  Widget _buildFlexibilitySection(BuildContext context) {
    return _buildSection(
      context,
      title: 'Flexibility',
      icon: Icons.self_improvement_rounded,
      color: AppColors.infoBlue,
      metrics: [
        _MetricData(
          label: 'Sit & Reach',
          current: _currentTest!.flexibilityCm!.toDouble(),
          previous: _previousTest?.flexibilityCm?.toDouble(),
          unit: 'cm',
          lowerIsBetter: false,
        ),
      ],
    );
  }

  /// Notes Section
  Widget _buildNotesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.note_rounded,
                  color: AppColors.primaryYellow,
                  size: 20,
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              _currentTest!.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Generic section builder
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required List<_MetricData> metrics,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingS),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: AppConstants.spacingS),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...metrics.map((metric) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                  child: _MetricRow(metric: metric),
                )),
          ],
        ),
      ),
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Test'),
        content: const Text(
          'Are you sure you want to delete this test? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<PlayerTestProvider>()
          .deleteTest(widget.testId);

      if (!mounted) return;

      if (success) {
        Navigator.pop(context); // Go back to player detail
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Test deleted successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to delete test'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  // Helper methods
  bool _hasVitals() {
    return _currentTest!.restingHeartRate != null ||
        _currentTest!.bloodPressureSystolic != null ||
        _currentTest!.bloodPressureDiastolic != null;
  }

  bool _hasSpeed() {
    return _currentTest!.speed10m != null || _currentTest!.speed20m != null;
  }

  bool _hasPower() {
    return _currentTest!.jumpHeightCm != null ||
        _currentTest!.longJumpCm != null;
  }

  bool _hasStrength() {
    return _currentTest!.pushupsCount != null ||
        _currentTest!.situpsCount != null ||
        _currentTest!.plankSeconds != null;
  }
}

/// Data class for metric comparison
class _MetricData {
  final String label;
  final double current;
  final double? previous;
  final String unit;
  final bool lowerIsBetter;

  _MetricData({
    required this.label,
    required this.current,
    required this.previous,
    required this.unit,
    required this.lowerIsBetter,
  });

  double? get change {
    if (previous == null) return null;
    return current - previous!;
  }

  double? get percentChange {
    if (previous == null || previous == 0) return null;
    return ((current - previous!) / previous!) * 100;
  }

  bool get isImprovement {
    if (change == null) return false;
    return lowerIsBetter ? change! < 0 : change! > 0;
  }
}

/// Widget displaying a single metric row with comparison
class _MetricRow extends StatelessWidget {
  final _MetricData metric;

  const _MetricRow({required this.metric});

  @override
  Widget build(BuildContext context) {
    final hasComparison = metric.previous != null;
    final isImprovement = metric.isImprovement;
    final change = metric.change;
    final percentChange = metric.percentChange;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: hasComparison
            ? Border.all(
                color: (isImprovement
                        ? AppColors.successGreen
                        : AppColors.errorRed)
                    .withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metric.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${metric.current.toStringAsFixed(metric.current == metric.current.toInt() ? 0 : 1)} ${metric.unit}',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (hasComparison) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(
                  isImprovement
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: isImprovement
                      ? AppColors.successGreen
                      : AppColors.errorRed,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  '${change! > 0 ? '+' : ''}${change.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isImprovement
                            ? AppColors.successGreen
                            : AppColors.errorRed,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (percentChange != null)
                  Text(
                    '${percentChange > 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isImprovement
                              ? AppColors.successGreen
                              : AppColors.errorRed,
                          fontSize: 11,
                        ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
