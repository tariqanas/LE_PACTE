import 'package:audioplayers/audioplayers.dart';

class EachDaysUtils {
  static AudioPlayer audioPlayer = AudioPlayer();

  void initAudioPlayer() {
    audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  static int convertTimeDurationToTimeStamp(String timeDuration) {
    var hhmmsstoseconds = timeDuration.split(":");
    int hourstoInt = int.parse(hhmmsstoseconds[0]);
    int minutestoInt = int.parse(hhmmsstoseconds[1]);
    int secondstoInt = int.parse(hhmmsstoseconds[2]);
    return hourstoInt * 3600 + minutestoInt * 60 + secondstoInt;
  }

  static Future<void> playTicTacSound() async {
    audioPlayer.play(AssetSource("timer_sound.mp3"));
  }

  static Future<void> stopTicTacSound() async {
    audioPlayer.stop();
    audioPlayer.dispose();
  }
}
