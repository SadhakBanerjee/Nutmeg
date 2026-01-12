import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_test_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/player_test_model.dart';

/// Analytics dashboard with charts and statistics
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String? _selectedPlayerId;
  String _selectedMetric = 'speed10m';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load players on init
      context.read<PlayerProvider>().fetchPlayers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              backgroundColor: Colors.transparent,
              title: Text(
                'Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.06,
                    ),
              ),
            ),
            // Content
            SliverPadding(
              padding: EdgeInsets.all(width * 0.04),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Player selector
                  _buildPlayerSelector(context, width, height),
                  SizedBox(height: height * 0.02),

                  if (_selectedPlayerId != null) ...[
                    // Metric selector
                    _buildMetricSelector(context, width, height),
                    SizedBox(height: height * 0.02),

                    // Progress chart
                    _buildProgressChart(context, width, height),
                    SizedBox(height: height * 0.02),

                    // Statistics cards
                    _buildStatisticsCards(context, width, height),
                    SizedBox(height: height * 0.02),

                    // Performance radar chart
                    _buildRadarChart(context, width, height),
                  ] else
                    _buildEmptyState(context, width, height),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Player selector dropdown - responsive
  Widget _buildPlayerSelector(
      BuildContext context, double width, double height) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        if (!playerProvider.hasPlayers) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.06),
              child: Center(
                child: Text(
                  'No players available. Add players first.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: width * 0.038,
                      ),
                ),
              ),
            ),
          );
        }

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryYellow,
                      size: width * 0.055,
                    ),
                    SizedBox(width: width * 0.025),
                    Text(
                      'Select Player',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.042,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.015),
                DropdownButtonFormField<String>(
                  value: _selectedPlayerId,
                  hint: Text(
                    'Choose a player to analyze',
                    style: TextStyle(fontSize: width * 0.036),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.people_rounded, size: width * 0.055),
                  ),
                  items: playerProvider.players.map((player) {
                    return DropdownMenuItem(
                      value: player.id,
                      child: Text(
                        player.name,
                        style: TextStyle(fontSize: width * 0.038),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPlayerId = value;
                    });
                    if (value != null) {
                      context
                          .read<PlayerTestProvider>()
                          .fetchTestsForPlayer(value);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Metric selector chips - responsive
  Widget _buildMetricSelector(
      BuildContext context, double width, double height) {
    final metrics = {
      'speed10m': {'label': '10m Sprint', 'icon': Icons.speed_rounded},
      'speed20m': {'label': '20m Sprint', 'icon': Icons.flash_on_rounded},
      'endurance': {'label': 'Endurance', 'icon': Icons.directions_run_rounded},
      'vertical_jump': {
        'label': 'Vertical Jump',
        'icon': Icons.arrow_upward_rounded
      },
      'pushups': {'label': 'Push-ups', 'icon': Icons.fitness_center_rounded},
    };

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primaryYellow,
                  size: width * 0.055,
                ),
                SizedBox(width: width * 0.025),
                Text(
                  'Select Metric',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: width * 0.042,
                      ),
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            Wrap(
              spacing: width * 0.02,
              runSpacing: height * 0.01,
              children: metrics.entries.map((entry) {
                final isSelected = _selectedMetric == entry.key;
                return FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.value['icon'] as IconData,
                        size: width * 0.04,
                        color: isSelected
                            ? AppColors.primaryYellow
                            : AppColors.textSecondary,
                      ),
                      SizedBox(width: width * 0.015),
                      Text(
                        entry.value['label'] as String,
                        style: TextStyle(fontSize: width * 0.032),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedMetric = entry.key;
                    });
                  },
                  backgroundColor: AppColors.cardBackground,
                  selectedColor: AppColors.primaryYellow.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primaryYellow,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? AppColors.primaryYellow
                        : AppColors.textSecondary,
                    fontSize: width * 0.032,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryYellow
                        : AppColors.cardBorder,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.03,
                    vertical: height * 0.008,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Progress line chart - responsive
  Widget _buildProgressChart(
      BuildContext context, double width, double height) {
    return Consumer<PlayerTestProvider>(
      builder: (context, testProvider, child) {
        if (testProvider.isLoading) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(width * 0.08),
              child: const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!testProvider.hasTests) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.08),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.show_chart_rounded,
                      size: width * 0.12,
                      color: AppColors.primaryYellow.withValues(alpha: 0.3),
                    ),
                    SizedBox(height: height * 0.015),
                    Text(
                      'No test data yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: width * 0.042,
                          ),
                    ),
                    SizedBox(height: height * 0.008),
                    Text(
                      'Add tests to see progress charts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: width * 0.032,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final chartData = _getChartData(testProvider.tests);

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.primaryYellow,
                      size: width * 0.055,
                    ),
                    SizedBox(width: width * 0.025),
                    Text(
                      'Progress Over Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.042,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: height * 0.3,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.cardBorder,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: width * 0.1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toStringAsFixed(1),
                                style: TextStyle(fontSize: width * 0.028),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: height * 0.04,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= chartData.length)
                                return const Text('');
                              return Text(
                                'Test ${value.toInt() + 1}',
                                style: TextStyle(fontSize: width * 0.028),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: chartData,
                          isCurved: true,
                          color: AppColors.primaryYellow,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: width * 0.01,
                                color: AppColors.primaryYellow,
                                strokeWidth: 2,
                                strokeColor: AppColors.background,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color:
                                AppColors.primaryYellow.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Statistics cards - responsive
  Widget _buildStatisticsCards(
      BuildContext context, double width, double height) {
    return Consumer<PlayerTestProvider>(
      builder: (context, testProvider, child) {
        if (!testProvider.hasTests) return const SizedBox.shrink();

        final stats = _calculateStatistics(testProvider.tests);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: width * 0.048,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: height * 0.015),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Best',
                    value: stats['best']!.toStringAsFixed(1),
                    icon: Icons.star_rounded,
                    color: AppColors.successGreen,
                    width: width,
                    height: height,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _StatCard(
                    label: 'Average',
                    value: stats['average']!.toStringAsFixed(1),
                    icon: Icons.show_chart_rounded,
                    color: AppColors.primaryYellow,
                    width: width,
                    height: height,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.015),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Latest',
                    value: stats['latest']!.toStringAsFixed(1),
                    icon: Icons.schedule_rounded,
                    color: AppColors.infoBlue,
                    width: width,
                    height: height,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _StatCard(
                    label: 'Improvement',
                    value:
                        '${stats['improvement']! > 0 ? '+' : ''}${stats['improvement']!.toStringAsFixed(1)}%',
                    icon: stats['improvement']! > 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: stats['improvement']! > 0
                        ? AppColors.successGreen
                        : AppColors.errorRed,
                    width: width,
                    height: height,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Performance radar chart - responsive
  Widget _buildRadarChart(BuildContext context, double width, double height) {
    return Consumer<PlayerTestProvider>(
      builder: (context, testProvider, child) {
        if (!testProvider.hasTests) return const SizedBox.shrink();

        final latestTest = testProvider.tests.first;
        final radarData = _getRadarData(latestTest);

        if (radarData.isEmpty) return const SizedBox.shrink();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.045),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.radar_rounded,
                      color: AppColors.primaryYellow,
                      size: width * 0.055,
                    ),
                    SizedBox(width: width * 0.025),
                    Text(
                      'Latest Performance Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: width * 0.042,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.02),
                SizedBox(
                  height: height * 0.35,
                  child: RadarChart(
                    RadarChartData(
                      radarShape: RadarShape.polygon,
                      radarBorderData: BorderSide(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      gridBorderData: BorderSide(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      tickBorderData: BorderSide(
                        color: AppColors.cardBorder,
                        width: 1,
                      ),
                      tickCount: 5,
                      ticksTextStyle: TextStyle(fontSize: width * 0.028),
                      radarBackgroundColor: Colors.transparent,
                      getTitle: (index, angle) {
                        if (index >= radarData.length)
                          return const RadarChartTitle(text: '');
                        return RadarChartTitle(
                          text: radarData[index]['label'] as String,
                          angle: angle,
                        );
                      },
                      dataSets: [
                        RadarDataSet(
                          fillColor:
                              AppColors.primaryYellow.withValues(alpha: 0.2),
                          borderColor: AppColors.primaryYellow,
                          borderWidth: 2,
                          dataEntries: radarData
                              .map((data) =>
                                  RadarEntry(value: data['value'] as double))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Empty state when no player selected - responsive
  Widget _buildEmptyState(BuildContext context, double width, double height) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.1),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.analytics_rounded,
                size: width * 0.2,
                color: AppColors.primaryYellow.withValues(alpha: 0.3),
              ),
              SizedBox(height: height * 0.025),
              Text(
                'Select a Player',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: width * 0.05,
                    ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                'Choose a player from the dropdown above to view their analytics',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: width * 0.036,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods
  List<FlSpot> _getChartData(List<PlayerTest> tests) {
    final sortedTests = tests.toList()
      ..sort((a, b) => a.testDate.compareTo(b.testDate));

    final spots = <FlSpot>[];
    for (var i = 0; i < sortedTests.length; i++) {
      final test = sortedTests[i];
      double? value;

      switch (_selectedMetric) {
        case 'speed10m':
          value = test.speed10m;
          break;
        case 'speed20m':
          value = test.speed20m;
          break;
        case 'endurance':
          value = test.enduranceScore;
          break;
        case 'vertical_jump':
          value = test.jumpHeightCm?.toDouble();
          break;
        case 'pushups':
          value = test.pushupsCount?.toDouble();
          break;
      }

      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }
    return spots;
  }

  Map<String, double> _calculateStatistics(List<PlayerTest> tests) {
    final values = <double>[];

    for (var test in tests) {
      double? value;
      switch (_selectedMetric) {
        case 'speed10m':
          value = test.speed10m;
          break;
        case 'speed20m':
          value = test.speed20m;
          break;
        case 'endurance':
          value = test.enduranceScore;
          break;
        case 'vertical_jump':
          value = test.jumpHeightCm?.toDouble();
          break;
        case 'pushups':
          value = test.pushupsCount?.toDouble();
          break;
      }

      if (value != null) values.add(value);
    }

    if (values.isEmpty) {
      return {'best': 0, 'average': 0, 'latest': 0, 'improvement': 0};
    }

    // For speed metrics, lower is better
    final lowerIsBetter = _selectedMetric.contains('speed');
    final best = lowerIsBetter
        ? values.reduce((a, b) => a < b ? a : b)
        : values.reduce((a, b) => a > b ? a : b);
    final average = values.reduce((a, b) => a + b) / values.length;
    final latest = values.last;

    double improvement = 0;
    if (values.length > 1) {
      final first = values.first;
      improvement = ((latest - first) / first) * 100;
      if (lowerIsBetter) improvement = -improvement; // Invert for speed
    }

    return {
      'best': best,
      'average': average,
      'latest': latest,
      'improvement': improvement,
    };
  }

  List<Map<String, dynamic>> _getRadarData(PlayerTest test) {
    final data = <Map<String, dynamic>>[];

    if (test.speed10m != null) {
      data.add({'label': 'Speed', 'value': _normalizeSpeed(test.speed10m!)});
    }

    if (test.enduranceScore != null) {
      data.add({
        'label': 'Endurance',
        'value': _normalizeEndurance(test.enduranceScore!)
      });
    }

    if (test.jumpHeightCm != null) {
      data.add({'label': 'Power', 'value': _normalizeJump(test.jumpHeightCm!)});
    }

    if (test.pushupsCount != null) {
      data.add({
        'label': 'Strength',
        'value': _normalizeStrength(test.pushupsCount!)
      });
    }

    if (test.agilityScore != null) {
      data.add(
          {'label': 'Agility', 'value': _normalizeAgility(test.agilityScore!)});
    }

    return data;
  }

  // Normalization functions (convert to 0-100 scale)
  double _normalizeSpeed(double speed) {
    return ((3.0 - speed) / 1.5 * 100).clamp(0, 100);
  }

  double _normalizeEndurance(double endurance) {
    return (endurance / 2000 * 100).clamp(0, 100);
  }

  double _normalizeJump(int jump) {
    return (jump / 60 * 100).clamp(0, 100);
  }

  double _normalizeStrength(int reps) {
    return (reps / 50 * 100).clamp(0, 100);
  }

  double _normalizeAgility(double agility) {
    return ((12.0 - agility) / 5 * 100).clamp(0, 100);
  }
}

/// Stat card widget - responsive
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double width;
  final double height;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.04),
        child: Column(
          children: [
            Icon(icon, color: color, size: width * 0.07),
            SizedBox(height: height * 0.01),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: width * 0.03,
                  ),
            ),
            SizedBox(height: height * 0.005),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: width * 0.042,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
