class Book {
  final String id;
  final String title;
  final List<String>? authors;
  final String? description;
  final String? thumbnailUrl;
  final String? publishedDate;
  final String? publisher;
  final int? pageCount;
  final List<String>? categories;
  final String? isbn;

  Book({
    required this.id,
    required this.title,
    this.authors,
    this.description,
    this.thumbnailUrl,
    this.publishedDate,
    this.publisher,
    this.pageCount,
    this.categories,
    this.isbn,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'] ?? 'Titre inconnu',
      authors: List<String>.from(json['volumeInfo']['authors'] ?? []),
      description: json['volumeInfo']['description'] ?? '',
      thumbnailUrl: json['volumeInfo']['imageLinks']?['thumbnail']?.replaceFirst('http:', 'https:'),
      publishedDate: json['volumeInfo']['publishedDate'],
      publisher: json['volumeInfo']['publisher'],
      pageCount: json['volumeInfo']['pageCount'],
      categories: List<String>.from(json['volumeInfo']['categories'] ?? []),
      isbn: _extractIsbn(json['volumeInfo']['industryIdentifiers']),
    );
  }

  static String? _extractIsbn(List<dynamic>? identifiers) {
    if (identifiers == null) return null;
    for (var id in identifiers) {
      if (id['type'] == 'ISBN_13') return id['identifier'];
      if (id['type'] == 'ISBN_10') return id['identifier'];
    }
    return null;
  }
}