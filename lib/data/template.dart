class Template {
  final String name;
  final String voice;
  final String language;
  final String character;

  Template({
    required this.name,
    required this.voice,
    required this.language,
    required this.character,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      name: json['name'] ?? '',
      voice: json['voice'] ?? '',
      language: json['language'] ?? '',
      character: json['character'] ?? '',
    );
  }
}
