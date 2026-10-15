import '../entities/doomscroll_limit.dart';

abstract class ILimitsRepository {
  Future<DoomscrollLimit> getLimits();
  Future<void> saveLimits(DoomscrollLimit limits);
}
