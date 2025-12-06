import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
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

  Future<void> _toggleFavorite(Quote quote) async {
    await _quoteService.toggleFavorite(quote);
    setState(() {});
  }

  void _shareQuote(Quote quote) {
    Share.share(
      '"${quote.text}"\n\n- ${quote.author}\n\n#오늘의명언',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.quotes.length,
        itemBuilder: (context, index) {
          final quote = widget.quotes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: QuoteCard(
              quote: quote,
              isFavorite: _quoteService.isFavorite(quote),
              onFavoritePressed: () => _toggleFavorite(quote),
              onSharePressed: () => _shareQuote(quote),
              compact: true,
            ),
          );
        },
      ),
    );
  }
}
