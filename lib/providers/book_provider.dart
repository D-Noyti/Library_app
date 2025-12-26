import 'package:flutter/material.dart';
import 'package:library_app/models/book.dart';
import 'package:library_app/services/api/google_books_service.dart';
import 'package:library_app/services/api/api_exceptions.dart';

class BookProvider with ChangeNotifier {
  final GoogleBooksService _booksService = GoogleBooksService();
  
  List<Book> _books = [];
  List<Book> _searchResults = [];
  Book? _selectedBook;
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<Book> get searchResults => _searchResults;
  Book? get selectedBook => _selectedBook;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchBooks(String query) async {
    _setLoading(true);
    _error = null;
    try {
      _searchResults = await _booksService.searchBooks(query);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getBookDetails(String bookId) async {
    _setLoading(true);
    _error = null;
    try {
      _selectedBook = await _booksService.getBookDetails(bookId);
    } on ApiException catch (e) {
      _error = e.message;
    } finally {
      _setLoading(false);
    }
  }

  void clearSearch() {
    _searchResults.clear();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}