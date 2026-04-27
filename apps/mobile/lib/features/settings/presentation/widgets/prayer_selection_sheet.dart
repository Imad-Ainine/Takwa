import 'package:flutter/material.dart';
import 'package:takwa/core/theme/app_theme.dart';

class PrayerSelectionSheet extends StatefulWidget {
  final String title;
  final List<String> selectedPrayers;
  final bool includeSunrise;
  final ValueChanged<List<String>> onChanged;

  const PrayerSelectionSheet({
    super.key,
    required this.title,
    required this.selectedPrayers,
    this.includeSunrise = false,
    required this.onChanged,
  });

  static void show({
    required BuildContext context,
    required String title,
    required List<String> selectedPrayers,
    bool includeSunrise = false,
    required ValueChanged<List<String>> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PrayerSelectionSheet(
        title: title,
        selectedPrayers: selectedPrayers,
        includeSunrise: includeSunrise,
        onChanged: onChanged,
      ),
    );
  }

  @override
  State<PrayerSelectionSheet> createState() => _PrayerSelectionSheetState();
}

class _PrayerSelectionSheetState extends State<PrayerSelectionSheet> {
  late List<String> _currentSelection;

  final Map<String, String> _prayerNames = {
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'jumuah': 'الجمعة',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  @override
  void initState() {
    super.initState();
    _currentSelection = List.from(widget.selectedPrayers);
  }

  void _togglePrayer(String key) {
    setState(() {
      if (_currentSelection.contains(key)) {
        _currentSelection.remove(key);
      } else {
        _currentSelection.add(key);
      }
    });
    widget.onChanged(_currentSelection);
  }

  @override
  Widget build(BuildContext context) {
    final prayers = [
      'fajr',
      if (widget.includeSunrise) 'sunrise',
      'dhuhr',
      'jumuah',
      'asr',
      'maghrib',
      'isha',
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: context.colors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              Text(
                widget.title,
                style: context.typography.headingMedium.copyWith(
                  fontSize: 18,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(width: 48), // Spacer for centering
            ],
          ),
          const SizedBox(height: 20),
          ...prayers.map((key) {
            final isSelected = _currentSelection.contains(key);
            final name = _prayerNames[key] ?? key;
            return InkWell(
              onTap: () => _togglePrayer(key),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _togglePrayer(key),
                      activeColor: context.colors.gold,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Text(
                      key == 'sunrise' ? 'تنبيهات الشروق' : 'أذان $name',
                      style: context.typography.bodyLarge.copyWith(
                        fontFamily: 'NotoNaskhArabic',
                        color: context.colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
