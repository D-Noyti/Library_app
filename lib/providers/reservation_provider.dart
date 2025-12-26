import 'package:flutter/material.dart';
import 'package:library_app/models/reservation.dart';
import 'package:library_app/services/local/database_helper.dart';
import 'package:library_app/services/firebase/auth.dart';

class ReservationProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final Auth _authService = Auth();
  
  List<Reservation> _reservations = [];
  bool _isLoading = false;
  String? _error;

  List<Reservation> get reservations => _reservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserReservations() async {
    _setLoading(true);
    _error = null;
    
    try {
      final user = _authService.currentUser;
      if (user != null) {
        _reservations = await _dbHelper.getReservationsByUser(user.uid);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des réservations';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reserveBook({
    required String bookId,
    required String bookTitle,
    required String? bookThumbnail,
  }) async {
    _setLoading(true);
    
    try {
      final user = _authService.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final reservation = Reservation(
        id: '${bookId}_${DateTime.now().millisecondsSinceEpoch}',
        bookId: bookId,
        userId: user.uid,
        bookTitle: bookTitle,
        bookThumbnail: bookThumbnail,
        reservationDate: DateTime.now(),
        status: ReservationStatus.active,
      );

      await _dbHelper.insertReservation(reservation);
      _reservations.insert(0, reservation);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la réservation';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    _setLoading(true);
    
    try {
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        var reservation = _reservations[index];
        reservation = Reservation(
          id: reservation.id,
          bookId: reservation.bookId,
          userId: reservation.userId,
          bookTitle: reservation.bookTitle,
          bookThumbnail: reservation.bookThumbnail,
          reservationDate: reservation.reservationDate,
          returnDate: reservation.returnDate,
          status: ReservationStatus.cancelled,
        );
        
        await _dbHelper.updateReservation(reservation);
        _reservations[index] = reservation;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors de l\'annulation';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> returnBook(String reservationId) async {
    _setLoading(true);
    
    try {
      final index = _reservations.indexWhere((r) => r.id == reservationId);
      if (index != -1) {
        var reservation = _reservations[index];
        reservation = Reservation(
          id: reservation.id,
          bookId: reservation.bookId,
          userId: reservation.userId,
          bookTitle: reservation.bookTitle,
          bookThumbnail: reservation.bookThumbnail,
          reservationDate: reservation.reservationDate,
          returnDate: DateTime.now(),
          status: ReservationStatus.returned,
        );
        
        await _dbHelper.updateReservation(reservation);
        _reservations[index] = reservation;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Erreur lors du retour';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteReservation(String reservationId) async {
    _setLoading(true);
    
    try {
      await _dbHelper.deleteReservation(reservationId);
      _reservations.removeWhere((r) => r.id == reservationId);
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la suppression';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}