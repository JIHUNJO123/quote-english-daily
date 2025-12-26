#!/usr/bin/env python3
"""
GPT-4o mini를 사용하여 모든 명언을 주요 8개 언어로 미리 번역
"""

import json
import os
import time
import requests

# OpenAI API 설정
API_KEY = os.environ.get('OPENAI_API_KEY', '')
API_URL = 'https://api.openai.com/v1/chat/completions'

# 번역할 주요 언어 6개
TARGET_LANGUAGES = {
    'ko': 'Korean',
    'ja': 'Japanese',
    'zh': 'Chinese (Simplified)',
    'es': 'Spanish',
    'fr': 'French',
    'pt': 'Portuguese',
}

def translate_quote(quote_text, target_lang_code, target_lang_name):
    """GPT-4o mini를 사용하여 명언 번역"""
    if not API_KEY:
        print("ERROR: OPENAI_API_KEY environment variable not set")
        return None
    
    try:
        response = requests.post(
            API_URL,
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {API_KEY}',
            },
            json={
                'model': 'gpt-4o-mini',
                'messages': [
                    {
                        'role': 'system',
                        'content': f'You are a professional translator. Translate the given English quote to {target_lang_name}. Maintain the meaning, tone, and style of the original quote. Only return the translation, nothing else.',
                    },
                    {
                        'role': 'user',
                        'content': quote_text,
                    },
                ],
                'temperature': 0.3,
                'max_tokens': 500,
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            translation = data['choices'][0]['message']['content'].strip()
            
            # 에러 체크
            if translation and not any(word in translation.lower() for word in ['error', 'sorry', 'cannot']):
                return translation
        else:
            print(f"API Error: {response.status_code} - {response.text}")
            
    except Exception as e:
        print(f"Translation error: {e}")
    
    return None

def main():
    if not API_KEY:
        print("ERROR: Please set OPENAI_API_KEY environment variable")
        print("Example: export OPENAI_API_KEY='your-api-key'")
        return
    
    # 명언 데이터 로드
    print("Loading quotes...")
    with open('assets/quotes.json', 'r', encoding='utf-8') as f:
        quotes = json.load(f)
    
    print(f"Total quotes: {len(quotes)}")
    print(f"Target languages: {list(TARGET_LANGUAGES.keys())}")
    
    # 번역 데이터 구조
    translations = {}
    
    # 각 명언 번역
    total = len(quotes) * len(TARGET_LANGUAGES)
    current = 0
    
    for quote in quotes:
        quote_text = quote['quote']
        quote_id = quote['id']
        
        translations[quote_id] = {
            'quote': quote_text,
            'translations': {}
        }
        
        for lang_code, lang_name in TARGET_LANGUAGES.items():
            current += 1
            print(f"[{current}/{total}] Translating quote {quote_id} to {lang_name}...")
            
            translation = translate_quote(quote_text, lang_code, lang_name)
            
            if translation:
                translations[quote_id]['translations'][lang_code] = translation
                print(f"  [OK] {lang_name}: {translation[:50]}...")
            else:
                print(f"  [FAIL] Failed to translate to {lang_name}")
            
            # API rate limit 방지 (초당 3개 요청 제한)
            time.sleep(0.4)
    
    # 번역 데이터 저장
    output_file = 'assets/quotes_translations.json'
    print(f"\nSaving translations to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(translations, f, ensure_ascii=False, indent=2)
    
    print(f"\n[SUCCESS] Translation complete!")
    print(f"  Total quotes: {len(quotes)}")
    print(f"  Languages: {len(TARGET_LANGUAGES)}")
    print(f"  Output file: {output_file}")

if __name__ == '__main__':
    main()

