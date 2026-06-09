class Dog {
  final int dogId;
  final int userId;
  final String name;
  final String? breed;
  final String? birthDate;
  final double weightKg;
  final double? baselineTempC;
  final bool heartRiskMode;
  final bool isActive;

  const Dog({
    required this.dogId,
    required this.userId,
    required this.name,
    required this.breed,
    required this.birthDate,
    required this.weightKg,
    required this.baselineTempC,
    required this.heartRiskMode,
    required this.isActive,
  });

  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      dogId: json['dog_id'] as int,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      breed: json['breed'] as String?,
      birthDate: json['birth_date'] as String?,
      weightKg: (json['weight_kg'] as num).toDouble(),
      baselineTempC: (json['baseline_temp_c'] as num?)?.toDouble(),
      heartRiskMode: json['heart_risk_mode'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'user_id': userId,
      'name': name,
      'breed': breed,
      'birth_date': birthDate,
      'weight_kg': weightKg,
      'baseline_temp_c': baselineTempC,
      'heart_risk_mode': heartRiskMode,
    };
  }
}
