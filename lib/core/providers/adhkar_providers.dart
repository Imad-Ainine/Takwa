// ═══════════════════════════════════════════════════════════════
//  lib/features/adhkar/data/adhkar_data.dart
//  lib/features/adhkar/providers/adhkar_providers.dart
//  تقوى — Adhkar Data + Providers + Notification Service
// ═══════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:math' as math;



// ═══════════════════════════════════════════════════════════════
//  MODELS
// ═══════════════════════════════════════════════════════════════
enum AdhkarCategory {
  wakingUp,
  morning,
  evening,
  afterPrayer,
  sleep,
  food,
  misc,
}

class DhikrItem {
  final int id;
  final String arabic;
  final String? transliteration;
  final String? fadl; // الفضل والفائدة
  final String? source; // المصدر
  final int count; // عدد التكرار
  final AdhkarCategory category;

  const DhikrItem({
    required this.id,
    required this.arabic,
    required this.count,
    required this.category,
    this.transliteration,
    this.fadl,
    this.source,
  });
}

// ═══════════════════════════════════════════════════════════════
//  ADHKAR DATA  (بيانات حقيقية من حصن المسلم)
// ═══════════════════════════════════════════════════════════════
const kAdhkarData = <AdhkarCategory, List<DhikrItem>>{
  // ────────────── الاستيقاظ من النوم ──────────────
  AdhkarCategory.wakingUp: [
    DhikrItem(
      id: 1,
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      count: 1,
      category: AdhkarCategory.wakingUp,
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 2,
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، سُبْحَانَ اللَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا اللَّهُ، وَاللَّهُ أَكْبَرُ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ الْعَلِيِّ الْعَظِيمِ، رَبِّ اغْفِرْ لِي',
      count: 1,
      category: AdhkarCategory.wakingUp,
      fadl: 'من قالها غُفر له، وإن دعا استُجيب له، وإن توضأ وصلى قُبلت صلاته',
      source: 'صحيح البخاري',
    ),
  ],

  // ────────────── الصباح ──────────────
  AdhkarCategory.morning: [
    DhikrItem(
      id: 101,
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيطانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      count: 1,
      category: AdhkarCategory.morning,
      transliteration: 'آية الكرسي',
      fadl: 'من قرأها حين يصبح أُجير من الجن حتى يمسي',
      source: 'صحيح الترغيب',
    ),
    DhikrItem(
      id: 102,
      arabic:
          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللَّهُ أَحَدٌ * اللَّهُ الصَّمَدُ * لَمْ يَلِدْ وَلَمْ يُولَدْ * وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ\n\nبِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ * مِن شَرِّ مَا خَلَقَ * وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ * وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ * وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nبِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ * مَلِكِ النَّاسِ * إِلَهِ النَّاسِ * مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ * الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ * مِنَ الْجِنَّةِ وَالنَّاسِ',
      count: 3,
      category: AdhkarCategory.morning,
      transliteration: 'المعوذات',
      fadl: 'تكفيك من كل شيء',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 103,
      arabic:
          'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذَا الْيَوْمِ وَخَيْرَ مَا بَعْدَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذَا الْيَوْمِ وَشَرِّ مَا بَعْدَهُ، رَبِّ أَعُوذُ بِكَ مِنَ الْكَسَلِ وَسُوءِ الْكِبَرِ، رَبِّ أَعُوذُ بِكَ مِنْ عَذَابٍ فِي النَّارِ وَعَذَابٍ فِي الْقَبْرِ',
      count: 1,
      category: AdhkarCategory.morning,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 104,
      arabic:
          'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
      count: 1,
      category: AdhkarCategory.morning,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 105,
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      count: 1,
      category: AdhkarCategory.morning,
      transliteration: 'سيد الاستغفار',
      fadl: 'من قالها موقناً بها فمات من يومه دخل الجنة',
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 106,
      arabic:
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي دِينِي وَدُنْيَايَ وَأَهْلِي وَمَالِي، اللَّهُمَّ اسْتُرْ عَوْرَاتِي وَآمِنْ رَوْعَاتِي، اللَّهُمَّ احْفَظْنِي مِنْ بَيْنِ يَدَيَّ، وَمِنْ خَلْفِي، وَعَنْ يَمِينِي، وَعَنْ شِمَالِي، وَمِنْ فَوْقِي، وَأَعُوذُ بِعَظَمَتِكَ أَنْ أُغْتَالَ مِنْ تَحْتِي',
      count: 1,
      category: AdhkarCategory.morning,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 107,
      arabic:
          'اللَّهُمَّ عَافِنِي فِي بَدَنِي، اللَّهُمَّ عَافِنِي فِي سَمْعِي، اللَّهُمَّ عَافِنِي فِي بَصَرِي، لَا إِلَٰهَ إِلَّا أَنْتَ. اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْكُفْرِ، وَالْفَقْرِ، وَأَعُوذُ بِكَ مِنْ عَذَابِ الْقَبْرِ، لَا إِلَٰهَ إِلَّا أَنْتَ',
      count: 3,
      category: AdhkarCategory.morning,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 108,
      arabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      count: 3,
      category: AdhkarCategory.morning,
      fadl: 'لم يضره شيء',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 109,
      arabic:
          'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
      count: 3,
      category: AdhkarCategory.morning,
      fadl: 'كان حقاً على الله أن يرضيه يوم القيامة',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 110,
      arabic:
          'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ، وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ',
      count: 1,
      category: AdhkarCategory.morning,
      source: 'النسائي في الكبرى',
    ),
    DhikrItem(
      id: 111,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      count: 100,
      category: AdhkarCategory.morning,
      fadl: 'من قالها مئة مرة حُطَّت خطاياه وإن كانت مثل زبد البحر',
      source: 'متفق عليه',
    ),
  ],

  // ────────────── المساء ──────────────
  AdhkarCategory.evening: [
    DhikrItem(
      id: 201,
      arabic:
          'أَعُوذُ بِاللَّهِ مِنَ الشَّيطانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ...',
      count: 1,
      category: AdhkarCategory.evening,
      transliteration: 'آية الكرسي',
      fadl: 'من قرأها حين يمسي أُجير من الجن حتى يصبح',
      source: 'صحيح الترغيب',
    ),
    DhikrItem(
      id: 202,
      arabic:
          'المعوذات (الإخلاص، الفلق، الناس)', // اختصاراً هنا، يُفضل وضع النص كاملاً كما في الصباح
      count: 3,
      category: AdhkarCategory.evening,
      fadl: 'تكفيك من كل شيء',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 203,
      arabic:
          'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، رَبِّ أَسْأَلُكَ خَيْرَ مَا فِي هَذِهِ اللَّيْلَةِ وَخَيْرَ مَا بَعْدَهَا، وَأَعُوذُ بِكَ مِنْ شَرِّ مَا فِي هَذِهِ اللَّيْلَةِ وَشَرِّ مَا بَعْدَهَا...',
      count: 1,
      category: AdhkarCategory.evening,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 204,
      arabic:
          'اللَّهُمَّ بِكَ أَمْسَيْنَا، وَبِكَ أَصْبَحْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ الْمَصِيرُ',
      count: 1,
      category: AdhkarCategory.evening,
      source: 'الترمذي',
    ),
    DhikrItem(
      id: 205,
      arabic:
          'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَٰهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      count: 1,
      category: AdhkarCategory.evening,
      transliteration: 'سيد الاستغفار',
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 206,
      arabic:
          'اللَّهُمَّ إِنِّي أَمْسَيْتُ أُشْهِدُكَ، وَأُشْهِدُ حَمَلَةَ عَرْشِكَ، وَمَلَائِكَتَكَ، وَجَمِيعَ خَلْقِكَ، أَنَّكَ أَنْتَ اللَّهُ لَا إِلَٰهَ إِلَّا أَنْتَ وَحْدَكَ لَا شَرِيكَ لَكَ، وَأَنَّ مُحَمَّدًا عَبْدُكَ وَرَسُولُكَ',
      count: 4,
      category: AdhkarCategory.evening,
      fadl: 'أعتقه الله من النار',
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 207,
      arabic:
          'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      count: 3,
      category: AdhkarCategory.evening,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 208,
      arabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      count: 3,
      category: AdhkarCategory.evening,
      fadl: 'لم يضره شيء في تلك الليلة',
      source: 'صحيح مسلم',
    ),
  ],

  // ────────────── بعد الصلاة ──────────────
  AdhkarCategory.afterPrayer: [
    DhikrItem(
      id: 301,
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      count: 3,
      category: AdhkarCategory.afterPrayer,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 302,
      arabic:
          'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 303,
      arabic:
          'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ، اللَّهُمَّ لَا مَانِعَ لِمَا أَعْطَيْتَ، وَلَا مُعْطِيَ لِمَا مَنَعْتَ، وَلَا يَنْفَعُ ذَا الْجَدِّ مِنْكَ الْجَدُّ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 304,
      arabic:
          'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ، وَشُكْرِكَ، وَحُسْنِ عِبَادَتِكَ',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 305,
      arabic:
          'سُبْحَانَ اللَّهِ (33) ، الْحَمْدُ لِلَّهِ (33) ، اللَّهُ أَكْبَرُ (33)\nلَا إِلَٰهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ (1)',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      fadl: 'غُفرت ذنوبه وإن كانت مثل زبد البحر',
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 306,
      arabic: 'قراءة آية الكرسي',
      count: 1,
      category: AdhkarCategory.afterPrayer,
      fadl: 'لم يمنعه من دخول الجنة إلا الموت',
      source: 'صحيح الجامع',
    ),
    DhikrItem(
      id: 307,
      arabic: 'قراءة المعوذات (الإخلاص، الفلق، الناس)',
      count: 1, // مرة واحدة دبر كل صلاة، و 3 مرات بعد الفجر والمغرب
      category: AdhkarCategory.afterPrayer,
      source: 'سنن أبي داود',
    ),
  ],

  // ────────────── النوم ──────────────
  AdhkarCategory.sleep: [
    DhikrItem(
      id: 401,
      arabic:
          'بِاسْمِكَ رَبِّي وَضَعْتُ جَنْبِي، وَبِكَ أَرْفَعُهُ، فَإِنْ أَمْسَكْتَ نَفْسِي فَارْحَمْهَا، وَإِنْ أَرْسَلْتَهَا فَاحْفَظْهَا بِمَا تَحْفَظُ بِهِ عِبَادَكَ الصَّالِحِينَ',
      count: 1,
      category: AdhkarCategory.sleep,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 402,
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      count: 1,
      category: AdhkarCategory.sleep,
      source: 'صحيح البخاري',
    ),
    DhikrItem(
      id: 403,
      arabic:
          'آمَنَ الرَّسُولُ بِمَا أُنزِلَ إِلَيْهِ مِن رَّبِّهِ وَالْمُؤْمِنُونَ ۚ ... (الآيتان من آخر سورة البقرة)',
      count: 1,
      category: AdhkarCategory.sleep,
      fadl: 'من قرأهما في ليلة كفتاه',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 404,
      arabic: 'اللَّهُمَّ قِنِي عَذَابَكَ يَوْمَ تَبْعَثُ عِبَادَكَ',
      count: 3,
      category: AdhkarCategory.sleep,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 405,
      arabic:
          'سُبْحَانَ اللَّهِ (33) ، الْحَمْدُ لِلَّهِ (33) ، اللَّهُ أَكْبَرُ (34)',
      count: 1,
      category: AdhkarCategory.sleep,
      fadl: 'خير لكما من خادم',
      source: 'متفق عليه',
    ),
  ],

  // ────────────── الطعام ──────────────
  AdhkarCategory.food: [
    DhikrItem(
      id: 501,
      arabic:
          'بِسْمِ اللَّهِ (في أوله) .. فإن نسي: بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ',
      count: 1,
      category: AdhkarCategory.food,
      source: 'سنن أبي داود',
    ),
    DhikrItem(
      id: 502,
      arabic:
          'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا، وَرَزَقَنِيهِ، مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
      count: 1,
      category: AdhkarCategory.food,
      fadl: 'غُفر له ما تقدم من ذنبه',
      source: 'سنن أبي داود',
    ),
  ],

  // ────────────── متنوعة ──────────────
  AdhkarCategory.misc: [
    DhikrItem(
      id: 601,
      arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ',
      count: 100,
      category: AdhkarCategory.misc,
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 602,
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
      count: 1,
      category: AdhkarCategory.misc,
      fadl: 'كلمتان خفيفتان على اللسان، ثقيلتان في الميزان، حبيبتان إلى الرحمن',
      source: 'متفق عليه',
    ),
    DhikrItem(
      id: 603,
      arabic: 'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
      count: 10,
      category: AdhkarCategory.misc,
      fadl: 'من صلى علي مرة واحدة صلى الله عليه بها عشراً',
      source: 'صحيح مسلم',
    ),
    DhikrItem(
      id: 604,
      arabic:
          'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ عَلَيْهِ تَوَكَّلْتُ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ',
      count: 7,
      category: AdhkarCategory.misc,
      fadl: 'كفاه الله ما أهمه من أمر الدنيا والآخرة',
      source: 'ابن السني',
    ),
    DhikrItem(
      id: 605,
      arabic: 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
      count: 100,
      category: AdhkarCategory.misc,
      fadl: 'كنز من كنوز الجنة',
      source: 'متفق عليه',
    ),
  ],
};

// ═══════════════════════════════════════════════════════════════
//  PROVIDERS
// ═══════════════════════════════════════════════════════════════

// ── حالة تقدم كل تصنيف (index → count) ──
class AdhkarProgressNotifier extends StateNotifier<Map<int, int>> {
  final AdhkarCategory category;

  AdhkarProgressNotifier(this.category) : super({}) {
    _load();
  }

  static const _prefix = 'adhkar_progress_';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${category.name}';
    final raw = prefs.getString(key);
    if (raw != null) {
      final map = Map<String, dynamic>.from(jsonDecode(raw));
      state = map.map((k, v) => MapEntry(int.parse(k), v as int));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${category.name}';
    final encoded = jsonEncode(state.map((k, v) => MapEntry(k.toString(), v)));
    await prefs.setString(key, encoded);
  }

  void increment(int index, int maxCount) {
    final current = state[index] ?? 0;
    if (current >= maxCount) return;
    state = {...state, index: current + 1};
    _save();
  }

  void reset() {
    state = {};
    _save();
  }
}

final adhkarProgressProvider =
    StateNotifierProvider.family<
      AdhkarProgressNotifier,
      Map<int, int>,
      AdhkarCategory
    >((ref, cat) => AdhkarProgressNotifier(cat));

// ── إعداد الإشعارات ──
final adhkarNotifEnabledProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_notif_enabled', true),
);

final adhkarMorningTimeProvider =
    StateNotifierProvider<_TimeNotifier, TimeOfDay>(
      (ref) => _TimeNotifier(
        'adhkar_morning_time',
        const TimeOfDay(hour: 6, minute: 30),
      ),
    );

final adhkarEveningTimeProvider =
    StateNotifierProvider<_TimeNotifier, TimeOfDay>(
      (ref) => _TimeNotifier(
        'adhkar_evening_time',
        const TimeOfDay(hour: 17, minute: 0),
      ),
    );

final adhkarAfterFajrProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_after_fajr', true),
);

final adhkarAfterAsrProvider = StateNotifierProvider<_BoolNotifier, bool>(
  (ref) => _BoolNotifier('adhkar_after_asr', true),
);

final adhkarSleepTimeProvider = StateNotifierProvider<_TimeNotifier, TimeOfDay>(
  (ref) =>
      _TimeNotifier('adhkar_sleep_time', const TimeOfDay(hour: 22, minute: 0)),
);

// ── Notifiers helpers ──
class _BoolNotifier extends StateNotifier<bool> {
  final String _key;
  _BoolNotifier(this._key, bool defaultVal) : super(defaultVal) {
    _load(defaultVal);
  }

  Future<void> _load(bool def) async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_key) ?? def;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, state);
  }

  Future<void> set(bool v) async {
    state = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, v);
  }
}

class _TimeNotifier extends StateNotifier<TimeOfDay> {
  final String _key;
  _TimeNotifier(this._key, TimeOfDay defaultVal) : super(defaultVal) {
    _load(defaultVal);
  }

  Future<void> _load(TimeOfDay def) async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString(_key);
    if (v != null) {
      final parts = v.split(':');
      state = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> set(TimeOfDay t) async {
    state = t;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      '${t.hour.toString().padLeft(2, "0")}:${t.minute.toString().padLeft(2, "0")}',
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  ADHKAR NOTIFICATION SERVICE
// ═══════════════════════════════════════════════════════════════
class AdhkarNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _morningId = 310;
  static const _eveningId = 311;
  static const _afterFajrId = 312;
  static const _afterAsrId = 313;
  static const _sleepId = 314;
  static const _dhikrId = 315;

  static Future<void> scheduleMorning(TimeOfDay time) async {
    await _cancelId(_morningId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(AdhkarCategory.morning);

    await _plugin.zonedSchedule(
      _morningId,
      '🌅 حان وقت أذكار الصباح',
      dhikr.arabic
          .replaceAll('\n', ' ')
          .substring(0, dhikr.arabic.length > 80 ? 80 : dhikr.arabic.length),
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_morning',
        channelName: 'أذكار الصباح',
        actions: [
          const AndroidNotificationAction(
            'read_morning',
            'قرأت الأذكار ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'open_morning',
            'فتح الأذكار',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'adhkar:morning',
    );
  }

  static Future<void> scheduleEvening(TimeOfDay time) async {
    await _cancelId(_eveningId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(AdhkarCategory.evening);

    await _plugin.zonedSchedule(
      _eveningId,
      '🌆 حان وقت أذكار المساء',
      dhikr.arabic
          .replaceAll('\n', ' ')
          .substring(0, dhikr.arabic.length > 80 ? 80 : dhikr.arabic.length),
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_evening',
        channelName: 'أذكار المساء',
        actions: [
          const AndroidNotificationAction(
            'read_evening',
            'قرأت الأذكار ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'open_evening',
            'فتح الأذكار',
            showsUserInterface: true,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'adhkar:evening',
    );
  }

  static Future<void> scheduleDailyDhikr({
    required TimeOfDay time,
    AdhkarCategory category = AdhkarCategory.misc,
  }) async {
    await _cancelId(_dhikrId);

    final now = DateTime.now();
    var scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    final dhikr = _randomDhikr(category);
    final arabic = dhikr.arabic.replaceAll('\n', ' ');
    final preview = arabic.length > 100
        ? '${arabic.substring(0, 100)}...'
        : arabic;

    await _plugin.zonedSchedule(
      _dhikrId,
      '📿 ذكر اليوم',
      preview,
      tz.TZDateTime.from(scheduled, tz.local),
      _buildDetails(
        channelId: 'adhkar_daily',
        channelName: 'ذكر اليوم',
        bigText: arabic + (dhikr.fadl != null ? '\n\n✨ ${dhikr.fadl}' : ''),
        actions: [
          AndroidNotificationAction(
            'read_dhikr_${dhikr.id}',
            'قرأت الذكر ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          const AndroidNotificationAction(
            'share_dhikr',
            'مشاركة',
            showsUserInterface: false,
            cancelNotification: false,
          ),
        ],
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'dhikr:${dhikr.id}',
    );
  }

  static Future<void> showDhikrNow(DhikrItem dhikr) async {
    final arabic = dhikr.arabic.replaceAll('\n', ' ');

    await _plugin.show(
      _dhikrId + dhikr.id,
      '📿 ${_categoryName(dhikr.category)}',
      arabic.length > 80 ? '${arabic.substring(0, 80)}...' : arabic,
      _buildDetails(
        channelId: 'adhkar_instant',
        channelName: 'أذكار فورية',
        bigText:
            arabic +
            (dhikr.fadl != null ? '\n\n✨ الفضل: ${dhikr.fadl}' : '') +
            (dhikr.source != null ? '\n— ${dhikr.source}' : ''),
        actions: [
          AndroidNotificationAction(
            'read_done_${dhikr.id}',
            'قرأت الذكر ✓',
            showsUserInterface: false,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'repeat_${dhikr.id}',
            'أعد لاحقاً 🔁',
            showsUserInterface: false,
            cancelNotification: false,
          ),
        ],
      ),
      payload: 'instant_dhikr:${dhikr.id}',
    );
  }

  static Future<void> cancelAll() async {
    for (final id in [
      _morningId,
      _eveningId,
      _afterFajrId,
      _afterAsrId,
      _sleepId,
      _dhikrId,
    ]) {
      await _plugin.cancel(id);
    }
  }

  static Future<void> _cancelId(int id) => _plugin.cancel(id);

  static NotificationDetails _buildDetails({
    required String channelId,
    required String channelName,
    String? bigText,
    List<AndroidNotificationAction>? actions,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'أذكار وأدعية من حصن المسلم',
        importance: Importance.high,
        priority: Priority.high,
        color: const Color(0xFFC8A96E),
        styleInformation: bigText != null
            ? BigTextStyleInformation(
                bigText,
                contentTitle: channelName,
                htmlFormatBigText: false,
              )
            : null,
        actions: actions,
        groupKey: 'adhkar_group',
        playSound: false,
        enableVibration: false,
      ),
      iOS: const DarwinNotificationDetails(
        categoryIdentifier: 'adhkar_category',
        presentAlert: true,
        presentBadge: false,
        presentSound: false,
        interruptionLevel: InterruptionLevel.passive,
      ),
    );
  }

  static DhikrItem _randomDhikr(AdhkarCategory cat) {
    final list = kAdhkarData[cat] ?? kAdhkarData[AdhkarCategory.misc]!;
    final rng = math.Random(DateTime.now().dayOfYear);
    return list[rng.nextInt(list.length)];
  }

  // تم تحديث الدالة لتدعم التصنيفات الجديدة ✅
  static String _categoryName(AdhkarCategory cat) => switch (cat) {
    AdhkarCategory.wakingUp => 'أذكار الاستيقاظ',
    AdhkarCategory.morning => 'أذكار الصباح',
    AdhkarCategory.evening => 'أذكار المساء',
    AdhkarCategory.afterPrayer => 'أذكار بعد الصلاة',
    AdhkarCategory.sleep => 'أذكار النوم',
    AdhkarCategory.food => 'أذكار الطعام',
    AdhkarCategory.misc => 'أذكار متنوعة',
  };
}

extension on DateTime {
  int get dayOfYear {
    final start = DateTime(year, 1, 1);
    return difference(start).inDays + 1;
  }
}
