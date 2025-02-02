import 'dart:async';

class TimerService {
  Timer? _minuteTimer;
  Timer? _hourTimer;

  // Start a timer that ticks every minute
  void startMinuteTimer({required void Function() onTick}) {
    Duration duration = const Duration(minutes: 1);
    _minuteTimer = Timer.periodic(duration, (timer) {
      onTick();
    });
  }

  // Start a timer that ticks every hour
  void startHourTimer({required void Function() onTick}) {
    Duration duration = const Duration(hours: 1);
    _hourTimer = Timer.periodic(duration, (timer) {
      onTick();
    });
  }

  void stopTimers() {
    _minuteTimer?.cancel();
    _hourTimer?.cancel();
  }
}
