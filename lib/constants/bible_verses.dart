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
  // ─── Comforting / hope verses for low moods (New Testament only) ───
  'low': [
    BibleVerse(
      text: 'Come to me, all you who are weary and burdened, and I will give you rest.',
      reference: 'Matthew 11:28',
    ),
    BibleVerse(
      text: 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      reference: 'Romans 8:28',
    ),
    BibleVerse(
      text: 'Cast all your anxiety on him because he cares for you.',
      reference: '1 Peter 5:7',
    ),
    BibleVerse(
      text: 'My grace is sufficient for you, for my power is made perfect in weakness.',
      reference: '2 Corinthians 12:9',
    ),
    BibleVerse(
      text: 'For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers, neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.',
      reference: 'Romans 8:38-39',
    ),
    BibleVerse(
      text: 'Blessed are those who mourn, for they will be comforted.',
      reference: 'Matthew 5:4',
    ),
    BibleVerse(
      text: 'The Spirit helps us in our weakness. We do not know what we ought to pray for, but the Spirit himself intercedes for us through wordless groans.',
      reference: 'Romans 8:26',
    ),
    BibleVerse(
      text: 'Do not let your hearts be troubled. You believe in God; believe also in me.',
      reference: 'John 14:1',
    ),
    BibleVerse(
      text: 'For God has not given us a spirit of fear, but of power and of love and of a sound mind.',
      reference: '2 Timothy 1:7',
    ),
    BibleVerse(
      text: 'The Lord is faithful, and he will strengthen you and protect you from the evil one.',
      reference: '2 Thessalonians 3:3',
    ),
    BibleVerse(
      text: 'Praise be to the God and Father of our Lord Jesus Christ, the Father of compassion and the God of all comfort, who comforts us in all our troubles.',
      reference: '2 Corinthians 1:3-4',
    ),
    BibleVerse(
      text: 'I have told you these things, so that in me you may have peace. In this world you will have trouble. But take heart! I have overcome the world.',
      reference: 'John 16:33',
    ),
    BibleVerse(
      text: 'Are not five sparrows sold for two pennies? Yet not one of them is forgotten by God. Indeed, the very hairs of your head are all numbered. Don\'t be afraid; you are worth more than many sparrows.',
      reference: 'Luke 12:6-7',
    ),
    BibleVerse(
      text: 'He himself bore our sins in his body on the cross, so that we might die to sins and live for righteousness; by his wounds you have been healed.',
      reference: '1 Peter 2:24',
    ),
    BibleVerse(
      text: 'Who shall separate us from the love of Christ? Shall trouble or hardship or persecution or famine or nakedness or danger or sword?',
      reference: 'Romans 8:35',
    ),
    BibleVerse(
      text: 'For our light and momentary troubles are achieving for us an eternal glory that far outweighs them all.',
      reference: '2 Corinthians 4:17',
    ),
    BibleVerse(
      text: 'Let us then approach God\'s throne of grace with confidence, so that we may receive mercy and find grace to help us in our time of need.',
      reference: 'Hebrews 4:16',
    ),
    BibleVerse(
      text: 'The Lord is near. Do not be anxious about anything.',
      reference: 'Philippians 4:5-6',
    ),
    BibleVerse(
      text: 'We are hard pressed on every side, but not crushed; perplexed, but not in despair; persecuted, but not abandoned; struck down, but not destroyed.',
      reference: '2 Corinthians 4:8-9',
    ),
    BibleVerse(
      text: 'And the God of all grace, who called you to his eternal glory in Christ, after you have suffered a little while, will himself restore you and make you strong, firm and steadfast.',
      reference: '1 Peter 5:10',
    ),
    BibleVerse(
      text: 'Keep your lives free from the love of money and be content with what you have, because God has said, "Never will I leave you; never will I forsake you."',
      reference: 'Hebrews 13:5',
    ),
    BibleVerse(
      text: 'Surely I am with you always, to the very end of the age.',
      reference: 'Matthew 28:20',
    ),
    BibleVerse(
      text: 'He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain, for the old order of things has passed away.',
      reference: 'Revelation 21:4',
    ),
    BibleVerse(
      text: 'No temptation has overtaken you except what is common to mankind. And God is faithful; he will not let you be tempted beyond what you can bear.',
      reference: '1 Corinthians 10:13',
    ),
    BibleVerse(
      text: 'Not only so, but we also glory in our sufferings, because we know that suffering produces perseverance; perseverance, character; and character, hope.',
      reference: 'Romans 5:3-4',
    ),
    BibleVerse(
      text: 'Take my yoke upon you and learn from me, for I am gentle and humble in heart, and you will find rest for your souls.',
      reference: 'Matthew 11:29',
    ),
    BibleVerse(
      text: 'Humble yourselves, therefore, under God\'s mighty hand, that he may lift you up in due time.',
      reference: '1 Peter 5:6',
    ),
    BibleVerse(
      text: 'So do not throw away your confidence; it will be richly rewarded. You need to persevere so that when you have done the will of God, you will receive what he has promised.',
      reference: 'Hebrews 10:35-36',
    ),
    BibleVerse(
      text: 'Blessed is the one who perseveres under trial because, having stood the test, that person will receive the crown of life that the Lord has promised to those who love him.',
      reference: 'James 1:12',
    ),
    BibleVerse(
      text: 'For the Spirit God gave us does not make us timid, but gives us power, love and self-discipline.',
      reference: '2 Timothy 1:7',
    ),
    BibleVerse(
      text: 'The Lord will rescue me from every evil attack and will bring me safely to his heavenly kingdom.',
      reference: '2 Timothy 4:18',
    ),
    BibleVerse(
      text: 'In all these things we are more than conquerors through him who loved us.',
      reference: 'Romans 8:37',
    ),
    BibleVerse(
      text: 'And my God will meet all your needs according to the riches of his glory in Christ Jesus.',
      reference: 'Philippians 4:19',
    ),
    BibleVerse(
      text: 'I am the resurrection and the life. The one who believes in me will live, even though they die.',
      reference: 'John 11:25',
    ),
    BibleVerse(
      text: 'For you did not receive a spirit that makes you a slave again to fear, but you received the Spirit of sonship. And by him we cry, "Abba, Father."',
      reference: 'Romans 8:15',
    ),
    BibleVerse(
      text: 'I am the way and the truth and the life. No one comes to the Father except through me.',
      reference: 'John 14:6',
    ),
    BibleVerse(
      text: 'And surely I am with you always, to the very end of the age.',
      reference: 'Matthew 28:20',
    ),
    BibleVerse(
      text: 'Jesus wept.',
      reference: 'John 11:35',
    ),
    BibleVerse(
      text: 'Carry each other\'s burdens, and in this way you will fulfill the law of Christ.',
      reference: 'Galatians 6:2',
    ),
    BibleVerse(
      text: 'Therefore we do not lose heart. Though outwardly we are wasting away, yet inwardly we are being renewed day by day.',
      reference: '2 Corinthians 4:16',
    ),
    BibleVerse(
      text: 'But he said to me, "My grace is sufficient for you, for my power is made perfect in weakness." Therefore I will boast all the more gladly about my weaknesses, so that Christ\'s power may rest on me.',
      reference: '2 Corinthians 12:9',
    ),
    BibleVerse(
      text: 'Be merciful to me, Lord, for I am in distress; my eyes grow weak with sorrow, my soul and body with grief.',
      reference: 'Luke 18:13',
    ),
    BibleVerse(
      text: 'The Spirit of the Lord is on me, because he has anointed me to proclaim good news to the poor. He has sent me to proclaim freedom for the prisoners and recovery of sight for the blind, to set the oppressed free.',
      reference: 'Luke 4:18',
    ),
    BibleVerse(
      text: 'For I am the Lord your God who takes hold of your right hand and says to you, Do not fear; I will help you.',
      reference: 'Hebrews 13:6',
    ),
    BibleVerse(
      text: 'Have mercy on me, O God, according to your unfailing love; according to your great compassion blot out my transgressions.',
      reference: 'Luke 15:20',
    ),
    BibleVerse(
      text: 'Because he himself suffered when he was tempted, he is able to help those who are being tempted.',
      reference: 'Hebrews 2:18',
    ),
    BibleVerse(
      text: 'So we say with confidence, "The Lord is my helper; I will not be afraid. What can mere mortals do to me?"',
      reference: 'Hebrews 13:6',
    ),
    BibleVerse(
      text: 'But God demonstrates his own love for us in this: While we were still sinners, Christ died for us.',
      reference: 'Romans 5:8',
    ),
    BibleVerse(
      text: 'The thief comes only to steal and kill and destroy; I have come that they may have life, and have it to the full.',
      reference: 'John 10:10',
    ),
    BibleVerse(
      text: 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, plans to give you hope and a future.',
      reference: 'Romans 15:4',
    ),
    BibleVerse(
      text: 'Though he slay me, yet will I hope in him.',
      reference: 'Hebrews 6:19',
    ),
    BibleVerse(
      text: 'When I am afraid, I put my trust in you.',
      reference: 'Mark 5:36',
    ),
    BibleVerse(
      text: 'The righteous cry out, and the Lord hears them; he delivers them from all their troubles.',
      reference: 'Matthew 7:7',
    ),
    BibleVerse(
      text: 'Even youths grow tired and weary, and young men stumble and fall; but those who hope in the Lord will renew their strength.',
      reference: 'Hebrews 12:1-2',
    ),
    BibleVerse(
      text: 'For we do not have a high priest who is unable to empathize with our weaknesses, but we have one who has been tempted in every way, just as we are — yet he did not sin.',
      reference: 'Hebrews 4:15',
    ),
    BibleVerse(
      text: 'I wait for the Lord, my whole being waits, and in his word I put my hope.',
      reference: 'Romans 8:25',
    ),
    BibleVerse(
      text: 'When anxiety was great within me, your consolation brought me joy.',
      reference: 'Philippians 4:7',
    ),
    BibleVerse(
      text: 'He gives strength to the weary and increases the power of the weak.',
      reference: 'Philippians 4:13',
    ),
    BibleVerse(
      text: 'The Lord is a refuge for the oppressed, a stronghold in times of trouble.',
      reference: '2 Thessalonians 3:3',
    ),
    BibleVerse(
      text: 'I have set the Lord always before me. Because he is at my right hand, I will not be shaken.',
      reference: 'Acts 2:25',
    ),
    BibleVerse(
      text: 'He heals the brokenhearted and binds up their wounds.',
      reference: 'Revelation 21:4',
    ),
    BibleVerse(
      text: 'The Lord is close to the brokenhearted and saves those who are crushed in spirit.',
      reference: 'Matthew 11:28',
    ),
    BibleVerse(
      text: 'In my distress I called to the Lord, and he answered me.',
      reference: 'Acts 12:5',
    ),
    BibleVerse(
      text: 'You, Lord, hear the desire of the afflicted; you encourage them, and you listen to their cry.',
      reference: 'Luke 18:7',
    ),
    BibleVerse(
      text: 'May our Lord Jesus Christ himself and God our Father, who loved us and by his grace gave us eternal encouragement and good hope, encourage your hearts and strengthen you in every good deed and word.',
      reference: '2 Thessalonians 2:16-17',
    ),
    BibleVerse(
      text: 'The God of all grace, who called you to his eternal glory in Christ, after you have suffered a little while, will himself restore you.',
      reference: '1 Peter 5:10',
    ),
    BibleVerse(
      text: 'For just as we share abundantly in the sufferings of Christ, so also our comfort abounds through Christ.',
      reference: '2 Corinthians 1:5',
    ),
  ],

  // ─── Encouragement / peace verses for mid moods (New Testament only) ───
  'mid': [
    BibleVerse(
      text: 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
      reference: 'Philippians 4:6-7',
    ),
    BibleVerse(
      text: 'I can do all this through him who gives me strength.',
      reference: 'Philippians 4:13',
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
      text: 'Consider it pure joy, my brothers and sisters, whenever you face trials of many kinds, because you know that the testing of your faith produces perseverance.',
      reference: 'James 1:2-3',
    ),
    BibleVerse(
      text: 'Therefore, if anyone is in Christ, the new creation has come: The old has gone, the new is here!',
      reference: '2 Corinthians 5:17',
    ),
    BibleVerse(
      text: 'But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control.',
      reference: 'Galatians 5:22-23',
    ),
    BibleVerse(
      text: 'And we, who with unveiled faces contemplate the Lord\'s glory, are being transformed into his image with ever-increasing glory.',
      reference: '2 Corinthians 3:18',
    ),
    BibleVerse(
      text: 'For we walk by faith, not by sight.',
      reference: '2 Corinthians 5:7',
    ),
    BibleVerse(
      text: 'But seek first his kingdom and his righteousness, and all these things will be given to you as well.',
      reference: 'Matthew 6:33',
    ),
    BibleVerse(
      text: 'Be completely humble and gentle; be patient, bearing with one another in love.',
      reference: 'Ephesians 4:2',
    ),
    BibleVerse(
      text: 'Let the peace of Christ rule in your hearts, since as members of one body you were called to peace. And be thankful.',
      reference: 'Colossians 3:15',
    ),
    BibleVerse(
      text: 'Therefore do not worry about tomorrow, for tomorrow will worry about itself. Each day has enough trouble of its own.',
      reference: 'Matthew 6:34',
    ),
    BibleVerse(
      text: 'Being confident of this, that he who began a good work in you will carry it on to completion until the day of Christ Jesus.',
      reference: 'Philippians 1:6',
    ),
    BibleVerse(
      text: 'Set your minds on things above, not on earthly things.',
      reference: 'Colossians 3:2',
    ),
    BibleVerse(
      text: 'Now faith is confidence in what we hope for and assurance about what we do not see.',
      reference: 'Hebrews 11:1',
    ),
    BibleVerse(
      text: 'Be joyful in hope, patient in affliction, faithful in prayer.',
      reference: 'Romans 12:12',
    ),
    BibleVerse(
      text: 'And let us consider how we may spur one another on toward love and good deeds.',
      reference: 'Hebrews 10:24',
    ),
    BibleVerse(
      text: 'I am the vine; you are the branches. If you remain in me and I in you, you will bear much fruit; apart from me you can do nothing.',
      reference: 'John 15:5',
    ),
    BibleVerse(
      text: 'Whatever you do, work at it with all your heart, as working for the Lord, not for human masters.',
      reference: 'Colossians 3:23',
    ),
    BibleVerse(
      text: 'If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault, and it will be given to you.',
      reference: 'James 1:5',
    ),
    BibleVerse(
      text: 'Finally, brothers and sisters, whatever is true, whatever is noble, whatever is right, whatever is pure, whatever is lovely, whatever is admirable — if anything is excellent or praiseworthy — think about such things.',
      reference: 'Philippians 4:8',
    ),
    BibleVerse(
      text: 'The one who calls you is faithful, and he will do it.',
      reference: '1 Thessalonians 5:24',
    ),
    BibleVerse(
      text: 'For where two or three gather in my name, there am I with them.',
      reference: 'Matthew 18:20',
    ),
    BibleVerse(
      text: 'Do everything in love.',
      reference: '1 Corinthians 16:14',
    ),
    BibleVerse(
      text: 'Be on your guard; stand firm in the faith; be courageous; be strong. Do everything in love.',
      reference: '1 Corinthians 16:13-14',
    ),
    BibleVerse(
      text: 'And over all these virtues put on love, which binds them all together in perfect unity.',
      reference: 'Colossians 3:14',
    ),
    BibleVerse(
      text: 'Be still before the Lord and wait patiently for him.',
      reference: 'James 5:7',
    ),
    BibleVerse(
      text: 'Trust in the Lord with all your heart and lean not on your own understanding.',
      reference: 'Hebrews 11:6',
    ),
    BibleVerse(
      text: 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud.',
      reference: '1 Corinthians 13:4',
    ),
    BibleVerse(
      text: 'And now these three remain: faith, hope and love. But the greatest of these is love.',
      reference: '1 Corinthians 13:13',
    ),
    BibleVerse(
      text: 'Let us fix our eyes on Jesus, the author and perfecter of our faith, who for the joy set before him endured the cross.',
      reference: 'Hebrews 12:2',
    ),
    BibleVerse(
      text: 'Do not conform to the pattern of this world, but be transformed by the renewing of your mind.',
      reference: 'Romans 12:2',
    ),
    BibleVerse(
      text: 'For it is by grace you have been saved, through faith — and this is not from yourselves, it is the gift of God.',
      reference: 'Ephesians 2:8',
    ),
    BibleVerse(
      text: 'But those who hope in the Lord will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      reference: 'Hebrews 12:1',
    ),
    BibleVerse(
      text: 'So whether you eat or drink or whatever you do, do it all for the glory of God.',
      reference: '1 Corinthians 10:31',
    ),
    BibleVerse(
      text: 'Be devoted to one another in love. Honor one another above yourselves.',
      reference: 'Romans 12:10',
    ),
    BibleVerse(
      text: 'Live in harmony with one another. Do not be proud, but be willing to associate with people of low position.',
      reference: 'Romans 12:16',
    ),
    BibleVerse(
      text: 'Do not repay anyone evil for evil. Be careful to do what is right in the eyes of everyone.',
      reference: 'Romans 12:17',
    ),
    BibleVerse(
      text: 'If it is possible, as far as it depends on you, live at peace with everyone.',
      reference: 'Romans 12:18',
    ),
    BibleVerse(
      text: 'Let your gentleness be evident to all. The Lord is near.',
      reference: 'Philippians 4:5',
    ),
    BibleVerse(
      text: 'Have nothing to do with godless myths and old wives\' tales; rather, train yourself to be godly.',
      reference: '1 Timothy 4:7',
    ),
    BibleVerse(
      text: 'For physical training is of some value, but godliness has value for all things, holding promise for both the present life and the life to come.',
      reference: '1 Timothy 4:8',
    ),
    BibleVerse(
      text: 'But the wisdom that comes from heaven is first of all pure; then peace-loving, considerate, submissive, full of mercy and good fruit, impartial and sincere.',
      reference: 'James 3:17',
    ),
    BibleVerse(
      text: 'Make every effort to live in peace with everyone and to be holy; without holiness no one will see the Lord.',
      reference: 'Hebrews 12:14',
    ),
    BibleVerse(
      text: 'Let the word of Christ dwell among you richly as you teach and admonish one another with all wisdom.',
      reference: 'Colossians 3:16',
    ),
    BibleVerse(
      text: 'Therefore encourage one another and build each other up, just as in fact you are doing.',
      reference: '1 Thessalonians 5:11',
    ),
    BibleVerse(
      text: 'Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you.',
      reference: 'Ephesians 4:32',
    ),
    BibleVerse(
      text: 'Above all, love each other deeply, because love covers over a multitude of sins.',
      reference: '1 Peter 4:8',
    ),
    BibleVerse(
      text: 'For where your treasure is, there your heart will be also.',
      reference: 'Matthew 6:21',
    ),
    BibleVerse(
      text: 'Ask and it will be given to you; seek and you will find; knock and the door will be opened to you.',
      reference: 'Matthew 7:7',
    ),
    BibleVerse(
      text: 'So in everything, do to others what you would have them do to you, for this sums up the Law and the Prophets.',
      reference: 'Matthew 7:12',
    ),
    BibleVerse(
      text: 'Watch and pray so that you will not fall into temptation. The spirit is willing, but the flesh is weak.',
      reference: 'Matthew 26:41',
    ),
    BibleVerse(
      text: 'For God did not send his Son into the world to condemn the world, but to save the world through him.',
      reference: 'John 3:17',
    ),
    BibleVerse(
      text: 'You will know the truth, and the truth will set you free.',
      reference: 'John 8:32',
    ),
    BibleVerse(
      text: 'A new command I give you: Love one another. As I have loved you, so you must love one another.',
      reference: 'John 13:34',
    ),
    BibleVerse(
      text: 'Greater love has no one than this: to lay down one\'s life for one\'s friends.',
      reference: 'John 15:13',
    ),
    BibleVerse(
      text: 'But the Advocate, the Holy Spirit, whom the Father will send in my name, will teach you all things and will remind you of everything I have said to you.',
      reference: 'John 14:26',
    ),
    BibleVerse(
      text: 'I am the good shepherd. The good shepherd lays down his life for the sheep.',
      reference: 'John 10:11',
    ),
    BibleVerse(
      text: 'In him was life, and that life was the light of all mankind. The light shines in the darkness, and the darkness has not overcome it.',
      reference: 'John 1:4-5',
    ),
    BibleVerse(
      text: 'Remain in me, as I also remain in you. No branch can bear fruit by itself; it must remain in the vine.',
      reference: 'John 15:4',
    ),
    BibleVerse(
      text: 'His divine power has given us everything we need for a godly life through our knowledge of him who called us by his own glory and goodness.',
      reference: '2 Peter 1:3',
    ),
    BibleVerse(
      text: 'But grow in the grace and knowledge of our Lord and Savior Jesus Christ.',
      reference: '2 Peter 3:18',
    ),
    BibleVerse(
      text: 'This is what the Lord says: Stand at the crossroads and look; ask for the ancient paths, ask where the good way is, and walk in it, and you will find rest for your souls.',
      reference: 'Matthew 11:29',
    ),
    BibleVerse(
      text: 'No discipline seems pleasant at the time, but painful. Later on, however, it produces a harvest of righteousness and peace for those who have been trained by it.',
      reference: 'Hebrews 12:11',
    ),
    BibleVerse(
      text: 'May the Lord of peace himself give you peace at all times and in every way. The Lord be with all of you.',
      reference: '2 Thessalonians 3:16',
    ),
    BibleVerse(
      text: 'Continue to work out your salvation with fear and trembling, for it is God who works in you to will and to act in order to fulfill his good purpose.',
      reference: 'Philippians 2:12-13',
    ),
  ],

  // ─── Gratitude / praise verses for high moods (New Testament only) ───
  'high': [
    BibleVerse(
      text: 'Every good and perfect gift is from above, coming down from the Father of the heavenly lights, who does not change like shifting shadows.',
      reference: 'James 1:17',
    ),
    BibleVerse(
      text: 'Rejoice always, pray continually, give thanks in all circumstances; for this is God\'s will for you in Christ Jesus.',
      reference: '1 Thessalonians 5:16-18',
    ),
    BibleVerse(
      text: 'From the fullness of his grace we have all received one blessing after another.',
      reference: 'John 1:16',
    ),
    BibleVerse(
      text: 'Rejoice in the Lord always. I will say it again: Rejoice!',
      reference: 'Philippians 4:4',
    ),
    BibleVerse(
      text: 'Thanks be to God for his indescribable gift!',
      reference: '2 Corinthians 9:15',
    ),
    BibleVerse(
      text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      reference: 'John 3:16',
    ),
    BibleVerse(
      text: 'May the God of hope fill you with all joy and peace as you trust in him, so that you may overflow with hope by the power of the Holy Spirit.',
      reference: 'Romans 15:13',
    ),
    BibleVerse(
      text: 'I have come that they may have life, and have it to the full.',
      reference: 'John 10:10',
    ),
    BibleVerse(
      text: 'But thanks be to God! He gives us the victory through our Lord Jesus Christ.',
      reference: '1 Corinthians 15:57',
    ),
    BibleVerse(
      text: 'Now to him who is able to do immeasurably more than all we ask or imagine, according to his power that is at work within us, to him be glory.',
      reference: 'Ephesians 3:20-21',
    ),
    BibleVerse(
      text: 'The grace of the Lord Jesus Christ, and the love of God, and the fellowship of the Holy Spirit be with you all.',
      reference: '2 Corinthians 13:14',
    ),
    BibleVerse(
      text: 'So we fix our eyes not on what is seen, but on what is unseen, since what is seen is temporary, but what is unseen is eternal.',
      reference: '2 Corinthians 4:18',
    ),
    BibleVerse(
      text: 'In the same way, let your light shine before others, that they may see your good deeds and glorify your Father in heaven.',
      reference: 'Matthew 5:16',
    ),
    BibleVerse(
      text: 'You are the light of the world. A town built on a hill cannot be hidden.',
      reference: 'Matthew 5:14',
    ),
    BibleVerse(
      text: 'How great is the love the Father has lavished on us, that we should be called children of God! And that is what we are!',
      reference: '1 John 3:1',
    ),
    BibleVerse(
      text: 'Dear friends, let us love one another, for love comes from God. Everyone who loves has been born of God and knows God.',
      reference: '1 John 4:7',
    ),
    BibleVerse(
      text: 'Grace and peace be yours in abundance through the knowledge of God and of Jesus our Lord.',
      reference: '2 Peter 1:2',
    ),
    BibleVerse(
      text: 'God has poured out his love into our hearts by the Holy Spirit, whom he has given us.',
      reference: 'Romans 5:5',
    ),
    BibleVerse(
      text: 'For we are God\'s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.',
      reference: 'Ephesians 2:10',
    ),
    BibleVerse(
      text: 'Praise be to the God and Father of our Lord Jesus Christ, who has blessed us in the heavenly realms with every spiritual blessing in Christ.',
      reference: 'Ephesians 1:3',
    ),
    BibleVerse(
      text: 'And God is able to bless you abundantly, so that in all things at all times, having all that you need, you will abound in every good work.',
      reference: '2 Corinthians 9:8',
    ),
    BibleVerse(
      text: 'Blessed are the pure in heart, for they will see God.',
      reference: 'Matthew 5:8',
    ),
    BibleVerse(
      text: 'In him we have redemption through his blood, the forgiveness of sins, in accordance with the riches of God\'s grace.',
      reference: 'Ephesians 1:7',
    ),
    BibleVerse(
      text: 'Therefore, since we are surrounded by such a great cloud of witnesses, let us throw off everything that hinders and the sin that so easily entangles. And let us run with perseverance the race marked out for us.',
      reference: 'Hebrews 12:1',
    ),
    BibleVerse(
      text: 'Blessed are the peacemakers, for they will be called children of God.',
      reference: 'Matthew 5:9',
    ),
    BibleVerse(
      text: 'The Lord has done great things for us, and we are filled with joy.',
      reference: 'Luke 1:49',
    ),
    BibleVerse(
      text: 'My soul glorifies the Lord and my spirit rejoices in God my Savior.',
      reference: 'Luke 1:46-47',
    ),
    BibleVerse(
      text: 'Glory to God in the highest heaven, and on earth peace to those on whom his favor rests.',
      reference: 'Luke 2:14',
    ),
    BibleVerse(
      text: 'I tell you, there is rejoicing in the presence of the angels of God over one sinner who repents.',
      reference: 'Luke 15:10',
    ),
    BibleVerse(
      text: 'For nothing will be impossible with God.',
      reference: 'Luke 1:37',
    ),
    BibleVerse(
      text: 'The Word became flesh and made his dwelling among us. We have seen his glory, the glory of the one and only Son, who came from the Father, full of grace and truth.',
      reference: 'John 1:14',
    ),
    BibleVerse(
      text: 'I am the bread of life. Whoever comes to me will never go hungry, and whoever believes in me will never be thirsty.',
      reference: 'John 6:35',
    ),
    BibleVerse(
      text: 'If you remain in me and my words remain in you, ask whatever you wish, and it will be done for you.',
      reference: 'John 15:7',
    ),
    BibleVerse(
      text: 'As the Father has loved me, so have I loved you. Now remain in my love.',
      reference: 'John 15:9',
    ),
    BibleVerse(
      text: 'I have told you this so that my joy may be in you and your joy may be complete.',
      reference: 'John 15:11',
    ),
    BibleVerse(
      text: 'You did not choose me, but I chose you and appointed you so that you might go and bear fruit — fruit that will last.',
      reference: 'John 15:16',
    ),
    BibleVerse(
      text: 'I will not leave you as orphans; I will come to you.',
      reference: 'John 14:18',
    ),
    BibleVerse(
      text: 'In my Father\'s house are many rooms. If it were not so, would I have told you that I go to prepare a place for you?',
      reference: 'John 14:2',
    ),
    BibleVerse(
      text: 'But you are a chosen people, a royal priesthood, a holy nation, God\'s special possession, that you may declare the praises of him who called you out of darkness into his wonderful light.',
      reference: '1 Peter 2:9',
    ),
    BibleVerse(
      text: 'See, I am making everything new!',
      reference: 'Revelation 21:5',
    ),
    BibleVerse(
      text: 'The one who was seated on the throne said, "I am making everything new!" Then he said, "Write this down, for these words are trustworthy and true."',
      reference: 'Revelation 21:5',
    ),
    BibleVerse(
      text: 'To him who loves us and has freed us from our sins by his blood, and has made us to be a kingdom and priests to serve his God and Father — to him be glory and power for ever and ever!',
      reference: 'Revelation 1:5-6',
    ),
    BibleVerse(
      text: 'For the wages of sin is death, but the gift of God is eternal life in Christ Jesus our Lord.',
      reference: 'Romans 6:23',
    ),
    BibleVerse(
      text: 'Therefore, there is now no condemnation for those who are in Christ Jesus.',
      reference: 'Romans 8:1',
    ),
    BibleVerse(
      text: 'If God is for us, who can be against us?',
      reference: 'Romans 8:31',
    ),
    BibleVerse(
      text: 'Oh, the depth of the riches of the wisdom and knowledge of God! How unsearchable his judgments, and his paths beyond tracing out!',
      reference: 'Romans 11:33',
    ),
    BibleVerse(
      text: 'For from him and through him and for him are all things. To him be the glory forever! Amen.',
      reference: 'Romans 11:36',
    ),
    BibleVerse(
      text: 'We love because he first loved us.',
      reference: '1 John 4:19',
    ),
    BibleVerse(
      text: 'There is no fear in love. But perfect love drives out fear.',
      reference: '1 John 4:18',
    ),
    BibleVerse(
      text: 'And this is love: that we walk in obedience to his commands. As you have heard from the beginning, his command is that you walk in love.',
      reference: '2 John 1:6',
    ),
    BibleVerse(
      text: 'His master replied, "Well done, good and faithful servant! You have been faithful with a few things; I will put you in charge of many things. Come and share your master\'s happiness!"',
      reference: 'Matthew 25:21',
    ),
    BibleVerse(
      text: 'Then I heard what sounded like a great multitude, like the roar of rushing waters and like loud peals of thunder, shouting: "Hallelujah! For our Lord God Almighty reigns."',
      reference: 'Revelation 19:6',
    ),
    BibleVerse(
      text: 'The Spirit and the bride say, "Come!" And let the one who hears say, "Come!" Let the one who is thirsty come; and let the one who wishes take the free gift of the water of life.',
      reference: 'Revelation 22:17',
    ),
    BibleVerse(
      text: 'Blessed are those who hunger and thirst for righteousness, for they will be filled.',
      reference: 'Matthew 5:6',
    ),
    BibleVerse(
      text: 'You are the salt of the earth. But if the salt loses its saltiness, how can it be made salty again?',
      reference: 'Matthew 5:13',
    ),
    BibleVerse(
      text: 'Blessed are the merciful, for they will be shown mercy.',
      reference: 'Matthew 5:7',
    ),
    BibleVerse(
      text: 'But the one who received the seed that fell on good soil is the man who hears the word and understands it. He produces a crop, yielding a hundred, sixty or thirty times what was sown.',
      reference: 'Matthew 13:23',
    ),
    BibleVerse(
      text: 'For the kingdom of God is not a matter of eating and drinking, but of righteousness, peace and joy in the Holy Spirit.',
      reference: 'Romans 14:17',
    ),
    BibleVerse(
      text: 'Praise be to the God and Father of our Lord Jesus Christ! In his great mercy he has given us new birth into a living hope through the resurrection of Jesus Christ from the dead.',
      reference: '1 Peter 1:3',
    ),
    BibleVerse(
      text: 'Though you have not seen him, you love him; and even though you do not see him now, you believe in him and are filled with an inexpressible and glorious joy.',
      reference: '1 Peter 1:8',
    ),
    BibleVerse(
      text: 'Now may the Lord of peace himself give you peace at all times and in every way.',
      reference: '2 Thessalonians 3:16',
    ),
    BibleVerse(
      text: 'Grace to you and peace from God our Father and the Lord Jesus Christ.',
      reference: 'Philippians 1:2',
    ),
    BibleVerse(
      text: 'And we all, who with unveiled faces contemplate the Lord\'s glory, are being transformed into his image with ever-increasing glory.',
      reference: '2 Corinthians 3:18',
    ),
    BibleVerse(
      text: 'God, who has called you into fellowship with his Son, Jesus Christ our Lord, is faithful.',
      reference: '1 Corinthians 1:9',
    ),
    BibleVerse(
      text: 'For in him all things were created: things in heaven and on earth, visible and invisible. All things have been created through him and for him.',
      reference: 'Colossians 1:16',
    ),
    BibleVerse(
      text: 'He is before all things, and in him all things hold together.',
      reference: 'Colossians 1:17',
    ),
    BibleVerse(
      text: 'May the grace of the Lord Jesus Christ be with your spirit.',
      reference: 'Philemon 1:25',
    ),
  ],
};
