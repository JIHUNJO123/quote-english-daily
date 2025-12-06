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
  String? _selectedCategory; // 선택된 카테고리 필터

  Future<void> loadQuotes() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _quotes = jsonList.map((json) => Quote.fromJson(json)).toList();
      await _loadFavorites();
      await _loadSelectedCategory();
    } catch (e) {
      print('Error loading quotes: $e');
      _quotes = [];
    }
  }

  // 선택된 카테고리 저장/로드
  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCategory = prefs.getString('selected_category');
  }

  Future<void> setSelectedCategory(String? category) async {
    _selectedCategory = category;
    final prefs = await SharedPreferences.getInstance();
    if (category == null) {
      await prefs.remove('selected_category');
    } else {
      await prefs.setString('selected_category', category);
    }
  }

  String? get selectedCategory => _selectedCategory;

  // 필터링된 명언 목록
  List<Quote> get _filteredQuotes {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      return _quotes;
    }
    return _quotes.where((q) => 
      q.category.toLowerCase() == _selectedCategory!.toLowerCase()
    ).toList();
  }

  List<Quote> get allQuotes => _quotes;
  List<Quote> get favorites => _favorites;

  Quote getRandomQuote() {
    final quotes = _filteredQuotes;
    if (quotes.isEmpty) {
      return Quote(
        id: 0,
        text: 'No quotes available',
        author: 'Unknown',
        category: '',
        tags: [],
      );
    }
    return quotes[_random.nextInt(quotes.length)];
  }

  Quote getDailyQuote() {
    final quotes = _filteredQuotes;
    if (quotes.isEmpty) {
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
    final index = (dayOfYear + now.year) % quotes.length;
    return quotes[index];
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
