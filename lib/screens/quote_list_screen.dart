import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import '../widgets/quote_card.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _hasRestoredScroll = false;

  @override
  void initState() {
    super.initState();
    _restoreScrollPosition();
  }

  Future<void> _restoreScrollPosition() async {
    if (_hasRestoredScroll) return;
    
    final prefs = await SharedPreferences.getInstance();
    final scrollOffset = prefs.getDouble('scroll_${widget.title}') ?? 0.0;
    
    if (scrollOffset > 0 && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(scrollOffset);
          _hasRestoredScroll = true;
        }
      });
    } else {
      _hasRestoredScroll = true;
    }
  }

  Future<void> _saveScrollPosition() async {
    if (!_scrollController.hasClients) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scroll_${widget.title}', _scrollController.offset);
  }

  @override
  void dispose() {
    _saveScrollPosition();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(Quote quote) async {
    await _quoteService.toggleFavorite(quote);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: widget.quotes.length,
        itemBuilder: (context, index) {
          final quote = widget.quotes[index];
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
}
