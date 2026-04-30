
import 'package:flutter/material.dart';

// ─── Color Palette ────────────────────────────────────────────
const kGold = Color(0xFFC8A96E);
const kGoldL = Color(0xFFE4C98A);
const kGoldD = Color(0xFF9A7040);
const kTeal = Color(0xFF3AAFA9);
const kNight = Color(0xFF0D1117);
const kCard = Color(0xFF1A2332);
const kBorder = Color(0xFF2A3A50);
const kText = Color(0xFFE8EDF3);
const kTextS = Color(0xFF8FA3BB);

// Khatma Green Palette
const kGreen = Color(0xFF1A5C3A); // main green
const kGreenDark = Color(0xFF0D3D24); // darker bg
const kGreenMid = Color(0xFF2A7A4E); // lighter card
const kGreenCard = Color(0xFF1E6B43); // action card
const kGoldChip = Color(0xFFD4A843); // chip badge
const kOlive = Color(0xFF7A6833); // history icon bg

// ─── Surah Colors ─────────────────────────────────────────────
Color surahColor(int n) {
  const colors = [
    Color(0xFFC8A96E),
    Color(0xFF3AAFA9),
    Color(0xFF4CAF7D),
    Color(0xFF9B59B6),
    Color(0xFFE67E22),
    Color(0xFF2980B9),
    Color(0xFFE74C3C),
    Color(0xFF16A085),
    Color(0xFFD35400),
  ];
  return colors[n % colors.length];
}

// ─── Quran Page → Juz Lookup ──────────────────────────────────
// Approximate Juz boundaries (page numbers, 1-indexed, Medina mushaf)
const _juzPageStarts = [
  1,
  22,
  42,
  62,
  82,
  102,
  121,
  142,
  162,
  182,
  201,
  222,
  242,
  262,
  282,
  302,
  322,
  342,
  362,
  382,
  402,
  422,
  442,
  462,
  482,
  502,
  522,
  542,
  562,
  582,
];

int pageToJuz(int page) {
  for (int i = _juzPageStarts.length - 1; i >= 0; i--) {
    if (page >= _juzPageStarts[i]) return i + 1;
  }
  return 1;
}

// ─── Juz Start (Surah, Ayah) ──────────────────────────────────
const juzStarts = [
  (1, 1),
  (2, 142),
  (2, 253),
  (3, 93),
  (4, 24),
  (4, 148),
  (5, 83),
  (6, 111),
  (7, 88),
  (8, 41),
  (9, 93),
  (11, 6),
  (12, 53),
  (15, 1),
  (17, 1),
  (18, 75),
  (21, 1),
  (23, 1),
  (25, 21),
  (27, 56),
  (29, 45),
  (33, 31),
  (36, 28),
  (39, 32),
  (41, 47),
  (46, 1),
  (51, 31),
  (58, 1),
  (67, 1),
  (78, 1),
];

// ─── Arabic Numerals ──────────────────────────────────────────
String ar(int n) {
  const d = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

const arWords = [
  'الأول',
  'الثاني',
  'الثالث',
  'الرابع',
  'الخامس',
  'السادس',
  'السابع',
  'الثامن',
  'التاسع',
  'العاشر',
  'الحادي عشر',
  'الثاني عشر',
  'الثالث عشر',
  'الرابع عشر',
  'الخامس عشر',
  'السادس عشر',
  'السابع عشر',
  'الثامن عشر',
  'التاسع عشر',
  'العشرون',
  'الحادي والعشرون',
  'الثاني والعشرون',
  'الثالث والعشرون',
  'الرابع والعشرون',
  'الخامس والعشرون',
  'السادس والعشرون',
  'السابع والعشرون',
  'الثامن والعشرون',
  'التاسع والعشرون',
  'الثلاثون',
];

String arWord(int n) => n >= 1 && n <= 30 ? arWords[n - 1] : ar(n);

// ─── Hijri Date Helper ────────────────────────────────────────
/// Simple Gregorian → Hijri approximation (±1 day accuracy)
String hijriDateString() {
  final now = DateTime.now();
  // Approximate Hijri using epoch offset
  // Base: 1 Muharram 1444 H = July 30, 2022 G
  final base = DateTime(2022, 7, 30);
  final diff = now.difference(base).inDays;
  int hijriDay = diff % 354;
  int hijriYear = 1444 + (diff ~/ 354);

  const months = [
    (30, 'محرم'),
    (29, 'صفر'),
    (30, 'ربيع الأول'),
    (29, 'ربيع الثاني'),
    (30, 'جمادى الأولى'),
    (29, 'جمادى الثانية'),
    (30, 'رجب'),
    (29, 'شعبان'),
    (30, 'رمضان'),
    (29, 'شوال'),
    (30, 'ذو القعدة'),
    (30, 'ذو الحجة'),
  ];

  int d = hijriDay;
  String monthName = 'محرم';
  int dayNum = 1;
  for (final (days, name) in months) {
    if (d < days) {
      monthName = name;
      dayNum = d + 1;
      break;
    }
    d -= days;
  }

  const weekdays = [
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];
  final weekday = weekdays[now.weekday - 1];
  return '$weekday ${ar(dayNum)} $monthName ${ar(hijriYear)}';
}

// ─── Page Routes ──────────────────────────────────────────────
Route slideRoute(Widget w) => PageRouteBuilder(
  pageBuilder: (_, a, _) => w,
  transitionsBuilder: (_, a, _, child) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: a, child: child),
  ),
  transitionDuration: const Duration(milliseconds: 380),
);

Route fadeRoute(Widget w) => PageRouteBuilder(
  pageBuilder: (_, a, _) => w,
  transitionsBuilder: (_, a, _, child) =>
      FadeTransition(opacity: a, child: child),
  transitionDuration: const Duration(milliseconds: 300),
);
