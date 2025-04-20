class Note {
  final String id;
  final String title;
  final String content;
  bool isSynced;

  Note(
      {required this.id,
      required this.title,
      required this.content,
      this.isSynced = true});

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id']?.toString() ?? '',
      title: (json['name']?.toString() ?? '').replaceAll('.txt', ''),
      content: json['content']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': title,
        'content': content,
        'isSynced': isSynced,
      };
}
