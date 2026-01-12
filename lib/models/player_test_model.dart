/// Represents a single fitness test session for a player
class PlayerTest {
  final String id;
  final String playerId; // Foreign key to Player
  final DateTime testDate;

  // Speed tests
  final double? speed20m;
  final double? speed10m;

  // Endurance
  final double? enduranceScore;
  final double? vo2MaxEstimate;

  // Agility
  final double? agilityScore;

  // Power
  final int? jumpHeightCm;
  final int? longJumpCm;

  // Strength
  final int? pushupsCount;
  final int? situpsCount;
  final int? plankSeconds;

  // Flexibility
  final int? flexibilityCm;

  // Vitals
  final int? restingHeartRate;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;

  // Calculated
  final double? bmi;

  // Notes
  final String? notes;

  final DateTime createdAt;

  PlayerTest({
    required this.id,
    required this.playerId,
    required this.testDate,
    this.speed20m,
    this.speed10m,
    this.enduranceScore,
    this.vo2MaxEstimate,
    this.agilityScore,
    this.jumpHeightCm,
    this.longJumpCm,
    this.pushupsCount,
    this.situpsCount,
    this.plankSeconds,
    this.flexibilityCm,
    this.restingHeartRate,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.bmi,
    this.notes,
    required this.createdAt,
  });

  // Static method to calculate BMI
  static double? calculateBMI(double? heightCm, double? weightKg) {
    if (heightCm == null || weightKg == null || heightCm <= 0) return null;

    final heightM = heightCm / 100; // Convert cm to meters
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1)); // Round to 1 decimal
  }

  // Static method to estimate VO2 Max from endurance score
  // Using Yo-Yo Intermittent Recovery Test formula
  static double? calculateVO2Max(double? enduranceScore, int? age) {
    if (enduranceScore == null || age == null) return null;

    // Simplified formula: VO2max = endurance_distance × 0.0084 + 36.4
    // This is an approximation for Yo-Yo IR1 test
    final vo2max = (enduranceScore * 0.0084) + 36.4;
    return double.parse(vo2max.toStringAsFixed(1)); // Round to 1 decimal
  }

  /// Create PlayerTest from Supabase JSON
factory PlayerTest.fromJson(Map<String, dynamic> json) {
  return PlayerTest(
    id: json['id'] as String,
    playerId: json['player_id'] as String,
    testDate: DateTime.parse(json['test_date'] as String),
    speed20m: _toDouble(json['speed_20m']),
    speed10m: _toDouble(json['speed_10m']),
    enduranceScore: _toDouble(json['endurance_score']),
    vo2MaxEstimate: _toDouble(json['vo2_max_estimate']),
    agilityScore: _toDouble(json['agility_score']),
    jumpHeightCm: json['jump_height_cm'] as int?,
    longJumpCm: json['long_jump_cm'] as int?,
    pushupsCount: json['pushups_count'] as int?,
    situpsCount: json['situps_count'] as int?,
    plankSeconds: json['plank_seconds'] as int?,
    flexibilityCm: json['flexibility_cm'] as int?,
    restingHeartRate: json['resting_heart_rate'] as int?,
    bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
    bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
    bmi: _toDouble(json['bmi']),
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

/// Helper method to safely convert int or double to double?
static double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

  /// Convert PlayerTest to JSON for updates
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'test_date':
          testDate.toIso8601String().split('T')[0], // Date only (YYYY-MM-DD)
      'speed_20m': speed20m,
      'speed_10m': speed10m,
      'endurance_score': enduranceScore,
      'vo2_max_estimate': vo2MaxEstimate,
      'agility_score': agilityScore,
      'jump_height_cm': jumpHeightCm,
      'long_jump_cm': longJumpCm,
      'pushups_count': pushupsCount,
      'situps_count': situpsCount,
      'plank_seconds': plankSeconds,
      'flexibility_cm': flexibilityCm,
      'resting_heart_rate': restingHeartRate,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'bmi': bmi,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convert to JSON for INSERT (without id and created_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'player_id': playerId,
      'test_date': testDate.toIso8601String().split('T')[0],
      'speed_20m': speed20m,
      'speed_10m': speed10m,
      'endurance_score': enduranceScore,
      'vo2_max_estimate': vo2MaxEstimate,
      'agility_score': agilityScore,
      'jump_height_cm': jumpHeightCm,
      'long_jump_cm': longJumpCm,
      'pushups_count': pushupsCount,
      'situps_count': situpsCount,
      'plank_seconds': plankSeconds,
      'flexibility_cm': flexibilityCm,
      'resting_heart_rate': restingHeartRate,
      'blood_pressure_systolic': bloodPressureSystolic,
      'blood_pressure_diastolic': bloodPressureDiastolic,
      'bmi': bmi,
      'notes': notes,
    };
  }

  /// Get formatted test date (e.g., "Jan 24, 2025")
  String get formattedDate {
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
    return '${months[testDate.month - 1]} ${testDate.day}, ${testDate.year}';
  }

  /// Get blood pressure as string (e.g., "120/80")
  String? get bloodPressureFormatted {
    if (bloodPressureSystolic == null || bloodPressureDiastolic == null) {
      return null;
    }
    return '$bloodPressureSystolic/$bloodPressureDiastolic';
  }

  /// Check if test has complete vital signs
  bool get hasVitals {
    return restingHeartRate != null &&
        bloodPressureSystolic != null &&
        bloodPressureDiastolic != null;
  }

  /// Check if test has any physical test data
  bool get hasPhysicalTests {
    return speed20m != null ||
        enduranceScore != null ||
        agilityScore != null ||
        jumpHeightCm != null;
  }

  /// Create a copy with updated fields
  PlayerTest copyWith({
    String? id,
    String? playerId,
    DateTime? testDate,
    double? speed20m,
    double? speed10m,
    double? enduranceScore,
    double? vo2MaxEstimate,
    double? agilityScore,
    int? jumpHeightCm,
    int? longJumpCm,
    int? pushupsCount,
    int? situpsCount,
    int? plankSeconds,
    int? flexibilityCm,
    int? restingHeartRate,
    int? bloodPressureSystolic,
    int? bloodPressureDiastolic,
    double? bmi,
    String? notes,
    DateTime? createdAt,
  }) {
    return PlayerTest(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      testDate: testDate ?? this.testDate,
      speed20m: speed20m ?? this.speed20m,
      speed10m: speed10m ?? this.speed10m,
      enduranceScore: enduranceScore ?? this.enduranceScore,
      vo2MaxEstimate: vo2MaxEstimate ?? this.vo2MaxEstimate,
      agilityScore: agilityScore ?? this.agilityScore,
      jumpHeightCm: jumpHeightCm ?? this.jumpHeightCm,
      longJumpCm: longJumpCm ?? this.longJumpCm,
      pushupsCount: pushupsCount ?? this.pushupsCount,
      situpsCount: situpsCount ?? this.situpsCount,
      plankSeconds: plankSeconds ?? this.plankSeconds,
      flexibilityCm: flexibilityCm ?? this.flexibilityCm,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      bloodPressureSystolic:
          bloodPressureSystolic ?? this.bloodPressureSystolic,
      bloodPressureDiastolic:
          bloodPressureDiastolic ?? this.bloodPressureDiastolic,
      bmi: bmi ?? this.bmi,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'PlayerTest(id: $id, playerId: $playerId, date: $formattedDate)';
  }

}
