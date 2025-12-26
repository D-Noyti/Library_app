import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ==================== HISTORIQUE DE RECHERCHE ====================
  
  Future<void> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return;
    
    final currentHistory = getSearchHistory();
    
    // Supprimer la recherche si elle existe déjà (pour éviter les doublons)
    final newHistory = currentHistory
        .where((item) => item.toLowerCase() != query.toLowerCase())
        .toList();
    
    // Ajouter au début de la liste
    newHistory.insert(0, query);
    
    // Garder seulement les 20 dernières recherches
    final limitedHistory = newHistory.take(20).toList();
    
    await _prefs.setStringList('search_history', limitedHistory);
  }

  List<String> getSearchHistory() {
    return _prefs.getStringList('search_history') ?? [];
  }

  Future<void> removeFromSearchHistory(String query) async {
    final currentHistory = getSearchHistory();
    final newHistory = currentHistory
        .where((item) => item.toLowerCase() != query.toLowerCase())
        .toList();
    
    await _prefs.setStringList('search_history', newHistory);
  }

  Future<void> clearSearchHistory() async {
    await _prefs.setStringList('search_history', []);
  }

  // ==================== THÈME ====================

  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool('dark_mode', isDark);
  }

  bool getThemeMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  // ==================== AUTRES PRÉFÉRENCES ====================

  Future<void> saveLastSearch(String query) async {
    await _prefs.setString('last_search', query);
  }

  String getLastSearch() {
    return _prefs.getString('last_search') ?? '';
  }

  Future<void> saveFavoriteBooks(List<String> bookIds) async {
    await _prefs.setStringList('favorite_books', bookIds);
  }

  List<String> getFavoriteBooks() {
    return _prefs.getStringList('favorite_books') ?? [];
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}