import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_card.dart';
import '../l10n/app_localizations.dart';

class QuoteListScreen extends StatefulWidget {
  final String title;
  final List<Quote> quotes;

  const QuoteListScreen({
    super.key,
    required this.title,
    required this.quotes,
  });

  @override
  State<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends State<QuoteListScreen> {
  final QuoteService _quoteService = QuoteService();
  final AdService _adService = AdService();

  Future<void> _toggleFavorite(Quote quote) async {
    await _quoteService.toggleFavorite(quote);
    setState(() {});
  }

  // 명언이 잠겨있는지 확인 (짝수번째 = 잠금)
  bool _isQuoteLocked(int index) {
    if (_adService.isPremium || _adService.isUnlocked) return false;
    return index % 2 == 1; // 인덱스 1,3,5,7... 잠금
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: widget.quotes.length,
        itemBuilder: (context, index) {
          final quote = widget.quotes[index];
          final isLocked = _isQuoteLocked(index);

          if (isLocked) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildLockedQuoteCard(context, index, l10n),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: QuoteCard(
              quote: quote,
              isFavorite: _quoteService.isFavorite(quote),
              onFavoritePressed: () => _toggleFavorite(quote),
              compact: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLockedQuoteCard(
      BuildContext context, int index, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: _unlockQuotes,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.get('locked_quote'),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.get('watch_ad_to_unlock'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_outline,
                color: colorScheme.primary,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
