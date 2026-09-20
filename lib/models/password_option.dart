class PasswordOption {
  final String id;
  final String label;
  final String example;

  PasswordOption({
    required this.id,
    required this.label,
    required this.example,
  });

  factory PasswordOption.fromJson(Map<String, dynamic> json) {
    return PasswordOption(
      id: json['id'] as String,
      label: json['label'] as String,
      example: json['example'] as String,
    );
  }
}

class LengthRange {
  final int min;
  final int max;
  final int defaultValue;

  LengthRange({
    required this.min,
    required this.max,
    required this.defaultValue,
  });

  factory LengthRange.fromJson(Map<String, dynamic> json) {
    return LengthRange(
      min: json['min'] as int,
      max: json['max'] as int,
      defaultValue: json['default'] as int,
    );
  }
}

class CharacterSetsResponse {
  final List<PasswordOption> options;
  final LengthRange length;

  CharacterSetsResponse({required this.options, required this.length});

  factory CharacterSetsResponse.fromJson(Map<String, dynamic> json) {
    return CharacterSetsResponse(
      options: (json['options'] as List)
          .map((o) => PasswordOption.fromJson(o as Map<String, dynamic>))
          .toList(),
      length: LengthRange.fromJson(json['length'] as Map<String, dynamic>),
    );
  }
}
