import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';

class GameTimerService {
  final int initialSeconds;
  final VoidCallback? onTimeUp;
  final ValueChanged<int>? onTick;

  Timer? _timer;
  int _secondsLeft;
  bool _isPaused = false;
  bool _hasTriggeredTimeUp = false;
  bool _isDisposed = false;

  GameTimerService({
    this.initialSeconds = AppConstants.roundDurationSeconds,
    this.onTimeUp,
    this.onTick,
  }) : _secondsLeft = initialSeconds;

  int get secondsLeft => _secondsLeft;
  double get progress => initialSeconds > 0 ? (_secondsLeft / initialSeconds).clamp(0.0, 1.0) : 0.0;
  bool get isRunning => _timer != null && _timer!.isActive && !_isPaused;
  bool get isPaused => _isPaused;
  bool get isFinished => _secondsLeft <= 0;

  void start() {
    if (_isDisposed) return;
    _cancelTimer();
    _secondsLeft = initialSeconds;
    _hasTriggeredTimeUp = false;
    _isPaused = false;
    _resumeTimer();
  }

  void _resumeTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      if (_isPaused) return;

      if (_secondsLeft > 1) {
        _secondsLeft--;
        onTick?.call(_secondsLeft);
      } else {
        _secondsLeft = 0;
        onTick?.call(0);
        timer.cancel();
        _fireTimeUpOnce();
      }
    });
  }

  void pause() => _isPaused = true;

  void resume() {
    if (_isDisposed || isFinished) return;
    _isPaused = false;
  }

  void applyPenalty([int penaltySeconds = AppConstants.wrongPenaltySeconds]) {
    if (_isDisposed || isFinished) return;
    _secondsLeft = (_secondsLeft - penaltySeconds).clamp(0, initialSeconds);
    onTick?.call(_secondsLeft);

    if (_secondsLeft <= 0) {
      _cancelTimer();
      _fireTimeUpOnce();
    }
  }

  void _fireTimeUpOnce() {
    if (!_hasTriggeredTimeUp && !_isDisposed) {
      _hasTriggeredTimeUp = true;
      onTimeUp?.call();
    }
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void stop() => _cancelTimer();

  void dispose() {
    _isDisposed = true;
    _cancelTimer();
  }
}
