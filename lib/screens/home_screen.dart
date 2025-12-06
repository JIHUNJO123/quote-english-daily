import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final QuoteService _quoteService = QuoteService();
  final AdService _adService = AdService();
  Quote? _currentQuote;
  bool _isLoading = true;
  bool _showDailyQuote = true;
  int _quoteViewCount = 0;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  Future<void> _loadQuotes() async {
    await _quoteService.loadQuotes();
    setState(() {
      _selectedCategory = _quoteService.selectedCategory;
      _currentQuote = _quoteService.getDailyQuote();
      _isLoading = false;
    });
  }

  void _getNewQuote() {
    _quoteViewCount++;
    
    // 5번마다 전면 광고 표시
    if (_quoteViewCount % 5 == 0 && !kIsWeb) {
      _adService.showInterstitialAd();
    }
    
    setState(() {
      _currentQuote = _quoteService.getRandomQuote();
      _showDailyQuote = false;
    });
  }

  void _showDailyQuoteAgain() {
    setState(() {
      _currentQuote = _quoteService.getDailyQuote();
      _showDailyQuote = true;
    });
  }

  Future<void> _showCategoryFilter(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final categories = _quoteService.getCategories();
    
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.get('filter_category'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.get('filter_category_desc'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 전체 선택 (필터 해제)
                ChoiceChip(
                  label: Text(l10n.get('all_categories')),
                  selected: _selectedCategory == null,
                  onSelected: (selected) async {
                    await _quoteService.setSelectedCategory(null);
                    setState(() {
                      _selectedCategory = null;
                      _currentQuote = _quoteService.getDailyQuote();
                      _showDailyQuote = true;
                    });
                    Navigator.pop(context);
                  },
                ),
                // 각 카테고리
                ...categories.map((category) => ChoiceChip(
                  label: Text(l10n.getCategory(category)),
                  selected: _selectedCategory?.toLowerCase() == category.toLowerCase(),
                  onSelected: (selected) async {
                    await _quoteService.setSelectedCategory(category);
                    setState(() {
                      _selectedCategory = category;
                      _currentQuote = _quoteService.getDailyQuote();
                      _showDailyQuote = true;
                    });
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_currentQuote != null) {
      await _quoteService.toggleFavorite(_currentQuote!);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // 헤더
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _showDailyQuote ? l10n.get('daily_quote') : l10n.get('random_quote'),
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(DateTime.now(), l10n),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                                      ),
                                    ),
                                    if (_selectedCategory != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          l10n.getCategory(_selectedCategory!),
                                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // 필터 버튼
                              IconButton(
                                onPressed: () => _showCategoryFilter(context),
                                icon: Icon(
                                  _selectedCategory != null ? Icons.filter_alt : Icons.filter_alt_outlined,
                                  color: _selectedCategory != null 
                                      ? Theme.of(context).colorScheme.primary 
                                      : null,
                                ),
                                tooltip: l10n.get('filter_category'),
                              ),
                              if (!_showDailyQuote)
                                IconButton(
                                  onPressed: _showDailyQuoteAgain,
                                  icon: const Icon(Icons.today),
                                  tooltip: l10n.get('view_daily_quote'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // 명언 카드
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: QuoteCard(
                            quote: _currentQuote!,
                            isFavorite: _quoteService.isFavorite(_currentQuote!),
                            onFavoritePressed: _toggleFavorite,
                          ),
                        ),
                      ),
                    ),
                    
                    // 새 명언 버튼
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _getNewQuote,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.get('new_quote')),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ),
                    
                    // 배너 광고 (웹이 아닌 경우에만)
                    if (!kIsWeb)
                      const BannerAdWidget(),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final locale = l10n.locale.languageCode;
    
    switch (locale) {
      case 'ko':
        const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
        return '${date.year}년 ${date.month}월 ${date.day}일 (${weekdays[date.weekday - 1]})';
      case 'ja':
        const weekdaysJa = ['月', '火', '水', '木', '金', '土', '日'];
        return '${date.year}年${date.month}月${date.day}日 (${weekdaysJa[date.weekday - 1]})';
      case 'zh':
        const weekdaysZh = ['一', '二', '三', '四', '五', '六', '日'];
        return '${date.year}年${date.month}月${date.day}日 周${weekdaysZh[date.weekday - 1]}';
      default:
        const weekdaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return '${weekdaysEn[date.weekday - 1]}, ${monthsEn[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
