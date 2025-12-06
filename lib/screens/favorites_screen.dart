import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../widgets/quote_card.dart';
import '../widgets/banner_ad_widget.dart';
import '../l10n/app_localizations.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final QuoteService _quoteService = QuoteService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _quoteService.loadQuotes();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(Quote quote) async {
    await _quoteService.toggleFavorite(quote);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = _quoteService.favorites;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.get('favorites')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: favorites.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.get('no_favorites'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.get('add_favorites_hint'),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final quote = favorites[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: QuoteCard(
                                quote: quote,
                                isFavorite: true,
                                onFavoritePressed: () => _toggleFavorite(quote),
                                compact: true,
                              ),
                            );
                          },
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
