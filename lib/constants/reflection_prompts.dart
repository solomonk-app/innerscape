enum ReflectionCadence { weekly, monthly }

class ReflectionPrompt {
  final String id;
  final String title;
  final String prompt;
  final List<String> topics;
  final ReflectionCadence cadence;

  const ReflectionPrompt({
    required this.id,
    required this.title,
    required this.prompt,
    required this.topics,
    required this.cadence,
  });
}

const List<ReflectionPrompt> weeklyPrompts = [
  ReflectionPrompt(
    id: 'w_energy',
    title: 'Energy this week',
    prompt: 'What gave you energy this week, and what drained it?',
    topics: ['the brightest moment', 'the heaviest moment', 'one shift for next week'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_pattern',
    title: 'Patterns you noticed',
    prompt: 'What pattern did you notice in yourself this week?',
    topics: ['when it showed up', 'what triggered it', 'what it might be asking'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_proud',
    title: 'Something to be proud of',
    prompt: 'What did you do this week that deserves more credit than you\'re giving yourself?',
    topics: ['the small wins', 'how you handled something hard', 'a kindness you offered'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_let_go',
    title: 'Ready to let go',
    prompt: 'What from this week are you ready to leave behind?',
    topics: ['a conversation', 'a feeling', 'a story you told yourself'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_next_week',
    title: 'Posture for next week',
    prompt: 'What posture do you want to bring into next week?',
    topics: ['a word to anchor it', 'a person to lean on', 'a habit to protect'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_unfinished',
    title: 'Unfinished business',
    prompt: 'What\'s sitting unfinished that you keep carrying?',
    topics: ['a task', 'a conversation', 'an emotion'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_relationships',
    title: 'People this week',
    prompt: 'Who showed up for you, and who did you show up for?',
    topics: ['a person to thank', 'a person to reach out to', 'a relationship that\'s shifting'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_body',
    title: 'Your body this week',
    prompt: 'How did your body feel this week? What does it need?',
    topics: ['energy, sleep, tension', 'what you ignored', 'one kindness for next week'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_surprise',
    title: 'A surprise',
    prompt: 'What surprised you this week — about the world, or about yourself?',
    topics: ['something you didn\'t expect', 'what it revealed', 'how it changed you'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_kindness',
    title: 'A kindness given or received',
    prompt: 'Where did kindness show up this week — yours or someone else\'s?',
    topics: ['who gave it', 'how it landed', 'how you can pay it forward'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_lesson',
    title: 'One lesson',
    prompt: 'If this week taught you one thing, what was it?',
    topics: ['what happened', 'what you saw', 'what you\'ll do differently'],
    cadence: ReflectionCadence.weekly,
  ),
  ReflectionPrompt(
    id: 'w_quiet',
    title: 'A quiet moment',
    prompt: 'Describe a quiet moment from this week you want to remember.',
    topics: ['where you were', 'what you noticed', 'why it stayed with you'],
    cadence: ReflectionCadence.weekly,
  ),
];

const List<ReflectionPrompt> monthlyPrompts = [
  ReflectionPrompt(
    id: 'm_shifts',
    title: 'What shifted this month',
    prompt: 'Look back at the month. What in you shifted, even quietly?',
    topics: ['a belief', 'a habit', 'a relationship'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_eisenhower',
    title: 'Time vs. importance',
    prompt: 'Where did your time go this month — and was it where it should have gone? (Try the Eisenhower exercise.)',
    topics: ['urgent and important', 'important but not urgent', 'urgent but not important', 'neither'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_proud',
    title: 'The month\'s proudest moment',
    prompt: 'What from this month are you most proud of?',
    topics: ['what you did', 'who it took to do it', 'who you became after'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_hardest',
    title: 'The hardest part',
    prompt: 'What was the hardest part of this month, and how did you carry it?',
    topics: ['what hurt', 'what helped', 'what you learned'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_relationships',
    title: 'Relationships this month',
    prompt: 'How did your closest relationships shift this month?',
    topics: ['who grew closer', 'who grew distant', 'what you want for next month'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_self',
    title: 'How you treated yourself',
    prompt: 'How did you treat yourself this month?',
    topics: ['kindest moment', 'harshest moment', 'what you want more of'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_growth',
    title: 'Growth edge',
    prompt: 'Where did you grow this month, and where do you still feel stuck?',
    topics: ['the growth', 'the stuckness', 'one experiment for next month'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_release',
    title: 'Ready to release',
    prompt: 'What from this month are you ready to release before the next one begins?',
    topics: ['a feeling', 'an obligation', 'an identity you\'re outgrowing'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_carry',
    title: 'What to carry forward',
    prompt: 'What\'s worth carrying into the next month?',
    topics: ['a habit', 'a person', 'a way of being'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_goal',
    title: 'One goal for next month',
    prompt: 'If you could focus on one thing next month, what would it be?',
    topics: ['the goal', 'why it matters now', 'the first small step'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_body',
    title: 'Body and rhythm',
    prompt: 'How did your body feel this month? What rhythm does it want next?',
    topics: ['sleep, energy, movement', 'a pattern you noticed', 'one change you\'ll try'],
    cadence: ReflectionCadence.monthly,
  ),
  ReflectionPrompt(
    id: 'm_letter',
    title: 'A letter to next-month-you',
    prompt: 'Write a short letter to yourself one month from now.',
    topics: ['what you hope for them', 'what you want them to remember', 'what you trust them with'],
    cadence: ReflectionCadence.monthly,
  ),
];

ReflectionPrompt weeklyPromptForWeek(DateTime date) {
  final dayOfYear = int.parse(
    '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}',
  );
  final weekIndex = dayOfYear ~/ 7;
  return weeklyPrompts[weekIndex % weeklyPrompts.length];
}

ReflectionPrompt monthlyPromptForMonth(DateTime date) {
  final monthIndex = (date.year * 12 + date.month - 1) % monthlyPrompts.length;
  return monthlyPrompts[monthIndex];
}
