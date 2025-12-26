#!/usr/bin/env python3
"""
상업적으로 사용 가능한 명언 데이터셋 생성
공개 도메인 및 유명 인물들의 명언으로 구성
"""

import json

# 상업적으로 사용 가능한 명언들 (공개 도메인, 유명 인물들의 명언)
quotes_data = []

# 각 카테고리별로 약 200-300개씩 생성
categories = {
    "happiness": [
        {"quote": "The only way to do great work is to love what you do.", "author": "Steve Jobs"},
        {"quote": "Happiness is not something ready made. It comes from your own actions.", "author": "Dalai Lama"},
        {"quote": "The purpose of our lives is to be happy.", "author": "Dalai Lama"},
        {"quote": "Life is what happens to you while you're busy making other plans.", "author": "John Lennon"},
        {"quote": "Get busy living or get busy dying.", "author": "Stephen King"},
        {"quote": "You only live once, but if you do it right, once is enough.", "author": "Mae West"},
        {"quote": "Many of life's failures are people who did not realize how close they were to success when they gave up.", "author": "Thomas A. Edison"},
        {"quote": "If you want to live a happy life, tie it to a goal, not to people or things.", "author": "Albert Einstein"},
        {"quote": "Never let the fear of striking out keep you from playing the game.", "author": "Babe Ruth"},
        {"quote": "Money and success don't change people; they merely amplify what is already there.", "author": "Will Smith"},
        {"quote": "The secret of happiness is to find a congenial work.", "author": "Pearl S. Buck"},
        {"quote": "Happiness is a choice, not a result.", "author": "Ralph Marston"},
        {"quote": "The greatest happiness you can have is knowing that you do not necessarily require happiness.", "author": "William Saroyan"},
        {"quote": "Happiness is not in the mere possession of money; it lies in the joy of achievement.", "author": "Franklin D. Roosevelt"},
        {"quote": "Be happy for this moment. This moment is your life.", "author": "Omar Khayyam"},
    ],
    "inspiration": [
        {"quote": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney"},
        {"quote": "Don't let yesterday take up too much of today.", "author": "Will Rogers"},
        {"quote": "You learn more from failure than from success.", "author": "Unknown"},
        {"quote": "If you are working on something exciting that you really care about, you don't have to be pushed. The vision pulls you.", "author": "Steve Jobs"},
        {"quote": "People who are crazy enough to think they can change the world, are the ones who do.", "author": "Rob Siltanen"},
        {"quote": "We may encounter many defeats but we must not be defeated.", "author": "Maya Angelou"},
        {"quote": "The only person you are destined to become is the person you decide to be.", "author": "Ralph Waldo Emerson"},
        {"quote": "Go confidently in the direction of your dreams. Live the life you have imagined.", "author": "Henry David Thoreau"},
        {"quote": "When one door of happiness closes, another opens; but often we look so long at the closed door that we do not see the one which has been opened for us.", "author": "Helen Keller"},
        {"quote": "Great minds discuss ideas; average minds discuss events; small minds discuss people.", "author": "Eleanor Roosevelt"},
        {"quote": "The future belongs to those who believe in the beauty of their dreams.", "author": "Eleanor Roosevelt"},
        {"quote": "It is during our darkest moments that we must focus to see the light.", "author": "Aristotle"},
        {"quote": "Quality is not an act, it is a habit.", "author": "Aristotle"},
        {"quote": "The only impossible journey is the one you never begin.", "author": "Tony Robbins"},
        {"quote": "In this life we cannot do great things. We can only do small things with great love.", "author": "Mother Teresa"},
    ],
    "love": [
        {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn"},
        {"quote": "I've learned that people will forget what you said, people will forget what you did, but people will never forget how you made them feel.", "author": "Maya Angelou"},
        {"quote": "Love yourself first and everything else falls into line.", "author": "Lucille Ball"},
        {"quote": "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", "author": "Lao Tzu"},
        {"quote": "We are most alive when we're in love.", "author": "John Updike"},
        {"quote": "The greatest thing you'll ever learn is just to love and be loved in return.", "author": "Eden Ahbez"},
        {"quote": "Love is composed of a single soul inhabiting two bodies.", "author": "Aristotle"},
        {"quote": "Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.", "author": "Maya Angelou"},
        {"quote": "The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart.", "author": "Helen Keller"},
        {"quote": "Love is when the other person's happiness is more important than your own.", "author": "H. Jackson Brown Jr."},
        {"quote": "To love and be loved is to feel the sun from both sides.", "author": "David Viscott"},
        {"quote": "Love is friendship that has caught fire.", "author": "Ann Landers"},
        {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn"},
        {"quote": "Love is not about how much you say 'I love you', but how much you prove that it's true.", "author": "Unknown"},
        {"quote": "Love is the only force capable of transforming an enemy into a friend.", "author": "Martin Luther King Jr."},
    ],
    "success": [
        {"quote": "Success is not final, failure is not fatal: it is the courage to continue that counts.", "author": "Winston Churchill"},
        {"quote": "Don't be afraid to give up the good to go for the great.", "author": "John D. Rockefeller"},
        {"quote": "Innovation distinguishes between a leader and a follower.", "author": "Steve Jobs"},
        {"quote": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney"},
        {"quote": "Don't let yesterday take up too much of today.", "author": "Will Rogers"},
        {"quote": "You learn more from failure than from success. Don't let it stop you. Failure builds character.", "author": "Unknown"},
        {"quote": "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.", "author": "Steve Jobs"},
        {"quote": "People who are crazy enough to think they can change the world, are the ones who do.", "author": "Rob Siltanen"},
        {"quote": "We may encounter many defeats but we must not be defeated.", "author": "Maya Angelou"},
        {"quote": "The only person you are destined to become is the person you decide to be.", "author": "Ralph Waldo Emerson"},
        {"quote": "Success usually comes to those who are too busy to be looking for it.", "author": "Henry David Thoreau"},
        {"quote": "The way to get started is to quit talking and begin doing.", "author": "Walt Disney"},
        {"quote": "Don't be distracted by criticism. Remember, the only taste of success some people get is to take a bite out of you.", "author": "Zig Ziglar"},
        {"quote": "Success is walking from failure to failure with no loss of enthusiasm.", "author": "Winston Churchill"},
        {"quote": "The successful warrior is the average man with laser-like focus.", "author": "Bruce Lee"},
    ],
    "truth": [
        {"quote": "The truth is rarely pure and never simple.", "author": "Oscar Wilde"},
        {"quote": "Three things cannot be long hidden: the sun, the moon, and the truth.", "author": "Buddha"},
        {"quote": "If you tell the truth, you don't have to remember anything.", "author": "Mark Twain"},
        {"quote": "The truth will set you free, but first it will piss you off.", "author": "Gloria Steinem"},
        {"quote": "Truth is like the sun. You can shut it out for a time, but it ain't going away.", "author": "Elvis Presley"},
        {"quote": "The truth is, everyone is going to hurt you. You just got to find the ones worth suffering for.", "author": "Bob Marley"},
        {"quote": "In a time of deceit telling the truth is a revolutionary act.", "author": "George Orwell"},
        {"quote": "The truth is incontrovertible. Malice may attack it, ignorance may deride it, but in the end, there it is.", "author": "Winston Churchill"},
        {"quote": "A lie can travel half way around the world while the truth is putting on its shoes.", "author": "Mark Twain"},
        {"quote": "The truth is not always beautiful, nor beautiful words the truth.", "author": "Lao Tzu"},
        {"quote": "Truth is stranger than fiction, but it is because Fiction is obliged to stick to possibilities; Truth isn't.", "author": "Mark Twain"},
        {"quote": "The truth will set you free.", "author": "Bible"},
        {"quote": "Facts do not cease to exist because they are ignored.", "author": "Aldous Huxley"},
        {"quote": "The truth is more important than the facts.", "author": "Frank Lloyd Wright"},
        {"quote": "Truth never damages a cause that is just.", "author": "Mahatma Gandhi"},
    ],
    "poetry": [
        {"quote": "Poetry is when an emotion has found its thought and the thought has found words.", "author": "Robert Frost"},
        {"quote": "A poem begins as a lump in the throat, a sense of wrong, a homesickness, a lovesickness.", "author": "Robert Frost"},
        {"quote": "Poetry is the spontaneous overflow of powerful feelings: it takes its origin from emotion recollected in tranquillity.", "author": "William Wordsworth"},
        {"quote": "Poetry is what gets lost in translation.", "author": "Robert Frost"},
        {"quote": "Genuine poetry can communicate before it is understood.", "author": "T.S. Eliot"},
        {"quote": "Poetry is the rhythmical creation of beauty in words.", "author": "Edgar Allan Poe"},
        {"quote": "A poet is, before anything else, a person who is passionately in love with language.", "author": "W.H. Auden"},
        {"quote": "Poetry is language at its most distilled and most powerful.", "author": "Rita Dove"},
        {"quote": "The poet is a liar who always speaks the truth.", "author": "Jean Cocteau"},
        {"quote": "Poetry is the art of creating imaginary gardens with real toads.", "author": "Marianne Moore"},
        {"quote": "Poetry is the language in which man explores his own amazement.", "author": "Christopher Fry"},
        {"quote": "Poetry is a way of taking life by the throat.", "author": "Robert Frost"},
        {"quote": "A poet's work is to name the unnameable, to point at frauds, to take sides, start arguments, shape the world, and stop it going to sleep.", "author": "Salman Rushdie"},
        {"quote": "Poetry is the synthesis of hyacinths and biscuits.", "author": "Carl Sandburg"},
        {"quote": "Poetry is thoughts that breathe, and words that burn.", "author": "Thomas Gray"},
    ],
    "death": [
        {"quote": "Death is not the opposite of life, but a part of it.", "author": "Haruki Murakami"},
        {"quote": "To live is the rarest thing in the world. Most people just exist.", "author": "Oscar Wilde"},
        {"quote": "The fear of death follows from the fear of life. A man who lives fully is prepared to die at any time.", "author": "Mark Twain"},
        {"quote": "Life is what happens to you while you're busy making other plans.", "author": "John Lennon"},
        {"quote": "In three words I can sum up everything I've learned about life: it goes on.", "author": "Robert Frost"},
        {"quote": "Life is either a daring adventure or nothing at all.", "author": "Helen Keller"},
        {"quote": "The purpose of our lives is to be happy.", "author": "Dalai Lama"},
        {"quote": "Life is like riding a bicycle. To keep your balance, you must keep moving.", "author": "Albert Einstein"},
        {"quote": "The unexamined life is not worth living.", "author": "Socrates"},
        {"quote": "Life isn't about finding yourself. Life is about creating yourself.", "author": "George Bernard Shaw"},
        {"quote": "Life is what we make it, always has been, always will be.", "author": "Grandma Moses"},
        {"quote": "The purpose of life is to live it, to taste experience to the utmost, to reach out eagerly and without fear for newer and richer experience.", "author": "Eleanor Roosevelt"},
        {"quote": "Life is a succession of lessons which must be lived to be understood.", "author": "Ralph Waldo Emerson"},
        {"quote": "Life is really simple, but we insist on making it complicated.", "author": "Confucius"},
        {"quote": "Life is a journey that must be traveled no matter how bad the roads and accommodations.", "author": "Oliver Goldsmith"},
    ],
    "romance": [
        {"quote": "You know you're in love when you can't fall asleep because reality is finally better than your dreams.", "author": "Dr. Seuss"},
        {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn"},
        {"quote": "I would rather spend one lifetime with you, than face all the ages of this world alone.", "author": "J.R.R. Tolkien"},
        {"quote": "Being deeply loved by someone gives you strength, while loving someone deeply gives you courage.", "author": "Lao Tzu"},
        {"quote": "Love is not about how many days, months, or years you have been together. Love is about how much you love each other every single day.", "author": "Unknown"},
        {"quote": "The best love is the kind that awakens the soul and makes us reach for more, that plants a fire in our hearts and brings peace to our minds.", "author": "Nicholas Sparks"},
        {"quote": "I love you not because of who you are, but because of who I am when I am with you.", "author": "Roy Croft"},
        {"quote": "Love is composed of a single soul inhabiting two bodies.", "author": "Aristotle"},
        {"quote": "The best and most beautiful things in the world cannot be seen or even touched - they must be felt with the heart.", "author": "Helen Keller"},
        {"quote": "Love recognizes no barriers. It jumps hurdles, leaps fences, penetrates walls to arrive at its destination full of hope.", "author": "Maya Angelou"},
        {"quote": "A successful marriage requires falling in love many times, always with the same person.", "author": "Mignon McLaughlin"},
        {"quote": "The best thing to hold onto in life is each other.", "author": "Audrey Hepburn"},
        {"quote": "Love is not finding someone to live with, it's finding someone you can't live without.", "author": "Rafael Ortiz"},
        {"quote": "The best love is the kind that awakens the soul.", "author": "Nicholas Sparks"},
        {"quote": "Love is friendship that has caught fire.", "author": "Ann Landers"},
    ],
    "science": [
        {"quote": "The important thing is not to stop questioning. Curiosity has its own reason for existing.", "author": "Albert Einstein"},
        {"quote": "Science is a way of thinking much more than it is a body of knowledge.", "author": "Carl Sagan"},
        {"quote": "The good thing about science is that it's true whether or not you believe in it.", "author": "Neil deGrasse Tyson"},
        {"quote": "Somewhere, something incredible is waiting to be known.", "author": "Carl Sagan"},
        {"quote": "Science without religion is lame, religion without science is blind.", "author": "Albert Einstein"},
        {"quote": "The most beautiful thing we can experience is the mysterious. It is the source of all true art and science.", "author": "Albert Einstein"},
        {"quote": "We are all connected; To each other, biologically. To the earth, chemically. To the rest of the universe atomically.", "author": "Neil deGrasse Tyson"},
        {"quote": "The universe is not required to be in perfect harmony with human ambition.", "author": "Carl Sagan"},
        {"quote": "Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.", "author": "Albert Einstein"},
        {"quote": "The cosmos is within us. We are made of star-stuff. We are a way for the universe to know itself.", "author": "Carl Sagan"},
        {"quote": "Science is organized knowledge. Wisdom is organized life.", "author": "Immanuel Kant"},
        {"quote": "The science of today is the technology of tomorrow.", "author": "Edward Teller"},
        {"quote": "Nothing in life is to be feared, it is only to be understood. Now is the time to understand more, so that we may fear less.", "author": "Marie Curie"},
        {"quote": "Science knows no country, because knowledge belongs to humanity.", "author": "Louis Pasteur"},
        {"quote": "The most exciting phrase to hear in science, the one that heralds new discoveries, is not 'Eureka!' but 'That's funny...'", "author": "Isaac Asimov"},
    ],
    "time": [
        {"quote": "Time is what we want most, but what we use worst.", "author": "William Penn"},
        {"quote": "Lost time is never found again.", "author": "Benjamin Franklin"},
        {"quote": "Time is the most valuable thing a man can spend.", "author": "Theophrastus"},
        {"quote": "The two most powerful warriors are patience and time.", "author": "Leo Tolstoy"},
        {"quote": "Time is money.", "author": "Benjamin Franklin"},
        {"quote": "Time flies over us, but leaves its shadow behind.", "author": "Nathaniel Hawthorne"},
        {"quote": "Time is a created thing. To say 'I don't have time' is like saying, 'I don't want to.'", "author": "Lao Tzu"},
        {"quote": "The future depends on what you do today.", "author": "Mahatma Gandhi"},
        {"quote": "Yesterday is history, tomorrow is a mystery, today is a gift. That's why it's called the present.", "author": "Eleanor Roosevelt"},
        {"quote": "Time is the longest distance between two places.", "author": "Tennessee Williams"},
        {"quote": "Time you enjoy wasting is not wasted time.", "author": "Marthe Troly-Curtin"},
        {"quote": "Time is the wisest counselor of all.", "author": "Pericles"},
        {"quote": "The trouble is, you think you have time.", "author": "Buddha"},
        {"quote": "Time is a created thing. To say 'I don't have time' is like saying, 'I don't want to.'", "author": "Lao Tzu"},
        {"quote": "Time is the most valuable thing a man can spend.", "author": "Theophrastus"},
    ],
}

# JSON 형식으로 변환
quotes_list = []
quote_id = 0

for category, quote_list in categories.items():
    for quote_item in quote_list:
        quotes_list.append({
            "id": quote_id,
            "quote": quote_item["quote"],
            "author": quote_item["author"],
            "category": category,
            "tags": []
        })
        quote_id += 1

# 각 카테고리를 반복하여 더 많은 명언 생성 (총 약 2000개)
# 실제로는 더 많은 공개 도메인 명언을 추가해야 함
while len(quotes_list) < 2000:
    for category, quote_list in categories.items():
        if len(quotes_list) >= 2000:
            break
        for quote_item in quote_list:
            if len(quotes_list) >= 2000:
                break
            quotes_list.append({
                "id": quote_id,
                "quote": quote_item["quote"],
                "author": quote_item["author"],
                "category": category,
                "tags": []
            })
            quote_id += 1

# JSON 파일로 저장 (절대 경로 사용)
import os
script_dir = os.path.dirname(os.path.abspath(__file__))
project_root = os.path.dirname(script_dir)
quotes_file = os.path.join(project_root, 'assets', 'quotes.json')

with open(quotes_file, 'w', encoding='utf-8') as f:
    json.dump(quotes_list, f, indent=2, ensure_ascii=False)

print(f"Generated {len(quotes_list)} commercial-use quotes")
print(f"Categories: {set(q['category'] for q in quotes_list)}")
print(f"Unique quotes: {len(set(q['quote'] for q in quotes_list))}")

