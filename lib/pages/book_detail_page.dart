import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:library_app/providers/book_provider.dart';
import 'package:library_app/providers/reservation_provider.dart';
import 'package:library_app/models/reservation.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;
  
  const BookDetailPage({Key? key, required this.bookId}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  bool _isReserving = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookProvider = Provider.of<BookProvider>(context, listen: false);
      final reservationProvider = Provider.of<ReservationProvider>(context, listen: false);
      
      bookProvider.getBookDetails(widget.bookId);
      reservationProvider.loadUserReservations(); // Charger les réservations
    });
  }

  // Vérifier si le livre est déjà réservé par l'utilisateur
  bool _isBookAlreadyReserved(ReservationProvider provider, String bookId) {
    return provider.reservations.any((reservation) => 
      reservation.bookId == bookId && 
      (reservation.status == ReservationStatus.active || 
       reservation.status == ReservationStatus.pending)
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context);
    
    final book = bookProvider.selectedBook;
    
    if (bookProvider.isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  const Color(0xFF4361EE),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chargement du livre...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (book == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Livre non trouvé'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.book_rounded,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Livre non disponible',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retour'),
              ),
            ],
          ),
        ),
      );
    }

    final bool isAlreadyReserved = _isBookAlreadyReserved(reservationProvider, book.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête avec bouton retour
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Détails du livre',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Section image + informations
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image verticale à gauche
                        Container(
                          width: 140,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: book.thumbnailUrl != null
                                ? Image.network(
                                    book.thumbnailUrl!,
                                    height: 200,
                                    width: 140,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 200,
                                        color: const Color(0xFFF5F5F5),
                                        child: const Center(
                                          child: Icon(
                                            Icons.book_rounded,
                                            size: 60,
                                            color: Color(0xFF4361EE),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    height: 200,
                                    color: const Color(0xFFF5F5F5),
                                    child: const Center(
                                      child: Icon(
                                        Icons.book_rounded,
                                        size: 60,
                                        color: Color(0xFF4361EE),
                                      ),
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 20),

                        // Informations à droite
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre
                              Text(
                                book.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF333333),
                                  height: 1.3,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Auteur(s)
                              if (book.authors != null && book.authors!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Auteur${book.authors!.length > 1 ? 's' : ''}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.authors!.join(', '),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF555555),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 16),

                              // Date de publication
                              if (book.publishedDate != null)
                                _buildInfoRow(
                                  icon: Icons.calendar_today_rounded,
                                  label: 'Publié',
                                  value: book.publishedDate!,
                                ),

                              // Éditeur
                              if (book.publisher != null)
                                _buildInfoRow(
                                  icon: Icons.business_rounded,
                                  label: 'Éditeur',
                                  value: book.publisher!,
                                ),

                              // Nombre de pages
                              if (book.pageCount != null)
                                _buildInfoRow(
                                  icon: Icons.description_rounded,
                                  label: 'Pages',
                                  value: '${book.pageCount}',
                                ),

                              // Statut de réservation
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isAlreadyReserved 
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : const Color(0xFF4361EE).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isAlreadyReserved 
                                      ? const Color(0xFF10B981).withOpacity(0.3)
                                      : const Color(0xFF4361EE).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAlreadyReserved 
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                      size: 14,
                                      color: isAlreadyReserved 
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFF4361EE),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isAlreadyReserved 
                                        ? 'Déjà réservé'
                                        : 'Disponible',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isAlreadyReserved 
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFF4361EE),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Section description
                    if (book.description != null && book.description!.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              book.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                    // Catégories
                    if (book.categories != null && book.categories!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 24),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: book.categories!
                              .map((category) => Chip(
                                    label: Text(
                                      category,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: const Color(0xFF4361EE).withOpacity(0.1),
                                    labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                                  ))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Bouton de réservation fixé en bas (seulement si non réservé)
            if (!isAlreadyReserved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isReserving
                        ? null
                        : () async {
                            setState(() => _isReserving = true);
                            
                            try {
                              await reservationProvider.reserveBook(
                                bookId: book.id,
                                bookTitle: book.title,
                                bookThumbnail: book.thumbnailUrl,
                              );
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      const Text('Livre réservé avec succès !'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                              
                              // Actualiser le statut
                              await reservationProvider.loadUserReservations();
                              
                              // Fermer la page après un court délai
                              Future.delayed(const Duration(milliseconds: 1500), () {
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              });
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Erreur: ${e.toString()}'),
                                    ],
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => _isReserving = false);
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isReserving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bookmark_add_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Réserver ce livre',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

            // Message si déjà réservé
            if (isAlreadyReserved)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFF10B981),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Livre déjà réservé',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Vous pouvez consulter cette réservation dans votre espace personnel',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Retour à la liste
                          // Optionnel : naviguer vers les réservations
                          // Navigator.pushNamed(context, '/reservations');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF4361EE),
                          side: BorderSide(color: const Color(0xFF4361EE).withOpacity(0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Voir mes réservations'),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF4361EE),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}