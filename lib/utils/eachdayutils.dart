import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:eachday/globalvars/globalvars.dart';
import 'package:logger/logger.dart';

class EachDaysUtils {

  static AudioPlayer audioPlayer = AudioPlayer();
  static String endMessage = "You're time is done ! You Lost. ⚡";
  static String almostEndMessage = "Less then 10 minutes left.⏱️";

  static verboseIt(String verboseMessage) {
    var logger = Logger(
      printer: PrettyPrinter(methodCount: 0));
      logger.v(verboseMessage);
  }

  static debugIt(String debugMessage) {
    var logger = Logger(
      printer: PrettyPrinter(methodCount: 0));
      logger.d(debugMessage);
  }

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

  static showEndingToast(bool timerEnded) {
    Fluttertoast.showToast(
        msg: timerEnded ? endMessage : almostEndMessage,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM_LEFT,
        backgroundColor: Colors.red,
        timeInSecForIosWeb: 1,
        textColor: Colors.black,
        fontSize: 20.0);
  }

  static howMuchTimeLeftAccordingToCurrentTime() {
    var format = DateFormat("HH:mm:ss");
    var one = format.parse("23:59:59");
    var two = format.parse(DateTime.now().hour.toString() +
        ":" +
        DateTime.now().minute.toString() +
        ":" +
        DateTime.now().second.toString());
    GlobalVars.timeLeft = one.difference(two).inSeconds.toInt();
  }
}
