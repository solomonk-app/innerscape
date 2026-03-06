class BibleVerse {
  final String text;
  final String reference;

  const BibleVerse({required this.text, required this.reference});
}

/// Mood category mapped from mood value:
/// low (1-2), mid (3-4), high (5-6)
String moodToCategory(int mood) {
  if (mood <= 2) return 'low';
  if (mood <= 4) return 'mid';
  return 'high';
}

const Map<String, List<BibleVerse>> curatedVerses = {
  // Comforting / hope verses for low moods
  'low': [
    BibleVerse(
      text: 'The Lord is close to the brokenhearted and saves those who are crushed in spirit.',
      reference: 'Psalm 34:18',
    ),
    BibleVerse(
      text: 'So do not fear, for I am with you; do not be dismayed, for I am your God. I will strengthen you and help you; I will uphold you with my righteous right hand.',
      reference: 'Isaiah 41:10',
    ),
    BibleVerse(
      text: 'Come to me, all you who are weary and burdened, and I will give you rest.',
      reference: 'Matthew 11:28',
    ),
    BibleVerse(
      text: 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      reference: 'Romans 8:28',
    ),
    BibleVerse(
      text: 'He heals the brokenhearted and binds up their wounds.',
      reference: 'Psalm 147:3',
    ),
    BibleVerse(
      text: 'The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul.',
      reference: 'Psalm 23:1-3',
    ),
    BibleVerse(
      text: 'Cast all your anxiety on him because he cares for you.',
      reference: '1 Peter 5:7',
    ),
    BibleVerse(
      text: 'God is our refuge and strength, an ever-present help in trouble.',
      reference: 'Psalm 46:1',
    ),
    BibleVerse(
      text: 'The Lord himself goes before you and will be with you; he will never leave you nor forsake you. Do not be afraid; do not be discouraged.',
      reference: 'Deuteronomy 31:8',
    ),
    BibleVerse(
      text: 'Weeping may stay for the night, but rejoicing comes in the morning.',
      reference: 'Psalm 30:5',
    ),
    BibleVerse(
      text: 'When you pass through the waters, I will be with you; and when you pass through the rivers, they will not sweep over you.',
      reference: 'Isaiah 43:2',
    ),
    BibleVerse(
      text: 'My grace is sufficient for you, for my power is made perfect in weakness.',
      reference: '2 Corinthians 12:9',
    ),
    BibleVerse(
      text: 'Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me.',
      reference: 'Psalm 23:4',
    ),
    BibleVerse(
      text: 'For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers, neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God.',
      reference: 'Romans 8:38-39',
    ),
    BibleVerse(
      text: 'He gives strength to the weary and increases the power of the weak.',
      reference: 'Isaiah 40:29',
    ),
  ],

  // Encouragement / peace verses for mid moods
  'mid': [
    BibleVerse(
      text: 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
      reference: 'Philippians 4:6-7',
    ),
    BibleVerse(
      text: 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      reference: 'Proverbs 3:5-6',
    ),
    BibleVerse(
      text: 'Be still, and know that I am God.',
      reference: 'Psalm 46:10',
    ),
    BibleVerse(
      text: '"For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, plans to give you hope and a future."',
      reference: 'Jeremiah 29:11',
    ),
    BibleVerse(
      text: 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      reference: 'Isaiah 40:31',
    ),
    BibleVerse(
      text: 'I can do all this through him who gives me strength.',
      reference: 'Philippians 4:13',
    ),
    BibleVerse(
      text: 'The Lord is my light and my salvation—whom shall I fear? The Lord is the stronghold of my life—of whom shall I be afraid?',
      reference: 'Psalm 27:1',
    ),
    BibleVerse(
      text: 'And let us not grow weary of doing good, for in due season we will reap, if we do not give up.',
      reference: 'Galatians 6:9',
    ),
    BibleVerse(
      text: 'Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid.',
      reference: 'John 14:27',
    ),
    BibleVerse(
      text: 'Commit to the Lord whatever you do, and he will establish your plans.',
      reference: 'Proverbs 16:3',
    ),
    BibleVerse(
      text: 'The Lord your God is with you, the Mighty Warrior who saves. He will take great delight in you; in his love he will no longer rebuke you, but will rejoice over you with singing.',
      reference: 'Zephaniah 3:17',
    ),
    BibleVerse(
      text: 'Be strong and courageous. Do not be afraid or terrified because of them, for the Lord your God goes with you; he will never leave you nor forsake you.',
      reference: 'Deuteronomy 31:6',
    ),
    BibleVerse(
      text: 'Have I not commanded you? Be strong and courageous. Do not be afraid; do not be discouraged, for the Lord your God will be with you wherever you go.',
      reference: 'Joshua 1:9',
    ),
    BibleVerse(
      text: 'Wait for the Lord; be strong and take heart and wait for the Lord.',
      reference: 'Psalm 27:14',
    ),
    BibleVerse(
      text: 'Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds, because you know that the testing of your faith produces perseverance.',
      reference: 'James 1:2-3',
    ),
  ],

  // Gratitude / praise verses for high moods
  'high': [
    BibleVerse(
      text: 'This is the day that the Lord has made; let us rejoice and be glad in it.',
      reference: 'Psalm 118:24',
    ),
    BibleVerse(
      text: 'Every good and perfect gift is from above, coming down from the Father of the heavenly lights, who does not change like shifting shadows.',
      reference: 'James 1:17',
    ),
    BibleVerse(
      text: 'Rejoice always, pray continually, give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.',
      reference: '1 Thessalonians 5:16-18',
    ),
    BibleVerse(
      text: 'Enter his gates with thanksgiving and his courts with praise; give thanks to him and praise his name.',
      reference: 'Psalm 100:4',
    ),
    BibleVerse(
      text: 'Delight yourself in the Lord, and he will give you the desires of your heart.',
      reference: 'Psalm 37:4',
    ),
    BibleVerse(
      text: 'The joy of the Lord is your strength.',
      reference: 'Nehemiah 8:10',
    ),
    BibleVerse(
      text: 'Shout for joy to the Lord, all the earth. Worship the Lord with gladness; come before him with joyful songs.',
      reference: 'Psalm 100:1-2',
    ),
    BibleVerse(
      text: 'Give thanks to the Lord, for he is good; his love endures forever.',
      reference: 'Psalm 107:1',
    ),
    BibleVerse(
      text: 'Let everything that has breath praise the Lord. Praise the Lord.',
      reference: 'Psalm 150:6',
    ),
    BibleVerse(
      text: 'The Lord has done great things for us, and we are filled with joy.',
      reference: 'Psalm 126:3',
    ),
    BibleVerse(
      text: 'I will praise you, Lord, with all my heart; I will tell of all the marvelous things you have done.',
      reference: 'Psalm 9:1',
    ),
    BibleVerse(
      text: 'You make known to me the path of life; you will fill me with joy in your presence, with eternal pleasures at your right hand.',
      reference: 'Psalm 16:11',
    ),
    BibleVerse(
      text: 'From the fullness of his grace we have all received one blessing after another.',
      reference: 'John 1:16',
    ),
    BibleVerse(
      text: 'The Lord is my strength and my shield; my heart trusts in him, and he helps me. My heart leaps for joy, and with my song I praise him.',
      reference: 'Psalm 28:7',
    ),
    BibleVerse(
      text: 'I will be glad and rejoice in you; I will sing the praises of your name, O Most High.',
      reference: 'Psalm 9:2',
    ),
  ],
};
