import 'package:flutter/material.dart';

enum QiyamStageStatus { idle, running, paused, completed }

class QiyamStage {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Duration defaultDuration;
  final Color color;

  const QiyamStage({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.defaultDuration,
    required this.color,
  });

  QiyamStage copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? emoji,
    Duration? defaultDuration,
    Color? color,
  }) {
    return QiyamStage(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      emoji: emoji ?? this.emoji,
      defaultDuration: defaultDuration ?? this.defaultDuration,
      color: color ?? this.color,
    );
  }
}

class QiyamSessionState {
  final int currentStageIndex;
  final QiyamStageStatus status;
  final Duration elapsed;
  final List<QiyamStage> stages;

  const QiyamSessionState({
    this.currentStageIndex = 0,
    this.status = QiyamStageStatus.idle,
    this.elapsed = Duration.zero,
    this.stages = const [
      QiyamStage(
        id: 'istighfar',
        title: 'الاستغفار',
        subtitle: 'تطهير القلب والروح',
        emoji: '📿',
        defaultDuration: Duration(minutes: 5),
        color: Color(0xFFB8860B), // Dark Gold
      ),
      QiyamStage(
        id: 'dua',
        title: 'الدعاء',
        subtitle: 'مناجاة الرحمن في السحر',
        emoji: '🤲',
        defaultDuration: Duration(minutes: 10),
        color: Color(0xFFD4AF37), // Metallic Gold
      ),
      QiyamStage(
        id: 'salah',
        title: 'صلاة القيام',
        subtitle: 'طول القنوت والركوع',
        emoji: '🕌',
        defaultDuration: Duration(minutes: 20),
        color: Color(0xFFA67C00), // Deep Gold
      ),
      QiyamStage(
        id: 'witr',
        title: 'الوتر',
        subtitle: 'خاتمة صلاة الليل',
        emoji: '✨',
        defaultDuration: Duration(minutes: 5),
        color: Color(0xFFFFD700), // Vivid Gold
      ),
    ],
  });

  QiyamStage get currentStage => stages[currentStageIndex];

  QiyamSessionState copyWith({
    int? currentStageIndex,
    QiyamStageStatus? status,
    Duration? elapsed,
    List<QiyamStage>? stages,
  }) {
    return QiyamSessionState(
      currentStageIndex: currentStageIndex ?? this.currentStageIndex,
      status: status ?? this.status,
      elapsed: elapsed ?? this.elapsed,
      stages: stages ?? this.stages,
    );
  }
}
