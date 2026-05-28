enum AffirmationTone {
  calming,
  empowering,
  selfCompassion,
  growth,
}

String affirmationToneLabel(AffirmationTone t) {
  switch (t) {
    case AffirmationTone.calming:
      return 'Calming';
    case AffirmationTone.empowering:
      return 'Empowering';
    case AffirmationTone.selfCompassion:
      return 'Self-Compassion';
    case AffirmationTone.growth:
      return 'Growth';
  }
}

class Affirmation {
  final String text;
  final AffirmationTone tone;

  const Affirmation({required this.text, required this.tone});
}

const List<Affirmation> affirmations = [
  // ─── Calming ───
  Affirmation(text: 'I am safe in this moment.', tone: AffirmationTone.calming),
  Affirmation(text: 'My breath is steady, and so am I.', tone: AffirmationTone.calming),
  Affirmation(text: 'I can rest without earning it.', tone: AffirmationTone.calming),
  Affirmation(text: 'This feeling will pass through me.', tone: AffirmationTone.calming),
  Affirmation(text: 'I let go of what I cannot control.', tone: AffirmationTone.calming),
  Affirmation(text: 'I move at my own pace.', tone: AffirmationTone.calming),
  Affirmation(text: 'Stillness is allowed here.', tone: AffirmationTone.calming),
  Affirmation(text: 'I do not need to figure it all out today.', tone: AffirmationTone.calming),
  Affirmation(text: 'Peace begins with the next breath.', tone: AffirmationTone.calming),
  Affirmation(text: 'I am held by something larger than my worries.', tone: AffirmationTone.calming),

  // ─── Empowering ───
  Affirmation(text: 'I have everything I need to begin.', tone: AffirmationTone.empowering),
  Affirmation(text: 'My voice matters.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I take up the space I deserve.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I trust the decisions I make for myself.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I am stronger than the doubt in my head.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I am the author of my own day.', tone: AffirmationTone.empowering),
  Affirmation(text: 'My past does not define my next step.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I can do hard things — I have before.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I choose courage over comfort today.', tone: AffirmationTone.empowering),
  Affirmation(text: 'I am allowed to want what I want.', tone: AffirmationTone.empowering),

  // ─── Self-Compassion ───
  Affirmation(text: 'I am doing the best I can with what I have.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I treat myself the way I treat someone I love.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I am allowed to make mistakes and still be worthy.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'My feelings are valid even when they\'re inconvenient.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I do not have to earn rest.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I forgive myself for what I did not yet know.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I am worthy of love I have to give myself.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I can be patient with the parts of me still healing.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'It is okay to have a hard day.', tone: AffirmationTone.selfCompassion),
  Affirmation(text: 'I am enough exactly as I am right now.', tone: AffirmationTone.selfCompassion),

  // ─── Growth ───
  Affirmation(text: 'Every small step is still a step.', tone: AffirmationTone.growth),
  Affirmation(text: 'I am becoming who I am meant to be.', tone: AffirmationTone.growth),
  Affirmation(text: 'I learn more from trying than from being right.', tone: AffirmationTone.growth),
  Affirmation(text: 'Discomfort is part of the path, not a sign to stop.', tone: AffirmationTone.growth),
  Affirmation(text: 'I am open to new ways of seeing myself.', tone: AffirmationTone.growth),
  Affirmation(text: 'I let curiosity be louder than fear.', tone: AffirmationTone.growth),
  Affirmation(text: 'Today I plant something I want to grow.', tone: AffirmationTone.growth),
  Affirmation(text: 'I release who I was to make room for who I\'m becoming.', tone: AffirmationTone.growth),
  Affirmation(text: 'I am allowed to outgrow what I have outgrown.', tone: AffirmationTone.growth),
  Affirmation(text: 'My next chapter is mine to write.', tone: AffirmationTone.growth),
];

List<Affirmation> affirmationsByTone(AffirmationTone tone) =>
    affirmations.where((a) => a.tone == tone).toList();
