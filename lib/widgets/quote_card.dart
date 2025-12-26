import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../l10n/app_localizations.dart';
import '../services/translation_service.dart';
import '../services/ad_service.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final bool compact;
  final bool isLocked;
  final VoidCallback? onUnlockPressed;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.isFavorite,
    required this.onFavoritePressed,
    this.compact = false,
    this.isLocked = false,
    this.onUnlockPressed,
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
    final offline =
        _translationService.getOfflineTranslation(widget.quote.text, langCode);
    if (offline != null) {
      setState(() {
        _translation = offline;
        _isTranslating = false;
      });
      return;
    }

    // 온라인 번역 시도
    final translation =
        await _translationService.getTranslation(widget.quote.text, langCode);
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

    // 잠금 상태일 때 잠금 카드 표시
    if (widget.isLocked) {
      return Card(
        elevation: widget.compact ? 2 : 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: widget.onUnlockPressed,
          child: Container(
            padding: EdgeInsets.all(widget.compact ? 14 : 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: widget.compact ? 40 : 60,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ),
                SizedBox(height: widget.compact ? 12 : 20),
                Text(
                  l10n.get('locked_quote'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.get('watch_ad_unlock'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: widget.compact ? 12 : 20),
                FilledButton.icon(
                  onPressed: widget.onUnlockPressed,
                  icon: const Icon(Icons.play_circle_outline),
                  label: Text(l10n.get('tap_to_unlock')),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: widget.compact ? 2 : 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: widget.isLocked ? null : () => _copyToClipboard(context),
        child: Container(
          padding: EdgeInsets.all(widget.compact ? 14 : 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                          fontSize: widget.compact ? 14 : 17,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // 번역 표시
                      if (showTranslateButton &&
                          _showTranslation &&
                          _translation != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _translation!,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontSize: widget.compact ? 12 : 14,
                                  height: 1.4,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
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

                      SizedBox(height: widget.compact ? 10 : 16),

                      // 저자
                      Text(
                        widget.quote.author,
                        style: GoogleFonts.lora(
                          fontSize: widget.compact ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: widget.compact ? 8 : 14),

              // 카테고리 태그
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  l10n.getCategory(widget.quote.category).toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),

              SizedBox(height: widget.compact ? 8 : 14),

              // 액션 버튼들
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: widget.onFavoritePressed,
                    icon: Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.isFavorite ? Colors.red : null,
                    ),
                    tooltip: l10n.get('favorites'),
                  ),
                  // 번역 버튼 (영어가 아닌 경우만)
                  if (showTranslateButton)
                    IconButton(
                      onPressed: () async {
                        if (_showTranslation) {
                          // 이미 보여주고 있으면 숨기기
                          setState(() => _showTranslation = false);
                        } else {
                          // 번역이 없으면 먼저 로드
                          if (_translation == null) {
                            await _loadTranslation(langCode);
                          }
                          // 번역이 있으면 표시
                          if (_translation != null && mounted) {
                            setState(() => _showTranslation = true);
                          }
                        }
                      },
                      icon: Icon(
                        _showTranslation
                            ? Icons.translate
                            : Icons.translate_outlined,
                        color: _showTranslation
                            ? Theme.of(context).colorScheme.primary
                            : null,
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
