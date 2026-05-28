enum JournalCategory {
  gratitude,
  selfDiscovery,
  healing,
  goals,
  relationships,
  dailyLife,
  creativity,
  shadowWork,
}

String journalCategoryLabel(JournalCategory c) {
  switch (c) {
    case JournalCategory.gratitude:
      return 'Gratitude';
    case JournalCategory.selfDiscovery:
      return 'Self-Discovery';
    case JournalCategory.healing:
      return 'Healing';
    case JournalCategory.goals:
      return 'Goals';
    case JournalCategory.relationships:
      return 'Relationships';
    case JournalCategory.dailyLife:
      return 'Daily Life';
    case JournalCategory.creativity:
      return 'Creativity';
    case JournalCategory.shadowWork:
      return 'Shadow Work';
  }
}

String journalCategoryEmoji(JournalCategory c) {
  switch (c) {
    case JournalCategory.gratitude:
      return '\u{1F33F}';
    case JournalCategory.selfDiscovery:
      return '\u{1F50D}';
    case JournalCategory.healing:
      return '\u{1F49A}';
    case JournalCategory.goals:
      return '\u{1F3AF}';
    case JournalCategory.relationships:
      return '\u{1F91D}';
    case JournalCategory.dailyLife:
      return '\u{1F305}';
    case JournalCategory.creativity:
      return '\u{1F3A8}';
    case JournalCategory.shadowWork:
      return '\u{1F319}';
  }
}

class JournalIdea {
  final String id;
  final String title;
  final String prompt;
  final List<String> topics;
  final JournalCategory category;
  final int estMinutes;

  const JournalIdea({
    required this.id,
    required this.title,
    required this.prompt,
    required this.topics,
    required this.category,
    required this.estMinutes,
  });
}

const List<JournalIdea> journalIdeas = [
  // ─── Gratitude ───
  JournalIdea(
    id: 'gratitude_three_things',
    title: 'Three things you\'re grateful for',
    prompt: 'List three things — small or large — you are grateful for today. Write why each one matters.',
    topics: [
      'a person who helped you',
      'a moment that made you smile',
      'a comfort you usually overlook',
    ],
    category: JournalCategory.gratitude,
    estMinutes: 5,
  ),
  JournalIdea(
    id: 'gratitude_body',
    title: 'A thank-you letter to your body',
    prompt: 'Write a short letter to your body, thanking it for what it does for you every day.',
    topics: [
      'your hands and what they make possible',
      'your senses and a recent delight',
      'recovery from something hard',
    ],
    category: JournalCategory.gratitude,
    estMinutes: 8,
  ),
  JournalIdea(
    id: 'gratitude_small_joys',
    title: 'Five small joys this week',
    prompt: 'Pause and list five small joys from the past week — the kind that usually go unnoticed.',
    topics: [
      'a taste, a smell, a texture',
      'a song or a sentence that landed',
      'a moment of quiet you didn\'t plan',
    ],
    category: JournalCategory.gratitude,
    estMinutes: 5,
  ),
  JournalIdea(
    id: 'gratitude_someone_who',
    title: 'Someone who shaped you',
    prompt: 'Think of one person who shaped who you are today. What did they give you?',
    topics: [
      'a specific lesson they taught',
      'something they said you still remember',
      'who you became because of them',
    ],
    category: JournalCategory.gratitude,
    estMinutes: 10,
  ),

  // ─── Self-Discovery ───
  JournalIdea(
    id: 'self_values',
    title: 'What do you value most?',
    prompt: 'List the five values that matter most to you. Which are you living out today, and which feel neglected?',
    topics: [
      'honesty, kindness, freedom, courage',
      'family, growth, peace, creativity',
      'one value you want to honor this week',
    ],
    category: JournalCategory.selfDiscovery,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'self_strengths',
    title: 'Your quiet strengths',
    prompt: 'What are you good at that you rarely give yourself credit for?',
    topics: [
      'something a friend has thanked you for',
      'a hard skill you take for granted',
      'a way you show up that no one sees',
    ],
    category: JournalCategory.selfDiscovery,
    estMinutes: 8,
  ),
  JournalIdea(
    id: 'self_younger_you',
    title: 'Letter to your younger self',
    prompt: 'Write a letter to yourself at age 12. What do you wish that version had heard?',
    topics: [
      'something they were worried about',
      'permission to feel what they felt',
      'what would surprise them about now',
    ],
    category: JournalCategory.selfDiscovery,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'self_energy_audit',
    title: 'Energy audit',
    prompt: 'What gives you energy and what drains it? Make two columns.',
    topics: [
      'people, places, activities',
      'one drain you can reduce this week',
      'one fuel you can add this week',
    ],
    category: JournalCategory.selfDiscovery,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'self_identity',
    title: 'Who am I, really?',
    prompt: 'Set a 10-minute timer and answer the question "Who am I?" without overthinking. Free-write.',
    topics: [
      'beyond your job and roles',
      'what you love when no one\'s watching',
      'the parts you hide and why',
    ],
    category: JournalCategory.selfDiscovery,
    estMinutes: 10,
  ),

  // ─── Healing ───
  JournalIdea(
    id: 'healing_let_go',
    title: 'What you\'re ready to release',
    prompt: 'Name something you\'re ready to let go of. Write about it like you\'re saying goodbye.',
    topics: [
      'a story you\'ve told yourself',
      'a relationship that\'s ended',
      'a version of you that no longer fits',
    ],
    category: JournalCategory.healing,
    estMinutes: 12,
  ),
  JournalIdea(
    id: 'healing_forgiveness',
    title: 'A forgiveness letter (unsent)',
    prompt: 'Write a letter to someone you need to forgive — or to yourself. You don\'t have to send it.',
    topics: [
      'what they did and how it landed',
      'what you needed instead',
      'what forgiveness would free in you',
    ],
    category: JournalCategory.healing,
    estMinutes: 20,
  ),
  JournalIdea(
    id: 'healing_grief',
    title: 'Tending to grief',
    prompt: 'What loss are you carrying right now? Give it room on the page.',
    topics: [
      'who or what is gone',
      'what you miss most',
      'how grief shows up in your body',
    ],
    category: JournalCategory.healing,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'healing_inner_child',
    title: 'Comforting your inner child',
    prompt: 'If your younger self walked in right now, what would they need to hear?',
    topics: [
      'their biggest fear',
      'the words no one said to them',
      'how you can parent them today',
    ],
    category: JournalCategory.healing,
    estMinutes: 15,
  ),

  // ─── Goals ───
  JournalIdea(
    id: 'goals_one_year',
    title: 'One year from now',
    prompt: 'Describe your life one year from today — in vivid detail, as if it\'s already happened.',
    topics: [
      'where you live and how you wake up',
      'who is in your day',
      'what you\'re proud of having built',
    ],
    category: JournalCategory.goals,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'goals_north_star',
    title: 'Your north star',
    prompt: 'If everything you did pointed toward one thing, what would it be?',
    topics: [
      'a feeling you want more of',
      'an impact you want to leave',
      'a person you want to become',
    ],
    category: JournalCategory.goals,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'goals_what_stops_you',
    title: 'What\'s stopping you?',
    prompt: 'Pick one goal that matters and write honestly about what\'s in the way.',
    topics: [
      'a fear you haven\'t named',
      'a belief that says you can\'t',
      'one small step you\'ve been avoiding',
    ],
    category: JournalCategory.goals,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'goals_this_week',
    title: 'One thing this week',
    prompt: 'What is the one thing this week that would make everything else feel easier?',
    topics: [
      'an unfinished task',
      'a conversation you\'re avoiding',
      'a habit you want to start tiny',
    ],
    category: JournalCategory.goals,
    estMinutes: 5,
  ),

  // ─── Relationships ───
  JournalIdea(
    id: 'relationships_people_who',
    title: 'People who lift you up',
    prompt: 'Who in your life makes you feel like yourself? Write about them.',
    topics: [
      'how they show up for you',
      'what you give back',
      'one person you want to thank this week',
    ],
    category: JournalCategory.relationships,
    estMinutes: 8,
  ),
  JournalIdea(
    id: 'relationships_difficult',
    title: 'A difficult relationship',
    prompt: 'Write about a relationship that\'s heavy right now. What\'s really going on for you?',
    topics: [
      'what triggers you and why',
      'what you wish you could say',
      'a boundary you\'re ready to set',
    ],
    category: JournalCategory.relationships,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'relationships_self',
    title: 'Your relationship with yourself',
    prompt: 'If you talked to yourself the way you talk to a friend, what would change?',
    topics: [
      'a recent self-criticism',
      'kinder words for that moment',
      'one promise you can keep to yourself',
    ],
    category: JournalCategory.relationships,
    estMinutes: 10,
  ),

  // ─── Daily Life ───
  JournalIdea(
    id: 'daily_morning_pages',
    title: 'Morning brain dump',
    prompt: 'First thing in the morning, write three pages of whatever shows up — unfiltered, no editing.',
    topics: [
      'whatever\'s in your head right now',
      'a worry that woke you up',
      'something you\'re looking forward to',
    ],
    category: JournalCategory.dailyLife,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'daily_evening_review',
    title: 'Evening review',
    prompt: 'Look back at today: what worked, what didn\'t, what you\'re carrying into tomorrow.',
    topics: [
      'one moment you want to remember',
      'one moment you wish went differently',
      'one thing to leave behind tonight',
    ],
    category: JournalCategory.dailyLife,
    estMinutes: 8,
  ),
  JournalIdea(
    id: 'daily_mood_unpacked',
    title: 'Unpack today\'s mood',
    prompt: 'Name how you feel right now in one word. Then write everything underneath that word.',
    topics: [
      'what triggered the feeling',
      'where it lives in your body',
      'what it\'s trying to tell you',
    ],
    category: JournalCategory.dailyLife,
    estMinutes: 8,
  ),
  JournalIdea(
    id: 'daily_seasons',
    title: 'Where are you in your season?',
    prompt: 'Are you in spring, summer, autumn, or winter right now? Write about it.',
    topics: [
      'what this season feels like',
      'what it\'s asking of you',
      'what you\'re growing or releasing',
    ],
    category: JournalCategory.dailyLife,
    estMinutes: 10,
  ),

  // ─── Creativity ───
  JournalIdea(
    id: 'creativity_what_if',
    title: 'What if?',
    prompt: 'Fill a page with "what if" questions. Don\'t answer them — just let them come.',
    topics: [
      'what if money wasn\'t a factor',
      'what if you couldn\'t fail',
      'what if no one was watching',
    ],
    category: JournalCategory.creativity,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'creativity_dream_day',
    title: 'Your perfect day',
    prompt: 'Describe your perfect day from waking to sleep. Make it specific.',
    topics: [
      'morning rituals',
      'who you\'re with and what you make',
      'how the day ends',
    ],
    category: JournalCategory.creativity,
    estMinutes: 15,
  ),
  JournalIdea(
    id: 'creativity_lost_dream',
    title: 'A dream you set down',
    prompt: 'Write about a dream you used to have that you\'ve quietly let go of. Is it still there?',
    topics: [
      'when you first held it',
      'why you set it down',
      'what part of it could still be alive',
    ],
    category: JournalCategory.creativity,
    estMinutes: 12,
  ),

  // ─── Shadow Work ───
  JournalIdea(
    id: 'shadow_envy',
    title: 'What you envy',
    prompt: 'Who do you envy, and what does that tell you about what you want?',
    topics: [
      'name the person honestly',
      'what specifically you envy',
      'what desire is hidden underneath',
    ],
    category: JournalCategory.shadowWork,
    estMinutes: 12,
  ),
  JournalIdea(
    id: 'shadow_anger',
    title: 'What you\'re angry about',
    prompt: 'What are you angry about that you haven\'t let yourself feel?',
    topics: [
      'name it without softening',
      'what would the anger say if it spoke',
      'what it\'s protecting',
    ],
    category: JournalCategory.shadowWork,
    estMinutes: 12,
  ),
  JournalIdea(
    id: 'shadow_avoid',
    title: 'What you\'re avoiding',
    prompt: 'What have you been avoiding this week? Why?',
    topics: [
      'the task or person you\'ve put off',
      'what you fear about facing it',
      'what would change if you did',
    ],
    category: JournalCategory.shadowWork,
    estMinutes: 10,
  ),
  JournalIdea(
    id: 'shadow_pattern',
    title: 'A pattern you keep repeating',
    prompt: 'What\'s a pattern in your life that keeps showing up? Write about it without judgment.',
    topics: [
      'when it first started',
      'what it costs you',
      'what it gives you that\'s hard to give up',
    ],
    category: JournalCategory.shadowWork,
    estMinutes: 15,
  ),
];

List<JournalIdea> ideasByCategory(JournalCategory category) =>
    journalIdeas.where((i) => i.category == category).toList();
