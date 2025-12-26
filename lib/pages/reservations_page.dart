import 'package:flutter/material.dart';
import 'package:library_app/models/reservation.dart';
import 'package:library_app/pages/book_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:library_app/providers/reservation_provider.dart';
import 'package:library_app/widgets/reservation_card.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({Key? key}) : super(key: key);

  @override
  _ReservationsPageState createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy HH:mm');
  ReservationStatus _selectedFilter = ReservationStatus.active;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReservationProvider>(context, listen: false)
          .loadUserReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              Provider.of<ReservationProvider>(context, listen: false)
                  .loadUserReservations();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres sous forme de segmented control
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Actives', ReservationStatus.active),
                  _buildFilterChip('En attente', ReservationStatus.pending),
                  _buildFilterChip('Annulées', ReservationStatus.cancelled),
                  _buildFilterChip('Retournées', ReservationStatus.returned),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<ReservationProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.reservations.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chargement des réservations...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Une erreur est survenue',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: provider.loadUserReservations,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Réessayer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4361EE),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filteredReservations = provider.reservations
                        .where((r) => r.status == _selectedFilter)
                        .toList();

                if (filteredReservations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getEmptyIcon(),
                            size: 72,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyMessage(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getEmptySubtitle(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Navigation vers la page de recherche
                            },
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('Chercher un livre'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4361EE),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => provider.loadUserReservations(),
                  color: const Color(0xFF4361EE),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredReservations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final reservation = filteredReservations[index];
                      return ReservationCard(
                        reservation: reservation,
                        dateFormat: _dateFormat,
                        onCancel: reservation.status == ReservationStatus.active
                            ? () => _showCancelDialog(context, provider, reservation.id)
                            : null,
                        onReturn: reservation.status == ReservationStatus.active
                            ? () => _showReturnDialog(context, provider, reservation.id)
                            : null,
                        onDelete: reservation.status == ReservationStatus.cancelled ||
                                reservation.status == ReservationStatus.returned
                            ? () => _showDeleteDialog(context, provider, reservation.id)
                            : null,
                        onRead: () => _showReadDialog(context, provider, reservation.id, reservation.bookId),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ReservationStatus? status) {
    final isSelected = _selectedFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = (selected ? status : null)!;
          });
        },
        backgroundColor: Colors.grey[100],
        selectedColor: const Color(0xFF4361EE),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }

  IconData _getEmptyIcon() {
    switch (_selectedFilter) {
      case ReservationStatus.active:
        return Icons.bookmark_border_rounded;
      case ReservationStatus.pending:
        return Icons.access_time_rounded;
      case ReservationStatus.cancelled:
        return Icons.cancel_rounded;
      case ReservationStatus.returned:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getEmptyMessage() {
    switch (_selectedFilter) {
      case ReservationStatus.active:
        return 'Aucune réservation active';
      case ReservationStatus.pending:
        return 'Aucune réservation en attente';
      case ReservationStatus.cancelled:
        return 'Aucune réservation annulée';
      case ReservationStatus.returned:
        return 'Aucun livre retourné';
    }
  }

  String _getEmptySubtitle() {
    return 'Trouvez des livres intéressants à réserver';
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    ReservationProvider provider,
    String reservationId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await provider.cancelReservation(reservationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réservation annulée avec succès'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showReturnDialog(
    BuildContext context,
    ReservationProvider provider,
    String reservationId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retourner le livre'),
        content: const Text('Confirmez-vous le retour de ce livre ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4361EE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await provider.returnBook(reservationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Livre retourné avec succès'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    ReservationProvider provider,
    String reservationId,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la réservation'),
        content: const Text('Cette action est irréversible. Continuer ?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await provider.deleteReservation(reservationId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Réservation supprimée'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  void _showReadDialog(BuildContext context, ReservationProvider provider, String reservationId, String bookId) {
    // Récupérer la réservation pour obtenir l'ID du livre
    final reservation = provider.reservations.firstWhere(
      (r) => r.id == reservationId,
      orElse: () => throw Exception('Réservation non trouvée'),
    );

    // Naviguer directement vers la page de détail du livre
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(bookId: reservation.bookId),
      ),
    );
  }
}