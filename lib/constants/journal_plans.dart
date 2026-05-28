class DayPrompt {
  final int day;
  final String title;
  final String prompt;
  final List<String> topics;

  const DayPrompt({
    required this.day,
    required this.title,
    required this.prompt,
    required this.topics,
  });
}

class JournalPlanTemplate {
  final String id;
  final String title;
  final String description;
  final int lengthDays;
  final String emoji;
  final List<DayPrompt> dayPrompts;

  const JournalPlanTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.lengthDays,
    required this.emoji,
    required this.dayPrompts,
  });
}

const _gratitude7 = JournalPlanTemplate(
  id: 'gratitude_7',
  title: '7-Day Gratitude Reset',
  description: 'A gentle week of noticing what\'s already good.',
  lengthDays: 7,
  emoji: '\u{1F33F}',
  dayPrompts: [
    DayPrompt(
      day: 1,
      title: 'Three small things',
      prompt: 'Three small things you appreciated today.',
      topics: ['a taste', 'a sound', 'a moment of ease'],
    ),
    DayPrompt(
      day: 2,
      title: 'A person',
      prompt: 'One person you are grateful for and exactly why.',
      topics: ['what they did', 'what it gave you', 'how you can tell them'],
    ),
    DayPrompt(
      day: 3,
      title: 'Your body',
      prompt: 'Thank your body for something it did for you this week.',
      topics: ['carried you somewhere', 'healed something', 'felt pleasure'],
    ),
    DayPrompt(
      day: 4,
      title: 'A struggle that taught you',
      prompt: 'A hard thing you went through that you can now see gave you something.',
      topics: ['what it cost', 'what it built', 'who it made you'],
    ),
    DayPrompt(
      day: 5,
      title: 'Where you live',
      prompt: 'What about the place you live are you grateful for today?',
      topics: ['a window or corner', 'a sound from outside', 'a small comfort'],
    ),
    DayPrompt(
      day: 6,
      title: 'Yourself',
      prompt: 'One thing about yourself you are grateful for.',
      topics: ['a trait you don\'t often credit', 'a way you show up', 'a choice you made'],
    ),
    DayPrompt(
      day: 7,
      title: 'The week itself',
      prompt: 'Look back at the week of noticing. What changed?',
      topics: ['what came easier', 'what surprised you', 'what you want to keep'],
    ),
  ],
);

const _anxiety7 = JournalPlanTemplate(
  id: 'anxiety_7',
  title: '7-Day Anxiety Release',
  description: 'A week of unpacking what\'s tight inside.',
  lengthDays: 7,
  emoji: '\u{1F300}',
  dayPrompts: [
    DayPrompt(
      day: 1,
      title: 'Name it',
      prompt: 'What are you anxious about right now? Say it plainly on the page.',
      topics: ['the loudest worry', 'how long it\'s been there', 'where it lives in your body'],
    ),
    DayPrompt(
      day: 2,
      title: 'Worst case',
      prompt: 'Write the worst-case scenario in detail — then write how you would still be okay.',
      topics: ['what would actually happen', 'who would help', 'how you\'ve survived hard before'],
    ),
    DayPrompt(
      day: 3,
      title: 'What\'s in your control',
      prompt: 'Two columns: what you can control and what you can\'t. Be honest.',
      topics: ['actions only you can take', 'things you\'re trying to control that aren\'t yours', 'what to set down'],
    ),
    DayPrompt(
      day: 4,
      title: 'A letter to the worry',
      prompt: 'Write a letter to the worry as if it were a person. What is it trying to do for you?',
      topics: ['what it\'s afraid will happen', 'what it needs to hear', 'what you want it to know'],
    ),
    DayPrompt(
      day: 5,
      title: 'Body check',
      prompt: 'Scan your body. Where is the anxiety living, and what would soothe that place?',
      topics: ['shoulders, chest, stomach, jaw', 'a small thing that helps', 'a permission you need to give yourself'],
    ),
    DayPrompt(
      day: 6,
      title: 'Evidence file',
      prompt: 'List moments you handled something you thought you couldn\'t.',
      topics: ['something recent', 'something from years ago', 'who you became after'],
    ),
    DayPrompt(
      day: 7,
      title: 'Tomorrow\'s posture',
      prompt: 'What posture do you want to bring into the week ahead?',
      topics: ['a phrase to repeat', 'a person to call', 'a boundary to honor'],
    ),
  ],
);

const _selfCompassion14 = JournalPlanTemplate(
  id: 'self_compassion_14',
  title: '14-Day Self-Compassion',
  description: 'Two weeks of softening toward yourself.',
  lengthDays: 14,
  emoji: '\u{1F49A}',
  dayPrompts: [
    DayPrompt(day: 1, title: 'How do you talk to yourself?', prompt: 'Write down the last harsh thing you said to yourself. Then rewrite it as a friend would say it.', topics: ['the exact words', 'the kinder version', 'what triggered it']),
    DayPrompt(day: 2, title: 'A wound you still carry', prompt: 'Name one wound you still carry. Acknowledge it without trying to fix it.', topics: ['when it happened', 'what you needed then', 'what it taught you to believe']),
    DayPrompt(day: 3, title: 'Common humanity', prompt: 'What are you struggling with that millions of others also know?', topics: ['the struggle', 'who else likely feels it', 'what would change if you remembered that']),
    DayPrompt(day: 4, title: 'Tender places', prompt: 'Name three parts of yourself you find hardest to love.', topics: ['why each one is hard', 'where it began', 'what it might need']),
    DayPrompt(day: 5, title: 'Forgiveness for yourself', prompt: 'Write a letter forgiving yourself for something you keep replaying.', topics: ['what you did', 'why you did it then', 'what you\'d choose now']),
    DayPrompt(day: 6, title: 'A moment of softness', prompt: 'Recall a recent moment someone was soft with you. Receive it again on the page.', topics: ['who was there', 'what they said or did', 'how it felt to be met']),
    DayPrompt(day: 7, title: 'The inner critic', prompt: 'What does your inner critic say? Talk back — not in anger, but in truth.', topics: ['its favorite lines', 'who taught it those lines', 'what is actually true']),
    DayPrompt(day: 8, title: 'Your hands today', prompt: 'Place a hand on your heart and write what you wish someone would say to you right now.', topics: ['what your heart needs', 'what your body is saying', 'what would feel like relief']),
    DayPrompt(day: 9, title: 'When you were a child', prompt: 'What did you need as a child that you didn\'t get? Can you give it to yourself now?', topics: ['the unmet need', 'how it shows up now', 'a way you can meet it today']),
    DayPrompt(day: 10, title: 'Permission slip', prompt: 'Write yourself a permission slip for something you\'ve been withholding.', topics: ['the thing you won\'t let yourself do', 'the rule you\'ve been following', 'the new rule']),
    DayPrompt(day: 11, title: 'A mistake reframed', prompt: 'Pick a mistake you replay. Write what a wise older version of you would say.', topics: ['the kindness they would lead with', 'the lesson they would name', 'what they\'d release']),
    DayPrompt(day: 12, title: 'Your worth without doing', prompt: 'If you accomplished nothing for a week, what would you still be?', topics: ['who you are without output', 'what makes you worth loving', 'what rest would feel like']),
    DayPrompt(day: 13, title: 'A loving witness', prompt: 'Write to yourself as a loving witness — someone who sees all of you and stays.', topics: ['what they see', 'what they admire', 'what they want for you']),
    DayPrompt(day: 14, title: 'What changed', prompt: 'Look back at the two weeks. How is your inner voice different now?', topics: ['what softened', 'what\'s still hard', 'what you want to keep practicing']),
  ],
);

const _healing14 = JournalPlanTemplate(
  id: 'healing_14',
  title: '14-Day Healing After Loss',
  description: 'Two weeks of tending to grief at your own pace.',
  lengthDays: 14,
  emoji: '\u{1F320}',
  dayPrompts: [
    DayPrompt(day: 1, title: 'Name the loss', prompt: 'Name the loss you\'re grieving. Write it plainly.', topics: ['who or what is gone', 'when it shifted', 'how the world looks different']),
    DayPrompt(day: 2, title: 'The first hard day', prompt: 'Write about the day you first felt the loss land.', topics: ['where you were', 'what you remember', 'who was with you']),
    DayPrompt(day: 3, title: 'What you miss', prompt: 'What specifically do you miss? Small details matter.', topics: ['a habit, a sound, a smell', 'a phrase they said', 'a way you used to feel']),
    DayPrompt(day: 4, title: 'Where grief lives', prompt: 'Where does the grief live in your body today?', topics: ['the physical sensation', 'what triggers it', 'what calms it']),
    DayPrompt(day: 5, title: 'A letter to them', prompt: 'Write a letter to who or what you lost. Say what was left unsaid.', topics: ['what you didn\'t get to say', 'what you want them to know', 'how you\'re carrying them']),
    DayPrompt(day: 6, title: 'The version of you before', prompt: 'Who were you before this loss? How are you different now?', topics: ['what you used to believe', 'what no longer fits', 'what you\'re becoming']),
    DayPrompt(day: 7, title: 'Permission to feel', prompt: 'Give yourself permission to feel what you\'re not supposed to feel.', topics: ['anger, relief, numbness, guilt', 'what you\'ve been hiding', 'who you\'re hiding it from']),
    DayPrompt(day: 8, title: 'A memory to keep', prompt: 'Write one memory in detail so you don\'t forget it.', topics: ['the smallest details', 'why it matters', 'how it still lives in you']),
    DayPrompt(day: 9, title: 'Support', prompt: 'Who or what has held you in this? Who else might be able to?', topics: ['who has shown up', 'who you haven\'t asked', 'one ask you can make this week']),
    DayPrompt(day: 10, title: 'The small returns', prompt: 'Have any small things become bearable again? Note them, gently.', topics: ['a song, a place, a routine', 'something you laughed at', 'a moment of forgetting']),
    DayPrompt(day: 11, title: 'What\'s changing', prompt: 'How has the grief shifted shape over time?', topics: ['what was true at first', 'what\'s true now', 'what you didn\'t expect']),
    DayPrompt(day: 12, title: 'Something to carry forward', prompt: 'What from what you lost will you carry forward?', topics: ['a value, a habit, a way of seeing', 'how it changed you for good', 'how to honor it']),
    DayPrompt(day: 13, title: 'A future without them', prompt: 'Imagine a future where the loss is part of you, not all of you.', topics: ['what you can still want', 'who you can still become', 'how they\'d want you to live']),
    DayPrompt(day: 14, title: 'What healing means here', prompt: 'What does healing mean to you now — not closure, but something else?', topics: ['what you\'ve learned about grief', 'what you don\'t need to rush', 'what feels possible now']),
  ],
);

const _confidence21 = JournalPlanTemplate(
  id: 'confidence_21',
  title: '21-Day Confidence Builder',
  description: 'Three weeks of reclaiming your own voice.',
  lengthDays: 21,
  emoji: '\u{1F525}',
  dayPrompts: [
    DayPrompt(day: 1, title: 'Where you feel small', prompt: 'In what part of your life do you currently feel smallest?', topics: ['the situation', 'who\'s in the room', 'what you wish you could do']),
    DayPrompt(day: 2, title: 'Old proof', prompt: 'Three times you were braver than you felt.', topics: ['what you did', 'what it cost you', 'what it gave you']),
    DayPrompt(day: 3, title: 'A voice in your head', prompt: 'Whose voice is the one that doubts you? Where did it come from?', topics: ['who taught you it', 'when it shows up', 'what you\'d say back now']),
    DayPrompt(day: 4, title: 'What you actually believe', prompt: 'Strip away other people\'s opinions. What do you actually believe about yourself?', topics: ['without their voices', 'in your quietest moment', 'on a good day']),
    DayPrompt(day: 5, title: 'A small risk', prompt: 'What\'s one small risk you could take this week that would stretch you a little?', topics: ['the smallest version of it', 'who you\'d become if you did', 'what you\'re afraid of']),
    DayPrompt(day: 6, title: 'Compliments you deflect', prompt: 'Write down compliments you usually dismiss. Sit with them.', topics: ['the most recent one', 'who said it', 'what if it were true']),
    DayPrompt(day: 7, title: 'A week in', prompt: 'How is your relationship to yourself shifting this week?', topics: ['one thing that\'s easier', 'one thing still stuck', 'what you want for week two']),
    DayPrompt(day: 8, title: 'Your body language', prompt: 'How do you sit, stand, speak when you feel confident? Practice describing it.', topics: ['posture, breath, gaze', 'how you take up space', 'when you last felt this']),
    DayPrompt(day: 9, title: 'A boundary', prompt: 'What boundary have you been avoiding setting?', topics: ['with whom', 'why you\'ve avoided it', 'one sentence you could say']),
    DayPrompt(day: 10, title: 'What\'s yours to want', prompt: 'What do you want that you\'ve told yourself you\'re not allowed to want?', topics: ['the desire', 'where the rule came from', 'what wanting it would mean']),
    DayPrompt(day: 11, title: 'A skill you have', prompt: 'Write about a skill you have that most people don\'t.', topics: ['how you got good at it', 'what it does for others', 'how to use it more']),
    DayPrompt(day: 12, title: 'When you said no', prompt: 'A time you said no when it was hard. How did it feel after?', topics: ['what you risked', 'what you protected', 'who you became']),
    DayPrompt(day: 13, title: 'Future self', prompt: 'Write as the version of you who already has the confidence you want.', topics: ['how they walk into a room', 'how they speak to themselves', 'one thing they want to tell you']),
    DayPrompt(day: 14, title: 'Two weeks in', prompt: 'What proof do you have so far that you\'re changing?', topics: ['a small win', 'a hard moment you handled', 'something you\'re ready to drop']),
    DayPrompt(day: 15, title: 'A redo', prompt: 'A moment you wish you\'d handled differently. Rewrite it as you would now.', topics: ['what happened', 'what you wish you\'d said', 'what you\'d do next time']),
    DayPrompt(day: 16, title: 'Your worth on a bad day', prompt: 'On your worst day, what is still true about you?', topics: ['without your achievements', 'without others\' approval', 'what remains']),
    DayPrompt(day: 17, title: 'Asking for help', prompt: 'Where have you needed help and not asked? Write it now.', topics: ['the ask you\'ve been avoiding', 'who you could ask', 'what asking would free']),
    DayPrompt(day: 18, title: 'A boundary kept', prompt: 'A time you kept a boundary even when it cost you. Honor it on the page.', topics: ['what you said no to', 'what it cost', 'what it built']),
    DayPrompt(day: 19, title: 'A bold sentence', prompt: 'Write one bold sentence about yourself that you wouldn\'t say out loud yet.', topics: ['something true', 'something you want to claim', 'something you\'re ready for']),
    DayPrompt(day: 20, title: 'Who you\'ve outgrown', prompt: 'What part of yourself have you outgrown in these three weeks?', topics: ['a story', 'a fear', 'a version of you']),
    DayPrompt(day: 21, title: 'What\'s next', prompt: 'Looking back at 21 days: what\'s shifted, and what\'s next?', topics: ['the biggest shift', 'a habit to keep', 'the next risk to take']),
  ],
);

const _vision21 = JournalPlanTemplate(
  id: 'vision_21',
  title: '21-Day Vision & Goals',
  description: 'Three weeks of clarifying what you actually want.',
  lengthDays: 21,
  emoji: '\u{1F3AF}',
  dayPrompts: [
    DayPrompt(day: 1, title: 'What you actually want', prompt: 'Strip away everyone else\'s expectations. What do you actually want?', topics: ['without should-s', 'in any area of life', 'the most honest answer']),
    DayPrompt(day: 2, title: 'A vivid future', prompt: 'One year from now, what does a good day look like in vivid detail?', topics: ['morning to night', 'who is in it', 'how you feel']),
    DayPrompt(day: 3, title: 'Your values', prompt: 'List your top five values. Which is most under-honored right now?', topics: ['name them', 'rank them', 'choose one to honor this week']),
    DayPrompt(day: 4, title: 'A bigger why', prompt: 'For one goal that matters: why does it matter? Keep asking why.', topics: ['the goal', 'the layer underneath', 'the deepest reason']),
    DayPrompt(day: 5, title: 'What stops you', prompt: 'Honestly: what stops you from going after what you want?', topics: ['fear, time, money, belief', 'the truest blocker', 'what you\'re avoiding feeling']),
    DayPrompt(day: 6, title: 'A mentor\'s advice', prompt: 'Imagine the wisest mentor you can. What would they tell you right now?', topics: ['their first sentence', 'what they\'d question', 'what they\'d encourage']),
    DayPrompt(day: 7, title: 'Week one wrap', prompt: 'What\'s become clearer this week?', topics: ['about what you want', 'about what\'s in the way', 'about who you are']),
    DayPrompt(day: 8, title: 'Three years out', prompt: 'Three years from now, what life are you living?', topics: ['where you are', 'what your work looks like', 'who you\'re with']),
    DayPrompt(day: 9, title: 'A goal broken open', prompt: 'Pick a big goal. Break it down to the smallest possible first step.', topics: ['the goal', 'the smallest action this week', 'when you\'ll do it']),
    DayPrompt(day: 10, title: 'What you\'d say yes to', prompt: 'If the right offer came today, what would you say yes to?', topics: ['what it looks like', 'what it asks of you', 'why you\'re ready']),
    DayPrompt(day: 11, title: 'What you\'d say no to', prompt: 'What are you ready to say no to so you have room for what matters?', topics: ['commitments', 'relationships', 'old goals']),
    DayPrompt(day: 12, title: 'Money on the page', prompt: 'How do you want money to feel in your life one year from now?', topics: ["what 'enough' looks like", 'what you\'d spend it on', 'what fears come up']),
    DayPrompt(day: 13, title: 'Work and meaning', prompt: 'How do you want your work to feel? What gives it meaning?', topics: ['the kind of problems', 'the kind of people', 'the kind of impact']),
    DayPrompt(day: 14, title: 'Two weeks in', prompt: 'Look back at the past two weeks. What surprised you?', topics: ['what came up', 'what you let go of', 'what you\'re ready to start']),
    DayPrompt(day: 15, title: 'Health and body', prompt: 'How do you want to feel in your body a year from now?', topics: ['energy, sleep, movement', 'what changes', 'what stays']),
    DayPrompt(day: 16, title: 'Relationships you want', prompt: 'Describe the quality of relationships you want in your life.', topics: ['romantic', 'family', 'friendship']),
    DayPrompt(day: 17, title: 'A risk worth taking', prompt: 'What\'s one risk this year worth taking even if it doesn\'t work?', topics: ['what it is', 'what failure would teach you', 'what success would unlock']),
    DayPrompt(day: 18, title: 'Daily habits', prompt: 'What daily habits would the version of you you\'re becoming have?', topics: ['morning', 'work hours', 'evening']),
    DayPrompt(day: 19, title: 'A 90-day plan', prompt: 'In the next 90 days, what three things matter most?', topics: ['the top three', 'why each one', 'what you\'ll put down for them']),
    DayPrompt(day: 20, title: 'Who you need', prompt: 'Who do you need to become for this vision — and who can help you get there?', topics: ['the new identity', 'a mentor', 'a friend who pushes you']),
    DayPrompt(day: 21, title: 'The first move', prompt: 'After 21 days: what\'s your very first move?', topics: ['the action this week', 'the action next week', 'how you\'ll celebrate it']),
  ],
);

const List<JournalPlanTemplate> journalPlanTemplates = [
  _gratitude7,
  _anxiety7,
  _selfCompassion14,
  _healing14,
  _confidence21,
  _vision21,
];

JournalPlanTemplate? planTemplateById(String id) {
  for (final p in journalPlanTemplates) {
    if (p.id == id) return p;
  }
  return null;
}
