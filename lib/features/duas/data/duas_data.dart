// ═══════════════════════════════════════════════════════════════
//  lib/features/duas/data/duas_data.dart
//  تقوى — بيانات الأدعية
// ═══════════════════════════════════════════════════════════════

enum DuaCategory {
  morning,
  distress,
  guidance,
  forgiveness,
  rizq,
  health,
  parents,
  travel,
  rain,
  general,
}

class DuaItem {
  final int id;
  final String arabic;
  final String meaning;
  final String occasion;
  final String source;
  final String emoji;
  final DuaCategory category;
  bool isFav;

  DuaItem({
    required this.id,
    required this.arabic,
    required this.meaning,
    required this.occasion,
    required this.source,
    required this.emoji,
    required this.category,
    this.isFav = false,
  });
}

final kDuasData = <DuaCategory, List<DuaItem>>{
  DuaCategory.distress: [
    DuaItem(
      id: 1,
      emoji: '🌊',
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      meaning: 'حسبي الله ولا إله إلا هو، عليه توكلت وهو رب العرش العظيم',
      occasion: 'عند الهم والكرب',
      source: 'التوبة: ١٢٩',
      category: DuaCategory.distress,
    ),
    DuaItem(
      id: 2,
      emoji: '🤲',
      arabic:
          'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ',
      meaning: 'اللهم أعوذ بك من الهم والحزن والعجز والكسل',
      occasion: 'دعاء الكرب والضيق',
      source: 'البخاري',
      category: DuaCategory.distress,
    ),
    DuaItem(
      id: 3,
      emoji: '💧',
      arabic:
          'لَا إِلَٰهَ إِلَّا أَنتَ سُبْحَانَكَ إِنِّي كُنتُ مِنَ الظَّالِمِينَ',
      meaning: 'دعاء يونس عليه السلام في بطن الحوت',
      occasion: 'عند الشدة والضيق الشديد',
      source: 'الأنبياء: ٨٧',
      category: DuaCategory.distress,
    ),
  ],
  DuaCategory.guidance: [
    DuaItem(
      id: 10,
      emoji: '🌟',
      arabic:
          'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي',
      meaning: 'ربي افتح لي صدري ويسر أمري واحلل عقدة لساني يفهموا كلامي',
      occasion: 'قبل الخطابة والحديث',
      source: 'طه: ٢٥-٢٨',
      category: DuaCategory.guidance,
    ),
    DuaItem(
      id: 11,
      emoji: '🧭',
      arabic: 'اللَّهُمَّ أَلْهِمْنِي رُشْدِي وَأَعِذْنِي مِنْ شَرِّ نَفْسِي',
      meaning: 'اللهم ألهمني الرشد وأعذني من شر نفسي',
      occasion: 'طلب الهداية والسداد',
      source: 'الترمذي — حسن',
      category: DuaCategory.guidance,
    ),
  ],
  DuaCategory.forgiveness: [
    DuaItem(
      id: 20,
      emoji: '🌿',
      arabic:
          'رَبِّ اغْفِرْ لِي وَتُبْ عَلَيَّ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ',
      meaning: 'ربي اغفر لي وتب علي إنك أنت التواب الرحيم',
      occasion: 'سيد الاستغفار — يومياً',
      source: 'أبو داود',
      category: DuaCategory.forgiveness,
    ),
    DuaItem(
      id: 21,
      emoji: '✨',
      arabic:
          'اللَّهُمَّ اغْفِرْ لِي مَا قَدَّمْتُ وَمَا أَخَّرْتُ، وَمَا أَسْرَرْتُ وَمَا أَعْلَنْتُ',
      meaning: 'اللهم اغفر لي ما قدمت وما أخرت وما أسررت وما أعلنت',
      occasion: 'في السجود وآخر الليل',
      source: 'مسلم',
      category: DuaCategory.forgiveness,
    ),
  ],
  DuaCategory.rizq: [
    DuaItem(
      id: 30,
      emoji: '🌾',
      arabic:
          'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
      meaning: 'اللهم اكفني بالحلال عن الحرام وأغنني بفضلك عمن سواك',
      occasion: 'دعاء الرزق الحلال',
      source: 'الترمذي — حسن',
      category: DuaCategory.rizq,
    ),
    DuaItem(
      id: 31,
      emoji: '💎',
      arabic:
          'اللَّهُمَّ رَبَّنَا أَنزِلْ عَلَيْنَا مَائِدَةً مِّنَ السَّمَاءِ تَكُونُ لَنَا عِيدًا',
      meaning: 'ربنا أنزل علينا رزقاً من عندك يكون لنا عيداً',
      occasion: 'طلب الرزق الكريم',
      source: 'المائدة: ١١٤',
      category: DuaCategory.rizq,
    ),
  ],
  DuaCategory.health: [
    DuaItem(
      id: 40,
      emoji: '🫀',
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي',
      meaning: 'اللهم عافني في بدني وسمعي وبصري',
      occasion: 'دعاء العافية يومياً',
      source: 'أبو داود',
      category: DuaCategory.health,
    ),
    DuaItem(
      id: 41,
      emoji: '🌱',
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ',
      meaning: 'اللهم إني أسألك العافية في الدنيا والآخرة',
      occasion: 'دعاء العافية الشامل',
      source: 'ابن ماجه — صحيح',
      category: DuaCategory.health,
    ),
  ],
  DuaCategory.parents: [
    DuaItem(
      id: 50,
      emoji: '❤️',
      arabic: 'رَّبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
      meaning: 'ربي ارحم والديّ كما ربياني وأنا صغير',
      occasion: 'الدعاء للوالدين — يومياً',
      source: 'الإسراء: ٢٤',
      category: DuaCategory.parents,
    ),
    DuaItem(
      id: 51,
      emoji: '🤍',
      arabic:
          'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ',
      meaning: 'ربي اغفر لي ولوالديّ وللمؤمنين يوم الحساب',
      occasion: 'الدعاء للوالدين والمؤمنين',
      source: 'إبراهيم: ٤١',
      category: DuaCategory.parents,
    ),
  ],
  DuaCategory.travel: [
    DuaItem(
      id: 60,
      emoji: '✈️',
      arabic:
          'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      meaning: 'سبحان الذي سخر لنا هذا وإنا إلى ربنا لمنقلبون',
      occasion: 'دعاء ركوب السيارة والطائرة',
      source: 'الزخرف: ١٣',
      category: DuaCategory.travel,
    ),
  ],
  DuaCategory.general: [
    DuaItem(
      id: 70,
      emoji: '🌍',
      arabic:
          'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
      meaning: 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
      occasion: 'أفضل الأدعية — يومياً',
      source: 'البقرة: ٢٠١',
      category: DuaCategory.general,
    ),
    DuaItem(
      id: 71,
      emoji: '🙏',
      arabic: 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
      meaning: 'اللهم إنك عفو تحب العفو فاعف عني',
      occasion: 'في ليلة القدر وكل وقت',
      source: 'الترمذي — صحيح',
      category: DuaCategory.general,
    ),
  ],
};
