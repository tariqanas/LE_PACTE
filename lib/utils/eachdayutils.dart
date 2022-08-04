class EachDaysUtils {

static int convertTimeDurationToTimeStamp(String timeDuration) {
    var hhmmsstoseconds = timeDuration.split(":");
    int hourstoInt = int.parse(hhmmsstoseconds[0]);
    int minutestoInt = int.parse(hhmmsstoseconds[1]);
    int secondstoInt = int.parse(hhmmsstoseconds[2]);
    return hourstoInt * 3600 + minutestoInt * 60 + secondstoInt;
  }
}