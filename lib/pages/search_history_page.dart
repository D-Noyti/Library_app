import 'package:flutter/material.dart';
import 'package:library_app/services/local/shared_prefs_service.dart';
import 'package:library_app/pages/search_page.dart';

class SearchHistoryPage extends StatefulWidget {
  const SearchHistoryPage({Key? key}) : super(key: key);

  @override
  _SearchHistoryPageState createState() => _SearchHistoryPageState();
}

class _SearchHistoryPageState extends State<SearchHistoryPage> {
  final SharedPrefsService _prefsService = SharedPrefsService();
  late List<String> _searchHistory;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _searchHistory = _prefsService.getSearchHistory();
    });
  }

  void _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer l\'historique'),
        content: const Text('Voulez-vous vraiment effacer tout l\'historique de recherche ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Effacer tout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _prefsService.clearSearchHistory();
      _loadHistory();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Historique effacé'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique de recherche'),
        actions: [
          if (_searchHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded),
              onPressed: _clearAllHistory,
              tooltip: 'Effacer tout',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.history_rounded,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 24),
            const Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vos recherches apparaîtront ici',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPage(),
                  ),
                );
              },
              child: const Text('Commencer une recherche'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadHistory();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _searchHistory.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final query = _searchHistory[index];
          return Dismissible(
            key: Key('history_$index'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(
                Icons.delete_rounded,
                color: Colors.white,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              await _prefsService.removeFromSearchHistory(query);
              _loadHistory();
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$query" supprimé'),
                  action: SnackBarAction(
                    label: 'Annuler',
                    onPressed: () async {
                      await _prefsService.addToSearchHistory(query);
                      _loadHistory();
                    },
                  ),
                ),
              );
            },
            child: ListTile(
              leading: const Icon(
                Icons.history_rounded,
                color: Colors.grey,
              ),
              title: Text(
                query,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.search_rounded, size: 20),
                color: const Color(0xFF4361EE),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchPage(initialQuery: query),
                    ),
                  );
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchPage(initialQuery: query),
                  ),
                );
              },
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          );
        },
      ),
    );
  }
}