/// Offline verses, hadiths and dhikr shown on the home screen.
///
/// Every list is [arabic, french, english].
enum ReminderKind { verse, hadith, dhikr }

class Reminder {
  const Reminder(this.kind, this.text, this.source);

  final ReminderKind kind;
  final List<String> text;
  final List<String> source;

  String textFor(int languageIndex) => text[languageIndex];
  String sourceFor(int languageIndex) => source[languageIndex];
}

abstract final class DailyReminders {
  static List<Reminder> of(ReminderKind kind) {
    switch (kind) {
      case ReminderKind.verse:
        return _verses;
      case ReminderKind.hadith:
        return _hadiths;
      case ReminderKind.dhikr:
        return _dhikr;
    }
  }

  /// Same item all day, a different one tomorrow.
  static Reminder forDay(ReminderKind kind, DateTime date) {
    final list = of(kind);
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return list[(dayOfYear + date.year) % list.length];
  }

  static const List<Reminder> _verses = [
    Reminder(
      ReminderKind.verse,
      [
        'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
        'Certes, avec la difficulté vient la facilité.',
        'Indeed, with hardship comes ease.',
      ],
      ['الشرح ٦', 'Ash-Sharh 94:6', 'Ash-Sharh 94:6'],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'فَاذْكُرُونِي أَذْكُرْكُمْ',
        'Souvenez-vous de Moi, Je me souviendrai de vous.',
        'So remember Me; I will remember you.',
      ],
      ['البقرة ١٥٢', 'Al-Baqara 2:152', 'Al-Baqarah 2:152'],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
        "C'est par l'évocation d'Allah que les cœurs s'apaisent.",
        'Verily, in the remembrance of Allah do hearts find rest.',
      ],
      ['الرعد ٢٨', "Ar-Ra'd 13:28", "Ar-Ra'd 13:28"],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ',
        'Quiconque place sa confiance en Allah, Il lui suffit.',
        'And whoever relies upon Allah — He is sufficient for him.',
      ],
      ['الطلاق ٣', 'At-Talaq 65:3', 'At-Talaq 65:3'],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
        'Allah est avec les endurants.',
        'Indeed, Allah is with the patient.',
      ],
      ['البقرة ١٥٣', 'Al-Baqara 2:153', 'Al-Baqarah 2:153'],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'وَقُل رَّبِّ زِدْنِي عِلْمًا',
        'Et dis : Seigneur, accrois mes connaissances.',
        'And say: My Lord, increase me in knowledge.',
      ],
      ['طه ١١٤', 'Ta-Ha 20:114', 'Ta-Ha 20:114'],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
        'Allah nous suffit, Il est le meilleur garant.',
        'Allah is sufficient for us, and He is the best disposer of affairs.',
      ],
      ['آل عمران ١٧٣', "Al 'Imran 3:173", "Al 'Imran 3:173"],
    ),
    Reminder(
      ReminderKind.verse,
      [
        'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ',
        'Ton Seigneur te donnera bientôt de quoi te satisfaire.',
        'And your Lord is going to give you, and you will be satisfied.',
      ],
      ['الضحى ٥', 'Ad-Duha 93:5', 'Ad-Duha 93:5'],
    ),
  ];

  static const List<Reminder> _hadiths = [
    Reminder(
      ReminderKind.hadith,
      [
        'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
        'Les actes ne valent que par les intentions.',
        'Actions are judged only by intentions.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
        'Ton sourire à ton frère est une aumône.',
        "Your smile in your brother's face is charity.",
      ],
      ['الترمذي', 'Tirmidhi', 'Tirmidhi'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
        "Le meilleur d'entre vous est celui qui apprend le Coran et l'enseigne.",
        'The best of you are those who learn the Quran and teach it.',
      ],
      ['البخاري', 'Bukhari', 'Bukhari'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
        "Nul d'entre vous ne croit vraiment tant qu'il n'aime pas pour son frère ce qu'il aime pour lui-même.",
        'None of you truly believes until he loves for his brother what he loves for himself.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'الطُّهُورُ شَطْرُ الْإِيمَانِ',
        'La propreté est la moitié de la foi.',
        'Cleanliness is half of faith.',
      ],
      ['مسلم', 'Muslim', 'Muslim'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
        'Que celui qui croit en Allah et au Jour dernier dise du bien ou se taise.',
        'Whoever believes in Allah and the Last Day, let him speak good or keep silent.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
    Reminder(
      ReminderKind.hadith,
      [
        'أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
        'Les actes les plus aimés d\'Allah sont les plus réguliers, même petits.',
        'The most beloved deeds to Allah are the most consistent, even if small.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
  ];

  static const List<Reminder> _dhikr = [
    Reminder(
      ReminderKind.dhikr,
      [
        'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
        'Gloire et louange à Allah, gloire à Allah le Magnifique.',
        'Glory and praise be to Allah; glory be to Allah the Magnificent.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
    Reminder(
      ReminderKind.dhikr,
      [
        'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
        "Il n'y a de force ni de puissance qu'en Allah.",
        'There is no power and no strength except with Allah.',
      ],
      ['متفق عليه', 'Bukhari et Muslim', 'Bukhari & Muslim'],
    ),
    Reminder(
      ReminderKind.dhikr,
      [
        'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ',
        'Je demande pardon à Allah le Magnifique et je me repens à Lui.',
        'I seek forgiveness from Allah the Magnificent and repent to Him.',
      ],
      ['ذكر', 'Dhikr', 'Dhikr'],
    ),
    Reminder(
      ReminderKind.dhikr,
      [
        'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
        'Ô Allah, prie sur notre Prophète Muhammad et salue-le.',
        'O Allah, send blessings and peace upon our Prophet Muhammad.',
      ],
      ['ذكر', 'Dhikr', 'Dhikr'],
    ),
    Reminder(
      ReminderKind.dhikr,
      [
        'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        'Louange à Allah, Seigneur des mondes.',
        'Praise be to Allah, Lord of the worlds.',
      ],
      ['الفاتحة ٢', 'Al-Fatiha 1:2', 'Al-Fatiha 1:2'],
    ),
    Reminder(
      ReminderKind.dhikr,
      [
        'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
        'Allah me suffit; nulle divinité sauf Lui; en Lui je place ma confiance; Il est le Seigneur du Trône immense.',
        'Allah is sufficient for me; there is no god but Him; in Him I trust; He is the Lord of the Mighty Throne.',
      ],
      ['التوبة ١٢٩', 'At-Tawba 9:129', 'At-Tawbah 9:129'],
    ),
  ];
}
