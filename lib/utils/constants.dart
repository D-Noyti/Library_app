class AppConstants {
  // API
  static const String googleBooksBaseUrl = 'https://www.googleapis.com/books/v1/';
  
  // SharedPreferences keys
  static const String prefDarkMode = 'dark_mode';
  static const String prefSearchHistory = 'search_history';
  static const String prefFirstLaunch = 'first_launch';
  
  // App info
  static const String appName = 'Library App';
  static const String appVersion = '1.0.0';
  
  // Messages
  static const String connectionError = 'Erreur de connexion';
  static const String unknownError = 'Une erreur est survenue';
  static const String noResults = 'Aucun résultat trouvé';
  static const String loading = 'Chargement...';
  
  // Dates
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  
  // Limits
  static const int maxSearchResults = 20;
  static const int maxSearchHistory = 10;
  static const int maxReservationsPerUser = 5;
  
  // Durations
  static const Duration apiTimeout = Duration(seconds: 10);
  static const Duration animationDuration = Duration(milliseconds: 300);
}

class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String reservationsCollection = 'reservations';
}