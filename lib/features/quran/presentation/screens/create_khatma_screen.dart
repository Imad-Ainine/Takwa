// ═══════════════════════════════════════════════════════════════
//  lib/features/quran/presentation/screens/create_khatma_screen.dart
//  3-step Khatma creation wizard
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

const _kBg = Color(0xFF08121E);
const _kCard = Color(0xFF0F1E2D);
const _kGreen = Color(0xFF1A5234);
const _kGold = Color(0xFFC8A96E);
const _kBorder = Color(0xFF1E3040);

class CreateKhatmaScreen extends ConsumerStatefulWidget {
  const CreateKhatmaScreen({super.key});
  @override
  ConsumerState<CreateKhatmaScreen> createState() => _CreateKhatmaScreenState();
}

class _CreateKhatmaScreenState extends ConsumerState<CreateKhatmaScreen> {
  int _step = 0; // 0, 1, 2

  // Step 0 state
  final _nameCtrl = TextEditingController();
  KhatmaType _type = KhatmaType.muyassara;

  // Step 1 state
  DateTime _startDate = DateTime.now();
  int _startPage = 1;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    // Default name
    final now = DateTime.now();
    final hijri = hijriDateString().split(' ');
    _nameCtrl.text =
        'ختمة ${hijri.length > 2 ? hijri[2] : ''} ${hijri.length > 3 ? hijri[3] : ''}';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _step == 0
                      ? _buildStep0()
                      : _step == 1
                      ? _buildStep1()
                      : _buildStep2(),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          CustomLeadingButton(),
          Spacer(),
          Text(
            'إنشاء ختمة جديدة',
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Spacer(),
          SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Row(
        children: [
          _stepDot(0),
          Expanded(child: _stepLine(0)),
          _stepDot(1),
          Expanded(child: _stepLine(1)),
          _stepDot(2),
        ],
      ),
    );
  }

  Widget _stepDot(int s) {
    final active = s == _step;
    final done = s < _step;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? _kGreen
            : done
            ? _kGreen.withOpacity(0.7)
            : _kCard,
        border: Border.all(
          color: active || done ? _kGreen : _kBorder,
          width: active ? 2 : 1,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${s + 1}',
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 13,
                  color: active || done ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _stepLine(int s) => Container(
    height: 2,
    color: s < _step ? _kGreen.withOpacity(0.6) : _kBorder,
  );

  // ──────────────────── STEP 0: Name & Type ────────────────────
  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        // edit name
                      },
                      child: const Icon(
                        Icons.edit_rounded,
                        color: _kGold,
                        size: 18,
                      ),
                    ),
                    const Text(
                      'اسم الختمة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameCtrl,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 15,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: _kBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _kGreen),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'نوع الختمة',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.account_tree_rounded, color: _kGold, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اختر نوع الختمة التي تريد إنشاءها',
                    style: TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 12,
                      color: Colors.white38,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _typeOption(
                  KhatmaType.muyassara,
                  'ختمة ميسرة',
                  'قراءة القرآن كاملاً بالترتيب بدون ورد يومي محدد أو وقت ختم محدد',
                ),
                const SizedBox(height: 10),
                _typeOption(
                  KhatmaType.multazima,
                  'ختمة ملتزمة',
                  'ختمة مع ورد يومي محدد ووقت ختم محدد',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeOption(KhatmaType type, String title, String desc) {
    final selected = _type == type;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _type = type);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Radio<KhatmaType>(
            value: type,
            groupValue: _type,
            activeColor: _kGreen,
            onChanged: (v) {
              if (v != null) setState(() => _type = v);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : Colors.white60,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontFamily: 'NotoNaskhArabic',
                    fontSize: 12,
                    color: Colors.white38,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── STEP 1: Settings ────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Start Date
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'تاريخ البداية',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.calendar_month_rounded, color: _kGold, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          color: _kGold,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontFamily: 'NotoNaskhArabic',
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Start Page
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'صفحة البداية',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.auto_stories_rounded, color: _kGold, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _startPage,
                      isExpanded: true,
                      dropdownColor: _kCard,
                      style: const TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white38,
                      ),
                      items: List.generate(
                        604,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('صفحة ${ar(i + 1)}'),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) setState(() => _startPage = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Notifications
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Switch(
                      value: _notificationsEnabled,
                      activeColor: _kGreen,
                      activeTrackColor: _kGreen.withOpacity(0.3),
                      inactiveTrackColor: _kBorder,
                      inactiveThumbColor: Colors.white38,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    const Spacer(),
                    const Row(
                      children: [
                        Text(
                          'تفعيل الإشعارات',
                          style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.notifications_rounded,
                          color: _kGold,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_notificationsEnabled) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A3500),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF7A5800)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'الإشعارات معطلة - لن يتم إرسال أي تذكرات',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontFamily: 'NotoNaskhArabic',
                              fontSize: 12,
                              color: Color(0xFFE8A030),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFE8A030),
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: _kGreen,
            surface: _kCard,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  // ──────────────────── STEP 2: Summary ────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _kGold.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: _kGold,
                    size: 16,
                  ),
                ),
                const Text(
                  'ملخص الختمة الميسرة',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Type pill
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A0D3A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4A1A7A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _type == KhatmaType.muyassara
                            ? 'ختمة ميسرة'
                            : 'ختمة ملتزمة',
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 15,
                          color: Color(0xFFB060E8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.account_tree_rounded,
                        color: Color(0xFFB060E8),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'نوع الختمة:',
                        style: TextStyle(
                          fontFamily: 'NotoNaskhArabic',
                          fontSize: 12,
                          color: Color(0xFFB060E8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _type == KhatmaType.muyassara
                        ? 'قراءة القرآن كاملاً بالترتيب بدون ورد يومي محدد أو وقت ختم محدد'
                        : 'ختمة مع ورد يومي محدد ووقت ختم محدد',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'NotoNaskhArabic',
                      fontSize: 11,
                      color: Color(0xFF9040C0),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow('اسم الختمة:', _nameCtrl.text),
            _summaryRow(
              'تاريخ البداية:',
              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
            ),
            _summaryRow('الصفحة الأولى:', 'صفحة ${ar(_startPage)}'),
            _summaryRow(
              'الإشعارات:',
              _notificationsEnabled ? 'مفعّلة' : 'معطلة',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kGreen.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'يمكنك البدء في القراءة فوراً بعد إنشاء الختمة',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: 'NotoNaskhArabic',
                        fontSize: 12,
                        color: Color(0xFF6ECC9A),
                      ),
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF6ECC9A),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'NotoNaskhArabic',
              fontSize: 13,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────── Bottom Bar ────────────────────
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: const BoxDecoration(
        color: _kBg,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _step--),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: _kBorder),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'السابق',
                      style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_step > 0) const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _onNextTap,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _kGreen,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: _kGreen.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _step == 2 ? 'إنشاء الختمة' : 'التالي',
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNextTap() {
    if (_step < 2) {
      setState(() => _step++);
    } else {
      _createKhatma();
    }
  }

  Future<void> _createKhatma() async {
    await ref
        .read(khatmaExProvider.notifier)
        .createNew(
          label: _nameCtrl.text.trim().isEmpty
              ? 'ختمة جديدة'
              : _nameCtrl.text.trim(),
          type: _type,
          startPage: _startPage,
          notificationsEnabled: _notificationsEnabled,
        );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تم إنشاء الختمة بنجاح',
            style: TextStyle(fontFamily: 'NotoNaskhArabic'),
          ),
          backgroundColor: _kGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _kBorder),
    ),
    child: child,
  );
}
