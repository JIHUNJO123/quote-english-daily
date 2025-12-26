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

  // 유명인 리스트 (확장)
  static const List<String> _famousPeople = [
    // 과학자/발명가
    'Einstein', 'Albert Einstein', 'Newton', 'Isaac Newton', 'Darwin',
    'Charles Darwin',
    'Galileo', 'Copernicus', 'Tesla', 'Nikola Tesla', 'Thomas Edison',
    'Stephen Hawking',
    'Marie Curie', 'Feynman', 'Carl Sagan', 'Neil deGrasse', 'Pasteur',
    'Edison',

    // 철학자/사상가
    'Aristotle', 'Plato', 'Socrates', 'Confucius', 'Buddha', 'Lao Tzu',
    'Sun Tzu',
    'Nietzsche', 'Voltaire', 'Descartes', 'Kant', 'Hegel', 'Marx', 'Rousseau',
    'Seneca', 'Marcus Aurelius', 'Epictetus', 'Emerson', 'Thoreau',
    'Kierkegaard',
    'Schopenhauer', 'Spinoza', 'Locke', 'Hume', 'Bacon', 'Pascal', 'Montaigne',

    // 작가/시인
    'Shakespeare', 'Mark Twain', 'Oscar Wilde', 'Hemingway', 'Ernest Hemingway',
    'Maya Angelou', 'Paulo Coelho', 'Rumi', 'Tolstoy', 'Leo Tolstoy',
    'Dostoevsky',
    'Dickens', 'Charles Dickens', 'Jane Austen', 'Virginia Woolf',
    'Edgar Allan Poe',
    'Victor Hugo', 'Goethe', 'Homer', 'Dante', 'Cervantes', 'Kafka', 'Orwell',
    'George Orwell', 'Aldous Huxley', 'F. Scott Fitzgerald', 'Fitzgerald',
    'Faulkner',
    'Steinbeck', 'Chekhov', 'Ibsen', 'Tennessee Williams', 'Arthur Miller',
    'Harper Lee', 'Toni Morrison', 'Gabriel García Márquez', 'Borges', 'Neruda',
    'Walt Whitman', 'Robert Frost', 'T.S. Eliot', 'Wordsworth', 'Keats',
    'Shelley',
    'Byron', 'William Blake', 'Yeats', 'Emily Dickinson', 'Sylvia Plath',
    'Langston Hughes',
    'Dr. Seuss', 'C.S. Lewis', 'J.R.R. Tolkien', 'Roald Dahl',
    'Agatha Christie',
    'Stephen King', 'J.K. Rowling', 'Dan Brown', 'Haruki Murakami',

    // 정치인/지도자
    'Gandhi', 'Mahatma Gandhi', 'Martin Luther King', 'Lincoln',
    'Abraham Lincoln',
    'Churchill', 'Winston Churchill', 'Nelson Mandela', 'Mandela',
    'John F. Kennedy',
    'Kennedy', 'JFK', 'Napoleon', 'Theodore Roosevelt', 'Franklin D. Roosevelt',
    'FDR',
    'Washington', 'George Washington', 'Jefferson', 'Thomas Jefferson',
    'Reagan',
    'Obama', 'Trump', 'Biden', 'Clinton', 'Margaret Thatcher',
    'Queen Elizabeth',
    'Princess Diana', 'Alexander the Great', 'Caesar', 'Julius Caesar',
    'Cleopatra',
    'Che Guevara', 'Malcolm X', 'Frederick Douglass', 'Harriet Tubman',

    // 종교/영적 지도자
    'Dalai Lama', 'Mother Teresa', 'Pope Francis', 'Pope John Paul',
    'Billy Graham',
    'Thich Nhat Hanh', 'Deepak Chopra', 'Eckhart Tolle', 'Osho', 'Krishnamurti',

    // 비즈니스/기업가
    'Steve Jobs', 'Bill Gates', 'Warren Buffett', 'Elon Musk', 'Jeff Bezos',
    'Henry Ford', 'Walt Disney', 'Ray Kroc', 'Richard Branson',
    'Mark Zuckerberg',
    'Jack Ma', 'Oprah', 'Oprah Winfrey', 'Dale Carnegie', 'Napoleon Hill',
    'Tony Robbins', 'Jim Rohn', 'Zig Ziglar', 'Brian Tracy', 'Robert Kiyosaki',

    // 스포츠
    'Michael Jordan', 'Muhammad Ali', 'Bruce Lee', 'Kobe Bryant',
    'LeBron James',
    'Tiger Woods', 'Serena Williams', 'Roger Federer', 'Messi', 'Ronaldo',
    'Pelé', 'Maradona', 'Vince Lombardi', 'Wayne Gretzky', 'Babe Ruth',
    'Michael Phelps', 'Usain Bolt', 'Tom Brady',

    // 엔터테인먼트/예술
    'Marilyn Monroe', 'Audrey Hepburn', 'Charlie Chaplin', 'Alfred Hitchcock',
    'Steven Spielberg', 'Quentin Tarantino', 'Stanley Kubrick',
    'Francis Ford Coppola',
    'Walt Disney', 'Jim Henson', 'Robin Williams', 'Morgan Freeman',
    'Tom Hanks',
    'Meryl Streep', 'Denzel Washington', 'Clint Eastwood', 'Robert De Niro',
    'Leonardo DiCaprio', 'Brad Pitt', 'Angelina Jolie', 'Johnny Depp',
    'John Lennon', 'Paul McCartney', 'Bob Dylan', 'Elvis', 'Elvis Presley',
    'Michael Jackson', 'Prince', 'David Bowie', 'Madonna', 'Whitney Houston',
    'Bob Marley', 'Freddie Mercury', 'Jimi Hendrix', 'Frank Sinatra', 'Beyoncé',
    'Jay-Z', 'Kanye West', 'Taylor Swift', 'Lady Gaga', 'Rihanna',
    'Picasso', 'Van Gogh', 'Da Vinci', 'Leonardo da Vinci', 'Michelangelo',
    'Monet', 'Rembrandt', 'Salvador Dalí', 'Andy Warhol', 'Frida Kahlo',

    // 심리학자/학자
    'Sigmund Freud', 'Freud', 'Carl Jung', 'Jung', 'Carl Rogers', 'Maslow',
    'B.F. Skinner', 'Pavlov', 'Noam Chomsky', 'Joseph Campbell',
    'Jordan Peterson',

    // 여성 리더/활동가
    'Helen Keller', 'Anne Frank', 'Eleanor Roosevelt', 'Rosa Parks',
    'Susan B. Anthony',
    'Gloria Steinem', 'Ruth Bader Ginsburg', 'Malala', 'Greta Thunberg',
    'Michelle Obama',
    'Hillary Clinton', 'Angela Merkel', 'Coco Chanel', 'Amelia Earhart',

    // 철학자/심리학자 추가
    'Albert Camus', 'Jean-Paul Sartre', 'Simone de Beauvoir', 'Hannah Arendt',
    'Bertrand Russell', 'Ludwig Wittgenstein', 'William James', 'John Dewey',

    // 기타 유명인
    'Benjamin Franklin', 'Nikola Tesla', 'Wright Brothers', 'Alan Turing',
    'Machiavelli', 'Nostradamus', 'Rasputin', 'Florence Nightingale',
    'Alexander Graham Bell', 'Gutenberg', 'Marco Polo', 'Christopher Columbus',
    'Vasco da Gama', 'Ferdinand Magellan', 'Neil Armstrong', 'Buzz Aldrin',
    'Yuri Gagarin', 'Sally Ride',

    // 현대 사상가/작가
    'Simon Sinek', 'Malcolm Gladwell', 'Seth Godin', 'Tim Ferriss',
    'Gary Vaynerchuk',
    'Brené Brown', 'Adam Grant', 'Daniel Pink', 'Angela Duckworth',
    'James Clear',
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

  // 외부에서 사용 가능한 유명인 확인 메서드
  bool isFamousPerson(String author) {
    final authorLower = author.toLowerCase();
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
          .where((q) =>
              q.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    // 추가 필터 적용 (특수 카테고리가 아닌 경우에만)
    if (_selectedCategory != categoryFamous &&
        _selectedCategory != categoryShort) {
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
