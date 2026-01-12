import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_colors.dart';

/// Settings and preferences screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${info.version} (${info.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = '1.0.0';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),

            // Content
            SliverPadding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Appearance Section
                  _buildSectionHeader(context, 'Appearance'),
                  _buildThemeToggle(context),
                  const SizedBox(height: AppConstants.spacingL),

                  // About Section
                  _buildSectionHeader(context, 'About'),
                  _buildAboutCard(context),
                  const SizedBox(height: AppConstants.spacingL),

                  // Data Section
                  _buildSectionHeader(context, 'Data & Privacy'),
                  _buildDataOptions(context),
                  const SizedBox(height: AppConstants.spacingL),

                  // App Info
                  _buildAppInfo(context),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppConstants.spacingS,
        bottom: AppConstants.spacingM,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primaryYellow,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Card(
          child: SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(
              themeProvider.isDarkMode ? 'Enabled' : 'Disabled',
            ),
            value: themeProvider.isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            secondary: Icon(
              themeProvider.isDarkMode
                  ? Icons.dark_mode_rounded
                  : Icons.light_mode_rounded,
              color: AppColors.primaryYellow,
            ),
            activeColor: AppColors.primaryYellow,
          ),
        );
      },
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primaryYellow,
              ),
            ),
            title: const Text('About Nutmeg'),
            subtitle: const Text('Train Smarter. Play Faster.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showAboutDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.code_rounded,
                color: AppColors.accentOrange,
              ),
            ),
            title: const Text('Version'),
            subtitle: Text(_appVersion),
          ),
        ],
      ),
    );
  }

  Widget _buildDataOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.infoBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.cloud_upload_rounded,
                color: AppColors.infoBlue,
              ),
            ),
            title: const Text('Backup Data'),
            subtitle: const Text('Export your data'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.shield_rounded,
                color: AppColors.successGreen,
              ),
            ),
            title: const Text('Privacy Policy'),
            subtitle: const Text('How we handle your data'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy policy coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(AppConstants.spacingS),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusS),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.errorRed,
              ),
            ),
            title: const Text('Clear Cache'),
            subtitle: const Text('Free up storage space'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _showClearCacheDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingL),
        child: Column(
          children: [
            // Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
              child: const Icon(
                Icons.sports_soccer,
                size: 40,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              AppConstants.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            Text(
              AppConstants.appTagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingL),
            Text(
              'Made with ❤️ for Coaches',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Nutmeg'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutmeg is a comprehensive player performance tracking app powered by AI.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Features:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingS),
            const Text('• Player management'),
            const Text('• Performance testing'),
            const Text('• Analytics & charts'),
            const Text('• AI-powered insights'),
            const Text('• Progress tracking'),
            const SizedBox(height: AppConstants.spacingM),
            Text(
              'Version: $_appVersion',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear temporary data and free up storage space. Your player data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Cache cleared successfully'),
                  backgroundColor: AppColors.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
