// ═══════════════════════════════════════════════════════════════
//  lib/main_shell.dart — Shell with BottomNavigationBar
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:muhasabah/core/theme/app_theme.dart';
import 'package:muhasabah/features/home/home_screen.dart';
import 'package:muhasabah/features/checklist/checklist_screen.dart';
import 'package:muhasabah/features/statistics/statistics_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageCtrl;

  final _screens = const [
    HomeScreen(),
    ChecklistScreen(),
    StatisticsScreen(),
  ];

  final _navItems = const [
    _NavItem('الرئيسية', '🏠', 'home'),
    _NavItem('تفاصيل اليوم', '📋', 'checklist'),
    _NavItem('إحصائيات', '📊', 'stats'),
  ];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onTabTap(int i) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = i);
    _pageCtrl.animateToPage(
      i,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.night,
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _BottomNav(
        items: _navItems,
        currentIndex: _currentIndex,
        onTap: _onTabTap,
      ),
    );
  }
}

// ─── Bottom Nav ───────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final List<_NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border:
            const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (i) => _NavChip(
                item: items[i],
                isActive: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavChip extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavChip({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0x22C8A96E), Color(0x113AAFA9)],
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: isActive
              ? Border.all(color: AppColors.gold.withOpacity(0.3))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isActive ? 22 : 20,
              ),
              child: Text(item.emoji),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: GoogleFonts.notoNaskhArabic(
                fontSize: 10,
                color: isActive ? AppColors.gold : AppColors.textDim,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final String emoji;
  final String key;
  const _NavItem(this.label, this.emoji, this.key);
}
