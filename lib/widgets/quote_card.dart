import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../l10n/app_localizations.dart';
import '../services/translation_service.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final bool compact;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.compact = false,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> {
  final TranslationService _translationService = TranslationService();
  String? _translation;
  bool _isTranslating = false;
  bool _showTranslation = false;

  @override
  void didUpdateWidget(covariant QuoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 명언이 바뀌면 번역 상태 초기화
    if (oldWidget.quote.text != widget.quote.text) {
      setState(() {
        _translation = null;
        _showTranslation = false;
        _isTranslating = false;
      });
    }
  }

  void _copyToClipboard(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    Clipboard.setData(ClipboardData(
      text: '"${widget.quote.text}"\n\n- ${widget.quote.author}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.get('copied_to_clipboard')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadTranslation(String langCode) async {
    if (langCode == 'en' || _translation != null) return;
    
    setState(() => _isTranslating = true);
    
    // 먼저 오프라인 번역 확인
    final offline = _translationService.getOfflineTranslation(widget.quote.text, langCode);
    if (offline != null) {
      setState(() {
        _translation = offline;
        _isTranslating = false;
      });
      return;
    }
    
    // 온라인 번역 시도
    final translation = await _translationService.getTranslation(widget.quote.text, langCode);
    if (mounted) {
      setState(() {
        _translation = translation;
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final langCode = Localizations.localeOf(context).languageCode;
    final showTranslateButton = langCode != 'en';

    return Card(
      elevation: widget.compact ? 2 : 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onLongPress: () => _copyToClipboard(context),
        child: Container(
          padding: EdgeInsets.all(widget.compact ? 20 : 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 따옴표 아이콘
              if (!widget.compact)
                Icon(
                  Icons.format_quote,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              
              if (!widget.compact) const SizedBox(height: 16),
              
              // 스크롤 가능한 명언 영역
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 영어 원문
                      Text(
                        widget.quote.text,
                        style: GoogleFonts.merriweather(
                          fontSize: widget.compact ? 16 : 20,
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      // 번역 표시
                      if (showTranslateButton && _showTranslation && _translation != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _translation!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: widget.compact ? 14 : 16,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      
                      if (_isTranslating) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(l10n.get('translating')),
                          ],
                        ),
                      ],
                      
                      SizedBox(height: widget.compact ? 16 : 24),
                      
                      // 저자
                      Text(
                        widget.quote.author,
                        style: GoogleFonts.lora(
                          fontSize: widget.compact ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: widget.compact ? 12 : 20),
              
              // 카테고리 태그
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.getCategory(widget.quote.category).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              SizedBox(height: widget.compact ? 12 : 20),
              
              // 액션 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onFavoritePressed,
                    icon: Icon(
                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : null,
                    ),
                    tooltip: l10n.get('favorites'),
                  ),
                  // 번역 버튼 (영어가 아닌 경우만)
                  if (showTranslateButton)
                    IconButton(
                      onPressed: () {
                        if (!_showTranslation && _translation == null) {
                          _loadTranslation(langCode);
                        }
                        setState(() => _showTranslation = !_showTranslation);
                      },
                      icon: Icon(
                        _showTranslation ? Icons.translate : Icons.translate_outlined,
                        color: _showTranslation ? Theme.of(context).colorScheme.primary : null,
                      ),
                      tooltip: l10n.get('translation'),
                    ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy),
                    tooltip: l10n.get('copy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
