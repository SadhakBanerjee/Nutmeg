/// Represents a football player with basic information
class Player {
  final String id;
  final String name;
  final int age;
  final int heightCm;
  final int weightKg;
  final String? position;  // Optional: Goalkeeper, Defender, Midfielder, Forward
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.age,
    required this.heightCm,
    required this.weightKg,
    this.position,
    required this.createdAt,
  });

  /// Create Player from Supabase JSON response
  /// This is called when fetching data from database
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      age: json['age'] as int,
      heightCm: json['height_cm'] as int,
      weightKg: json['weight_kg'] as int,
      position: json['position'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert Player to JSON for sending to Supabase
  /// This is called when inserting/updating data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'position': position,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Create JSON for INSERT (without id and created_at - Supabase generates these)
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'position': position,
    };
  }

  /// Calculate BMI (Body Mass Index)
  /// Formula: weight(kg) / (height(m))²
  double get bmi {
    final heightInMeters = heightCm / 100;
    return weightKg / (heightInMeters * heightInMeters);
  }

  /// Get BMI category for display
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  /// Create a copy of Player with some fields updated
  /// Useful for editing player information
  Player copyWith({
    String? id,
    String? name,
    int? age,
    int? heightCm,
    int? weightKg,
    String? position,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, age: $age, position: $position)';
  }
}
