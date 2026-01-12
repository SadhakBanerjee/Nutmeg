import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/analytics_service.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_test_provider.dart';
import '../../models/player_test_model.dart';
import '../players/player_list_screen.dart';
import '../analytics/analytics_screen.dart';
import '../settings/settings_screen.dart';
import '../players/add_player_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Screens for bottom navigation
  final List<Widget> _screens = const [
    HomeContent(),
    PlayerListScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load players when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().fetchPlayers();
      context.read<PlayerTestProvider>().fetchAllTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // Floating Action Button - Add Player (only on Players tab)
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPlayerScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Player'),
            )
          : null,

      // Bottom Navigation Bar with Modern Icons
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt_rounded),
            label: 'Players',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            activeIcon: Icon(Icons.leaderboard_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_suggest_outlined),
            activeIcon: Icon(Icons.settings_suggest_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

/// Enhanced Dashboard with Analytics
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String _aiInsights = 'Loading insights...';
  bool _loadingInsights = true;

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    // Wait a bit for data to load
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final playerProvider = context.read<PlayerProvider>();
    final testProvider = context.read<PlayerTestProvider>();

    final players = playerProvider.players;
    final allTests = testProvider.allTests;

    if (players.isEmpty) {
      setState(() {
        _aiInsights = 'Add players and complete tests to get AI insights!';
        _loadingInsights = false;
      });
      return;
    }

    // Calculate metrics
    final avgSpeed =
        analyticsService.calculateTeamAverage(allTests, 'speed20m');
    final avgEndurance =
        analyticsService.calculateTeamAverage(allTests, 'endurance');
    final bestPerformer = analyticsService.findBestPerformer(players, allTests);
    final trend = analyticsService.getPerformanceTrend(allTests);

    // Get AI insights
    try {
      final insights = await analyticsService.getAIInsights(
        totalPlayers: players.length,
        totalTests: allTests.length,
        avgSpeed: avgSpeed,
        avgEndurance: avgEndurance,
        bestPerformerName: bestPerformer['player']?.name ?? 'N/A',
        trend: trend,
      );

      if (mounted) {
        setState(() {
          _aiInsights = insights;
          _loadingInsights = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiInsights =
              'Unable to load AI insights. Please check your connection.';
          _loadingInsights = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;
    final horizontalPadding = width * 0.05;
    final spacing = height * 0.02;

    return Consumer2<PlayerProvider, PlayerTestProvider>(
      builder: (context, playerProvider, testProvider, child) {
        final players = playerProvider.players;
        final allTests = testProvider.allTests;
        final isLoading = playerProvider.isLoading || testProvider.isLoading;

        // Calculate metrics
        final bestPerformer =
            analyticsService.findBestPerformer(players, allTests);

        return RefreshIndicator(
          onRefresh: () async {
            await playerProvider.fetchPlayers();
            await testProvider.fetchAllTests();
            await _loadInsights();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(context, width, height, horizontalPadding, spacing),

              // Content
              SliverToBoxAdapter(
                child: isLoading
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(spacing * 2),
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Quick Stats
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    width: width,
                                    icon: Icons.people_rounded,
                                    value: '${players.length}',
                                    label: 'Players',
                                    gradient: [Colors.blue, Colors.lightBlue],
                                  ),
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    width: width,
                                    icon: Icons.assessment_rounded,
                                    value: '${allTests.length}',
                                    label: 'Tests',
                                    gradient: [
                                      Colors.orange,
                                      Colors.deepOrange
                                    ],
                                  ),
                                ),
                                SizedBox(width: width * 0.03),
                                Expanded(
                                  child: _buildStatCard(
                                    context,
                                    width: width,
                                    icon: Icons.emoji_events_rounded,
                                    value: bestPerformer['player'] != null
                                        ? '${bestPerformer['player'].name.split(' ')[0]}'
                                        : '-',
                                    label: 'Top',
                                    gradient: [Colors.amber, Colors.orange],
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: spacing * 1.5),

                            // AI Insights Card
                            _buildAIInsightsCard(context, width, height),

                            SizedBox(height: spacing * 1.2),

                            // Performance Chart
                            if (allTests.isNotEmpty)
                              _buildPerformanceChart(
                                  context, width, height, allTests),

                            SizedBox(height: spacing * 1.2),

                            // Performance Trend Line Chart - NEW
                            if (allTests.length >= 3)
                              _buildPerformanceTrendChart(
                                  context, width, height, allTests),

                            SizedBox(height: spacing * 1.2),

                            // Team Overview
                            _buildTeamOverviewCard(context, width, height,
                                playerProvider, allTests),

                            SizedBox(height: spacing * 1.2),

                            // Quick Actions
                            _buildQuickActions(context, width, players.length),

                            SizedBox(height: spacing * 1.2),

                            // Recent Players
                            _buildRecentPlayersSection(
                                context, width, spacing, playerProvider),

                            SizedBox(height: spacing * 1.2),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, double width, double height,
      double horizontalPadding, double spacing) {
    return SliverAppBar(
      expandedHeight: height * 0.15,
      floating: true,
      pinned: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            height * 0.06,
            horizontalPadding,
            spacing,
          ),
          child: Row(
            children: [
              Container(
                width: width * 0.14,
                height: width * 0.14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Icon(
                    Icons.sports_rounded,
                    size: width * 0.07,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getGreeting(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onBackground
                                .withValues(alpha: 0.7),
                            fontSize: width * 0.035,
                          ),
                    ),
                    SizedBox(height: height * 0.005),
                    Text(
                      'Coach',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: width * 0.055,
                              ),
                    ),
                  ],
                ),
              ),
              Container(
                width: width * 0.12,
                height: width * 0.12,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(Icons.notifications_outlined, size: width * 0.06),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIInsightsCard(
      BuildContext context, double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(width * 0.025),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(width * 0.025),
                ),
                child: Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: width * 0.06,
                ),
              ),
              SizedBox(width: width * 0.03),
              Text(
                'AI Insights',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.048,
                    ),
              ),
              const Spacer(),
              if (_loadingInsights)
                SizedBox(
                  width: width * 0.05,
                  height: width * 0.05,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withValues(alpha: 0.8)),
                  ),
                ),
            ],
          ),
          SizedBox(height: height * 0.02),
          Text(
            _aiInsights,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: width * 0.038,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context, double width,
      double height, List<PlayerTest> allTests) {
    if (allTests.isEmpty) return const SizedBox();

    // Count which categories have data (more meaningful)
    final speedTests = allTests.where((t) => t.speed20m != null).length;
    final enduranceTests =
        allTests.where((t) => t.enduranceScore != null).length;
    final agilityTests = allTests.where((t) => t.agilityScore != null).length;
    final strengthTests = allTests
        .where((t) => t.pushupsCount != null || t.situpsCount != null)
        .length;

    // Calculate percentages based on total tests (9 in your case)
    final totalTests = allTests.length;

    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Test Coverage',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.025,
                  vertical: height * 0.005,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(width * 0.02),
                ),
                child: Text(
                  '$totalTests tests',
                  style: TextStyle(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.01),
          Text(
            'Percentage of tests measuring each category',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: width * 0.03,
                ),
          ),
          SizedBox(height: height * 0.02),

          // Progress bars showing coverage
          _buildCoverageBar(context, width, height, 'Speed', speedTests,
              totalTests, Colors.blue),
          SizedBox(height: height * 0.015),
          _buildCoverageBar(context, width, height, 'Endurance', enduranceTests,
              totalTests, Colors.green),
          SizedBox(height: height * 0.015),
          _buildCoverageBar(context, width, height, 'Agility', agilityTests,
              totalTests, Colors.orange),
          SizedBox(height: height * 0.015),
          _buildCoverageBar(context, width, height, 'Strength', strengthTests,
              totalTests, Colors.red),
        ],
      ),
    );
  }

  Widget _buildCoverageBar(
    BuildContext context,
    double width,
    double height,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    final isComplete = count == total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: width * 0.025,
                  height: width * 0.025,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: width * 0.02),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '$count/$total',
                  style: TextStyle(
                    fontSize: width * 0.032,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: width * 0.02),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: width * 0.032,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                if (isComplete) ...[
                  SizedBox(width: width * 0.015),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: width * 0.04,
                  ),
                ],
              ],
            ),
          ],
        ),
        SizedBox(height: width * 0.015),
        Stack(
          children: [
            // Background
            Container(
              height: width * 0.02,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(width * 0.01),
              ),
            ),
            // Progress
            FractionallySizedBox(
              widthFactor: percentage / 100,
              child: Container(
                height: width * 0.02,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(width * 0.01),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

// Performance Trend Line Chart
  Widget _buildPerformanceTrendChart(BuildContext context, double width,
      double height, List<PlayerTest> allTests) {
    if (allTests.length < 3)
      return const SizedBox(); // Need at least 3 data points

    // Get last 7 tests
    final recentTests = allTests.take(7).toList().reversed.toList();

    // Calculate average score for each test
    final spots = <FlSpot>[];
    for (var i = 0; i < recentTests.length; i++) {
      final test = recentTests[i];
      double score = 0;
      int count = 0;

      // Calculate overall performance score
      if (test.speed20m != null) {
        score += (10 - test.speed20m!) * 10; // Lower is better, so invert
        count++;
      }
      if (test.enduranceScore != null) {
        score += test.enduranceScore! / 100;
        count++;
      }
      if (test.agilityScore != null) {
        score += (20 - test.agilityScore!) * 5;
        count++;
      }
      if (test.jumpHeightCm != null) {
        score += test.jumpHeightCm! / 10;
        count++;
      }

      if (count > 0) {
        spots.add(FlSpot(i.toDouble(), score / count));
      }
    }

    if (spots.isEmpty) return const SizedBox();

    return Container(
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.045,
                ),
          ),
          SizedBox(height: height * 0.01),
          Text(
            'Last ${recentTests.length} tests',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: width * 0.03,
                ),
          ),
          SizedBox(height: height * 0.02),

          // LINE CHART
          SizedBox(
            height: height * 0.2,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 10,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: EdgeInsets.only(top: width * 0.02),
                          child: Text(
                            'T${value.toInt() + 1}',
                            style: TextStyle(
                              fontSize: width * 0.028,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: width * 0.028,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (recentTests.length - 1).toDouble(),
                minY: 0,
                maxY:
                    spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.3),
                          Theme.of(context)
                              .colorScheme
                              .secondary
                              .withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, double width, String label,
      double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: width * 0.035,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: width * 0.032,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        SizedBox(height: width * 0.015),
        ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.02),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: width * 0.02,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamOverviewCard(
    BuildContext context,
    double width,
    double height,
    PlayerProvider provider,
    List<PlayerTest> allTests,
  ) {
    final avgAge = provider.players.isEmpty
        ? 0
        : (provider.players.map((p) => p.age).reduce((a, b) => a + b) /
                provider.players.length)
            .round();

    final activeThisWeek = analyticsService.getRecentActivityCount(allTests);

    return Container(
      padding: EdgeInsets.all(width * 0.06),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(width * 0.06),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Team Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.048,
                    ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: height * 0.008,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Text(
                  '${DateTime.now().year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.025),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOverviewStat(context, width, 'Total',
                  '${provider.players.length}', Icons.people_rounded),
              _buildOverviewStat(
                  context, width, 'Avg Age', '$avgAge yrs', Icons.cake_rounded),
              _buildOverviewStat(context, width, 'This Week', '$activeThisWeek',
                  Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewStat(BuildContext context, double width, String label,
      String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(width * 0.03),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(width * 0.03),
          ),
          child: Icon(icon, color: Colors.white, size: width * 0.06),
        ),
        SizedBox(height: width * 0.02),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: width * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: width * 0.03,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(
      BuildContext context, double width, int playerCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: width * 0.05,
              ),
        ),
        SizedBox(height: width * 0.04),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                width: width,
                icon: Icons.person_add_rounded,
                label: 'Add Player',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddPlayerScreen(),
                    ),
                  );
                },
              ),
            ),
            SizedBox(width: width * 0.03),
            Expanded(
              child: _buildActionButton(
                context,
                width: width,
                icon: Icons.analytics_outlined,
                label: 'View Stats',
                color: Colors.blue,
                onTap: () {
                  // Switch to analytics tab
                  final homeState =
                      context.findAncestorStateOfType<_HomeScreenState>();
                  homeState?.setState(() {
                    homeState._selectedIndex = 2;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required double width,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(width * 0.04),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: width * 0.04),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(width * 0.04),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: width * 0.08),
            SizedBox(height: width * 0.02),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: width * 0.035,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPlayersSection(BuildContext context, double width,
      double spacing, PlayerProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Players',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.05,
                  ),
            ),
            TextButton(
              onPressed: () {
                // Switch to players tab
                final homeState =
                    context.findAncestorStateOfType<_HomeScreenState>();
                homeState?.setState(() {
                  homeState._selectedIndex = 1;
                });
              },
              child: Text(
                'View all',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: width * 0.035,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: spacing * 0.8),
        if (provider.players.isEmpty)
          _buildEmptyState(context, width)
        else
          ...provider.players.take(5).map((player) => Padding(
                padding: EdgeInsets.only(bottom: width * 0.03),
                child: _buildPlayerCard(context, width, player),
              )),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, double width) {
    return Container(
      padding: EdgeInsets.all(width * 0.08),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: width * 0.15,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          SizedBox(height: width * 0.04),
          Text(
            'No players yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: width * 0.02),
          Text(
            'Add your first player to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, double width, player) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(width * 0.04),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.name[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05,
                ),
              ),
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: width * 0.04,
                      ),
                ),
                SizedBox(height: width * 0.01),
                Text(
                  '${player.age} yrs • ${player.heightCm}cm • ${player.position ?? "No position"}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                        fontSize: width * 0.032,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: width * 0.04,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required double width,
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: width * 0.04,
        horizontal: width * 0.02,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(width * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(width * 0.02),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(width * 0.03),
            ),
            child: Icon(icon, color: Colors.white, size: width * 0.06),
          ),
          SizedBox(height: width * 0.03),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: width * 0.038,
                  ),
            ),
          ),
          SizedBox(height: width * 0.01),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                  fontSize: width * 0.028,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! 👋';
    if (hour < 17) return 'Good Afternoon! 👋';
    return 'Good Evening! 👋';
  }
}
