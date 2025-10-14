class Song {
  final String id;
  final String? title;
  final String? text;
  final String? url;
  final bool isFavorite;
  final int lastAccessed;

  const Song({
    required this.id,
    this.title,
    this.text,
    this.url,
    this.isFavorite = false,
    this.lastAccessed = 0,
  });

  // Преобразование из Map (из базы данных)
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String?,
      text: map['text'] as String?,
      url: map['url'] as String?,
      isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
      lastAccessed: map['lastAccessed'] as int? ?? 0,
    );
  }

  // Преобразование в Map (для базы данных)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'text': text,
      'url': url,
      'isFavorite': isFavorite ? 1 : 0,
      'lastAccessed': lastAccessed,
    };
  }

  // Создание копии с изменениями
  Song copyWith({
    String? id,
    String? title,
    String? text,
    String? url,
    bool? isFavorite,
    int? lastAccessed,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  String toString() {
    return 'Song{id: $id, title: $title, isFavorite: $isFavorite}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

