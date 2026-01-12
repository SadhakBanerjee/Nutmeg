import 'package:flutter/material.dart';
import 'package:nutmeg/screens/ai/ai_insights_screen.dart';
import 'package:nutmeg/screens/players/edit_player_screen.dart';
import 'package:nutmeg/screens/tests/test_detail_screen.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../providers/player_test_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/player_model.dart';
import '../tests/add_test_screen.dart';

/// Screen showing detailed player information
class PlayerDetailScreen extends StatefulWidget {
  final String playerId;

  const PlayerDetailScreen({
    super.key,
    required this.playerId,
  });

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Load player and their tests
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().selectPlayer(widget.playerId);
      context.read<PlayerTestProvider>().fetchTestsForPlayer(widget.playerId);
    });

    // Listen to scroll position for button visibility
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 100 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          final player = playerProvider.selectedPlayer;

          // Loading state
          if (player == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar with enhanced visibility
              _buildAppBar(context, player, width, height),

              // Content
              SliverPadding(
                padding: EdgeInsets.all(width * 0.04),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Basic info card
                    _buildBasicInfoCard(context, player, width, height),
                    SizedBox(height: height * 0.02),

                    // Physical stats card
                    _buildPhysicalStatsCard(context, player, width, height),
                    SizedBox(height: height * 0.02),

                    // Test history section
                    _buildTestHistorySection(context, width, height),
                    SizedBox(height: height * 0.02),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Enhanced app bar - proper spacing, no overlap
  Widget _buildAppBar(
      BuildContext context, Player player, double width, double height) {
    return SliverAppBar(
      expandedHeight: height * 0.32, // Increased for more space
      pinned: true,
      // Black background when scrolled
      backgroundColor: _isScrolled ? Colors.black : Colors.transparent,
      foregroundColor: Colors.white,
      elevation: _isScrolled ? 4 : 0,

      // Centered title styling
      centerTitle: true,

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        // Proper spacing for title - pushed down to avoid overlap
        titlePadding: EdgeInsets.only(
          left: width * 0.15,
          right: width * 0.15,
          bottom: height * 0.022, // More bottom padding
        ),
        title: _isScrolled
            ? null // Hide title when scrolled
            : Text(
                player.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.05,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      offset: const Offset(0, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Yellow gradient background
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
            ),
            // Dark overlay for better contrast
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
            // Centered content with proper spacing
            Padding(
              padding: EdgeInsets.only(
                  bottom: height * 0.08), // Space for name at bottom
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.05),

                  // Player avatar - centered
                  Container(
                    width: width * 0.28,
                    height: width * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        player.name[0].toUpperCase(),
                        style: TextStyle(
                          fontSize: width * 0.14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.6),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height:
                          height * 0.018), // Space between avatar and badges

                  // Player info badges - centered horizontally
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Age badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.035,
                          vertical: height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(width * 0.05),
                          border: Border.all(
                            color:
                                AppColors.primaryYellow.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.cake_rounded,
                              color: AppColors.primaryYellow,
                              size: width * 0.045,
                            ),
                            SizedBox(width: width * 0.015),
                            Text(
                              '${player.age} yrs',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.036,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (player.position != null) ...[
                        SizedBox(width: width * 0.03),
                        // Position badge
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.035,
                            vertical: height * 0.01,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(width * 0.05),
                            border: Border.all(
                              color: AppColors.primaryYellow
                                  .withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.sports_soccer_rounded,
                                color: AppColors.primaryYellow,
                                size: width * 0.045,
                              ),
                              SizedBox(width: width * 0.015),
                              Text(
                                player.position!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: width * 0.036,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Back button
      leading: Container(
        margin: EdgeInsets.all(width * 0.022),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: width * 0.06,
          ),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
        ),
      ),

      // Action buttons
      actions: [
        // Edit button
        Container(
          margin: EdgeInsets.all(width * 0.022),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.edit_rounded,
              color: Colors.white,
              size: width * 0.055,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditPlayerScreen(player: player),
                ),
              ).then((_) {
                context.read<PlayerProvider>().selectPlayer(widget.playerId);
              });
            },
            padding: EdgeInsets.zero,
          ),
        ),
        // Delete button
        Container(
          margin: EdgeInsets.only(
            top: width * 0.022,
            bottom: width * 0.022,
            right: width * 0.04,
            left: width * 0.022,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.errorRed.withValues(alpha: 0.6),
              width: 1.5,
            ),
          ),
          child: IconButton(
            icon: Icon(
              Icons.delete_rounded,
              color: AppColors.errorRed,
              size: width * 0.055,
            ),
            onPressed: () => _showDeleteDialog(context, player),
            padding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  /// Basic information card - responsive
  Widget _buildBasicInfoCard(
      BuildContext context, Player player, double width, double height) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryYellow,
                  size: width * 0.055,
                ),
                SizedBox(width: width * 0.025),
                Text(
                  'Basic Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: width * 0.048,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            _InfoRow(
              icon: Icons.cake_rounded,
              label: 'Age',
              value: '${player.age} years',
              width: width,
            ),
            if (player.position != null) ...[
              SizedBox(height: height * 0.015),
              _InfoRow(
                icon: Icons.sports_soccer_rounded,
                label: 'Position',
                value: player.position!,
                width: width,
              ),
            ],
            SizedBox(height: height * 0.015),
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Added',
              value: _formatDate(player.createdAt),
              width: width,
            ),
          ],
        ),
      ),
    );
  }

  /// Physical statistics card - responsive
  Widget _buildPhysicalStatsCard(
      BuildContext context, Player player, double width, double height) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.04),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.045),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.primaryYellow,
                  size: width * 0.055,
                ),
                SizedBox(width: width * 0.025),
                Text(
                  'Physical Stats',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: width * 0.048,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Height',
                    value: '${player.heightCm}',
                    unit: 'cm',
                    icon: Icons.height_rounded,
                    width: width,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: _StatBox(
                    label: 'Weight',
                    value: '${player.weightKg}',
                    unit: 'kg',
                    icon: Icons.monitor_weight_rounded,
                    width: width,
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'BMI',
                    value: player.bmi.toStringAsFixed(1),
                    unit: '',
                    icon: Icons.analytics_rounded,
                    width: width,
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(width * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(width * 0.03),
                      border: Border.all(
                        color: _getBMIColor(player.bmiCategory)
                            .withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Category',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: width * 0.032,
                                  ),
                        ),
                        SizedBox(height: height * 0.008),
                        Text(
                          player.bmiCategory,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: _getBMIColor(player.bmiCategory),
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.038,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Test history section - responsive
  Widget _buildTestHistorySection(
      BuildContext context, double width, double height) {
    return Consumer<PlayerTestProvider>(
      builder: (context, testProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment_rounded,
                  color: AppColors.primaryYellow,
                  size: width * 0.055,
                ),
                SizedBox(width: width * 0.025),
                Text(
                  'Test History',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: width * 0.048,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    final player =
                        context.read<PlayerProvider>().selectedPlayer;
                    if (player == null) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddTestScreen(
                          playerId: player.id,
                          playerName: player.name,
                        ),
                      ),
                    ).then((_) {
                      context
                          .read<PlayerTestProvider>()
                          .fetchTestsForPlayer(player.id);
                    });
                  },
                  icon: Icon(Icons.add_rounded, size: width * 0.045),
                  label: Text('Add Test',
                      style: TextStyle(fontSize: width * 0.035)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.012,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: height * 0.02),

            // AI Insights Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final player = context.read<PlayerProvider>().selectedPlayer;
                  if (player == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AIInsightsScreen(
                        playerId: player.id,
                        playerName: player.name,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.psychology_rounded, size: width * 0.05),
                label: Text('Get AI Insights',
                    style: TextStyle(fontSize: width * 0.038)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.06,
                    vertical: height * 0.015,
                  ),
                ),
              ),
            ),
            SizedBox(height: height * 0.02),

            // Test list
            if (testProvider.isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(height * 0.04),
                  child: const CircularProgressIndicator(),
                ),
              )
            else if (!testProvider.hasTests)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(width * 0.08),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.assessment_rounded,
                          size: width * 0.12,
                          color: AppColors.primaryYellow.withValues(alpha: 0.3),
                        ),
                        SizedBox(height: height * 0.02),
                        Text(
                          'No tests recorded yet',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontSize: width * 0.042,
                                  ),
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          'Add a test to start tracking performance',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: width * 0.035,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: testProvider.tests.length,
                itemBuilder: (context, index) {
                  final test = testProvider.tests[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: height * 0.01),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: width * 0.04,
                        vertical: height * 0.01,
                      ),
                      leading: CircleAvatar(
                        radius: width * 0.055,
                        backgroundColor:
                            AppColors.primaryYellow.withValues(alpha: 0.2),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          color: AppColors.primaryYellow,
                          size: width * 0.055,
                        ),
                      ),
                      title: Text(
                        test.formattedDate,
                        style: TextStyle(
                          fontSize: width * 0.04,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${_getTestMetricsCount(test)} metrics recorded',
                        style: TextStyle(fontSize: width * 0.032),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primaryYellow,
                        size: width * 0.06,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TestDetailScreen(
                              testId: test.id,
                              playerId: widget.playerId,
                            ),
                          ),
                        ).then((_) {
                          context
                              .read<PlayerTestProvider>()
                              .fetchTestsForPlayer(widget.playerId);
                        });
                      },
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteDialog(BuildContext context, Player player) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Player'),
        content: Text(
          'Are you sure you want to delete ${player.name}? This will also delete all test records.',
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
      final success =
          await context.read<PlayerProvider>().deletePlayer(player.id);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Player deleted successfully'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getBMIColor(String category) {
    switch (category) {
      case 'Normal':
        return AppColors.successGreen;
      case 'Underweight':
      case 'Overweight':
        return AppColors.primaryYellow;
      case 'Obese':
        return AppColors.errorRed;
      default:
        return AppColors.textSecondary;
    }
  }

  int _getTestMetricsCount(test) {
    int count = 0;
    if (test.speed20m != null) count++;
    if (test.speed10m != null) count++;
    if (test.enduranceScore != null) count++;
    if (test.agilityScore != null) count++;
    if (test.jumpHeightCm != null) count++;
    if (test.restingHeartRate != null) count++;
    return count;
  }
}

/// Info row widget
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final double width;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: width * 0.05, color: AppColors.primaryYellow),
        SizedBox(width: width * 0.025),
        Text(
          '$label:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontSize: width * 0.036,
              ),
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: width * 0.038,
              ),
        ),
      ],
    );
  }
}

/// Stat box widget
class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final double width;

  const _StatBox({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(width * 0.04),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(width * 0.03),
        border: Border.all(
          color: AppColors.primaryYellow.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryYellow, size: width * 0.06),
          SizedBox(height: width * 0.02),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: width * 0.032,
                ),
          ),
          SizedBox(height: width * 0.01),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryYellow,
                      fontSize: width * 0.055,
                    ),
              ),
              if (unit.isNotEmpty) ...[
                SizedBox(width: width * 0.01),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: width * 0.03,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
