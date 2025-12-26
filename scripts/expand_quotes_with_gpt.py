#!/usr/bin/env python3
"""
GPT API를 사용하여 더 많은 상업적으로 사용 가능한 명언 생성
"""

import json
import requests
import time

# OpenAI API 설정
# API 키는 환경 변수에서 가져옴
import os
API_KEY = os.environ.get('OPENAI_API_KEY', '')
API_URL = 'https://api.openai.com/v1/chat/completions'

if not API_KEY:
    print('Warning: OPENAI_API_KEY environment variable not set')

def generate_quotes_with_gpt(category, num_quotes=50):
    """GPT API를 사용하여 특정 카테고리의 명언 생성"""
    prompt = f"""Generate {num_quotes} inspiring, commercial-use-friendly quotes about {category}. 
Each quote should be:
1. Original or from public domain sources
2. Suitable for commercial use
3. Inspiring and meaningful
4. From well-known authors, philosophers, or public figures
5. Format: "quote text" - Author Name

Return only the quotes in this format:
"Quote text" - Author Name
"Quote text" - Author Name
..."""

    try:
        response = requests.post(
            API_URL,
            headers={
                'Content-Type': 'application/json',
                'Authorization': f'Bearer {API_KEY}'
            },
            json={
                'model': 'gpt-4o-mini',
                'messages': [
                    {'role': 'system', 'content': 'You are a helpful assistant that generates inspiring quotes suitable for commercial use.'},
                    {'role': 'user', 'content': prompt}
                ],
                'temperature': 0.8,
                'max_tokens': 2000
            },
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            content = data['choices'][0]['message']['content']
            return content
        else:
            print(f"API Error: {response.status_code} - {response.text}")
            return None
    except Exception as e:
        print(f"Error generating quotes: {e}")
        return None

def parse_quotes(text, category):
    """생성된 텍스트에서 명언 파싱"""
    quotes = []
    lines = text.strip().split('\n')
    
    for line in lines:
        line = line.strip()
        if not line or not line.startswith('"'):
            continue
        
        # "Quote" - Author 형식 파싱
        if ' - ' in line:
            parts = line.split(' - ', 1)
            quote_text = parts[0].strip().strip('"')
            author = parts[1].strip() if len(parts) > 1 else "Unknown"
            
            if quote_text and len(quote_text) > 10:  # 최소 길이 체크
                quotes.append({
                    "quote": quote_text,
                    "author": author,
                    "category": category
                })
    
    return quotes

# 기존 명언 로드
with open('../assets/quotes.json', 'r', encoding='utf-8') as f:
    existing_quotes = json.load(f)

print(f"Existing quotes: {len(existing_quotes)}")
print(f"Unique quotes: {len(set(q['quote'] for q in existing_quotes))}")

# 각 카테고리별로 추가 명언 생성
categories = ['happiness', 'inspiration', 'love', 'success', 'truth', 'poetry', 'death', 'romance', 'science', 'time']
new_quotes = []

for category in categories:
    print(f"\nGenerating quotes for {category}...")
    gpt_output = generate_quotes_with_gpt(category, num_quotes=30)
    
    if gpt_output:
        parsed = parse_quotes(gpt_output, category)
        new_quotes.extend(parsed)
        print(f"Generated {len(parsed)} quotes for {category}")
    
    time.sleep(1)  # API 레이트 리밋 방지

# 기존 명언과 합치기
all_quotes = existing_quotes.copy()

# 중복 제거하면서 추가
existing_quote_texts = set(q['quote'] for q in existing_quotes)
quote_id = len(existing_quotes)

for quote in new_quotes:
    if quote['quote'] not in existing_quote_texts:
        all_quotes.append({
            "id": quote_id,
            "quote": quote['quote'],
            "author": quote['author'],
            "category": quote['category'],
            "tags": []
        })
        existing_quote_texts.add(quote['quote'])
        quote_id += 1

# 저장
with open('../assets/quotes.json', 'w', encoding='utf-8') as f:
    json.dump(all_quotes, f, indent=2, ensure_ascii=False)

print(f"\nTotal quotes: {len(all_quotes)}")
print(f"Unique quotes: {len(set(q['quote'] for q in all_quotes))}")
print(f"New quotes added: {len(all_quotes) - len(existing_quotes)}")

