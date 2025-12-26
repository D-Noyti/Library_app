import 'package:flutter/material.dart';
import 'package:library_app/pages/search_history_page.dart';
import 'package:provider/provider.dart';
import 'package:library_app/providers/auth_provider.dart';
import 'package:library_app/providers/reservation_provider.dart';
import 'package:library_app/pages/search_page.dart';
import 'package:library_app/pages/reservations_page.dart';
import 'package:library_app/pages/profile_page.dart';
import 'package:library_app/widgets/book_recommendation_card.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = [
    const HomeContent(),
    const SearchPage(),
    const ReservationsPage(),
    const ProfilePage(),
  ];

  // Couleurs cohérentes avec la Login Page
  final Color _primaryColor = const Color(0xFF4361EE);
  final Color _backgroundColor = const Color(0xFFF8F9FA);
  final Color _surfaceColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: _surfaceColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _selectedIndex == 0 
                ? _primaryColor.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.home_rounded,
              size: _selectedIndex == 0 ? 26 : 24,
            ),
          ),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _selectedIndex == 1 
                ? _primaryColor.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.search_rounded,
              size: _selectedIndex == 1 ? 26 : 24,
            ),
          ),
          label: 'Recherche',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _selectedIndex == 2 
                ? _primaryColor.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.bookmark_rounded,
              size: _selectedIndex == 2 ? 26 : 24,
            ),
          ),
          label: 'Réservations',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _selectedIndex == 3 
                ? _primaryColor.withOpacity(0.1) 
                : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.person_rounded,
              size: _selectedIndex == 3 ? 26 : 24,
            ),
          ),
          label: 'Profil',
        ),
      ],
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    // Charger les réservations de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reservationProvider = Provider.of<ReservationProvider>(
        context, 
        listen: false
      );
      reservationProvider.loadUserReservations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final reservationProvider = Provider.of<ReservationProvider>(context);
    final user = authProvider.user;

    // Calculer les statistiques
    final reservations = reservationProvider.reservations;
    final borrowedCount = reservations.where((r) => r.status.name == 'active').length;
    final returnedCount = reservations.where((r) => r.status.name == 'returned').length;
    final pendingCount = reservations.where((r) => r.status.name == 'pending').length;

    // Couleurs cohérentes
    final Color primaryColor = const Color(0xFF4361EE);
    final Color secondaryColor = const Color(0xFF3A0CA3);
    final Color accentColor = const Color(0xFF7209B7);

    // Données des recommandations par catégorie
    final List<Map<String, dynamic>> recommendations = [
      {
        'category': 'Anime & Manga',
        'searchQuery': 'anime',
        'color': const Color(0xFFF72585),
        'icon': Icons.animation_rounded,
      },
      {
        'category': 'Comics & BD',
        'searchQuery': 'comics graphic novel',
        'color': const Color(0xFF7209B7),
        'icon': Icons.auto_stories_rounded,
      },
      {
        'category': 'Biologie',
        'searchQuery': 'biology science',
        'color': const Color(0xFF4CC9F0),
        'icon': Icons.psychology_rounded,
      },
      {
        'category': 'Géographie',
        'searchQuery': 'geography earth',
        'color': const Color(0xFF4895EF),
        'icon': Icons.public_rounded,
      },
      {
        'category': 'Histoire',
        'searchQuery': 'history historical',
        'color': const Color(0xFF4361EE),
        'icon': Icons.history_edu_rounded,
      },
      {
        'category': 'Programmation',
        'searchQuery': 'programming coding',
        'color': const Color(0xFF3A0CA3),
        'icon': Icons.code_rounded,
      },
      {
        'category': 'Art & Design',
        'searchQuery': 'art design',
        'color': const Color(0xFFFFB703),
        'icon': Icons.palette_rounded,
      },
      {
        'category': 'Science Fiction',
        'searchQuery': 'sci-fi science fiction',
        'color': const Color(0xFFFB8500),
        'icon': Icons.rocket_launch_rounded,
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // En-tête avec profil
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour,',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email?.split('@').first ?? 'Utilisateur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section bienvenue
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    primaryColor.withOpacity(0.9),
                    secondaryColor.withOpacity(0.9),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bibliothèque Digitale',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Explorez notre collection de livres et gérez vos réservations facilement.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.library_books_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section actions rapides
            Text(
              'Actions Rapides',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  icon: Icons.search_rounded,
                  title: 'Rechercher',
                  subtitle: 'Trouver des livres',
                  color: primaryColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchPage()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.bookmark_rounded,
                  title: 'Réservations',
                  subtitle: 'Voir mes emprunts',
                  color: accentColor,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReservationsPage()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Historique',
                  subtitle: 'Mes lectures',
                  color: const Color(0xFF4CC9F0),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SearchHistoryPage()),
                  ),
                ),
                _buildActionCard(
                  context,
                  icon: Icons.notifications_rounded,
                  title: 'Notifications',
                  subtitle: 'Alertes et rappels',
                  color: const Color(0xFFF72585),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notifications à venir bientôt !'),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section statistiques RÉELLES
            Text(
              'Mes Statistiques',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: secondaryColor,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    context,
                    value: borrowedCount.toString(),
                    label: 'Livres\nempruntés',
                    color: primaryColor,
                    icon: Icons.book_rounded,
                  ),
                  _buildStatItem(
                    context,
                    value: returnedCount.toString(),
                    label: 'Livres\nretournés',
                    color: const Color(0xFF4CAF50),
                    icon: Icons.check_circle_rounded,
                  ),
                  _buildStatItem(
                    context,
                    value: pendingCount.toString(),
                    label: 'En\nattente',
                    color: accentColor,
                    icon: Icons.access_time_rounded,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section recommandations par catégorie
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Explorez par Catégorie',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: secondaryColor,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Tout voir',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Liste horizontale des cartes de recommandation
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return BookRecommendationCard(
                    category: rec['category'],
                    searchQuery: rec['searchQuery'],
                    cardColor: rec['color'],
                    icon: rec['icon'],
                    onTap: () {
                      // Navigation vers SearchPage avec la recherche pré-remplie
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(
                            initialQuery: rec['searchQuery'],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3A0CA3),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            height: 1.3,
          ),
        ),
      ],
    );
  }
}