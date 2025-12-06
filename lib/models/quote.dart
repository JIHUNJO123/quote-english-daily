class Quote {
  final int id;
  final String text;
  final String author;
  final String category;
  final List<String> tags;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    required this.tags,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'] ?? 0,
      text: json['quote'] ?? '',
      author: json['author'] ?? 'Unknown',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quote': text,
      'author': author,
      'category': category,
      'tags': tags,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quote && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
