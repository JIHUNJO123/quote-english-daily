import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/quote_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../l10n/app_localizations.dart';
import 'quote_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final QuoteService _quoteService = QuoteService();
  List<String> _categories = [];
  bool _isLoading = true;

  final Map<String, IconData> _categoryIcons = {
    'happiness': Icons.sentiment_very_satisfied,
    'inspiration': Icons.lightbulb,
    'love': Icons.favorite,
    'success': Icons.emoji_events,
    'truth': Icons.verified,
    'poetry': Icons.menu_book,
    'death': Icons.hourglass_empty,
    'romance': Icons.favorite_border,
    'science': Icons.science,
    'time': Icons.access_time,
  };

  final Map<String, Color> _categoryColors = {
    'happiness': Colors.amber,
    'inspiration': Colors.orange,
    'love': Colors.red,
    'success': Colors.green,
    'truth': Colors.blue,
    'poetry': Colors.purple,
    'death': Colors.grey,
    'romance': Colors.pink,
    'science': Colors.teal,
    'time': Colors.indigo,
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _quoteService.loadQuotes();
    setState(() {
      _categories = _quoteService.getCategories();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('categories')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final quotes = _quoteService.getQuotesByCategory(category);
                        
                        return _CategoryCard(
                          category: category,
                          displayName: l10n.getCategory(category),
                          icon: _categoryIcons[category.toLowerCase()] ?? Icons.format_quote,
                          color: _categoryColors[category.toLowerCase()] ?? Colors.grey,
                          quoteCount: quotes.length,
                          quotesCountLabel: l10n.get('quotes_count'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuoteListScreen(
                                  title: l10n.getCategory(category),
                                  quotes: quotes,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                // 배너 광고
                if (!kIsWeb)
                  const BannerAdWidget(),
              ],
            ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final String displayName;
  final IconData icon;
  final Color color;
  final int quoteCount;
  final String quotesCountLabel;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.displayName,
    required this.icon,
    required this.color,
    required this.quoteCount,
    required this.quotesCountLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '$quoteCount $quotesCountLabel',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
