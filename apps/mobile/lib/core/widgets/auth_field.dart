import 'package:flutter/material.dart';
import '../theme/ramadan_theme.dart';

class AuthField extends StatefulWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final AdaptiveStyle style;
  final bool isPassword;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AuthField({
    super.key,
    required this.ctrl,
    required this.hint,
    required this.icon,
    required this.style,
    this.isPassword = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _obscure = true;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.style;
    return Focus(
      onFocusChange: (val) => setState(() => _focused = val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: _focused ? s.card.withOpacity(0.6) : s.bg.withOpacity(0.55),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: _focused ? s.gold : s.border.withOpacity(0.5),
            width: _focused ? 2 : 1.5,
          ),
          boxShadow: _focused
              ? [
                  BoxShadow(
                    color: s.gold.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: TextFormField(
          controller: widget.ctrl,
          obscureText: widget.isPassword ? _obscure : false,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: s.naskh(15, weight: FontWeight.w600),
          cursorColor: s.gold,
          decoration: InputDecoration(
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: widget.hint,
            hintStyle: s.naskh(13, color: s.textDim),
            prefixIcon: Icon(
              widget.icon,
              color: _focused ? s.gold : s.textSec,
              size: 20,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded,
                      color: s.textSec,
                      size: 20,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordStrengthBar extends StatelessWidget {
  final double strength; // 0..1
  final AdaptiveStyle style;
  const PasswordStrengthBar({
    super.key,
    required this.strength,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final label = strength < 0.26
        ? 'ضعيفة'
        : strength < 0.51
        ? 'متوسطة'
        : strength < 0.76
        ? 'جيدة'
        : 'قوية ✓';
    final color = strength < 0.26
        ? Colors.redAccent
        : strength < 0.51
        ? Colors.orange
        : strength < 0.76
        ? Colors.amber
        : Colors.greenAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(height: 4, color: style.border.withOpacity(0.3)),
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 300),
                widthFactor: strength.clamp(0.05, 1.0),
                alignment: AlignmentDirectional.centerStart,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.4), blurRadius: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text('قوة كلمة المرور: $label', style: style.naskh(11, color: color)),
      ],
    );
  }
}
