class Reservation {
  final String id;
  final String bookId;
  final String userId;
  final String bookTitle;
  final String? bookThumbnail;
  final DateTime reservationDate;
  final DateTime? returnDate;
  final ReservationStatus status;

  Reservation({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.bookTitle,
    this.bookThumbnail,
    required this.reservationDate,
    this.returnDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookId': bookId,
      'userId': userId,
      'bookTitle': bookTitle,
      'bookThumbnail': bookThumbnail,
      'reservationDate': reservationDate.toIso8601String(),
      'returnDate': returnDate?.toIso8601String(),
      'status': status.name,
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      bookId: map['bookId'],
      userId: map['userId'],
      bookTitle: map['bookTitle'],
      bookThumbnail: map['bookThumbnail'],
      reservationDate: DateTime.parse(map['reservationDate']),
      returnDate: map['returnDate'] != null ? DateTime.parse(map['returnDate']) : null,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReservationStatus.pending,
      ),
    );
  }
}

enum ReservationStatus {
  pending,
  active,
  cancelled,
  returned,
}