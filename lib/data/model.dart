class Model {
  final String name; // The model identifier, e.g., "qwen"
  final String description; // The display description, e.g., "Qwen 实时（推荐）"

  Model({
    required this.name,
    required this.description,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }

  /// Get display name (description if available, otherwise name)
  String get displayName => description.isNotEmpty ? description : name;

  /// Check if this is the recommended model
  bool get isRecommended => description.contains('推荐') || description.contains('recommended');
} 