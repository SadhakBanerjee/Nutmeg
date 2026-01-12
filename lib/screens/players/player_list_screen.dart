import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_colors.dart';
import '../../models/player_model.dart';
import 'player_detail_screen.dart';

/// Screen showing list of all players
class PlayerListScreen extends StatefulWidget {
  const PlayerListScreen({super.key});

  @override
  State<PlayerListScreen> createState() => _PlayerListScreenState();
}

class _PlayerListScreenState extends State<PlayerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedPosition;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with search
            _buildHeader(context, width, height),
            // Filter chips
            _buildFilterChips(context, width, height),
            // Player list
            Expanded(
              child: _buildPlayerList(context, width, height),
            ),
          ],
        ),
      ),
    );
  }

  /// Header with title and search bar - responsive
  Widget _buildHeader(BuildContext context, double width, double height) {
    return Padding(
      padding: EdgeInsets.all(width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Players',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: width * 0.065,
                ),
          ),
          SizedBox(height: height * 0.015),
          // Search bar with yellow accent
          TextField(
            controller: _searchController,
            onChanged: (value) {
              if (value.isEmpty) {
                context.read<PlayerProvider>().fetchPlayers();
              } else {
                context.read<PlayerProvider>().searchPlayers(value);
              }
            },
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: width * 0.038,
            ),
            decoration: InputDecoration(
              hintText: 'Search players...',
              hintStyle: TextStyle(fontSize: width * 0.036),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.primaryYellow,
                size: width * 0.06,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: AppColors.textTertiary,
                        size: width * 0.055,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        context.read<PlayerProvider>().fetchPlayers();
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Filter chips for positions - responsive
  Widget _buildFilterChips(BuildContext context, double width, double height) {
    return SizedBox(
      height: height * 0.06,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        children: [
          _FilterChip(
            label: 'All',
            isSelected: _selectedPosition == null,
            onTap: () {
              setState(() => _selectedPosition = null);
              context.read<PlayerProvider>().fetchPlayers();
            },
            width: width,
          ),
          ...AppConstants.positions.map((position) {
            return _FilterChip(
              label: position,
              isSelected: _selectedPosition == position,
              onTap: () {
                setState(() => _selectedPosition = position);
                context.read<PlayerProvider>().filterByPosition(position);
              },
              width: width,
            );
          }),
        ],
      ),
    );
  }

  /// Player list with loading and empty states - responsive
  Widget _buildPlayerList(BuildContext context, double width, double height) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        // Loading state
        if (playerProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Error state
        if (playerProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(width * 0.05),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: width * 0.16,
                    color: AppColors.errorRed,
                  ),
                  SizedBox(height: height * 0.02),
                  Text(
                    'Error loading players',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: width * 0.048,
                        ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    playerProvider.errorMessage!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: width * 0.036,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.03),
                  ElevatedButton.icon(
                    onPressed: () => playerProvider.fetchPlayers(),
                    icon: Icon(Icons.refresh_rounded, size: width * 0.05),
                    label: Text('Retry',
                        style: TextStyle(fontSize: width * 0.038)),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.05,
                        vertical: height * 0.015,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Empty state
        if (!playerProvider.hasPlayers) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: width * 0.2,
                  color: AppColors.primaryYellow.withValues(alpha: 0.3),
                ),
                SizedBox(height: height * 0.025),
                Text(
                  'No players yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontSize: width * 0.052,
                      ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Add your first player to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: width * 0.038,
                      ),
                ),
              ],
            ),
          );
        }

        // Player list
        return RefreshIndicator(
          color: AppColors.primaryYellow,
          onRefresh: () => playerProvider.fetchPlayers(),
          child: ListView.builder(
            padding: EdgeInsets.all(width * 0.04),
            itemCount: playerProvider.players.length,
            itemBuilder: (context, index) {
              final player = playerProvider.players[index];
              return _PlayerCard(
                player: player,
                width: width,
                height: height,
              );
            },
          ),
        );
      },
    );
  }
}

/// Filter chip widget - responsive
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: width * 0.02),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(fontSize: width * 0.034),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: AppColors.cardBackground,
        selectedColor: AppColors.primaryYellow.withValues(alpha: 0.2),
        checkmarkColor: AppColors.primaryYellow,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryYellow : AppColors.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: width * 0.034,
        ),
        side: BorderSide(
          color: isSelected ? AppColors.primaryYellow : AppColors.cardBorder,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.03,
          vertical: width * 0.02,
        ),
      ),
    );
  }
}

/// Player card widget - responsive
class _PlayerCard extends StatelessWidget {
  final Player player;
  final double width;
  final double height;

  const _PlayerCard({
    required this.player,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: height * 0.015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.03),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlayerDetailScreen(playerId: player.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(width * 0.03),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            children: [
              // Avatar - YELLOW BACKGROUND
              CircleAvatar(
                radius: width * 0.08,
                backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.2),
                child: Text(
                  player.name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: width * 0.065,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryYellow,
                  ),
                ),
              ),
              SizedBox(width: width * 0.04),

              // Player info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: width * 0.042,
                          ),
                    ),
                    SizedBox(height: height * 0.005),
                    Row(
                      children: [
                        _InfoChip(
                          icon: Icons.cake_rounded,
                          label: '${player.age} yrs',
                          width: width,
                        ),
                        SizedBox(width: width * 0.02),
                        if (player.position != null)
                          _InfoChip(
                            icon: Icons.sports_soccer_rounded,
                            label: player.position!,
                            width: width,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow icon - YELLOW
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryYellow,
                size: width * 0.065,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small info chip widget - responsive
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final double width;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: width * 0.035,
          color: AppColors.textTertiary,
        ),
        SizedBox(width: width * 0.01),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontSize: width * 0.032,
              ),
        ),
      ],
    );
  }
}
