class AppConstants {
  AppConstants._();
  
  // App info
  static const String appName = 'Nutmeg';
  static const String appTagline = 'Football Performance Tracker';
  
  // Spacing (consistent padding/margins)
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  
  // Border radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  
  // Icon sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
  
  // Test parameter labels
  static const Map<String, String> testLabels = {
    'speed_20m': '20m Sprint',
    'speed_10m': '10m Sprint',
    'endurance_score': 'Endurance',
    'agility_score': 'Agility',
    'jump_height_cm': 'Vertical Jump',
    'long_jump_cm': 'Long Jump',
    'pushups_count': 'Push-ups',
    'situps_count': 'Sit-ups',
    'plank_seconds': 'Plank Hold',
    'flexibility_cm': 'Flexibility',
    'resting_heart_rate': 'Resting HR',
    'blood_pressure_systolic': 'BP Systolic',
    'blood_pressure_diastolic': 'BP Diastolic',
  };
  
  // Units for display
  static const Map<String, String> testUnits = {
    'speed_20m': 's',
    'speed_10m': 's',
    'endurance_score': 'pts',
    'agility_score': 's',
    'jump_height_cm': 'cm',
    'long_jump_cm': 'cm',
    'pushups_count': 'reps',
    'situps_count': 'reps',
    'plank_seconds': 's',
    'flexibility_cm': 'cm',
    'resting_heart_rate': 'bpm',
    'blood_pressure_systolic': 'mmHg',
    'blood_pressure_diastolic': 'mmHg',
  };
  
  // Player positions
  static const List<String> positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
  ];
}
