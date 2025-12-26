import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_card.dart';
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
  String? _selectedCategory;
  int _quoteViewCount = 0; // 명언 조회 수 (짝수번째 잠금용)

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

  // 현재 명언이 잠겨있는지 확인 (짝수번째 + 잠금해제 안됨)
  bool get _isCurrentQuoteLocked {
    if (_adService.isPremium || _adService.isUnlocked) return false;
    if (_showDailyQuote) return false; // 오늘의 명언은 항상 무료
    return _quoteViewCount % 2 == 0; // 짝수번째 잠금
  }

  Future<void> _getNewQuote() async {
    _quoteViewCount++;

    // 보상 명언이 있으면 사용
    await _quoteService.useRewardedQuote();

    setState(() {
      _currentQuote = _quoteService.getRandomQuote();
      _showDailyQuote = false;
    });
  }

  Future<void> _unlockQuotes() async {
    final l10n = AppLocalizations.of(context);

    await _adService.showRewardedAd(
      onRewarded: (rewardAmount, rewardType) async {
        await _adService.unlockUntilMidnight();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('unlocked_until_midnight')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {});
        }
      },
    );
  }

  // _showRewardedAd와 _unlockQuotes를 통일 - 자정까지 무료로
  Future<void> _showRewardedAdForUnlock() async {
    final l10n = AppLocalizations.of(context);

    await _adService.showRewardedAd(
      onRewarded: (rewardAmount, rewardType) async {
        await _adService.unlockUntilMidnight();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.get('unlocked_until_midnight')),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
          setState(() {});
        }
      },
    );
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
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
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

                // 추가 필터 토글 섹션
                _buildFilterToggleSection(context, l10n, setModalState),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                // 특수 카테고리 섹션 (추가 필터가 꺼져있을 때만)
                if (!_quoteService.filterFamousOnly &&
                    !_quoteService.filterShortOnly) ...[
                  _buildSpecialCategoryCard(
                    context,
                    icon: Icons.star,
                    title: l10n.get('category_famous'),
                    description: l10n.get('category_famous_desc'),
                    count: _quoteService.famousQuotesCount,
                    isSelected:
                        _selectedCategory == QuoteService.categoryFamous,
                    onTap: () async {
                      await _quoteService
                          .setSelectedCategory(QuoteService.categoryFamous);
                      setState(() {
                        _selectedCategory = QuoteService.categoryFamous;
                        _currentQuote = _quoteService.getDailyQuote();
                        _showDailyQuote = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildSpecialCategoryCard(
                    context,
                    icon: Icons.flash_on,
                    title: l10n.get('category_short'),
                    description: l10n.get('category_short_desc'),
                    count: _quoteService.shortQuotesCount,
                    isSelected: _selectedCategory == QuoteService.categoryShort,
                    onTap: () async {
                      await _quoteService
                          .setSelectedCategory(QuoteService.categoryShort);
                      setState(() {
                        _selectedCategory = QuoteService.categoryShort;
                        _currentQuote = _quoteService.getDailyQuote();
                        _showDailyQuote = true;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // 일반 카테고리
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // 전체 선택 (필터 해제)
                    ChoiceChip(
                      label: Text(
                          '${l10n.get('all_categories')} (${_quoteService.getFilteredCountForCategory(null)})'),
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
                    ...categories.map((category) {
                      final count =
                          _quoteService.getFilteredCountForCategory(category);
                      return ChoiceChip(
                        label: Text('${l10n.getCategory(category)} ($count)'),
                        selected: _selectedCategory?.toLowerCase() ==
                            category.toLowerCase(),
                        onSelected: count > 0
                            ? (selected) async {
                                await _quoteService
                                    .setSelectedCategory(category);
                                setState(() {
                                  _selectedCategory = category;
                                  _currentQuote = _quoteService.getDailyQuote();
                                  _showDailyQuote = true;
                                });
                                Navigator.pop(context);
                              }
                            : null,
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterToggleSection(
      BuildContext context, AppLocalizations l10n, StateSetter setModalState) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.get('additional_filters'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 유명인만 토글
            _buildFilterToggle(
              context,
              icon: Icons.star_outline,
              activeIcon: Icons.star,
              label: l10n.get('filter_famous_only'),
              value: _quoteService.filterFamousOnly,
              onChanged: (value) async {
                await _quoteService.setFilterFamousOnly(value);
                setModalState(() {});
                setState(() {
                  _currentQuote = _quoteService.getDailyQuote();
                });
              },
            ),
            const SizedBox(height: 8),
            // 짧은 것만 토글
            _buildFilterToggle(
              context,
              icon: Icons.short_text,
              activeIcon: Icons.short_text,
              label: l10n.get('filter_short_only'),
              value: _quoteService.filterShortOnly,
              onChanged: (value) async {
                await _quoteService.setFilterShortOnly(value);
                setModalState(() {});
                setState(() {
                  _currentQuote = _quoteService.getDailyQuote();
                });
              },
            ),
            if (_quoteService.filterFamousOnly ||
                _quoteService.filterShortOnly) ...[
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: colorScheme.onPrimaryContainer),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '${l10n.get('filtered_quotes_count')}: ${_quoteService.currentFilteredCount}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              value ? activeIcon : icon,
              color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          value ? colorScheme.primary : colorScheme.onSurface,
                      fontWeight: value ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected ? colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected ? colorScheme.onPrimary : colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, color: colorScheme.primary),
              ],
            ],
          ),
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
                                  _showDailyQuote
                                      ? l10n.get('daily_quote')
                                      : l10n.get('random_quote'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimaryContainer,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      _formatDate(DateTime.now(), l10n),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                                .withOpacity(0.7),
                                          ),
                                    ),
                                    if (_selectedCategory != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          l10n.getCategory(_selectedCategory!),
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
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
                                  _selectedCategory != null
                                      ? Icons.filter_alt
                                      : Icons.filter_alt_outlined,
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
                            isFavorite:
                                _quoteService.isFavorite(_currentQuote!),
                            onFavoritePressed: _toggleFavorite,
                            isLocked: _isCurrentQuoteLocked,
                            onUnlockPressed: _unlockQuotes,
                          ),
                        ),
                      ),
                    ),

                    // 잠금 해제 상태 표시
                    if (_adService.isUnlocked && !_adService.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_open,
                                size: 16, color: Colors.green),
                            const SizedBox(width: 6),
                            Text(
                              l10n.get('unlocked_until_midnight'),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),

                    // 새 명언 버튼 및 보상형 광고 버튼
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // 새 명언 버튼
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _getNewQuote,
                              icon: const Icon(Icons.refresh),
                              label: Text(l10n.get('new_quote')),
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                          ),

                          // 보상형 광고 버튼 - 자정까지 무료 잠금 해제
                          if (!kIsWeb &&
                              _adService.shouldShowAds &&
                              !_adService.isUnlocked)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _showRewardedAdForUnlock,
                                  icon: const Icon(Icons.lock_open),
                                  label: Text(l10n.get('watch_ad_unlock')),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    side: BorderSide(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // 잠금 해제 상태 표시
                          if (_adService.isUnlocked && !_adService.isPremium)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.get('unlocked_until_midnight'),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
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
        const monthsEn = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        return '${weekdaysEn[date.weekday - 1]}, ${monthsEn[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
