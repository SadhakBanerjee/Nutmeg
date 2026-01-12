import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../models/player_model.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_colors.dart';

/// Screen to edit existing player information
class EditPlayerScreen extends StatefulWidget {
  final Player player;

  const EditPlayerScreen({
    super.key,
    required this.player,
  });

  @override
  State<EditPlayerScreen> createState() => _EditPlayerScreenState();
}

class _EditPlayerScreenState extends State<EditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  
  String? _selectedPosition;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing data
    _nameController = TextEditingController(text: widget.player.name);
    _ageController = TextEditingController(text: widget.player.age.toString());
    _heightController = TextEditingController(text: widget.player.heightCm.toString());
    _weightController = TextEditingController(text: widget.player.weightKg.toString());
    _selectedPosition = widget.player.position;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Create updated player object
    final updatedPlayer = Player(
      id: widget.player.id,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      heightCm: int.parse(_heightController.text),
      weightKg: int.parse(_weightController.text),
      position: _selectedPosition,
      createdAt: widget.player.createdAt,
    );

    final success = await context.read<PlayerProvider>().updatePlayer(updatedPlayer);

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Player updated successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to update player'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Player'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            children: [
              // Header with player avatar
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primaryYellow.withValues(alpha: 0.2),
                      child: Text(
                        widget.player.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryYellow,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      'Edit ${widget.player.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Name field
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter player name',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter player name';
                  }
                  if (value.trim().length < 2) {
                    return 'Name must be at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Age field
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: 'Enter age',
                  prefixIcon: Icon(Icons.cake_rounded),
                  suffixText: 'years',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter age';
                  }
                  final age = int.tryParse(value);
                  if (age == null) {
                    return 'Please enter a valid number';
                  }
                  if (age < 5 || age > 50) {
                    return 'Age must be between 5 and 50';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Height field
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height',
                  hintText: 'Enter height',
                  prefixIcon: Icon(Icons.height_rounded),
                  suffixText: 'cm',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  final height = int.tryParse(value);
                  if (height == null) {
                    return 'Please enter a valid number';
                  }
                  if (height < 100 || height > 250) {
                    return 'Height must be between 100 and 250 cm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Weight field
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight',
                  hintText: 'Enter weight',
                  prefixIcon: Icon(Icons.monitor_weight_rounded),
                  suffixText: 'kg',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  final weight = int.tryParse(value);
                  if (weight == null) {
                    return 'Please enter a valid number';
                  }
                  if (weight < 20 || weight > 200) {
                    return 'Weight must be between 20 and 200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppConstants.spacingM),

              // Position dropdown
              DropdownButtonFormField<String>(
                value: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Position (Optional)',
                  prefixIcon: Icon(Icons.sports_soccer_rounded),
                ),
                items: AppConstants.positions.map((position) {
                  return DropdownMenuItem(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedPosition = value);
                },
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // Submit button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
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
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
