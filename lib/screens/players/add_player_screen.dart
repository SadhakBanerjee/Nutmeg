import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/player_provider.dart';
import '../../theme/app_colors.dart';

/// Screen to add a new player
class AddPlayerScreen extends StatefulWidget {
  const AddPlayerScreen({super.key});

  @override
  State<AddPlayerScreen> createState() => _AddPlayerScreenState();
}

class _AddPlayerScreenState extends State<AddPlayerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  String? _selectedPosition;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Create player
    final success = await context.read<PlayerProvider>().createPlayer(
          name: _nameController.text.trim(),
          age: int.parse(_ageController.text),
          heightCm: int.parse(_heightController.text),
          weightKg: int.parse(_weightController.text),
          position: _selectedPosition,
        );

    setState(() => _isSubmitting = false);

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Player added successfully!'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      
      // Go back to previous screen
      Navigator.pop(context);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Failed to add player. Please try again.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Player'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            children: [
              // Header
              Text(
                'Player Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppConstants.spacingS),
              Text(
                'Enter basic details about the player',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: AppConstants.spacingL),

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
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Player'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
