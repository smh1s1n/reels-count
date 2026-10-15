import 'dart:async';
import 'package:intl/intl.dart';
import 'local_storage_datasource.dart';

class SimulatedReelDataSource {
  final LocalStorageDataSource _localStorage;
  final StreamController<Map<String, dynamic>> _controller = StreamController<Map<String, dynamic>>.broadcast();

  Timer? _activeSimulationTimer;
  String _currentApp = 'instagram';
  bool _isInsideContainer = false;

  SimulatedReelDataSource(this._localStorage);

  Stream<Map<String, dynamic>> get eventStream => _controller.stream;

  String _getTodayKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void startAutoSimulation({String appName = 'instagram', int scrollIntervalSeconds = 5}) {
    stopAutoSimulation();
    _currentApp = appName;
    _isInsideContainer = true;

    _controller.add({
      'eventType': 'container_entered',
      'appName': _currentApp,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    int secondsTicked = 0;
    _activeSimulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isInsideContainer) return;
      secondsTicked++;

      // Session tick every second
      final dateKey = _getTodayKey();
      final totalSecs = _localStorage.getSimulatedDuration(dateKey) + 1;
      _localStorage.saveSimulatedDuration(dateKey, totalSecs);

      final appSecs = _localStorage.getSimulatedAppDuration(_currentApp, dateKey) + 1;
      _localStorage.saveSimulatedAppDuration(_currentApp, dateKey, appSecs);

      final currentReels = _localStorage.getSimulatedReelCount(dateKey);

      _controller.add({
        'eventType': 'session_tick',
        'appName': _currentApp,
        'reelsCount': currentReels,
        'durationSeconds': totalSecs,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      // Reel scroll event at intervals
      if (secondsTicked % scrollIntervalSeconds == 0) {
        final newReelCount = currentReels + 1;
        _localStorage.saveSimulatedReelCount(dateKey, newReelCount);

        final appReels = _localStorage.getSimulatedAppReels(_currentApp, dateKey) + 1;
        _localStorage.saveSimulatedAppReels(_currentApp, dateKey, appReels);

        _controller.add({
          'eventType': 'reel_detected',
          'appName': _currentApp,
          'reelsCount': newReelCount,
          'durationSeconds': totalSecs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }
    });
  }

  void triggerSingleScroll({required String appName, int dwellSeconds = 4}) {
    final dateKey = _getTodayKey();
    final newReelCount = _localStorage.getSimulatedReelCount(dateKey) + 1;
    final newDuration = _localStorage.getSimulatedDuration(dateKey) + dwellSeconds;

    _localStorage.saveSimulatedReelCount(dateKey, newReelCount);
    _localStorage.saveSimulatedDuration(dateKey, newDuration);

    final appReels = _localStorage.getSimulatedAppReels(appName, dateKey) + 1;
    final appDuration = _localStorage.getSimulatedAppDuration(appName, dateKey) + dwellSeconds;

    _localStorage.saveSimulatedAppReels(appName, dateKey, appReels);
    _localStorage.saveSimulatedAppDuration(appName, dateKey, appDuration);

    _controller.add({
      'eventType': 'reel_detected',
      'appName': appName,
      'reelsCount': newReelCount,
      'durationSeconds': newDuration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  void stopAutoSimulation() {
    _activeSimulationTimer?.cancel();
    _activeSimulationTimer = null;
    if (_isInsideContainer) {
      _isInsideContainer = false;
      _controller.add({
        'eventType': 'container_exited',
        'appName': _currentApp,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }

  bool get isAutoRunning => _activeSimulationTimer != null && _activeSimulationTimer!.isActive;

  void dispose() {
    stopAutoSimulation();
    _controller.close();
  }
}
