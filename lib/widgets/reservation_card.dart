import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:library_app/models/reservation.dart';

class ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final DateFormat dateFormat;
  final VoidCallback? onCancel;
  final VoidCallback? onReturn;
  final VoidCallback? onDelete;
  final VoidCallback onRead; // Nouveau callback pour lire

  const ReservationCard({
    Key? key,
    required this.reservation,
    required this.dateFormat,
    this.onCancel,
    this.onReturn,
    this.onDelete,
    required this.onRead, // Requis maintenant
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Indicateur de statut sur le côté gauche
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16).copyWith(left: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Couverture du livre avec bord arrondi
                    Container(
                      width: 70,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: reservation.bookThumbnail != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                reservation.bookThumbnail!,
                                width: 70,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[100],
                                    child: const Center(
                                      child: Icon(
                                        Icons.book_rounded,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              color: Colors.grey[100],
                              child: const Center(
                                child: Icon(
                                  Icons.book_rounded,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre du livre
                          Text(
                            reservation.bookTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // Date de réservation
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(reservation.reservationDate),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          
                          // Date de retour si applicable
                          if (reservation.returnDate != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: 14,
                                  color: Colors.green[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Retourné le: ${dateFormat.format(reservation.returnDate!)}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.green[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                          
                          // Badge de statut
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: _getStatusColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                // Bouton Lire et autres actions
                const SizedBox(height: 12),
                Divider(
                  color: Colors.grey[200],
                  height: 1,
                ),
                const SizedBox(height: 12),
                
                // Bouton Lire (toujours visible sauf pour annulé/supprimé)
                if (reservation.status != ReservationStatus.cancelled &&
                    reservation.status != ReservationStatus.returned)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: onRead,
                        icon: const Icon(Icons.auto_stories_rounded, size: 18),
                        label: const Text('Lire'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                
                // Autres actions
                if (onCancel != null || onReturn != null || onDelete != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (onCancel != null)
                        _buildActionButton(
                          context,
                          Icons.close_rounded,
                          'Annuler',
                          Colors.orange,
                          onCancel!,
                        ),
                      if (onReturn != null) ...[
                        if (onCancel != null) const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.check_rounded,
                          'Retourner',
                          const Color(0xFF4361EE),
                          onReturn!,
                        ),
                      ],
                      if (onDelete != null) ...[
                        if (onCancel != null || onReturn != null) const SizedBox(width: 8),
                        _buildActionButton(
                          context,
                          Icons.delete_rounded,
                          'Supprimer',
                          Colors.red,
                          onDelete!,
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(0, 36),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (reservation.status) {
      case ReservationStatus.active:
        return const Color(0xFF10B981); // Vert
      case ReservationStatus.pending:
        return const Color(0xFFF59E0B); // Orange
      case ReservationStatus.cancelled:
        return const Color(0xFFEF4444); // Rouge
      case ReservationStatus.returned:
        return const Color(0xFF3B82F6); // Bleu
    }
  }

  String _getStatusText() {
    switch (reservation.status) {
      case ReservationStatus.active:
        return 'Active';
      case ReservationStatus.pending:
        return 'En attente';
      case ReservationStatus.cancelled:
        return 'Annulée';
      case ReservationStatus.returned:
        return 'Retournée';
    }
  }
}