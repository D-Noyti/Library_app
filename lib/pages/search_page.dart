import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:library_app/providers/book_provider.dart';
import 'package:library_app/widgets/book_card.dart';
import 'package:library_app/pages/book_detail_page.dart';
import 'package:library_app/services/local/shared_prefs_service.dart';

class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({Key? key, this.initialQuery}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final SharedPrefsService _prefsService = SharedPrefsService();
  late BookProvider _bookProvider;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _bookProvider = Provider.of<BookProvider>(context, listen: false);
    _loadSearchHistory();
    
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performSearch(widget.initialQuery!);
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadSearchHistory() {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: _buildSearchField(),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.grey),
              onPressed: () {
                _searchController.clear();
                _bookProvider.clearSearch();
              },
            ),
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Color(0xFF4361EE)),
            onPressed: () {
              _showSearchHistoryBottomSheet(context);
            },
            tooltip: 'Historique de recherche',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Rechercher un livre...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4361EE)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        onSubmitted: (value) => _performSearch(value.trim()),
        onChanged: (value) {
          if (value.isEmpty) {
            _bookProvider.clearSearch();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<BookProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4361EE)),
                ),
                SizedBox(height: 16),
                Text(
                  'Recherche en cours...',
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
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de recherche',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
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
                  ElevatedButton(
                    onPressed: () => _performSearch(_searchController.text.trim()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4361EE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.searchResults.isEmpty && _searchController.text.isEmpty) {
          return _buildEmptyState();
        }

        if (provider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
          return _buildNoResultsState();
        }

        return _buildResultsList(provider);
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 24),
                Text(
                  'Recherchez des livres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Tapez un titre, un auteur, un genre ou un sujet pour trouver des livres',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Suggestions rapides
          Text(
            'Suggestions rapides',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSearchChip('Roman', Icons.menu_book_rounded),
              _buildQuickSearchChip('Science-Fiction', Icons.rocket_launch_rounded),
              _buildQuickSearchChip('Histoire', Icons.history_edu_rounded),
              _buildQuickSearchChip('Biologie', Icons.psychology_rounded),
              _buildQuickSearchChip('Art', Icons.palette_rounded),
              _buildQuickSearchChip('Programmation', Icons.code_rounded),
              _buildQuickSearchChip('Manga', Icons.animation_rounded),
              _buildQuickSearchChip('BD', Icons.auto_stories_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              children: [
                const TextSpan(text: 'Aucun livre trouvé pour '),
                TextSpan(
                  text: '"${_searchController.text}"',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4361EE),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec des mots-clés différents ou vérifiez l\'orthographe',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BookProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${provider.searchResults.length} résultat${provider.searchResults.length > 1 ? 's' : ''} trouvé${provider.searchResults.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _bookProvider.clearSearch();
                  _searchController.clear();
                },
                icon: const Icon(Icons.clear_all_rounded, size: 16),
                label: const Text('Effacer'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: provider.searchResults.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final book = provider.searchResults[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookDetailPage(bookId: book.id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickSearchChip(String label, IconData icon) {
    return ActionChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: const Color(0xFF4361EE)),
      onPressed: () {
        _searchController.text = label;
        _performSearch(label);
      },
      backgroundColor: const Color(0xFFF0F2F5),
      labelStyle: const TextStyle(
        fontSize: 12,
        color: Color(0xFF4361EE),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _performSearch(String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      _bookProvider.clearSearch();
      return;
    }

    _prefsService.addToSearchHistory(trimmedQuery);
    _loadSearchHistory();
    
    _bookProvider.searchBooks(trimmedQuery);
  }

  void _showSearchHistoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final history = _prefsService.getSearchHistory();
        
        return Container(
          padding: const EdgeInsets.only(top: 16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Historique de recherche',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (history.isNotEmpty)
                      TextButton(
                        onPressed: () async {
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
                            _loadSearchHistory();
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          'Effacer tout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.history_toggle_off_rounded,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun historique',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Vos recherches apparaîtront ici',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: history.length,
                        itemBuilder: (context, index) {
                          final query = history[index];
                          return ListTile(
                            leading: const Icon(Icons.history_rounded, color: Colors.grey),
                            title: Text(query),
                            trailing: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: Colors.grey,
                              onPressed: () {
                                _prefsService.removeFromSearchHistory(query);
                                _loadSearchHistory();
                                Navigator.pop(context);
                              },
                            ),
                            onTap: () {
                              _searchController.text = query;
                              _performSearch(query);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}