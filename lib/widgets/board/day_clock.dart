/// Shared 6am–11pm day scale. The paper, both timetable rails, and the
/// glass stickers all map a clock time onto the same vertical band so a
/// 6am to-do sits at the top of the page and an 11pm one at the bottom.
class DayClock {
  DayClock._();

  static const double startHour = 6;
  static const double endHour = 23;

  static double get spanHours => endHour - startHour;

  /// 0 at 6:00, 1 at 23:00. Untimed entries return null.
  static double? fractionFor(DateTime? time) {
    if (time == null) return null;
    final hours = time.hour + time.minute / 60;
    return ((hours - startHour) / spanHours).clamp(0.0, 1.0);
  }

  static double yFor(DateTime time, double height) =>
      (fractionFor(time) ?? 1.0) * height;
}
