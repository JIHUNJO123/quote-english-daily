import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quote.dart';

class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  List<Quote> _quotes = [];
  List<Quote> _favorites = [];
  final Random _random = Random();

  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _quotes = jsonList.map((json) => Quote.fromJson(json)).toList();
      await _loadFavorites();
    } catch (e) {
      print('Error loading quotes: $e');
      _quotes = [];
    }
  }

  List<Quote> get allQuotes => _quotes;
  List<Quote> get favorites => _favorites;

  Quote getRandomQuote() {
    if (_quotes.isEmpty) {
      return Quote(
        id: 0,
        text: 'No quotes available',
        author: 'Unknown',
        category: '',
        tags: [],
      );
    }
    return _quotes[_random.nextInt(_quotes.length)];
  }

  Quote getDailyQuote() {
    if (_quotes.isEmpty) {
      return Quote(
        id: 0,
        text: 'No quotes available',
        author: 'Unknown',
        category: '',
        tags: [],
      );
    }
    
    // 날짜 기반으로 동일한 명언 반환
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final index = (dayOfYear + now.year) % _quotes.length;
    return _quotes[index];
  }

  List<Quote> getQuotesByCategory(String category) {
    return _quotes.where((quote) => 
      quote.category.toLowerCase() == category.toLowerCase()
    ).toList();
  }

  List<String> getCategories() {
    final categories = _quotes.map((q) => q.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // 즐겨찾기 관련
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorites') ?? [];
    _favorites = _quotes.where((q) => favIds.contains(q.id.toString())).toList();
  }

  Future<void> toggleFavorite(Quote quote) async {
    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favorites') ?? [];
    
    if (_favorites.contains(quote)) {
      _favorites.remove(quote);
      favIds.remove(quote.id.toString());
    } else {
      _favorites.add(quote);
      favIds.add(quote.id.toString());
    }
    
    await prefs.setStringList('favorites', favIds);
  }

  bool isFavorite(Quote quote) {
    return _favorites.any((q) => q.id == quote.id);
  }
}
