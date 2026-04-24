import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:takwa/core/widgets/custom_leading_button.dart';
import 'package:takwa/core/theme/ramadan_theme.dart';
import 'package:takwa/core/providers/database_providers.dart';
import '../../providers/quran_providers.dart';
import '../../utils/quran_helpers.dart';

// Styles are managed via AdaptiveStyle for consistent theming (including Ramadan mode).

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
    final isRamadan = ref.watch(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);
    final khatma = ref.watch(khatmaExProvider);

    return Scaffold(
      backgroundColor: style.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(style),
            _buildStepIndicator(style),
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
                      ? _buildStep0(style)
                      : _step == 1
                      ? _buildStep1(style)
                      : _buildStep2(style),
                ),
              ),
            ),
            _buildBottomBar(style),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          const CustomLeadingButton(),
          const Spacer(),
          Text(
            'إنشاء ختمة جديدة',
            style: style.amiri(22, color: style.text, weight: FontWeight.bold),
          ),
          const Spacer(),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 20, 40, 20),
      child: Row(
        children: [
          _stepDot(0, style),
          Expanded(child: _stepLine(0, style)),
          _stepDot(1, style),
          Expanded(child: _stepLine(1, style)),
          _stepDot(2, style),
        ],
      ),
    );
  }

  Widget _stepDot(int s, AdaptiveStyle style) {
    final active = s == _step;
    final done = s < _step;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? (style.isRamadan ? style.gold : style.teal)
            : done
            ? (style.isRamadan ? style.gold : style.teal).withOpacity(0.7)
            : style.card,
        border: Border.all(
          color: active || done
              ? (style.isRamadan ? style.gold : style.teal)
              : style.border,
          width: active ? 2 : 1,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, color: Colors.white, size: 16)
            : Text(
                '${s + 1}',
                style: style.amiri(
                  13,
                  color: active || done ? Colors.white : style.textDim,
                  weight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _stepLine(int s, AdaptiveStyle style) => Container(
    height: 2,
    color: s < _step
        ? (style.isRamadan ? style.gold : style.teal).withOpacity(0.6)
        : style.border,
  );

  // ──────────────────── STEP 0: Name & Type ────────────────────
  Widget _buildStep0(AdaptiveStyle style) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _card(
            style,
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
                      child: Icon(
                        Icons.edit_rounded,
                        color: style.gold,
                        size: 18,
                      ),
                    ),
                    Text(
                      'اسم الختمة',
                      style: style.amiri(
                        18,
                        color: style.text,
                        weight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _nameCtrl,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: style.naskh(15, color: style.text),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: style.bg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: style.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: style.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: style.isRamadan ? style.gold : style.teal,
                      ),
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
            style,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'نوع الختمة',
                      style: style.amiri(
                        18,
                        color: style.text,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.account_tree_rounded,
                      color: style.gold,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'اختر نوع الختمة التي تريد إنشاءها',
                    style: style.naskh(12, color: style.textDim),
                  ),
                ),
                const SizedBox(height: 16),
                _typeOption(
                  KhatmaType.muyassara,
                  'ختمة ميسرة',
                  'قراءة القرآن كاملاً بالترتيب بدون ورد يومي محدد أو وقت ختم محدد',
                  style,
                ),
                const SizedBox(height: 10),
                _typeOption(
                  KhatmaType.multazima,
                  'ختمة ملتزمة',
                  'ختمة مع ورد يومي محدد ووقت ختم محدد',
                  style,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeOption(
    KhatmaType type,
    String title,
    String desc,
    AdaptiveStyle style,
  ) {
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
            activeColor: style.isRamadan ? style.gold : style.teal,
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
                  style: style.amiri(
                    16,
                    color: selected ? style.text : style.textSec,
                    weight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: style.naskh(12, color: style.textDim),
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
  Widget _buildStep1(AdaptiveStyle style) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Start Date
          _card(
            style,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'تاريخ البداية',
                      style: style.amiri(
                        18,
                        color: style.text,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.calendar_month_rounded,
                      color: style.gold,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _pickDate(style),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: style.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: style.border),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: style.gold,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_startDate.year}-${_startDate.month.toString().padLeft(2, '0')}-${_startDate.day.toString().padLeft(2, '0')}',
                          style: style.naskh(15, color: style.text),
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
            style,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'صفحة البداية',
                      style: style.amiri(
                        18,
                        color: style.text,
                        weight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.auto_stories_rounded,
                      color: style.gold,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: style.bg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: style.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _startPage,
                      isExpanded: true,
                      dropdownColor: style.card,
                      style: style.naskh(15, color: style.text),
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: style.textDim,
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
            style,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Switch(
                      value: _notificationsEnabled,
                      activeColor: style.isRamadan ? style.gold : style.teal,
                      activeTrackColor:
                          (style.isRamadan ? style.gold : style.teal)
                              .withOpacity(0.3),
                      inactiveTrackColor: style.border,
                      inactiveThumbColor: style.textDim,
                      onChanged: (v) =>
                          setState(() => _notificationsEnabled = v),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          'تفعيل الإشعارات',
                          style: style.amiri(
                            18,
                            color: style.text,
                            weight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.notifications_rounded,
                          color: style.gold,
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
                      color: style.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: style.danger.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            'الإشعارات معطلة - لن يتم إرسال أي تذكرات',
                            textAlign: TextAlign.right,
                            style: style.naskh(12, color: style.danger),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.info_outline_rounded,
                          color: style.danger,
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

  Future<void> _pickDate(AdaptiveStyle style) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: style.isRamadan ? style.gold : style.teal,
            surface: style.card,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  // ──────────────────── STEP 2: Summary ────────────────────
  Widget _buildStep2(AdaptiveStyle style) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _card(
        style,
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
                    color: style.gold.withOpacity(0.2),
                  ),
                  child: Icon(Icons.check_rounded, color: style.gold, size: 16),
                ),
                Text(
                  'ملخص الختمة الميسرة',
                  style: style.amiri(
                    18,
                    color: style.text,
                    weight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Type pill
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: style.isRamadan
                    ? style.gold.withOpacity(0.1)
                    : style.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (style.isRamadan ? style.gold : style.teal)
                      .withOpacity(0.3),
                ),
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
                        style: style.amiri(
                          15,
                          color: style.isRamadan ? style.gold : style.teal,
                          weight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.account_tree_rounded,
                        color: style.isRamadan ? style.gold : style.teal,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'نوع الختمة:',
                        style: style.naskh(
                          12,
                          color: style.isRamadan ? style.gold : style.teal,
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
                    style: style.naskh(
                      11,
                      color: (style.isRamadan ? style.gold : style.teal)
                          .withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _summaryRow('اسم الختمة:', _nameCtrl.text, style),
            _summaryRow(
              'تاريخ البداية:',
              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
              style,
            ),
            _summaryRow('الصفحة الأولى:', 'صفحة ${ar(_startPage)}', style),
            _summaryRow(
              'الإشعارات:',
              _notificationsEnabled ? 'مفعّلة' : 'معطلة',
              style,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (style.isRamadan ? style.gold : style.teal).withOpacity(
                  0.15,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (style.isRamadan ? style.gold : style.teal)
                      .withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'يمكنك البدء في القراءة فوراً بعد إنشاء الختمة',
                      textAlign: TextAlign.right,
                      style: style.naskh(
                        12,
                        color: style.isRamadan ? style.gold : style.teal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.info_outline_rounded,
                    color: style.isRamadan ? style.gold : style.teal,
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

  Widget _summaryRow(String label, String value, AdaptiveStyle style) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(value, style: style.naskh(13, color: style.textSec)),
          Text(label, style: style.naskh(13, color: style.textDim)),
        ],
      ),
    );
  }

  // ──────────────────── Bottom Bar ────────────────────
  Widget _buildBottomBar(AdaptiveStyle style) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: style.bg,
        border: Border(top: BorderSide(color: style.border)),
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
                    border: Border.all(color: style.border),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      'السابق',
                      style: style.amiri(16, color: style.textSec),
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
                  color: style.isRamadan ? style.gold : style.teal,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: (style.isRamadan ? style.gold : style.teal)
                          .withOpacity(0.35),
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
    final isRamadan = ref.read(ramadanModeProvider).value ?? false;
    final style = AdaptiveStyle(context, isRamadan);

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
          backgroundColor: style.isRamadan ? style.gold : style.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Widget _card(AdaptiveStyle style, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: style.card,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: style.border),
    ),
    child: child,
  );
}
