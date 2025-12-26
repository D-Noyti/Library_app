class ApiConfig {
  // Clé API Google Books
  static const String googleBooksApiKey = 'AIzaSyDDa50LPxAQuf8cxnApmnxkKjKgUL8HWFw';
  
  // URLs de base
  static const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/';
  
  // Configuration des requêtes
  static const Duration requestTimeout = Duration(seconds: 10);
  static const int defaultMaxResults = 20;
}