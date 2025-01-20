import 'dart:async';

class TimerService {
  Timer? _timer;

  void startTimer(
      {Duration duration = const Duration(minutes: 1),
      required void Function() onTick}) {
    _timer = Timer.periodic(duration, (timer) {
      onTick();
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }
}
