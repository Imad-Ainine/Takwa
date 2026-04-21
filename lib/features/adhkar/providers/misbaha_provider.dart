import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:takwa/core/providers/adhkar_providers.dart';

class MisbahaState {
  final int count;
  final bool isListening;
  final bool isAvailable;
  final bool isSpeaking;
  final DhikrItem? selectedDhikr;

  MisbahaState({
    this.count = 0,
    this.isListening = false,
    this.isAvailable = false,
    this.isSpeaking = false,
    this.selectedDhikr,
  });

  MisbahaState copyWith({
    int? count,
    bool? isListening,
    bool? isAvailable,
    bool? isSpeaking,
    DhikrItem? selectedDhikr,
    bool clearSelectedDhikr = false,
  }) {
    return MisbahaState(
      count: count ?? this.count,
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      selectedDhikr: clearSelectedDhikr
          ? null
          : (selectedDhikr ?? this.selectedDhikr),
    );
  }
}

class MisbahaNotifier extends Notifier<MisbahaState> {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  String _lastRecognizedWords = '';
  DateTime _lastIncrementTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  MisbahaState build() {
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _initSpeech();
    _initTts();
    return MisbahaState();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("ar-SA");
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);

    _tts.setCompletionHandler(() {
      state = state.copyWith(isSpeaking: false);
    });

    _tts.setCancelHandler(() {
      state = state.copyWith(isSpeaking: false);
    });
  }

  void selectDhikr(DhikrItem item) {
    // Also stop speaking if currently speaking
    if (state.isSpeaking) _tts.stop();
    state = state.copyWith(selectedDhikr: item, count: 0, isSpeaking: false);
  }

  void clearDhikr() {
    if (state.isSpeaking) _tts.stop();
    state = state.copyWith(
      clearSelectedDhikr: true,
      count: 0,
      isSpeaking: false,
    );
  }

  Future<void> speakDhikr() async {
    if (state.selectedDhikr == null) return;

    if (state.isSpeaking) {
      await _tts.stop();
      state = state.copyWith(isSpeaking: false);
    } else {
      state = state.copyWith(isSpeaking: true);
      await _tts.speak(state.selectedDhikr!.arabic);
    }
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          if (state.isListening && state.isAvailable) {
            _startListening();
          } else {
            state = state.copyWith(isListening: false);
          }
        }
      },
      onError: (val) {
        if (state.isListening && state.isAvailable) {
          _startListening();
        } else {
          state = state.copyWith(isListening: false);
        }
      },
    );
    state = state.copyWith(isAvailable: available);
  }

  void increment() {
    int newCount = state.count + 1;
    
    // Check if target is reached
    if (state.selectedDhikr != null && newCount >= state.selectedDhikr!.count) {
      state = state.copyWith(count: state.selectedDhikr!.count);
      // Heavy vibration on completion
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () => HapticFeedback.heavyImpact());
    } else {
      state = state.copyWith(count: newCount);
      // Light feedback on increment
      HapticFeedback.lightImpact();
    }
  }

  void reset() {
    HapticFeedback.mediumImpact();
    state = state.copyWith(count: 0);
  }

  Future<void> listen(bool start) async {
    if (start) {
      if (!state.isAvailable) {
        await _initSpeech();
        if (!state.isAvailable) return;
      }
      if (!state.isListening) {
        state = state.copyWith(isListening: true);
        _lastRecognizedWords = '';
        await _startListening();
      }
    } else {
      if (state.isListening) {
        state = state.copyWith(isListening: false);
        await _speech.stop();
      }
    }
  }

  Future<void> _startListening() async {
    if (state.isListening) {
      _lastRecognizedWords = '';
      try {
        await _speech.listen(
          onResult: (val) {
            final currentWords = val.recognizedWords.trim();
            if (currentWords.isNotEmpty &&
                currentWords.length > _lastRecognizedWords.length) {
              
              // Count words or increments? 
              // Usually in Misbaha, every word or phrase like "Subhan Allah" counts as 1.
              // We compare the length to see if new words were added.
              final newChars = currentWords.substring(_lastRecognizedWords.length).trim();
              if (newChars.isNotEmpty) {
                _lastRecognizedWords = currentWords;
                final now = DateTime.now();
                if (now.difference(_lastIncrementTime).inMilliseconds > 400) {
                  _lastIncrementTime = now;
                  increment();
                }
              }
            }
          },
          localeId: 'ar',
          cancelOnError: false,
          partialResults: true,
        );
      } catch (e) {
        state = state.copyWith(isListening: false);
      }
    }
  }
}

final misbahaProvider = NotifierProvider<MisbahaNotifier, MisbahaState>(() {
  return MisbahaNotifier();
});
