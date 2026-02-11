class Flashcard {
  final String id;
  final int index;
  final String name;
  final String description;
  final String subject;
  final String imageUrl;
  final String exampleSentence;

  Flashcard({
    required this.id,
    required this.index,
    required this.name,
    required this.description,
    required this.subject,
    required this.imageUrl,
    required this.exampleSentence,
  });

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['_id']?.toString() ?? '',
      index: json['index'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      exampleSentence: json['exampleSentence'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'index': index,
      'name': name,
      'description': description,
      'subject': subject,
      'imageUrl': imageUrl,
      'exampleSentence': exampleSentence,
    };
  }
}
