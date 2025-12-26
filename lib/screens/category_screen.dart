import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
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
  bool _filterFamousOnly = false;
  bool _filterShortOnly = false;

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

  // 필터가 적용된 명언 가져오기
  List<Quote> _getFilteredQuotes(String category) {
    var quotes = _quoteService.getQuotesByCategory(category);

    if (_filterFamousOnly) {
      quotes =
          quotes.where((q) => _quoteService.isFamousPerson(q.author)).toList();
    }

    if (_filterShortOnly) {
      quotes = quotes.where((q) => q.text.length <= 100).toList();
    }

    return quotes;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('categories')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // 필터 토글 섹션
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune,
                              color: colorScheme.primary, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            l10n.get('additional_filters'),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildFilterChip(
                              context,
                              icon: Icons.star,
                              label: l10n.get('filter_famous_only'),
                              value: _filterFamousOnly,
                              onChanged: (value) {
                                setState(() => _filterFamousOnly = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildFilterChip(
                              context,
                              icon: Icons.flash_on,
                              label: l10n.get('filter_short_only'),
                              value: _filterShortOnly,
                              onChanged: (value) {
                                setState(() => _filterShortOnly = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 카테고리 그리드
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final quotes = _getFilteredQuotes(category);

                        return _CategoryCard(
                          category: category,
                          displayName: l10n.getCategory(category),
                          icon: _categoryIcons[category.toLowerCase()] ??
                              Icons.format_quote,
                          color: _categoryColors[category.toLowerCase()] ??
                              Colors.grey,
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
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: value ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: value ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
        ),
      ),
      selected: value,
      onSelected: onChanged,
      selectedColor: colorScheme.primary,
      checkmarkColor: colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 4),
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
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  size: 26,
                  color: Colors.white,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$quoteCount $quotesCountLabel',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
