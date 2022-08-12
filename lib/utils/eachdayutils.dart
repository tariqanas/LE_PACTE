import 'package:audioplayers/audioplayers.dart';

class EachDaysUtils {
  static int convertTimeDurationToTimeStamp(String timeDuration) {
    var hhmmsstoseconds = timeDuration.split(":");
    int hourstoInt = int.parse(hhmmsstoseconds[0]);
    int minutestoInt = int.parse(hhmmsstoseconds[1]);
    int secondstoInt = int.parse(hhmmsstoseconds[2]);
    return hourstoInt * 3600 + minutestoInt * 60 + secondstoInt;
  }

  static Future<void> playTicTacSound() async {
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    audioPlayer.play(AssetSource("timer_sound.mp3"));
  }
}
