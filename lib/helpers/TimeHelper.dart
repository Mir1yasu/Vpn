class TimeHelper {
  static String getStringDuration(double seconds) {
    if (seconds == null) return '00:00:00';
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    int secondsInt = int.parse(seconds.toInt().toString());

    Duration duration = new Duration(seconds: secondsInt);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
