// ═══════════════════════════════════════════════════════════════
//  lib/core/notifications/overlays/adhkar_overlay_window.dart
//  تقوى — Overlay Entry Point (يستدعي UnifiedOverlayWindow)
//  ملاحظة: يجب أن يكون overlayMain هنا فقط (نقطة دخول واحدة)
// ═══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'unified_overlay_window.dart';

// ────────────────────────────────────────────
//  OVERLAY ENTRY POINT  (vm:entry-point إجباري)
// ────────────────────────────────────────────

@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UnifiedOverlayWindow(),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
//  HELPER: إظهار/إخفاء الـ Overlay
// ═══════════════════════════════════════════════════════════════

class AdhkarOverlayNotification {
  /// يُظهر الـ Overlay من يمين الشاشة في المنتصف العمودي.
  static Future<void> show() async {
    final bool isActive = await FlutterOverlayWindow.isActive();
    if (isActive) await FlutterOverlayWindow.closeOverlay();

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: 'أذكار تقوى',
      overlayContent: 'ذكر/دعاء متجدد',
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.center,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.none,
      height: 420,
      width: 320,
    );

    // نرسل البيانات بعد برهة لضمان عمل الـ Listener في الـ Isolate الآخر
    Future.delayed(const Duration(milliseconds: 500), () {
      FlutterOverlayWindow.shareData({'type': 'adhkar'});
    });
  }

  /// يُغلق الـ Overlay.
  static Future<void> dismiss() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}
