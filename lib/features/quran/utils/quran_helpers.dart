// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/utils/quran_helpers.dart
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

Color surahColor(int n) {
  const colors = [
    Color(0xFFC8A96E), Color(0xFF3AAFA9), Color(0xFF4CAF7D),
    Color(0xFF9B59B6), Color(0xFFE67E22), Color(0xFF2980B9),
    Color(0xFFE74C3C), Color(0xFF16A085), Color(0xFFD35400),
  ];
  return colors[n % colors.length];
}

const juzStarts = [
  (1, 1), (2, 142), (2, 253), (3, 93), (4, 24), (4, 148), (5, 83), (6, 111),
  (7, 88), (8, 41), (9, 93), (11, 6), (12, 53), (15, 1), (17, 1), (18, 75),
  (21, 1), (23, 1), (25, 21), (27, 56), (29, 45), (33, 31), (36, 28), (39, 32),
  (41, 47), (46, 1), (51, 31), (58, 1), (67, 1), (78, 1)
];

String ar(int n) {
  const d = ['٠','١','٢','٣','٤','٥','٦','٧','٨','٩'];
  return n.toString().split('').map((c) => d[int.parse(c)]).join();
}

const arWords = [
  'الأول','الثاني','الثالث','الرابع','الخامس','السادس','السابع','الثامن',
  'التاسع','العاشر','الحادي عشر','الثاني عشر','الثالث عشر','الرابع عشر',
  'الخامس عشر','السادس عشر','السابع عشر','الثامن عشر','التاسع عشر','العشرون',
  'الحادي والعشرون','الثاني والعشرون','الثالث والعشرون','الرابع والعشرون',
  'الخامس والعشرون','السادس والعشرون','السابع والعشرون','الثامن والعشرون',
  'التاسع والعشرون','الثلاثون',
];

String arWord(int n) => n >= 1 && n <= 30 ? arWords[n - 1] : ar(n);

Route slideRoute(Widget w) => PageRouteBuilder(
  pageBuilder: (_, a, _) => w,
  transitionsBuilder: (_, a, _, child) => SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 0.04), end: Offset.zero,
    ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: a, child: child),
  ),
  transitionDuration: const Duration(milliseconds: 380),
);

// Colors
const kGold   = Color(0xFFC8A96E);
const kGoldL  = Color(0xFFE4C98A);
const kGoldD  = Color(0xFF9A7040);
const kTeal   = Color(0xFF3AAFA9);
const kNight  = Color(0xFF0D1117);
const kCard   = Color(0xFF1A2332);
const kBorder = Color(0xFF2A3A50);
const kText   = Color(0xFFE8EDF3);
const kTextS  = Color(0xFF8FA3BB);
