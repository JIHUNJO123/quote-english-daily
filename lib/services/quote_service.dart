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
  int _rewardedQuotes = 0; // 보상으로 받은 명언 수
  
  // 추가 필터 옵션
  bool _filterFamousOnly = false;
  bool _filterShortOnly = false;

  // 특수 카테고리 상수
  static const String categoryFamous = '_FAMOUS_';
  static const String categoryShort = '_SHORT_';

  // 유명인 리스트
  static const List<String> _famousPeople = [
    'Einstein',
    'Gandhi',
    'Steve Jobs',
    'Mark Twain',
    'Oscar Wilde',
    'Aristotle',
    'Plato',
    'Buddha',
    'Confucius',
    'Shakespeare',
    'Martin Luther King',
    'Lincoln',
    'Churchill',
    'Nelson Mandela',
    'Dalai Lama',
    'Mother Teresa',
    'Oprah',
    'Walt Disney',
    'Henry Ford',
    'Thomas Edison',
    'Benjamin Franklin',
    'John F. Kennedy',
    'Napoleon',
    'Socrates',
    'Voltaire',
    'Nietzsche',
    'Hemingway',
    'Maya Angelou',
    'Paulo Coelho',
    'Rumi',
    'Lao Tzu',
    'Sun Tzu',
    'Warren Buffett',
    'Elon Musk',
    'Bill Gates',
    'Michael Jordan',
    'Muhammad Ali',
    'Bruce Lee',
    'Kobe Bryant',
    'Marilyn Monroe',
    'Audrey Hepburn',
    'Albert Camus',
    'Leo Tolstoy',
    'Sigmund Freud',
    'Carl Jung',
    'Stephen Hawking',
    'Helen Keller',
    'Anne Frank',
    'Eleanor Roosevelt',
    'Rosa Parks',
    'Albert Einstein',
    'Mahatma Gandhi',
    'Winston Churchill',
  ];

  int get rewardedQuotes => _rewardedQuotes;

  Future<void> loadQuotes() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/quotes.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _quotes = jsonList.map((json) => Quote.fromJson(json)).toList();
      await _loadFavorites();
      await _loadSelectedCategory();
      await _loadRewardedQuotes();
      await _loadFilterOptions();
    } catch (e) {
      print('Error loading quotes: $e');
      _quotes = [];
    }
  }

  // 보상 명언 수 로드/저장
  Future<void> _loadRewardedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    _rewardedQuotes = prefs.getInt('rewarded_quotes') ?? 0;
  }

  Future<void> addRewardedQuotes(int count) async {
    _rewardedQuotes += count;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rewarded_quotes', _rewardedQuotes);
  }

  Future<void> useRewardedQuote() async {
    if (_rewardedQuotes > 0) {
      _rewardedQuotes--;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('rewarded_quotes', _rewardedQuotes);
    }
  }

  // 선택된 카테고리 저장/로드
  Future<void> _loadSelectedCategory() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedCategory = prefs.getString('selected_category');
  }
  
  // 필터 옵션 저장/로드
  Future<void> _loadFilterOptions() async {
    final prefs = await SharedPreferences.getInstance();
    _filterFamousOnly = prefs.getBool('filter_famous_only') ?? false;
    _filterShortOnly = prefs.getBool('filter_short_only') ?? false;
  }
  
  // 필터 옵션 게터
  bool get filterFamousOnly => _filterFamousOnly;
  bool get filterShortOnly => _filterShortOnly;
  
  // 필터 옵션 세터
  Future<void> setFilterFamousOnly(bool value) async {
    _filterFamousOnly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('filter_famous_only', value);
  }
  
  Future<void> setFilterShortOnly(bool value) async {
    _filterShortOnly = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('filter_short_only', value);
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

  // 유명인 명언인지 확인
  bool _isFamousQuote(Quote quote) {
    final authorLower = quote.author.toLowerCase();
    return _famousPeople
        .any((person) => authorLower.contains(person.toLowerCase()));
  }

  // 짧은 명언인지 확인 (100자 이하)
  bool _isShortQuote(Quote quote) {
    return quote.text.length <= 100;
  }
  
  // 추가 필터 적용
  List<Quote> _applyAdditionalFilters(List<Quote> quotes) {
    var filtered = quotes;
    
    if (_filterFamousOnly) {
      filtered = filtered.where((q) => _isFamousQuote(q)).toList();
    }
    
    if (_filterShortOnly) {
      filtered = filtered.where((q) => _isShortQuote(q)).toList();
    }
    
    return filtered;
  }

  // 필터링된 명언 목록
  List<Quote> get _filteredQuotes {
    List<Quote> baseQuotes;
    
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      baseQuotes = _quotes;
    } else if (_selectedCategory == categoryFamous) {
      // 특수 카테고리: Famous (유명인)
      baseQuotes = _quotes.where((q) => _isFamousQuote(q)).toList();
    } else if (_selectedCategory == categoryShort) {
      // 특수 카테고리: Short (100자 이하)
      baseQuotes = _quotes.where((q) => _isShortQuote(q)).toList();
    } else {
      // 일반 카테고리
      baseQuotes = _quotes
          .where((q) => q.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }
    
    // 추가 필터 적용 (특수 카테고리가 아닌 경우에만)
    if (_selectedCategory != categoryFamous && _selectedCategory != categoryShort) {
      return _applyAdditionalFilters(baseQuotes);
    }
    
    return baseQuotes;
  }

  // 특수 카테고리별 명언 수
  int get famousQuotesCount => _quotes.where((q) => _isFamousQuote(q)).length;
  int get shortQuotesCount => _quotes.where((q) => _isShortQuote(q)).length;
  
  // 현재 필터에 맞는 명언 수 (추가 필터 적용 후)
  int get currentFilteredCount => _filteredQuotes.length;
  
  // 카테고리별 필터 적용 후 명언 수 계산
  int getFilteredCountForCategory(String? category) {
    List<Quote> baseQuotes;
    
    if (category == null) {
      baseQuotes = _quotes;
    } else if (category == categoryFamous || category == categoryShort) {
      // 특수 카테고리는 추가 필터 적용 안함
      if (category == categoryFamous) {
        return _quotes.where((q) => _isFamousQuote(q)).length;
      } else {
        return _quotes.where((q) => _isShortQuote(q)).length;
      }
    } else {
      baseQuotes = _quotes
          .where((q) => q.category.toLowerCase() == category.toLowerCase())
          .toList();
    }
    
    return _applyAdditionalFilters(baseQuotes).length;
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
    return _quotes
        .where(
            (quote) => quote.category.toLowerCase() == category.toLowerCase())
        .toList();
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
    _favorites =
        _quotes.where((q) => favIds.contains(q.id.toString())).toList();
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
