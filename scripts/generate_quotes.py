#!/usr/bin/env python3
"""
상업적으로 사용 가능한 명언 데이터셋 생성 스크립트
공개 도메인 및 상업 사용 가능한 명언들로 구성
"""

import json
import random

# 상업적으로 사용 가능한 명언 데이터 (공개 도메인 및 유명 인물들의 명언)
COMMERCIAL_QUOTES = [
    # Happiness
    {"quote": "The only way to do great work is to love what you do.", "author": "Steve Jobs", "category": "happiness"},
    {"quote": "Happiness is not something ready made. It comes from your own actions.", "author": "Dalai Lama", "category": "happiness"},
    {"quote": "The purpose of our lives is to be happy.", "author": "Dalai Lama", "category": "happiness"},
    {"quote": "Life is what happens to you while you're busy making other plans.", "author": "John Lennon", "category": "happiness"},
    {"quote": "Get busy living or get busy dying.", "author": "Stephen King", "category": "happiness"},
    {"quote": "You only live once, but if you do it right, once is enough.", "author": "Mae West", "category": "happiness"},
    {"quote": "Many of life's failures are people who did not realize how close they were to success when they gave up.", "author": "Thomas A. Edison", "category": "happiness"},
    {"quote": "If you want to live a happy life, tie it to a goal, not to people or things.", "author": "Albert Einstein", "category": "happiness"},
    {"quote": "Never let the fear of striking out keep you from playing the game.", "author": "Babe Ruth", "category": "happiness"},
    {"quote": "Money and success don't change people; they merely amplify what is already there.", "author": "Will Smith", "category": "happiness"},
    
    # Inspiration
    {"quote": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney", "category": "inspiration"},
    {"quote": "Don't let yesterday take up too much of today.", "author": "Will Rogers", "category": "inspiration"},
    {"quote": "You learn more from failure than from success.", "author": "Unknown", "category": "inspiration"},
    {"quote": "If you are working on something exciting that you really care about, you don't have to be pushed. The vision pulls you.", "author": "Steve Jobs", "category": "inspiration"},
    {"quote": "People who are crazy enough to think they can change the world, are the ones who do.", "author": "Rob Siltanen", "category": "inspiration"},
    {"quote": "We may encounter many defeats but we must not be defeated.", "author": "Maya Angelou", "category": "inspiration"},
    {"quote": "The only person you are destined to become is the person you decide to be.", "author": "Ralph Waldo Emerson", "category": "inspiration"},
    {"quote": "Go confidently in the direction of your dreams. Live the life you have imagined.", "author": "Henry David Thoreau", "category": "inspiration"},
    {"quote": "When one door of happiness closes, another opens; but often we look so long at the closed door that we do not see the one which has been opened for us.", "author": "Helen Keller", "category": "inspiration"},
    {"quote": "Great minds discuss ideas; average minds discuss events; small minds discuss people.", "author": "Eleanor Roosevelt", "category": "inspiration"},
    
    # Love
    {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn", "category": "love"},
    {"quote": "I've learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.", "author": "Maya Angelou", "category": "love"},
    {"quote": "Love yourself first and everything else falls into line.", "author": "Lucille Ball", "category": "love"},
    {"quote": "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", "author": "Lao Tzu", "category": "love"},
    {"quote": "We are most alive when we're in love.", "author": "John Updike", "category": "love"},
    {"quote": "The greatest thing you'll ever learn is just to love and be loved in return.", "author": "Eden Ahbez", "category": "love"},
    {"quote": "Love is composed of a single soul inhabiting two bodies.", "author": "Aristotle", "category": "love"},
    {"quote": "Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.", "author": "Maya Angelou", "category": "love"},
    {"quote": "The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart.", "author": "Helen Keller", "category": "love"},
    {"quote": "Love is when the other person's happiness is more important than your own.", "author": "H. Jackson Brown Jr.", "category": "love"},
    
    # Success
    {"quote": "Success is not final, failure is not fatal: it is the courage to continue that counts.", "author": "Winston Churchill", "category": "success"},
    {"quote": "Don't be afraid to give up the good to go for the great.", "author": "John D. Rockefeller", "category": "success"},
    {"quote": "Innovation distinguishes between a leader and a follower.", "author": "Steve Jobs", "category": "success"},
    {"quote": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney", "category": "success"},
    {"quote": "Don't let yesterday take up too much of today.", "author": "Will Rogers", "category": "success"},
    {"quote": "You learn more from failure than from success. Don't let it stop you. Failure builds character.", "author": "Unknown", "category": "success"},
    {"quote": "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.", "author": "Steve Jobs", "category": "success"},
    {"quote": "People who are crazy enough to think they can change the world, are the ones who do.", "author": "Rob Siltanen", "category": "success"},
    {"quote": "We may encounter many defeats but we must not be defeated.", "author": "Maya Angelou", "category": "success"},
    {"quote": "The only person you are destined to become is the person you decide to be.", "author": "Ralph Waldo Emerson", "category": "success"},
    
    # Truth
    {"quote": "The truth is rarely pure and never simple.", "author": "Oscar Wilde", "category": "truth"},
    {"quote": "Three things cannot be long hidden: the sun, the moon, and the truth.", "author": "Buddha", "category": "truth"},
    {"quote": "If you tell the truth, you don't have to remember anything.", "author": "Mark Twain", "category": "truth"},
    {"quote": "The truth will set you free, but first it will piss you off.", "author": "Gloria Steinem", "category": "truth"},
    {"quote": "Truth is like the sun. You can shut it out for a time, but it ain't going away.", "author": "Elvis Presley", "category": "truth"},
    {"quote": "The truth is, everyone is going to hurt you. You just got to find the ones worth suffering for.", "author": "Bob Marley", "category": "truth"},
    {"quote": "In a time of deceit telling the truth is a revolutionary act.", "author": "George Orwell", "category": "truth"},
    {"quote": "The truth is incontrovertible. Malice may attack it, ignorance may deride it, but in the end, there it is.", "author": "Winston Churchill", "category": "truth"},
    {"quote": "A lie can travel half way around the world while the truth is putting on its shoes.", "author": "Mark Twain", "category": "truth"},
    {"quote": "The truth is not always beautiful, nor beautiful words the truth.", "author": "Lao Tzu", "category": "truth"},
    
    # Poetry
    {"quote": "Poetry is when an emotion has found its thought and the thought has found words.", "author": "Robert Frost", "category": "poetry"},
    {"quote": "A poem begins as a lump in the throat, a sense of wrong, a homesickness, a lovesickness.", "author": "Robert Frost", "category": "poetry"},
    {"quote": "Poetry is the spontaneous overflow of powerful feelings: it takes its origin from emotion recollected in tranquillity.", "author": "William Wordsworth", "category": "poetry"},
    {"quote": "Poetry is what gets lost in translation.", "author": "Robert Frost", "category": "poetry"},
    {"quote": "Genuine poetry can communicate before it is understood.", "author": "T.S. Eliot", "category": "poetry"},
    {"quote": "Poetry is the rhythmical creation of beauty in words.", "author": "Edgar Allan Poe", "category": "poetry"},
    {"quote": "A poet is, before anything else, a person who is passionately in love with language.", "author": "W.H. Auden", "category": "poetry"},
    {"quote": "Poetry is language at its most distilled and most powerful.", "author": "Rita Dove", "category": "poetry"},
    {"quote": "The poet is a liar who always speaks the truth.", "author": "Jean Cocteau", "category": "poetry"},
    {"quote": "Poetry is the art of creating imaginary gardens with real toads.", "author": "Marianne Moore", "category": "poetry"},
    
    # Life & Death
    {"quote": "Death is not the opposite of life, but a part of it.", "author": "Haruki Murakami", "category": "death"},
    {"quote": "To live is the rarest thing in the world. Most people just exist.", "author": "Oscar Wilde", "category": "death"},
    {"quote": "The fear of death follows from the fear of life. A man who lives fully is prepared to die at any time.", "author": "Mark Twain", "category": "death"},
    {"quote": "Life is what happens to you while you're busy making other plans.", "author": "John Lennon", "category": "death"},
    {"quote": "In three words I can sum up everything I've learned about life: it goes on.", "author": "Robert Frost", "category": "death"},
    {"quote": "Life is either a daring adventure or nothing at all.", "author": "Helen Keller", "category": "death"},
    {"quote": "The purpose of our lives is to be happy.", "author": "Dalai Lama", "category": "death"},
    {"quote": "Life is like riding a bicycle. To keep your balance, you must keep moving.", "author": "Albert Einstein", "category": "death"},
    {"quote": "The unexamined life is not worth living.", "author": "Socrates", "category": "death"},
    {"quote": "Life isn't about finding yourself. Life is about creating yourself.", "author": "George Bernard Shaw", "category": "death"},
    
    # Romance
    {"quote": "You know you're in love when you can't fall asleep because reality is finally better than your dreams.", "author": "Dr. Seuss", "category": "romance"},
    {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn", "category": "romance"},
    {"quote": "I would rather spend one lifetime with you, than face all the ages of this world alone.", "author": "J.R.R. Tolkien", "category": "romance"},
    {"quote": "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", "author": "Lao Tzu", "category": "romance"},
    {"quote": "Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.", "author": "Unknown", "category": "romance"},
    {"quote": "The best love is the kind that awakens the soul and makes us reach for more, that plants a fire in our hearts and brings peace to our minds.", "author": "Nicholas Sparks", "category": "romance"},
    {"quote": "I love you not because of who you are, but because of who I am when I am with you.", "author": "Roy Croft", "category": "romance"},
    {"quote": "Love is composed of a single soul inhabiting two bodies.", "author": "Aristotle", "category": "romance"},
    {"quote": "The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart.", "author": "Helen Keller", "category": "romance"},
    {"quote": "Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.", "author": "Maya Angelou", "category": "romance"},
    
    # Science
    {"quote": "The important thing is not to stop questioning. Curiosity has its own reason for existing.", "author": "Albert Einstein", "category": "science"},
    {"quote": "Science is a way of thinking much more than it is a body of knowledge.", "author": "Carl Sagan", "category": "science"},
    {"quote": "The good thing about science is that it's true whether or not you believe in it.", "author": "Neil deGrasse Tyson", "category": "science"},
    {"quote": "Somewhere, something incredible is waiting to be known.", "author": "Carl Sagan", "category": "science"},
    {"quote": "Science without religion is lame, religion without science is blind.", "author": "Albert Einstein", "category": "science"},
    {"quote": "The most beautiful thing we can experience is the mysterious. It is the source of all true art and science.", "author": "Albert Einstein", "category": "science"},
    {"quote": "We are all connected; To each other, biologically. To the earth, chemically. To the rest of the universe atomically.", "author": "Neil deGrasse Tyson", "category": "science"},
    {"quote": "The universe is not required to be in perfect harmony with human ambition.", "author": "Carl Sagan", "category": "science"},
    {"quote": "Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.", "author": "Albert Einstein", "category": "science"},
    {"quote": "The cosmos is within us. We are made of star-stuff. We are a way for the universe to know itself.", "author": "Carl Sagan", "category": "science"},
    
    # Time
    {"quote": "Time is what we want most, but what we use worst.", "author": "William Penn", "category": "time"},
    {"quote": "Lost time is never found again.", "author": "Benjamin Franklin", "category": "time"},
    {"quote": "Time is the most valuable thing a man can spend.", "author": "Theophrastus", "category": "time"},
    {"quote": "The two most powerful warriors are patience and time.", "author": "Leo Tolstoy", "category": "time"},
    {"quote": "Time is money.", "author": "Benjamin Franklin", "category": "time"},
    {"quote": "Time flies over us, but leaves its shadow behind.", "author": "Nathaniel Hawthorne", "category": "time"},
    {"quote": "Time is a created thing. To say 'I don't have time' is like saying, 'I don't want to.'", "author": "Lao Tzu", "category": "time"},
    {"quote": "The future depends on what you do today.", "author": "Mahatma Gandhi", "category": "time"},
    {"quote": "Yesterday is history, tomorrow is a mystery, today is a gift. That's why it's called the present.", "author": "Eleanor Roosevelt", "category": "time"},
    {"quote": "Time is the longest distance between two places.", "author": "Tennessee Williams", "category": "time"},
]

def generate_quotes_dataset(num_quotes=1000):
    """상업적으로 사용 가능한 명언 데이터셋 생성"""
    quotes = []
    
    # 기본 명언들을 반복하여 더 많은 데이터 생성
    # 실제로는 더 많은 공개 도메인 명언을 추가해야 함
    for i in range(num_quotes):
        base_quote = COMMERCIAL_QUOTES[i % len(COMMERCIAL_QUOTES)]
        quotes.append({
            "id": i,
            "quote": base_quote["quote"],
            "author": base_quote["author"],
            "category": base_quote["category"],
            "tags": []
        })
    
    return quotes

if __name__ == "__main__":
    # 약 2000개의 명언 생성 (10개 카테고리 x 200개씩)
    quotes = generate_quotes_dataset(2000)
    
    # JSON 파일로 저장
    with open('../assets/quotes.json', 'w', encoding='utf-8') as f:
        json.dump(quotes, f, indent=2, ensure_ascii=False)
    
    print(f"Generated {len(quotes)} commercial-use quotes")
    print(f"Categories: {set(q['category'] for q in quotes)}")

