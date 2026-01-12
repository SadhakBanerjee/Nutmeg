import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_constants.dart';
import '../../models/player_test_model.dart';
import '../../providers/player_test_provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/player_provider.dart';

/// Screen to add new test results for a player
class AddTestScreen extends StatefulWidget {
  final String playerId;
  final String playerName;

  const AddTestScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<AddTestScreen> createState() => _AddTestScreenState();
}

class _AddTestScreenState extends State<AddTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  DateTime _testDate = DateTime.now();

  // Vitals Controllers
  final _restingHRController = TextEditingController();
  final _bpSystolicController = TextEditingController();
  final _bpDiastolicController = TextEditingController();

  // Speed Controllers
  final _speed10mController = TextEditingController();
  final _speed20mController = TextEditingController();

  // Endurance Controller
  final _enduranceController = TextEditingController();

  // Agility Controller
  final _agilityController = TextEditingController();

  // Power Controllers
  final _verticalJumpController = TextEditingController();
  final _longJumpController = TextEditingController();

  // Strength Controllers
  final _pushupsController = TextEditingController();
  final _situpsController = TextEditingController();
  final _plankController = TextEditingController();

  // Flexibility Controller
  final _flexibilityController = TextEditingController();

  // Notes Controller
  final _notesController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _restingHRController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _speed10mController.dispose();
    _speed20mController.dispose();
    _enduranceController.dispose();
    _agilityController.dispose();
    _verticalJumpController.dispose();
    _longJumpController.dispose();
    _pushupsController.dispose();
    _situpsController.dispose();
    _plankController.dispose();
    _flexibilityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

// Add this method to show test information
  void _showTestInfo(String title, String description, List<String> steps) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryYellow,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'How to conduct:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              ...steps.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryYellow.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _testDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryYellow,
              onPrimary: Colors.black,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _testDate) {
      setState(() {
        _testDate = picked;
      });
    }
  }

  Future<void> _submitTest() async {
    // Check if at least one field is filled
    if (!_hasAnyData()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Please enter at least one test result'),
          backgroundColor: AppColors.warningOrange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      // Get player data for BMI calculation
      final playerProvider = context.read<PlayerProvider>();
      final player = playerProvider.players.firstWhere(
        (p) => p.id == widget.playerId,
        orElse: () => throw Exception('Player not found'),
      );

      // Calculate BMI from player's height and weight
      final calculatedBMI = PlayerTest.calculateBMI(
        player.heightCm.toDouble(),
        player.weightKg.toDouble(),
      );

      // Calculate VO2 Max from endurance score
      final calculatedVO2Max = PlayerTest.calculateVO2Max(
        _parseDoubleOrNull(_enduranceController.text),
        player.age,
      );

      // Create test object with calculated values
      final test = PlayerTest(
        id: _uuid.v4(),
        playerId: widget.playerId,
        testDate: _testDate,
        restingHeartRate: _parseIntOrNull(_restingHRController.text),
        bloodPressureSystolic: _parseIntOrNull(_bpSystolicController.text),
        bloodPressureDiastolic: _parseIntOrNull(_bpDiastolicController.text),
        speed10m: _parseDoubleOrNull(_speed10mController.text),
        speed20m: _parseDoubleOrNull(_speed20mController.text),
        enduranceScore: _parseDoubleOrNull(_enduranceController.text),
        agilityScore: _parseDoubleOrNull(_agilityController.text),
        jumpHeightCm: _parseIntOrNull(_verticalJumpController.text),
        longJumpCm: _parseIntOrNull(_longJumpController.text),
        pushupsCount: _parseIntOrNull(_pushupsController.text),
        situpsCount: _parseIntOrNull(_situpsController.text),
        plankSeconds: _parseIntOrNull(_plankController.text),
        flexibilityCm: _parseIntOrNull(_flexibilityController.text),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        vo2MaxEstimate: calculatedVO2Max, // ✅ Now calculated
        bmi: calculatedBMI, // ✅ Now calculated
        createdAt: DateTime.now(),
      );

      print('📊 Calculated BMI: $calculatedBMI');
      print('📊 Calculated VO2 Max: $calculatedVO2Max');

      final success = await context.read<PlayerTestProvider>().createTest(test);

      setState(() => _isSubmitting = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('✅ Test results saved successfully!'),
                if (calculatedBMI != null)
                  Text('BMI: $calculatedBMI',
                      style: const TextStyle(fontSize: 12)),
                if (calculatedVO2Max != null)
                  Text(
                      'VO2 Max: ${calculatedVO2Max.toStringAsFixed(1)} ml/kg/min',
                      style: const TextStyle(fontSize: 12)),
              ],
            ),
            backgroundColor: AppColors.successGreen,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save test results'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  bool _hasAnyData() {
    return _restingHRController.text.isNotEmpty ||
        _bpSystolicController.text.isNotEmpty ||
        _bpDiastolicController.text.isNotEmpty ||
        _speed10mController.text.isNotEmpty ||
        _speed20mController.text.isNotEmpty ||
        _enduranceController.text.isNotEmpty ||
        _agilityController.text.isNotEmpty ||
        _verticalJumpController.text.isNotEmpty ||
        _longJumpController.text.isNotEmpty ||
        _pushupsController.text.isNotEmpty ||
        _situpsController.text.isNotEmpty ||
        _plankController.text.isNotEmpty ||
        _flexibilityController.text.isNotEmpty;
  }

  int? _parseIntOrNull(String text) {
    if (text.trim().isEmpty) return null;
    return int.tryParse(text);
  }

  double? _parseDoubleOrNull(String text) {
    if (text.trim().isEmpty) return null;
    return double.tryParse(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Test Results'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            // Player name header
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.2),
                    child: Text(
                      widget.playerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
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
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(
                          'Test Date: ${_formatDate(_testDate)}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.black87,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today_rounded,
                        color: Colors.black),
                    onPressed: _selectDate,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Instructions
            Text(
              'Fill in the metrics you measured. You can leave fields empty if not tested.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            // Vitals Section
            _buildSectionHeader(
              context,
              icon: Icons.favorite_rounded,
              title: 'Vitals (Before Tests)',
              subtitle: 'Measured at rest',
              infoTitle: 'Resting Vitals Measurement',
              infoDescription:
                  'Baseline health metrics taken before physical tests.',
              infoSteps: [
                'Have player sit and rest for 5 minutes',
                'Use heart rate monitor or feel pulse for 60 seconds',
                'Take blood pressure with digital monitor or manual cuff',
                'Record systolic (top number) and diastolic (bottom number)',
                'Normal ranges: HR 60-80 bpm, BP 110-120/70-80 mmHg',
                'Take measurements before any physical activity',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            _buildNumberField(
              controller: _restingHRController,
              label: 'Resting Heart Rate',
              hint: 'e.g., 65',
              suffix: 'bpm',
              icon: Icons.monitor_heart_rounded,
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _bpSystolicController,
                    label: 'BP Systolic',
                    hint: 'e.g., 120',
                    suffix: 'mmHg',
                    icon: Icons.bloodtype_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildNumberField(
                    controller: _bpDiastolicController,
                    label: 'BP Diastolic',
                    hint: 'e.g., 80',
                    suffix: 'mmHg',
                    icon: Icons.bloodtype_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Speed Section
            _buildSectionHeader(
              context,
              icon: Icons.speed_rounded,
              title: 'Speed Tests',
              subtitle: 'Sprint times',
              infoTitle: '10m & 20m Sprint Tests',
              infoDescription:
                  'Measures acceleration and maximum speed over short distances.',
              infoSteps: [
                'Mark a straight 20-meter track with cones at 0m, 10m, and 20m',
                'Player starts in a standing position behind the start line',
                'On "GO", player sprints at maximum speed',
                'Record time when player crosses each marker (10m and 20m)',
                'Allow 3-5 minutes rest between attempts',
                'Take best of 2-3 attempts',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildDecimalField(
                    controller: _speed10mController,
                    label: '10m Sprint',
                    hint: 'e.g., 1.8',
                    suffix: 'sec',
                    icon: Icons.flash_on_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildDecimalField(
                    controller: _speed20mController,
                    label: '20m Sprint',
                    hint: 'e.g., 3.2',
                    suffix: 'sec',
                    icon: Icons.flash_on_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Endurance Section
            _buildSectionHeader(
              context,
              icon: Icons.directions_run_rounded,
              title: 'Endurance',
              subtitle: 'Yo-Yo or Cooper test',
              infoTitle: 'Yo-Yo Intermittent Recovery Test',
              infoDescription:
                  'Measures aerobic endurance and recovery capacity.',
              infoSteps: [
                'Set up two cones 20 meters apart',
                'Player runs back and forth between cones',
                'Beep sound indicates pace (use Yo-Yo test app)',
                'Player has 10 seconds recovery between runs',
                'Test ends when player misses the beep twice',
                'Record the final level and shuttle number reached',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            _buildDecimalField(
              controller: _enduranceController,
              label: 'Endurance Score',
              hint: 'e.g., 1800 (meters) or level',
              suffix: 'score',
              icon: Icons.directions_run_rounded,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Agility Section
            _buildSectionHeader(
              context,
              icon: Icons.alt_route_rounded,
              title: 'Agility',
              subtitle: 'T-Test or agility drill',
              infoTitle: 'T-Test Agility Drill',
              infoDescription:
                  'Measures lateral movement, change of direction, and agility.',
              infoSteps: [
                'Set up cones in a T-shape: 3 cones 5m apart horizontally, 1 cone 10m forward',
                'Player starts at the base of the T',
                'Sprint forward to center cone, touch with hand',
                'Side-shuffle left to left cone, touch with hand',
                'Side-shuffle right to right cone (10m), touch',
                'Side-shuffle back to center, then backpedal to start',
                'Record total time with stopwatch',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            _buildDecimalField(
              controller: _agilityController,
              label: 'Agility Score',
              hint: 'e.g., 8.5',
              suffix: 'sec',
              icon: Icons.alt_route_rounded,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Power Section
            _buildSectionHeader(
              context,
              icon: Icons.fitness_center_rounded,
              title: 'Power & Explosiveness',
              subtitle: 'Jump tests',
              infoTitle: 'Vertical & Long Jump Tests',
              infoDescription: 'Measures lower body explosive power.',
              infoSteps: [
                'Vertical Jump: Player stands next to wall with arm raised',
                'Mark highest reach point (standing reach height)',
                'Player jumps as high as possible and touches wall',
                'Measure difference between standing and jumping height',
                'Long Jump: Player stands behind line',
                'Player jumps forward as far as possible',
                'Measure distance from line to closest heel landing',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _verticalJumpController,
                    label: 'Vertical Jump',
                    hint: 'e.g., 45',
                    suffix: 'cm',
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildNumberField(
                    controller: _longJumpController,
                    label: 'Long Jump',
                    hint: 'e.g., 200',
                    suffix: 'cm',
                    icon: Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Strength Section
            _buildSectionHeader(
              context,
              icon: Icons.sports_kabaddi_rounded,
              title: 'Strength',
              subtitle: 'Max reps in 60 seconds',
              infoTitle: 'Strength Endurance Tests',
              infoDescription: 'Measures muscular endurance and core strength.',
              infoSteps: [
                'Push-ups: Chest must touch floor, arms fully extended each rep',
                'Sit-ups: Hands behind head, elbows touch knees, shoulders touch floor',
                'Plank: Maintain straight line from head to heels on forearms',
                'Each test is 60 seconds maximum',
                'Record total reps or time held (for plank)',
                'Ensure proper form - stop if form breaks down',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    controller: _pushupsController,
                    label: 'Push-ups',
                    hint: 'e.g., 35',
                    suffix: 'reps',
                    icon: Icons.accessibility_new_rounded,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                Expanded(
                  child: _buildNumberField(
                    controller: _situpsController,
                    label: 'Sit-ups',
                    hint: 'e.g., 40',
                    suffix: 'reps',
                    icon: Icons.airline_seat_recline_normal_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            _buildNumberField(
              controller: _plankController,
              label: 'Plank Hold',
              hint: 'e.g., 90',
              suffix: 'sec',
              icon: Icons.timer_rounded,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Flexibility Section
            _buildSectionHeader(
              context,
              icon: Icons.self_improvement_rounded,
              title: 'Flexibility',
              subtitle: 'Sit & Reach test',
              infoTitle: 'Sit & Reach Flexibility Test',
              infoDescription: 'Measures hamstring and lower back flexibility.',
              infoSteps: [
                'Player sits with legs straight, feet flat against box',
                'Place ruler/measuring tape on box with 0 at feet level',
                'Player reaches forward slowly with both hands',
                'Keep knees straight and push ruler as far as possible',
                'Hold stretch for 2 seconds',
                'Record distance reached beyond toes (+ cm) or before toes (- cm)',
              ],
            ),
            const SizedBox(height: AppConstants.spacingM),
            _buildNumberField(
              controller: _flexibilityController,
              label: 'Sit & Reach',
              hint: 'e.g., 25',
              suffix: 'cm',
              icon: Icons.self_improvement_rounded,
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Notes Section
            _buildSectionHeader(
              context,
              icon: Icons.note_rounded,
              title: 'Additional Notes',
              subtitle: 'Optional observations',
            ),
            const SizedBox(height: AppConstants.spacingM),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Player seemed fatigued, weather was hot...',
                prefixIcon: const Icon(Icons.edit_note_rounded),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitTest,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Text('Save Test Results'),
            ),
            const SizedBox(height: AppConstants.spacingL),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? infoTitle,
    String? infoDescription,
    List<String>? infoSteps,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppConstants.spacingS),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppConstants.radiusS),
          ),
          child: Icon(icon, color: AppColors.primaryYellow, size: 20),
        ),
        const SizedBox(width: AppConstants.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textTertiary,
                    ),
              ),
            ],
          ),
        ),
        // Info button
        if (infoTitle != null && infoDescription != null && infoSteps != null)
          IconButton(
            icon: Icon(
              Icons.info_outline_rounded,
              color: AppColors.primaryYellow,
              size: 22,
            ),
            onPressed: () =>
                _showTestInfo(infoTitle, infoDescription, infoSteps),
            tooltip: 'Test instructions',
          ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildDecimalField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffix,
        prefixIcon: Icon(icon),
      ),
    );
  }

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
}
